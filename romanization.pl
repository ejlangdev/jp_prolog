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
ns_long_vowel(a, ??).
ns_long_vowel(e, ??).
ns_long_vowel(i, ??).
ns_long_vowel(o, ??).
ns_long_vowel(u, ??).

%Hepburn macron
hb_long_vowel(a, ??).
hb_long_vowel(e, ??).
hb_long_vowel(i, ??).
hb_long_vowel(o, ??).
hb_long_vowel(u, ??).

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
romaji(RT,[Kana,???|Ls]) --> {line_double_v(RT, [Kana], RmjLv)}, [RmjLv], romaji(RT,Ls).
romaji(RT,[Kana,Kana2,???|Ls]) --> {line_double_v(RT, [Kana, Kana2], RmjLv)}, [RmjLv], romaji(RT,Ls).
romaji(RT,[Kana,KanaV|Ls]) --> {double_v(RT, [Kana], [KanaV], RmjLv)}, [RmjLv], romaji(RT,Ls).
romaji(RT,[Kana,Kana2,KanaV|Ls]) --> {double_v(RT, [Kana,Kana2], [KanaV], RmjLv)}, [RmjLv], romaji(RT,Ls).
%Double consonants
romaji(RT,[???,Kana|Ls]) --> {double_consonant(RT, [Kana], Consonant)}, [Consonant], romaji(RT,[Kana|Ls]).
romaji(RT,[???,Kana|Ls]) --> {double_consonant(RT, [Kana], Consonant)}, [Consonant], romaji(RT,[Kana|Ls]).


%Spaces and punctuation
romaji(RT,[' '|Ls]) --> [' '], romaji(RT,Ls).
romaji(RT,['???'|Ls]) --> [' '], romaji(RT,Ls).
romaji(RT,['???'|Ls]) --> ['.'], romaji(RT,Ls).
romaji(RT,['???'|Ls]) --> [','], romaji(RT,Ls).

%Standard conversions ----
romaji(RT,[???,???|Ls]) --> [kya], romaji(RT,Ls). 
romaji(ns,[???,???|Ls]) --> [sya], romaji(ns,Ls). 
romaji(hb,[???,???|Ls]) --> [sha], romaji(hb,Ls). 
romaji(ns,[???,???|Ls]) --> [tya], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [cha], romaji(hb,Ls). 
romaji(RT,[???,???|Ls]) --> [nya], romaji(RT,Ls). 
romaji(RT,[???,???|Ls]) --> [hya], romaji(RT,Ls). 
romaji(RT,[???,???|Ls]) --> [mya], romaji(RT,Ls). 
romaji(RT,[???,???|Ls]) --> [rya], romaji(RT,Ls). 
romaji(RT,[???,???|Ls]) --> [gya], romaji(RT,Ls). 
romaji(ns,[???,???|Ls]) --> [zya], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [ja], romaji(hb,Ls). 
romaji(ns,[???,???|Ls]) --> [dya], romaji(ns,Ls). 
romaji(hb,[???,???|Ls]) --> [ja], romaji(hb,Ls). 
romaji(RT,[???,???|Ls]) --> [bya], romaji(RT,Ls). 
romaji(RT,[???,???|Ls]) --> [pya], romaji(RT,Ls). 
               
romaji(RT,[???,???|Ls]) --> [kyu], romaji(RT,Ls).
romaji(ns,[???,???|Ls]) --> [syu], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [shu], romaji(hb,Ls).
romaji(ns,[???,???|Ls]) --> [tyu], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [chu], romaji(hb,Ls).
romaji(RT,[???,???|Ls]) --> [nyu], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [hyu], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [myu], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [ryu], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [gyu], romaji(RT,Ls).
romaji(ns,[???,???|Ls]) --> [zyu], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [ju], romaji(hb,Ls).
romaji(ns,[???,???|Ls]) --> [dyu], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [ju], romaji(hb,Ls).
romaji(RT,[???,???|Ls]) --> [byu], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [pyu], romaji(RT,Ls).
               
