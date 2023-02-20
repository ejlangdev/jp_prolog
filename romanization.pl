/* All rights still remain the owner under exclusive copywrite, this excerpt 
has been uploaded as reference and will at a future date be placed under a
more permissive licence along with additional features.*/



/* General usage romanization (romaji) converter, this accepts both
katakana and hiragana and converts it into a variant of romaji.

Romanji types --
hb - Hepburn: uses macrons long vowels 
     and a more english friendly phonetic system
ns - Nihon-shiki: uses circumflex long vowels
     and a more japanese friendly phonetic system

Other types and options for types are being considered for addition
such as: 

    older and antiquated types and variants of romanization.

    Wapuro romaji (used for input into devices rather than romanization).

    n' or m commonly used for distinguishing the unique phonetic
    sound of the n when used as a consonant rather than as part of the
    standard kana.

    lossless romanization for converting back and forth without losing
    information.

    Space handling (currently just converts explicit spaces into ' ').

    Comprehensive punctuation handler

    Hyphen usage

    Reversal (Note: currently returns mixed hiragana and katakana, needs
            some given options to be implemented so that it works reasonably)

Currently the romanizer fails if it reaches a symbol that it had not
an adequate conversion for. This means that large quantities of japanese
text should not be used until a more extensive list of values can be
processed as well a pre-processing step which will erase/filter/convert
other symbols (such as numbers or punctuation) so that data is not lost.
*/

%This is the primary interface for romanization.
%Takes a string of kana in the Word argument, returns Sections and Romanji
% (RT?, Word+, Sections-, Romaji-)
kana_to_romaji(Word, RT, Sections, Romaji) :-
    atom_chars(Word, ALs),
    romaji_type(RT),
    phrase(romaji(RT, ALs), Sections),
    atomic_list_concat(Sections, Romaji).
%Quick use: Default type is hepburn
kana_to_romaji(Word, Romaji) :-
    atom_chars(Word, ALs),
    romaji_type(hb),
    phrase(romaji(hb, ALs), Sections),
    atomic_list_concat(Sections, Romaji).


%RT - Romanji type - currently either hepburn(hb) or nihon-shiki(ns)
romaji_type(hb).
romaji_type(ns).

%Nihon-shiki circumflex
ns_long_vowel(a, â).
ns_long_vowel(e, ê).
ns_long_vowel(i, î).
ns_long_vowel(o, ô).
ns_long_vowel(u, û).

%Hepburn macron
hb_long_vowel(a, ā).
hb_long_vowel(e, ē).
hb_long_vowel(i, ī).
hb_long_vowel(o, ō).
hb_long_vowel(u, ū).

%Situations in which the long vowel is formed
long_vowel_match(a, a).
long_vowel_match(e, e).
long_vowel_match(e, i).
long_vowel_match(i, i).
long_vowel_match(o, o).
long_vowel_match(o, u).
long_vowel_match(u, u).


double_consonant(RT, Kanas, Consonant) :-
    phrase(romaji(RT, Kanas), [Rmj]),
    atom_chars(Rmj, [Consonant|_]).
%Handles katakana line notation
line_double_v(RT, Kanas, R) :-
    share_same_vowel(RT, Kanas, RmjChars, Vowel),
    apply_long_vowel(RT, RmjChars, Vowel, R).
%Handles hiragana double vowels
double_v(RT, Kanas, KanaV, R) :-
    share_same_vowel(RT, Kanas, RmjChars, Vowel),
    phrase(romaji(RT, KanaV), [Vowel2]), %edited
    long_vowel_match(Vowel, Vowel2),
    apply_long_vowel(RT, RmjChars, Vowel, R).
share_same_vowel(RT, Kanas, RmjChars, Vowel) :-
    phrase(romaji(RT, Kanas), [Rmj1]),
    atom_chars(Rmj1, RmjChars),
    last(RmjChars, Vowel).

%Long vowel varies between types of romanization
%Later versions will be more complex, hence abstraction here.
apply_long_vowel(ns, RmjChars, Vowel, R) :-
    ns_long_vowel(Vowel, LV),
    replace_last(RmjChars, LV, RmjLv),
    atom_chars(R, RmjLv).
apply_long_vowel(hb, RmjChars, Vowel, R) :-
    hb_long_vowel(Vowel, LV),
    replace_last(RmjChars, LV, RmjLv),
    atom_chars(R, RmjLv).


