/* All rights still remain the owner under exclusive copywrite, this excerpt 
has been uploaded as reference and will at a future date be placed under a
more permissive licence along with additional features.*/

/* General usage verb conjugator, the aim of this is to provide the most
general forms of conjugation without relying on already existed records
of words. Note: not all conjugations are used in japanese and sometimes the
meaning of conjugations will change from what is expected as with any language.
Use this only as a general outline.

TODO
    addition of more auxilliary words
        current selection contains most common, but there may be more
    refinement of the root-base system to remove redundancies
        this system is also used in other parts of the language
    multiple conjugations, eg..
        (tabesaseraretakunakatta, "did not want to be made to eat")
            need to include transforms on suffixes 
    Support ichidan verbs / irregular verbs (not just kuru and suru)
*/

conjugate_verb(Word, X, XA, Record) :-
    phrase(verb(Word, Record), X),
    atomic_list_concat(X, XA).


%Vowel swap
switch_kana_vowel([Last], SubstitutedVowel, [NewLast]) :-
    jp_alphabet(_, Last), %Is it a vowel (u)
    jp_alphabet(SubstitutedVowel, NewLast), !.
%Consonant + vowel swap
switch_kana_vowel([Last], SubstitutedVowel, [NewLast]) :-
    jp_alphabet(C, _, Last),
    jp_alphabet(C, SubstitutedVowel, NewLast), !.
switch_kana_vowel([H|T], SubstitutedVowel, [H|Stem]) :-
    switch_kana_vowel(T, SubstitutedVowel, Stem). 


form(imperfective).
form(conditional).
form(potential).
form(imperative).
form(negative).
form(passive).
form(causative).
form(volitional).
form(conjunctive).
form(perfective).
form(te).

stem_base(terminal, '').
stem_base(attributive, '').
stem_base(hypothetical, e).
stem_base(potential, e).
stem_base(imperative, e).
stem_base(irrealis, a). 
stem_base(volitional, o).
stem_base(conjunctive, i).
stem_base(euphonic, remove).

%Word modifications and logic -------
get_stem(Word, StemType, Stem) :-
    stem_base(StemType, SubstitutedVowel),
    split_word(Word, SubstitutedVowel, Stem).

split_word(Word, '', Word) :- !.
split_word(Word, remove, Stem) :-
    atom_chars(Word, Ws),
    remove_last(Ws, Ss),
    atom_chars(Stem, Ss), !.
split_word(Word, SubstitutedVowel, Stem) :-
    atom_chars(Word, Ws),
    switch_kana_vowel(Ws, SubstitutedVowel, Ss),
    atom_chars(Stem, Ss).

remove_last([_], []) :- !.
remove_last([H|T], [H|Stem]) :-
    remove_last(T, Stem). 

get_last(Word, Last) :-
    \+ compound(Word),
    atom_chars(Word, Ws),
    get_last(Ws, Last).     
get_last([Last], Last) :- !.
get_last([_|T], Last) :-
    get_last(T, Last). 

%Application of conjugations
%Entry
verb(Root, Record) --> base(Root, Record). %{reverse(Record, RRecord)}.

%Roots
%Both shushikei and tentaikei are identical for verbs, limiting rentaikei until theres a use for it
shushikei(Root, []) --> {get_stem(Root, terminal, Stem)}, [Stem]. %AKA dictionary/plain base (u)
%rentaikei(Root, Record) --> {get_stem(Root, attributive, Stem)}, [Stem].
kateikei(Root, []) --> {get_stem(Root, hypothetical, Stem)}, [Stem]. %(e)
kanokei(Root, []) --> {get_stem(Root, potential, Stem)}, [Stem]. %(e)
meireikei(Root, []) --> {get_stem(Root, imperative, Stem)}, [Stem]. %(e)
mizenkei(Root, []) --> {get_stem(Root, irrealis, Stem)}, [Stem]. %AKA negative base (a)
ishikei(Root, []) --> {get_stem(Root, volitional, Stem)}, [Stem]. %(o)
renyokei(Root, []) --> {get_stem(Root, conjunctive, Stem)}, [Stem]. %(i)
onbinkei(Root, []) --> {get_stem(Root, euphonic, Stem)}, [Stem]. %(remove/complete change)