romaji(RT,[???,???|Ls]) --> [kyo], romaji(RT,Ls). 
romaji(ns,[???,???|Ls]) --> [syo], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [sho], romaji(hb,Ls). 
romaji(ns,[???,???|Ls]) --> [tyo], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [cho], romaji(hb,Ls). 
romaji(RT,[???,???|Ls]) --> [nyo], romaji(RT,Ls). 
romaji(RT,[???,???|Ls]) --> [hyo], romaji(RT,Ls). 
romaji(RT,[???,???|Ls]) --> [myo], romaji(RT,Ls). 
romaji(RT,[???,???|Ls]) --> [ryo], romaji(RT,Ls). 
romaji(RT,[???,???|Ls]) --> [gyo], romaji(RT,Ls). 
romaji(ns,[???,???|Ls]) --> [zyo], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [jo], romaji(hb,Ls). 
romaji(ns,[???,???|Ls]) --> [dyo], romaji(ns,Ls). 
romaji(hb,[???,???|Ls]) --> [jo], romaji(hb,Ls). 
romaji(RT,[???,???|Ls]) --> [byo], romaji(RT,Ls). 
romaji(RT,[???,???|Ls]) --> [pyo], romaji(RT,Ls). 
% Oddities (Less common in hiragana than katakana, add when discovered)
romaji(RT,[???,???|Ls]) --> [je], romaji(RT,Ls).


romaji(RT,[???|Ls]) --> [a], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ka], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [sa], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [ta], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [na], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [ha], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [ma], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [ya], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [ra], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [wa], romaji(RT,Ls).             
             
romaji(RT,[???|Ls]) --> [ga], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [za], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [da], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [ba], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [pa], romaji(RT,Ls).

romaji(RT,[???|Ls]) --> [i], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [ki], romaji(RT,Ls). 
romaji(ns,[???|Ls]) --> [si], romaji(ns,Ls).
romaji(hb,[???|Ls]) --> [shi], romaji(hb,Ls).             
romaji(ns,[???|Ls]) --> [ti], romaji(ns,Ls).
romaji(hb,[???|Ls]) --> [chi], romaji(hb,Ls).             
romaji(RT,[???|Ls]) --> [ni], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [hi], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [mi], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [ri], romaji(RT,Ls).             
             
romaji(RT,[???|Ls]) --> [gi], romaji(RT,Ls).             
romaji(ns,[???|Ls]) --> [zi], romaji(ns,Ls).
romaji(hb,[???|Ls]) --> [ji], romaji(hb,Ls).             
romaji(ns,[???|Ls]) --> [di], romaji(ns,Ls).     
romaji(hb,[???|Ls]) --> [ji], romaji(hb,Ls).             
romaji(RT,[???|Ls]) --> [bi], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [pi], romaji(RT,Ls).             

romaji(RT,[???|Ls]) --> [u], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ku], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [su], romaji(RT,Ls). 
romaji(ns,[???|Ls]) --> [tu], romaji(ns,Ls).
romaji(hb,[???|Ls]) --> [tsu], romaji(hb,Ls). 
romaji(RT,[???|Ls]) --> [nu], romaji(RT,Ls). 
romaji(ns,[???|Ls]) --> [hu], romaji(ns,Ls).
romaji(hb,[???|Ls]) --> [fu], romaji(hb,Ls). 
romaji(RT,[???|Ls]) --> [mu], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [yu], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [ru], romaji(RT,Ls).

romaji(RT,[???|Ls]) --> [gu], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [zu], romaji(RT,Ls). 
romaji(ns,[???|Ls]) --> [du], romaji(ns,Ls).
romaji(hb,[???|Ls]) --> [zu], romaji(hb,Ls). 
romaji(RT,[???|Ls]) --> [bu], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [pu], romaji(RT,Ls). 

romaji(RT,[???|Ls]) --> [e], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [ke], romaji(RT,Ls).  
romaji(RT,[???|Ls]) --> [se], romaji(RT,Ls).  
romaji(RT,[???|Ls]) --> [te], romaji(RT,Ls).    
romaji(RT,[???|Ls]) --> [ne], romaji(RT,Ls).  
romaji(RT,[???|Ls]) --> [he], romaji(RT,Ls).  
romaji(RT,[???|Ls]) --> [me], romaji(RT,Ls).  
romaji(RT,[???|Ls]) --> [re], romaji(RT,Ls).  