%Takes the romaji and replaces the vowel (for macrons etc..)
replace_last([_], V, [V]) :- !.
replace_last([H|T], V, [H|T2]) :-
    replace_last(T, V, T2). 



%Romanization converter DCG, iterates through the kana and puts out a sequence of
%applicable romanization.

%End of sequence
romaji(_,[]) --> [].
%Long vowels
romaji(RT,[Kana,ー|Ls]) --> {line_double_v(RT, [Kana], RmjLv)}, [RmjLv], romaji(RT,Ls).
romaji(RT,[Kana,Kana2,ー|Ls]) --> {line_double_v(RT, [Kana, Kana2], RmjLv)}, [RmjLv], romaji(RT,Ls).
romaji(RT,[Kana,KanaV|Ls]) --> {double_v(RT, [Kana], [KanaV], RmjLv)}, [RmjLv], romaji(RT,Ls).
romaji(RT,[Kana,Kana2,KanaV|Ls]) --> {double_v(RT, [Kana,Kana2], [KanaV], RmjLv)}, [RmjLv], romaji(RT,Ls).
%Double consonants
romaji(RT,[っ,Kana|Ls]) --> {double_consonant(RT, [Kana], Consonant)}, [Consonant], romaji(RT,[Kana|Ls]).
romaji(RT,[ッ,Kana|Ls]) --> {double_consonant(RT, [Kana], Consonant)}, [Consonant], romaji(RT,[Kana|Ls]).


%Spaces and punctuation
romaji(RT,[' '|Ls]) --> [' '], romaji(RT,Ls).
romaji(RT,['・'|Ls]) --> [' '], romaji(RT,Ls).
romaji(RT,['。'|Ls]) --> ['.'], romaji(RT,Ls).
romaji(RT,['、'|Ls]) --> [','], romaji(RT,Ls).

%Standard conversions ----
romaji(RT,[き,ゃ|Ls]) --> [kya], romaji(RT,Ls). 
romaji(ns,[し,ゃ|Ls]) --> [sya], romaji(ns,Ls). 
romaji(hb,[し,ゃ|Ls]) --> [sha], romaji(hb,Ls). 
romaji(ns,[ち,ゃ|Ls]) --> [tya], romaji(ns,Ls).
romaji(hb,[ち,ゃ|Ls]) --> [cha], romaji(hb,Ls). 
romaji(RT,[に,ゃ|Ls]) --> [nya], romaji(RT,Ls). 
romaji(RT,[ひ,ゃ|Ls]) --> [hya], romaji(RT,Ls). 
romaji(RT,[み,ゃ|Ls]) --> [mya], romaji(RT,Ls). 
romaji(RT,[り,ゃ|Ls]) --> [rya], romaji(RT,Ls). 
romaji(RT,[ぎ,ゃ|Ls]) --> [gya], romaji(RT,Ls). 
romaji(ns,[じ,ゃ|Ls]) --> [zya], romaji(ns,Ls).
romaji(hb,[じ,ゃ|Ls]) --> [ja], romaji(hb,Ls). 
romaji(ns,[ぢ,ゃ|Ls]) --> [dya], romaji(ns,Ls). 
romaji(hb,[ぢ,ゃ|Ls]) --> [ja], romaji(hb,Ls). 
romaji(RT,[び,ゃ|Ls]) --> [bya], romaji(RT,Ls). 
romaji(RT,[ぴ,ゃ|Ls]) --> [pya], romaji(RT,Ls). 
               
romaji(RT,[き,ゅ|Ls]) --> [kyu], romaji(RT,Ls).
romaji(ns,[し,ゅ|Ls]) --> [syu], romaji(ns,Ls).
romaji(hb,[し,ゅ|Ls]) --> [shu], romaji(hb,Ls).
romaji(ns,[ち,ゅ|Ls]) --> [tyu], romaji(ns,Ls).
romaji(hb,[ち,ゅ|Ls]) --> [chu], romaji(hb,Ls).
romaji(RT,[に,ゅ|Ls]) --> [nyu], romaji(RT,Ls).
romaji(RT,[ひ,ゅ|Ls]) --> [hyu], romaji(RT,Ls).
romaji(RT,[み,ゅ|Ls]) --> [myu], romaji(RT,Ls).
romaji(RT,[り,ゅ|Ls]) --> [ryu], romaji(RT,Ls).
romaji(RT,[ぎ,ゅ|Ls]) --> [gyu], romaji(RT,Ls).
romaji(ns,[じ,ゅ|Ls]) --> [zyu], romaji(ns,Ls).
romaji(hb,[じ,ゅ|Ls]) --> [ju], romaji(hb,Ls).
romaji(ns,[ぢ,ゅ|Ls]) --> [dyu], romaji(ns,Ls).
romaji(hb,[ぢ,ゅ|Ls]) --> [ju], romaji(hb,Ls).
romaji(RT,[び,ゅ|Ls]) --> [byu], romaji(RT,Ls).
romaji(RT,[ぴ,ゅ|Ls]) --> [pyu], romaji(RT,Ls).
               