%Valid Bases and auxilliaries
base(Root, [dictionary|Record]) --> shushikei(Root, Record).
base(Root, [dictionary, rashii_aux|Record]) --> shushikei(Root, Record), rashii_aux_suffix.
base(Root, [dictionary, so_da_aux|Record]) --> shushikei(Root, Record), so_da_plain_aux_suffix.

base(Root, [hypothetical|Record]) --> kateikei(Root, Record), hypothetical_inflection_suffix.

base(Root, [potential|Record]) --> kanokei(Root, Record), potential_inflection_suffix.

base(Root, [imperative|Record]) --> meireikei(Root, Record).
base(Root, [causative|Record]) --> mizenkei(Root, Record), causative_inflection_suffix.
base(Root, [passive|Record]) --> mizenkei(Root, Record), passive_inflection_suffix.

base(Root, [negative|Record]) --> mizenkei(Root, Record). %Unsure about negative without suffix
base(Root, [negative, neg_aux|Record]) --> mizenkei(Root, Record), negative_aux_suffix.
base(Root, [negative, seru_aux|Record]) --> mizenkei(Root, Record), seru_aux_suffix.
base(Root, [negative, reru_aux|Record]) --> mizenkei(Root, Record), reru_aux_suffix.

base(Root, [volitional|Record]) --> ishikei(Root, Record), volitional_inflection_suffix.

base(Root, [conjunctive|Record]) --> renyokei(Root, Record).
base(Root, [conjunctive, polite_aux|Record]) --> renyokei(Root, Record), polite_aux_suffix.
base(Root, [conjunctive, tai_aux|Record]) --> renyokei(Root, Record), tai_aux_suffix.
base(Root, [conjunctive, tagaru_aux|Record]) --> renyokei(Root, Record), tagaru_aux_suffix.
base(Root, [conjunctive, so_da_con_aux|Record]) --> renyokei(Root, Record), so_da_con_aux_suffix.

base(Root, [te|Record]) --> onbinkei(Root, Record), {get_last(Root, LastKana)}, te_inflection_suffix(LastKana).
base(Root, [te, hoshii_aux|Record]) --> onbinkei(Root, Record), {get_last(Root, LastKana)}, te_inflection_suffix(LastKana), hoshii_aux_suffix.

base(Root, [ta, rashii_aux|Record]) --> onbinkei(Root, Record), {get_last(Root, LastKana)}, ta_inflection_suffix(LastKana), rashii_aux_suffix.
base(Root, [ta, so_da_aux|Record]) --> onbinkei(Root, Record), {get_last(Root, LastKana)}, ta_inflection_suffix(LastKana), so_da_plain_aux_suffix.

base(Root, [tara|Record]) --> onbinkei(Root, Record), {get_last(Root, LastKana)}, tara_inflection_suffix(LastKana).
base(Root, [tari|Record]) --> onbinkei(Root, Record), {get_last(Root, LastKana)}, tari_inflection_suffix(LastKana).

/* Inflection suffixes are necessary additions to the base,
the te,ta,tara,tari suffixes change depending on the last
symbol of the word (all possible verb endings are given)*/
hypothetical_inflection_suffix --> [ば].
potential_inflection_suffix --> [る].
causative_inflection_suffix --> [せる].
passive_inflection_suffix --> [れる].
volitional_inflection_suffix --> [う].

%Argument is last kana
te_inflection_suffix(る) --> [って].
te_inflection_suffix(う) --> [って].
te_inflection_suffix(つ) --> [って].
te_inflection_suffix(す) --> [して].
te_inflection_suffix(く) --> [いて].
te_inflection_suffix(ぐ) --> [いで].
te_inflection_suffix(ぶ) --> [んで].
te_inflection_suffix(む) --> [んで].
te_inflection_suffix(ぬ) --> [んで].

ta_inflection_suffix(る) --> [った].
ta_inflection_suffix(う) --> [った].
ta_inflection_suffix(つ) --> [った].
ta_inflection_suffix(す) --> [した].
ta_inflection_suffix(く) --> [いた].
ta_inflection_suffix(ぐ) --> [いだ].
ta_inflection_suffix(ぶ) --> [んだ].
ta_inflection_suffix(む) --> [んだ].
ta_inflection_suffix(ぬ) --> [んだ].