romaji(RT,[???|Ls]) --> [ge], romaji(RT,Ls).  
romaji(RT,[???|Ls]) --> [ze], romaji(RT,Ls).  
romaji(RT,[???|Ls]) --> [de], romaji(RT,Ls).  
romaji(RT,[???|Ls]) --> [be], romaji(RT,Ls).  
romaji(RT,[???|Ls]) --> [pe], romaji(RT,Ls).  

romaji(RT,[???|Ls]) --> [o], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [ko], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [so], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [to], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [no], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [ho], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [mo], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [yo], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [ro], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [wo], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [n], romaji(RT,Ls).

romaji(RT,[???|Ls]) --> [go], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [zo], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [do], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [bo], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [po], romaji(RT,Ls).

%Katakana
%Three letters
romaji(RT,[???,???,???|Ls]) --> [fye], romaji(RT,Ls).
romaji(RT,[???,???,???|Ls]) --> [vye], romaji(RT,Ls).

%Common two letters 
romaji(RT,[???,???|Ls]) --> [kya], romaji(RT,Ls).
romaji(ns,[???,???|Ls]) --> [sya], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [sha], romaji(hb,Ls).
romaji(ns,[???,???|Ls]) --> [tya], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [cha], romaji(hb,Ls).
romaji(RT,[???,???|Ls]) --> [nya], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [hya], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [mya], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [rya], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [gya], romaji(RT,Ls).
romaji(ns,[???,???|Ls]) --> [zya], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [ja], romaji(hb,Ls).
romaji(ns,[???,???|Ls]) --> [dya], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [ja], romaji(hb,Ls).
romaji(RT,[???,???|Ls]) --> [bya], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [pya], romaji(RT,Ls).

romaji(RT,[???,???|Ls]) --> [kyu], romaji(RT,Ls).
romaji(ns,[???,???|Ls]) --> [syu], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [shu], romaji(hb,Ls).
romaji(ns,[???,???|Ls]) --> [tyu], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [chu], romaji(hb,Ls).
romaji(RT,[???,???|Ls]) --> [nyu], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [hyu], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [myu], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [ryu], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [gyu], romaji(RT,Ls).
romaji(ns,[???,???|Ls]) --> [zyu], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [ju], romaji(hb,Ls).
romaji(ns,[???,???|Ls]) --> [dyu], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [ju], romaji(hb,Ls).
romaji(RT,[???,???|Ls]) --> [byu], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [pyu], romaji(RT,Ls).

romaji(RT,[???,???|Ls]) --> [kyo], romaji(RT,Ls).
romaji(ns,[???,???|Ls]) --> [syo], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [sho], romaji(hb,Ls).
romaji(ns,[???,???|Ls]) --> [tyo], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [cho], romaji(hb,Ls).
romaji(RT,[???,???|Ls]) --> [nyo], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [hyo], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [myo], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [ryo], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [gyo], romaji(RT,Ls).
romaji(ns,[???,???|Ls]) --> [zyo], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [jo], romaji(hb,Ls).
romaji(ns,[???,???|Ls]) --> [dyo], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [jo], romaji(hb,Ls).
romaji(RT,[???,???|Ls]) --> [byo], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [pyo], romaji(RT,Ls).
    
%Uncommon two letters (often for sounds in english not common in jp)
romaji(RT,[???,???|Ls]) --> [she], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [je], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [che], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [tsa], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [tse], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [tso], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [ti], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [di], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [dyu], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [fa], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [fi], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [fe], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [fo], romaji(RT,Ls).

romaji(RT,[???,???|Ls]) --> [wa], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [wyu], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [vya], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [vyo], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [kye], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [gye], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [kwa], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [gwi], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [gwe], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [gwo], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [tsyu], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [nye], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [hye], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [bye], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [pye], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [fya], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [fyo], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [mye], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [rye], romaji(RT,Ls).