romaji(RT,[き,ょ|Ls]) --> [kyo], romaji(RT,Ls). 
romaji(ns,[し,ょ|Ls]) --> [syo], romaji(ns,Ls).
romaji(hb,[し,ょ|Ls]) --> [sho], romaji(hb,Ls). 
romaji(ns,[ち,ょ|Ls]) --> [tyo], romaji(ns,Ls).
romaji(hb,[ち,ょ|Ls]) --> [cho], romaji(hb,Ls). 
romaji(RT,[に,ょ|Ls]) --> [nyo], romaji(RT,Ls). 
romaji(RT,[ひ,ょ|Ls]) --> [hyo], romaji(RT,Ls). 
romaji(RT,[み,ょ|Ls]) --> [myo], romaji(RT,Ls). 
romaji(RT,[り,ょ|Ls]) --> [ryo], romaji(RT,Ls). 
romaji(RT,[ぎ,ょ|Ls]) --> [gyo], romaji(RT,Ls). 
romaji(ns,[じ,ょ|Ls]) --> [zyo], romaji(ns,Ls).
romaji(hb,[じ,ょ|Ls]) --> [jo], romaji(hb,Ls). 
romaji(ns,[ぢ,ょ|Ls]) --> [dyo], romaji(ns,Ls). 
romaji(hb,[ぢ,ょ|Ls]) --> [jo], romaji(hb,Ls). 
romaji(RT,[び,ょ|Ls]) --> [byo], romaji(RT,Ls). 
romaji(RT,[ぴ,ょ|Ls]) --> [pyo], romaji(RT,Ls). 
% Oddities (Less common in hiragana than katakana, add when discovered)
romaji(RT,[じ,ぇ|Ls]) --> [je], romaji(RT,Ls).


romaji(RT,[あ|Ls]) --> [a], romaji(RT,Ls).
romaji(RT,[か|Ls]) --> [ka], romaji(RT,Ls).             
romaji(RT,[さ|Ls]) --> [sa], romaji(RT,Ls).             
romaji(RT,[た|Ls]) --> [ta], romaji(RT,Ls).             
romaji(RT,[な|Ls]) --> [na], romaji(RT,Ls).             
romaji(RT,[は|Ls]) --> [ha], romaji(RT,Ls).             
romaji(RT,[ま|Ls]) --> [ma], romaji(RT,Ls).             
romaji(RT,[や|Ls]) --> [ya], romaji(RT,Ls).             
romaji(RT,[ら|Ls]) --> [ra], romaji(RT,Ls).             
romaji(RT,[わ|Ls]) --> [wa], romaji(RT,Ls).             
             
romaji(RT,[が|Ls]) --> [ga], romaji(RT,Ls).             
romaji(RT,[ざ|Ls]) --> [za], romaji(RT,Ls).             
romaji(RT,[だ|Ls]) --> [da], romaji(RT,Ls).             
romaji(RT,[ば|Ls]) --> [ba], romaji(RT,Ls).             
romaji(RT,[ぱ|Ls]) --> [pa], romaji(RT,Ls).

romaji(RT,[い|Ls]) --> [i], romaji(RT,Ls).             
romaji(RT,[き|Ls]) --> [ki], romaji(RT,Ls). 
romaji(ns,[し|Ls]) --> [si], romaji(ns,Ls).
romaji(hb,[し|Ls]) --> [shi], romaji(hb,Ls).             
romaji(ns,[ち|Ls]) --> [ti], romaji(ns,Ls).
romaji(hb,[ち|Ls]) --> [chi], romaji(hb,Ls).             
romaji(RT,[に|Ls]) --> [ni], romaji(RT,Ls).             
romaji(RT,[ひ|Ls]) --> [hi], romaji(RT,Ls).             
romaji(RT,[み|Ls]) --> [mi], romaji(RT,Ls).             
romaji(RT,[り|Ls]) --> [ri], romaji(RT,Ls).             
             