tara_inflection_suffix(る) --> [ったら].
tara_inflection_suffix(う) --> [ったら].
tara_inflection_suffix(つ) --> [ったら].
tara_inflection_suffix(す) --> [したら].
tara_inflection_suffix(く) --> [いたら].
tara_inflection_suffix(ぐ) --> [いだら].
tara_inflection_suffix(ぶ) --> [んだら].
tara_inflection_suffix(む) --> [んだら].
tara_inflection_suffix(ぬ) --> [んだら].

tari_inflection_suffix(る) --> [ったり].
tari_inflection_suffix(う) --> [ったり].
tari_inflection_suffix(つ) --> [ったり].
tari_inflection_suffix(す) --> [したり].
tari_inflection_suffix(く) --> [いたり].
tari_inflection_suffix(ぐ) --> [いだり].
tari_inflection_suffix(ぶ) --> [んだり].
tari_inflection_suffix(む) --> [んだり].
tari_inflection_suffix(ぬ) --> [んだり].


/*  Auxilliary verb suffixes:
Used to add meaning and context to each verb, these auxilliaries can only be
applied to certain bases, often this will shift the meaning to one of the other bases
Eg..:
base word 'hajimaru' (begin) -> conjunctive root (renyokei) 'hajimari' ->
negative auxilliary 'nai' -> plain verb (negative) 'hajimarinai'
*/
%Polite Masu conjunctive
polite_aux_suffix --> [ません]. %negative
polite_aux_suffix --> [ませんでした]. %past negative
polite_aux_suffix --> [ます]. %plain
polite_aux_suffix --> [ますれば]. %conditional
%mase/mashi** only honorific imperative
%polite_aux_suffix(なさい). %imperative / ＋な ?
polite_aux_suffix --> [ましょう]. %volitional
polite_aux_suffix --> [まして]. %te form
polite_aux_suffix --> [ました]. %ta form

%Negative Auxilliary negative
negative_aux_suffix --> [なくはない]. %negative
negative_aux_suffix --> [なく]. %conjunctive
negative_aux_suffix --> [ない]. %plain
negative_aux_suffix --> [なければ]. %conditional
negative_aux_suffix --> [なくて]. %te
negative_aux_suffix --> [なかった]. %ta form
negative_aux_suffix --> [なかったら]. %tara

%tai Auxilliary (First person) conjunctive
tai_aux_suffix --> [たくない]. %negative
tai_aux_suffix --> [たく]. %conjunctive
tai_aux_suffix --> [たい]. %plain
tai_aux_suffix --> [たければ]. %conditional
tai_aux_suffix --> [たくて]. %te
tai_aux_suffix --> [たかった]. %ta form
tai_aux_suffix --> [たかったら]. %tara

%tagaru Auxilliary (Third person) conjunctive
%Forced into godan verb
tagaru_aux_suffix --> [たがら]. %negative
tagaru_aux_suffix --> [たがり]. %conjunctive
tagaru_aux_suffix --> [たがる]. %plain
tagaru_aux_suffix --> [たがって]. %te
tagaru_aux_suffix --> [たがった]. %ta form
tagaru_aux_suffix --> [たがったら]. %tara (conditional)

%hoshii Auxilliary (desire for someone to do) te
hoshii_aux_suffix --> [ほしくない]. %negative
hoshii_aux_suffix --> [ほしく]. %conjunctive
hoshii_aux_suffix --> [ほしい]. %plain
hoshii_aux_suffix --> [ほしければ]. %conditional
hoshii_aux_suffix --> [ほしくて]. %te
hoshii_aux_suffix --> [ほしくった]. %ta form
hoshii_aux_suffix --> [ほしくったら]. %tara (conditional)

%rashii plain/ta
rashii_aux_suffix --> [らしく]. %conjunctive
rashii_aux_suffix --> [らしい]. %plain
rashii_aux_suffix --> [らしくて]. %te