romaji(RT,[???,???|Ls]) --> [ye], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [wi], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [we], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [wo], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [va], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [vi], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [ve], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [vo], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [vyu], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [kwa], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [kwi], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [kwe], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [kwo], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [gwa], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [tsi], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [tu], romaji(RT,Ls).
romaji(ns,[???,???|Ls]) --> [tyu], romaji(ns,Ls).
romaji(hb,[???,???|Ls]) --> [chu], romaji(hb,Ls).
romaji(RT,[???,???|Ls]) --> [du], romaji(RT,Ls).
romaji(RT,[???,???|Ls]) --> [fyu], romaji(RT,Ls).

romaji(RT,[???|Ls]) --> [a], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ka], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [sa], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ta], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [na], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ha], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ma], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ya], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ra], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [wa], romaji(RT,Ls).

romaji(RT,[???|Ls]) --> [ga], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [za], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [da], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ba], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [pa], romaji(RT,Ls).

romaji(RT,[???|Ls]) --> [i], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ki], romaji(RT,Ls). 
romaji(ns,[???|Ls]) --> [si], romaji(ns,Ls).
romaji(hb,[???|Ls]) --> [shi], romaji(hb,Ls).
romaji(ns,[???|Ls]) --> [ti], romaji(ns,Ls).
romaji(hb,[???|Ls]) --> [chi], romaji(hb,Ls).
romaji(RT,[???|Ls]) --> [ni], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [hi], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [mi], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ri], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [gi], romaji(RT,Ls). 
romaji(ns,[???|Ls]) --> [zi], romaji(ns,Ls).
romaji(hb,[???|Ls]) --> [ji], romaji(hb,Ls). 
romaji(ns,[???|Ls]) --> [di], romaji(ns,Ls).
romaji(hb,[???|Ls]) --> [ji], romaji(hb,Ls). 
romaji(RT,[???|Ls]) --> [bi], romaji(RT,Ls). 
romaji(RT,[???|Ls]) --> [pi], romaji(RT,Ls). 

romaji(RT,[???|Ls]) --> [u], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ku], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [su], romaji(RT,Ls).
romaji(ns,[???|Ls]) --> [tu], romaji(ns,Ls).
romaji(hb,[???|Ls]) --> [tsu], romaji(hb,Ls). 
romaji(RT,[???|Ls]) --> [nu], romaji(RT,Ls).
romaji(ns,[???|Ls]) --> [hu], romaji(ns,Ls).
romaji(hb,[???|Ls]) --> [fu], romaji(hb,Ls).
romaji(RT,[???|Ls]) --> [mu], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [yu], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ru], romaji(RT,Ls).

romaji(RT,[???|Ls]) --> [gu], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [zu], romaji(RT,Ls).
romaji(ns,[???|Ls]) --> [du], romaji(ns,Ls).
romaji(hb,[???|Ls]) --> [zu], romaji(hb,Ls).
romaji(RT,[???|Ls]) --> [bu], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [pu], romaji(RT,Ls).

romaji(RT,[???|Ls]) --> [e], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ke], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [se], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [te], romaji(RT,Ls).  
romaji(RT,[???|Ls]) --> [ne], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [he], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [me], romaji(RT,Ls).  
romaji(RT,[???|Ls]) --> [re], romaji(RT,Ls).

romaji(RT,[???|Ls]) --> [ge], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ze], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [de], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [be], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [pe], romaji(RT,Ls).

romaji(RT,[???|Ls]) --> [o], romaji(RT,Ls).             
romaji(RT,[???|Ls]) --> [ko], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [so], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [to], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [no], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ho], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [mo], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [yo], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [ro], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [wo], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [n], romaji(RT,Ls).

romaji(RT,[???|Ls]) --> [go], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [zo], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [do], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [bo], romaji(RT,Ls).
romaji(RT,[???|Ls]) --> [po], romaji(RT,Ls).

%odd
romaji(RT,[???|Ls]) --> [vu], romaji(RT,Ls).