romaji(RT,[ぎ|Ls]) --> [gi], romaji(RT,Ls).             
romaji(ns,[じ|Ls]) --> [zi], romaji(ns,Ls).
romaji(hb,[じ|Ls]) --> [ji], romaji(hb,Ls).             
romaji(ns,[ぢ|Ls]) --> [di], romaji(ns,Ls).     
romaji(hb,[ぢ|Ls]) --> [ji], romaji(hb,Ls).             
romaji(RT,[び|Ls]) --> [bi], romaji(RT,Ls).             
romaji(RT,[ぴ|Ls]) --> [pi], romaji(RT,Ls).             

romaji(RT,[う|Ls]) --> [u], romaji(RT,Ls).
romaji(RT,[く|Ls]) --> [ku], romaji(RT,Ls). 
romaji(RT,[す|Ls]) --> [su], romaji(RT,Ls). 
romaji(ns,[つ|Ls]) --> [tu], romaji(ns,Ls).
romaji(hb,[つ|Ls]) --> [tsu], romaji(hb,Ls). 
romaji(RT,[ぬ|Ls]) --> [nu], romaji(RT,Ls). 
romaji(ns,[ふ|Ls]) --> [hu], romaji(ns,Ls).
romaji(hb,[ふ|Ls]) --> [fu], romaji(hb,Ls). 
romaji(RT,[む|Ls]) --> [mu], romaji(RT,Ls). 
romaji(RT,[ゆ|Ls]) --> [yu], romaji(RT,Ls). 
romaji(RT,[る|Ls]) --> [ru], romaji(RT,Ls).

romaji(RT,[ぐ|Ls]) --> [gu], romaji(RT,Ls). 
romaji(RT,[ず|Ls]) --> [zu], romaji(RT,Ls). 
romaji(ns,[づ|Ls]) --> [du], romaji(ns,Ls).
romaji(hb,[づ|Ls]) --> [zu], romaji(hb,Ls). 
romaji(RT,[ぶ|Ls]) --> [bu], romaji(RT,Ls). 
romaji(RT,[ぷ|Ls]) --> [pu], romaji(RT,Ls). 

romaji(RT,[え|Ls]) --> [e], romaji(RT,Ls).             
romaji(RT,[け|Ls]) --> [ke], romaji(RT,Ls).  
romaji(RT,[せ|Ls]) --> [se], romaji(RT,Ls).  
romaji(RT,[て|Ls]) --> [te], romaji(RT,Ls).    
romaji(RT,[ね|Ls]) --> [ne], romaji(RT,Ls).  
romaji(RT,[へ|Ls]) --> [he], romaji(RT,Ls).  
romaji(RT,[め|Ls]) --> [me], romaji(RT,Ls).  
romaji(RT,[れ|Ls]) --> [re], romaji(RT,Ls).  

romaji(RT,[げ|Ls]) --> [ge], romaji(RT,Ls).  
romaji(RT,[ぜ|Ls]) --> [ze], romaji(RT,Ls).  
romaji(RT,[で|Ls]) --> [de], romaji(RT,Ls).  
romaji(RT,[べ|Ls]) --> [be], romaji(RT,Ls).  
romaji(RT,[ぺ|Ls]) --> [pe], romaji(RT,Ls).  

romaji(RT,[お|Ls]) --> [o], romaji(RT,Ls). 
romaji(RT,[こ|Ls]) --> [ko], romaji(RT,Ls). 
romaji(RT,[そ|Ls]) --> [so], romaji(RT,Ls). 
romaji(RT,[と|Ls]) --> [to], romaji(RT,Ls). 
romaji(RT,[の|Ls]) --> [no], romaji(RT,Ls). 
romaji(RT,[ほ|Ls]) --> [ho], romaji(RT,Ls). 
romaji(RT,[も|Ls]) --> [mo], romaji(RT,Ls). 
romaji(RT,[よ|Ls]) --> [yo], romaji(RT,Ls). 
romaji(RT,[ろ|Ls]) --> [ro], romaji(RT,Ls).
romaji(RT,[を|Ls]) --> [wo], romaji(RT,Ls).
romaji(RT,[ん|Ls]) --> [n], romaji(RT,Ls).