%Souda    
%plain/ta *hearsay
so_da_plain_aux_suffix --> [そうだ]. %dictionary
%conjunctive *conjecture
so_da_con_aux_suffix --> [そうだ]. %dictionary
so_da_con_aux_suffix --> [そうなら]. %conditional
so_da_con_aux_suffix --> [そうだった]. %ta

%"to make/let someone do something."
%seru/saseru negative(godan) turns ichidan
seru_aux_suffix --> [せ]. %negative
seru_aux_suffix --> [せ]. %conjunctive
seru_aux_suffix --> [せる]. %plain
seru_aux_suffix --> [せれ]. %conditional
seru_aux_suffix --> [せろ]. %imperative
seru_aux_suffix --> [せよ]. %imperative
seru_aux_suffix --> [せよう]. %volitional
seru_aux_suffix --> [せて]. %te
seru_aux_suffix --> [せた]. %ta

%Reru/rareru Negative
reru_aux_suffix --> [れ]. %negative
reru_aux_suffix --> [れ]. %conjunctive
reru_aux_suffix --> [れる]. %plain
reru_aux_suffix --> [れて]. %te
reru_aux_suffix --> [れた]. %ta


/*
Alphabet table, used for substitutions not romanization
for example: 'what is the vowel u version of ka(か)':
    C-Consonant, u, S-Symbol
    jp_alphabet(C,_,か)
    jp_alphabet(C,u,S)
Not all of these entries need to be used but kept full
for all possibilities just incase 
*/

jp_alphabet(a, わ). %Special case: uses kana for wa instead of a
jp_alphabet(i, い).
jp_alphabet(u, う).
jp_alphabet(e, え).
jp_alphabet(o, お).

jp_alphabet(k, a, か).
jp_alphabet(g, a, が).
jp_alphabet(s, a, さ).
jp_alphabet(z, a, ざ).
jp_alphabet(t, a, た).
jp_alphabet(d, a, だ).
jp_alphabet(n, a, な).
jp_alphabet(h, a, は).
jp_alphabet(b, a, ば).
jp_alphabet(p, a, ぱ).
jp_alphabet(m, a, ま).
jp_alphabet(y, a, や).
jp_alphabet(r, a, ら).
jp_alphabet(w, a, わ).

jp_alphabet(k, i, き).
jp_alphabet(g, i, ぎ).
jp_alphabet(s, i, し).
jp_alphabet(z, i, じ).
jp_alphabet(t, i, ち).
jp_alphabet(d, i, ぢ).
jp_alphabet(n, i, に).
jp_alphabet(h, i, ひ).
jp_alphabet(b, i, び).
jp_alphabet(p, i, ぴ).
jp_alphabet(m, i, み).
jp_alphabet(r, i, り).

jp_alphabet(k, u, く).
jp_alphabet(g, u, ぐ).
jp_alphabet(s, u, す).
jp_alphabet(z, u, ず).
jp_alphabet(t, u, つ).
jp_alphabet(d, u, づ).
jp_alphabet(n, u, づ).
jp_alphabet(h, u, ふ).
jp_alphabet(b, u, ぶ).
jp_alphabet(p, u, ぷ).
jp_alphabet(m, u, む).
jp_alphabet(y, u, ゆ).
jp_alphabet(r, u, る).

jp_alphabet(k, e, け).
jp_alphabet(g, e, げ).
jp_alphabet(s, e, せ).
jp_alphabet(z, e, ぜ).
jp_alphabet(t, e, て).
jp_alphabet(d, e, で).
jp_alphabet(n, e, ね).
jp_alphabet(h, e, へ).
jp_alphabet(b, e, べ).
jp_alphabet(p, e, ぺ).
jp_alphabet(m, e, め).
jp_alphabet(r, e, れ).

jp_alphabet(k, o, こ).
jp_alphabet(g, o, ご).
jp_alphabet(s, o, そ).
jp_alphabet(z, o, ぞ).
jp_alphabet(t, o, と).
jp_alphabet(d, o, ど).
jp_alphabet(n, o, の).
jp_alphabet(h, o, ほ).
jp_alphabet(b, o, ぼ).
jp_alphabet(p, o, ぽ).
jp_alphabet(m, o, も).
jp_alphabet(y, o, よ).
jp_alphabet(r, o, ろ).
jp_alphabet(w, o, を).