romaji(RT,[ご|Ls]) --> [go], romaji(RT,Ls). 
romaji(RT,[ぞ|Ls]) --> [zo], romaji(RT,Ls). 
romaji(RT,[ど|Ls]) --> [do], romaji(RT,Ls). 
romaji(RT,[ぼ|Ls]) --> [bo], romaji(RT,Ls). 
romaji(RT,[ぽ|Ls]) --> [po], romaji(RT,Ls).

%Katakana
%Three letters
romaji(RT,[フ,ィ,ェ|Ls]) --> [fye], romaji(RT,Ls).
romaji(RT,[ヴ,ィ,ェ|Ls]) --> [vye], romaji(RT,Ls).

%Common two letters 
romaji(RT,[キ,ャ|Ls]) --> [kya], romaji(RT,Ls).
romaji(ns,[シ,ャ|Ls]) --> [sya], romaji(ns,Ls).
romaji(hb,[シ,ャ|Ls]) --> [sha], romaji(hb,Ls).
romaji(ns,[チ,ャ|Ls]) --> [tya], romaji(ns,Ls).
romaji(hb,[チ,ャ|Ls]) --> [cha], romaji(hb,Ls).
romaji(RT,[ニ,ャ|Ls]) --> [nya], romaji(RT,Ls).
romaji(RT,[ヒ,ャ|Ls]) --> [hya], romaji(RT,Ls).
romaji(RT,[ミ,ャ|Ls]) --> [mya], romaji(RT,Ls).
romaji(RT,[リ,ャ|Ls]) --> [rya], romaji(RT,Ls).
romaji(RT,[ギ,ャ|Ls]) --> [gya], romaji(RT,Ls).
romaji(ns,[ジ,ャ|Ls]) --> [zya], romaji(ns,Ls).
romaji(hb,[ジ,ャ|Ls]) --> [ja], romaji(hb,Ls).
romaji(ns,[ヂ,ャ|Ls]) --> [dya], romaji(ns,Ls).
romaji(hb,[ヂ,ャ|Ls]) --> [ja], romaji(hb,Ls).
romaji(RT,[ビ,ャ|Ls]) --> [bya], romaji(RT,Ls).
romaji(RT,[ピ,ャ|Ls]) --> [pya], romaji(RT,Ls).

romaji(RT,[キ,ュ|Ls]) --> [kyu], romaji(RT,Ls).
romaji(ns,[シ,ュ|Ls]) --> [syu], romaji(ns,Ls).
romaji(hb,[シ,ュ|Ls]) --> [shu], romaji(hb,Ls).
romaji(ns,[チ,ュ|Ls]) --> [tyu], romaji(ns,Ls).
romaji(hb,[チ,ュ|Ls]) --> [chu], romaji(hb,Ls).
romaji(RT,[ニ,ュ|Ls]) --> [nyu], romaji(RT,Ls).
romaji(RT,[ヒ,ュ|Ls]) --> [hyu], romaji(RT,Ls).
romaji(RT,[ミ,ュ|Ls]) --> [myu], romaji(RT,Ls).
romaji(RT,[リ,ュ|Ls]) --> [ryu], romaji(RT,Ls).
romaji(RT,[ギ,ュ|Ls]) --> [gyu], romaji(RT,Ls).
romaji(ns,[ジ,ュ|Ls]) --> [zyu], romaji(ns,Ls).
romaji(hb,[ジ,ュ|Ls]) --> [ju], romaji(hb,Ls).
romaji(ns,[ヂ,ュ|Ls]) --> [dyu], romaji(ns,Ls).
romaji(hb,[ヂ,ュ|Ls]) --> [ju], romaji(hb,Ls).
romaji(RT,[ビ,ュ|Ls]) --> [byu], romaji(RT,Ls).
romaji(RT,[ピ,ュ|Ls]) --> [pyu], romaji(RT,Ls).

romaji(RT,[キ,ョ|Ls]) --> [kyo], romaji(RT,Ls).
romaji(ns,[シ,ョ|Ls]) --> [syo], romaji(ns,Ls).
romaji(hb,[シ,ョ|Ls]) --> [sho], romaji(hb,Ls).
romaji(ns,[チ,ョ|Ls]) --> [tyo], romaji(ns,Ls).
romaji(hb,[チ,ョ|Ls]) --> [cho], romaji(hb,Ls).
romaji(RT,[ニ,ョ|Ls]) --> [nyo], romaji(RT,Ls).
romaji(RT,[ヒ,ョ|Ls]) --> [hyo], romaji(RT,Ls).
romaji(RT,[ミ,ョ|Ls]) --> [myo], romaji(RT,Ls).
romaji(RT,[リ,ョ|Ls]) --> [ryo], romaji(RT,Ls).
romaji(RT,[ギ,ョ|Ls]) --> [gyo], romaji(RT,Ls).
romaji(ns,[ジ,ョ|Ls]) --> [zyo], romaji(ns,Ls).
romaji(hb,[ジ,ョ|Ls]) --> [jo], romaji(hb,Ls).
romaji(ns,[ヂ,ョ|Ls]) --> [dyo], romaji(ns,Ls).
romaji(hb,[ヂ,ョ|Ls]) --> [jo], romaji(hb,Ls).
romaji(RT,[ビ,ョ|Ls]) --> [byo], romaji(RT,Ls).
romaji(RT,[ピ,ョ|Ls]) --> [pyo], romaji(RT,Ls).
    
%Uncommon two letters (often for sounds in english not common in jp)
romaji(RT,[シ,ェ|Ls]) --> [she], romaji(RT,Ls).
romaji(RT,[ジ,ェ|Ls]) --> [je], romaji(RT,Ls).
romaji(RT,[チ,ェ|Ls]) --> [che], romaji(RT,Ls).
romaji(RT,[ツ,ァ|Ls]) --> [tsa], romaji(RT,Ls).
romaji(RT,[ツ,ェ|Ls]) --> [tse], romaji(RT,Ls).
romaji(RT,[ツ,ォ|Ls]) --> [tso], romaji(RT,Ls).
romaji(RT,[テ,ィ|Ls]) --> [ti], romaji(RT,Ls).
romaji(RT,[デ,ィ|Ls]) --> [di], romaji(RT,Ls).
romaji(RT,[デ,ュ|Ls]) --> [dyu], romaji(RT,Ls).
romaji(RT,[フ,ァ|Ls]) --> [fa], romaji(RT,Ls).
romaji(RT,[フ,ィ|Ls]) --> [fi], romaji(RT,Ls).
romaji(RT,[フ,ェ|Ls]) --> [fe], romaji(RT,Ls).
romaji(RT,[フ,ォ|Ls]) --> [fo], romaji(RT,Ls).

romaji(RT,[ウ,ァ|Ls]) --> [wa], romaji(RT,Ls).
romaji(RT,[ウ,ュ|Ls]) --> [wyu], romaji(RT,Ls).
romaji(RT,[ヴ,ャ|Ls]) --> [vya], romaji(RT,Ls).
romaji(RT,[ヴ,ョ|Ls]) --> [vyo], romaji(RT,Ls).
romaji(RT,[キ,ェ|Ls]) --> [kye], romaji(RT,Ls).
romaji(RT,[ギ,ェ|Ls]) --> [gye], romaji(RT,Ls).
romaji(RT,[ク,ヮ|Ls]) --> [kwa], romaji(RT,Ls).
romaji(RT,[グ,ィ|Ls]) --> [gwi], romaji(RT,Ls).
romaji(RT,[グ,ェ|Ls]) --> [gwe], romaji(RT,Ls).
romaji(RT,[グ,ォ|Ls]) --> [gwo], romaji(RT,Ls).
romaji(RT,[ツ,ュ|Ls]) --> [tsyu], romaji(RT,Ls).
romaji(RT,[ニ,ェ|Ls]) --> [nye], romaji(RT,Ls).
romaji(RT,[ヒ,ェ|Ls]) --> [hye], romaji(RT,Ls).
romaji(RT,[ビ,ェ|Ls]) --> [bye], romaji(RT,Ls).
romaji(RT,[ピ,ェ|Ls]) --> [pye], romaji(RT,Ls).
romaji(RT,[フ,ャ|Ls]) --> [fya], romaji(RT,Ls).
romaji(RT,[フ,ョ|Ls]) --> [fyo], romaji(RT,Ls).
romaji(RT,[ミ,ェ|Ls]) --> [mye], romaji(RT,Ls).
romaji(RT,[リ,ェ|Ls]) --> [rye], romaji(RT,Ls).

romaji(RT,[イ,ェ|Ls]) --> [ye], romaji(RT,Ls).
romaji(RT,[ウ,ィ|Ls]) --> [wi], romaji(RT,Ls).
romaji(RT,[ウ,ェ|Ls]) --> [we], romaji(RT,Ls).
romaji(RT,[ウ,ォ|Ls]) --> [wo], romaji(RT,Ls).
romaji(RT,[ヴ,ァ|Ls]) --> [va], romaji(RT,Ls).
romaji(RT,[ヴ,ィ|Ls]) --> [vi], romaji(RT,Ls).
romaji(RT,[ヴ,ェ|Ls]) --> [ve], romaji(RT,Ls).
romaji(RT,[ヴ,ォ|Ls]) --> [vo], romaji(RT,Ls).
romaji(RT,[ヴ,ュ|Ls]) --> [vyu], romaji(RT,Ls).
romaji(RT,[ク,ァ|Ls]) --> [kwa], romaji(RT,Ls).
romaji(RT,[ク,ィ|Ls]) --> [kwi], romaji(RT,Ls).
romaji(RT,[ク,ェ|Ls]) --> [kwe], romaji(RT,Ls).
romaji(RT,[ク,ォ|Ls]) --> [kwo], romaji(RT,Ls).
romaji(RT,[グ,ァ|Ls]) --> [gwa], romaji(RT,Ls).
romaji(RT,[ツ,ィ|Ls]) --> [tsi], romaji(RT,Ls).
romaji(RT,[ト,ゥ|Ls]) --> [tu], romaji(RT,Ls).
romaji(ns,[テ,ュ|Ls]) --> [tyu], romaji(ns,Ls).
romaji(hb,[テ,ュ|Ls]) --> [chu], romaji(hb,Ls).
romaji(RT,[ド,ゥ|Ls]) --> [du], romaji(RT,Ls).
romaji(RT,[フ,ュ|Ls]) --> [fyu], romaji(RT,Ls).

romaji(RT,[ア|Ls]) --> [a], romaji(RT,Ls).
romaji(RT,[カ|Ls]) --> [ka], romaji(RT,Ls).
romaji(RT,[サ|Ls]) --> [sa], romaji(RT,Ls).
romaji(RT,[タ|Ls]) --> [ta], romaji(RT,Ls).
romaji(RT,[ナ|Ls]) --> [na], romaji(RT,Ls).
romaji(RT,[ハ|Ls]) --> [ha], romaji(RT,Ls).
romaji(RT,[マ|Ls]) --> [ma], romaji(RT,Ls).
romaji(RT,[ヤ|Ls]) --> [ya], romaji(RT,Ls).
romaji(RT,[ラ|Ls]) --> [ra], romaji(RT,Ls).
romaji(RT,[ワ|Ls]) --> [wa], romaji(RT,Ls).

romaji(RT,[ガ|Ls]) --> [ga], romaji(RT,Ls).
romaji(RT,[ザ|Ls]) --> [za], romaji(RT,Ls).
romaji(RT,[ダ|Ls]) --> [da], romaji(RT,Ls).
romaji(RT,[バ|Ls]) --> [ba], romaji(RT,Ls).
romaji(RT,[パ|Ls]) --> [pa], romaji(RT,Ls).

romaji(RT,[イ|Ls]) --> [i], romaji(RT,Ls).
romaji(RT,[キ|Ls]) --> [ki], romaji(RT,Ls). 
romaji(ns,[シ|Ls]) --> [si], romaji(ns,Ls).
romaji(hb,[シ|Ls]) --> [shi], romaji(hb,Ls).
romaji(ns,[チ|Ls]) --> [ti], romaji(ns,Ls).
romaji(hb,[チ|Ls]) --> [chi], romaji(hb,Ls).
romaji(RT,[ニ|Ls]) --> [ni], romaji(RT,Ls). 
romaji(RT,[ヒ|Ls]) --> [hi], romaji(RT,Ls). 
romaji(RT,[ミ|Ls]) --> [mi], romaji(RT,Ls).
romaji(RT,[リ|Ls]) --> [ri], romaji(RT,Ls). 
romaji(RT,[ギ|Ls]) --> [gi], romaji(RT,Ls). 
romaji(ns,[ジ|Ls]) --> [zi], romaji(ns,Ls).
romaji(hb,[ジ|Ls]) --> [ji], romaji(hb,Ls). 
romaji(ns,[ヂ|Ls]) --> [di], romaji(ns,Ls).
romaji(hb,[ヂ|Ls]) --> [ji], romaji(hb,Ls). 
romaji(RT,[ビ|Ls]) --> [bi], romaji(RT,Ls). 
romaji(RT,[ピ|Ls]) --> [pi], romaji(RT,Ls). 

romaji(RT,[ウ|Ls]) --> [u], romaji(RT,Ls).
romaji(RT,[ク|Ls]) --> [ku], romaji(RT,Ls).
romaji(RT,[ス|Ls]) --> [su], romaji(RT,Ls).
romaji(ns,[ツ|Ls]) --> [tu], romaji(ns,Ls).
romaji(hb,[ツ|Ls]) --> [tsu], romaji(hb,Ls). 
romaji(RT,[ヌ|Ls]) --> [nu], romaji(RT,Ls).
romaji(ns,[フ|Ls]) --> [hu], romaji(ns,Ls).
romaji(hb,[フ|Ls]) --> [fu], romaji(hb,Ls).
romaji(RT,[ム|Ls]) --> [mu], romaji(RT,Ls).
romaji(RT,[ユ|Ls]) --> [yu], romaji(RT,Ls).
romaji(RT,[ル|Ls]) --> [ru], romaji(RT,Ls).

romaji(RT,[グ|Ls]) --> [gu], romaji(RT,Ls).
romaji(RT,[ズ|Ls]) --> [zu], romaji(RT,Ls).
romaji(ns,[ヅ|Ls]) --> [du], romaji(ns,Ls).
romaji(hb,[ヅ|Ls]) --> [zu], romaji(hb,Ls).
romaji(RT,[ブ|Ls]) --> [bu], romaji(RT,Ls).
romaji(RT,[プ|Ls]) --> [pu], romaji(RT,Ls).

romaji(RT,[エ|Ls]) --> [e], romaji(RT,Ls).
romaji(RT,[ケ|Ls]) --> [ke], romaji(RT,Ls).
romaji(RT,[セ|Ls]) --> [se], romaji(RT,Ls).
romaji(RT,[テ|Ls]) --> [te], romaji(RT,Ls).  
romaji(RT,[ネ|Ls]) --> [ne], romaji(RT,Ls).
romaji(RT,[ヘ|Ls]) --> [he], romaji(RT,Ls).
romaji(RT,[メ|Ls]) --> [me], romaji(RT,Ls).  
romaji(RT,[レ|Ls]) --> [re], romaji(RT,Ls).

romaji(RT,[ゲ|Ls]) --> [ge], romaji(RT,Ls).
romaji(RT,[ゼ|Ls]) --> [ze], romaji(RT,Ls).
romaji(RT,[デ|Ls]) --> [de], romaji(RT,Ls).
romaji(RT,[ベ|Ls]) --> [be], romaji(RT,Ls).
romaji(RT,[ペ|Ls]) --> [pe], romaji(RT,Ls).

romaji(RT,[オ|Ls]) --> [o], romaji(RT,Ls).             
romaji(RT,[コ|Ls]) --> [ko], romaji(RT,Ls).
romaji(RT,[ソ|Ls]) --> [so], romaji(RT,Ls).
romaji(RT,[ト|Ls]) --> [to], romaji(RT,Ls).
romaji(RT,[ノ|Ls]) --> [no], romaji(RT,Ls).
romaji(RT,[ホ|Ls]) --> [ho], romaji(RT,Ls).
romaji(RT,[モ|Ls]) --> [mo], romaji(RT,Ls).
romaji(RT,[ヨ|Ls]) --> [yo], romaji(RT,Ls).
romaji(RT,[ロ|Ls]) --> [ro], romaji(RT,Ls).
romaji(RT,[ヲ|Ls]) --> [wo], romaji(RT,Ls).
romaji(RT,[ン|Ls]) --> [n], romaji(RT,Ls).

romaji(RT,[ゴ|Ls]) --> [go], romaji(RT,Ls).
romaji(RT,[ゾ|Ls]) --> [zo], romaji(RT,Ls).
romaji(RT,[ド|Ls]) --> [do], romaji(RT,Ls).
romaji(RT,[ボ|Ls]) --> [bo], romaji(RT,Ls).
romaji(RT,[ポ|Ls]) --> [po], romaji(RT,Ls).

%odd
romaji(RT,[ヴ|Ls]) --> [vu], romaji(RT,Ls).
