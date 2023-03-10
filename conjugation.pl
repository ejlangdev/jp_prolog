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
hypothetical_inflection_suffix --> [???].
potential_inflection_suffix --> [???].
causative_inflection_suffix --> [??????].
passive_inflection_suffix --> [??????].
volitional_inflection_suffix --> [???].

%Argument is last kana
te_inflection_suffix(???) --> [??????].
te_inflection_suffix(???) --> [??????].
te_inflection_suffix(???) --> [??????].
te_inflection_suffix(???) --> [??????].
te_inflection_suffix(???) --> [??????].
te_inflection_suffix(???) --> [??????].
te_inflection_suffix(???) --> [??????].
te_inflection_suffix(???) --> [??????].
te_inflection_suffix(???) --> [??????].

ta_inflection_suffix(???) --> [??????].
ta_inflection_suffix(???) --> [??????].
ta_inflection_suffix(???) --> [??????].
ta_inflection_suffix(???) --> [??????].
ta_inflection_suffix(???) --> [??????].
ta_inflection_suffix(???) --> [??????].
ta_inflection_suffix(???) --> [??????].
ta_inflection_suffix(???) --> [??????].
ta_inflection_suffix(???) --> [??????].

tara_inflection_suffix(???) --> [?????????].
tara_inflection_suffix(???) --> [?????????].
tara_inflection_suffix(???) --> [?????????].
tara_inflection_suffix(???) --> [?????????].
tara_inflection_suffix(???) --> [?????????].
tara_inflection_suffix(???) --> [?????????].
tara_inflection_suffix(???) --> [?????????].
tara_inflection_suffix(???) --> [?????????].
tara_inflection_suffix(???) --> [?????????].

tari_inflection_suffix(???) --> [?????????].
tari_inflection_suffix(???) --> [?????????].
tari_inflection_suffix(???) --> [?????????].
tari_inflection_suffix(???) --> [?????????].
tari_inflection_suffix(???) --> [?????????].
tari_inflection_suffix(???) --> [?????????].
tari_inflection_suffix(???) --> [?????????].
tari_inflection_suffix(???) --> [?????????].
tari_inflection_suffix(???) --> [?????????].


/*  Auxilliary verb suffixes:
Used to add meaning and context to each verb, these auxilliaries can only be
applied to certain bases, often this will shift the meaning to one of the other bases
Eg..:
base word 'hajimaru' (begin) -> conjunctive root (renyokei) 'hajimari' ->
negative auxilliary 'nai' -> plain verb (negative) 'hajimarinai'
*/
%Polite Masu conjunctive
polite_aux_suffix --> [?????????]. %negative
polite_aux_suffix --> [??????????????????]. %past negative
polite_aux_suffix --> [??????]. %plain
polite_aux_suffix --> [????????????]. %conditional
%mase/mashi** only honorific imperative
%polite_aux_suffix(?????????). %imperative / ?????? ?
polite_aux_suffix --> [????????????]. %volitional
polite_aux_suffix --> [?????????]. %te form
polite_aux_suffix --> [?????????]. %ta form

%Negative Auxilliary negative
negative_aux_suffix --> [???????????????]. %negative
negative_aux_suffix --> [??????]. %conjunctive
negative_aux_suffix --> [??????]. %plain
negative_aux_suffix --> [????????????]. %conditional
negative_aux_suffix --> [?????????]. %te
negative_aux_suffix --> [????????????]. %ta form
negative_aux_suffix --> [???????????????]. %tara

%tai Auxilliary (First person) conjunctive
tai_aux_suffix --> [????????????]. %negative
tai_aux_suffix --> [??????]. %conjunctive
tai_aux_suffix --> [??????]. %plain
tai_aux_suffix --> [????????????]. %conditional
tai_aux_suffix --> [?????????]. %te
tai_aux_suffix --> [????????????]. %ta form
tai_aux_suffix --> [???????????????]. %tara

%tagaru Auxilliary (Third person) conjunctive
%Forced into godan verb
tagaru_aux_suffix --> [?????????]. %negative
tagaru_aux_suffix --> [?????????]. %conjunctive
tagaru_aux_suffix --> [?????????]. %plain
tagaru_aux_suffix --> [????????????]. %te
tagaru_aux_suffix --> [????????????]. %ta form
tagaru_aux_suffix --> [???????????????]. %tara (conditional)

%hoshii Auxilliary (desire for someone to do) te
hoshii_aux_suffix --> [???????????????]. %negative
hoshii_aux_suffix --> [?????????]. %conjunctive
hoshii_aux_suffix --> [?????????]. %plain
hoshii_aux_suffix --> [???????????????]. %conditional
hoshii_aux_suffix --> [????????????]. %te
hoshii_aux_suffix --> [???????????????]. %ta form
hoshii_aux_suffix --> [??????????????????]. %tara (conditional)

%rashii plain/ta
rashii_aux_suffix --> [?????????]. %conjunctive
rashii_aux_suffix --> [?????????]. %plain
rashii_aux_suffix --> [????????????]. %te

%Souda    
%plain/ta *hearsay
so_da_plain_aux_suffix --> [?????????]. %dictionary
%conjunctive *conjecture
so_da_con_aux_suffix --> [?????????]. %dictionary
so_da_con_aux_suffix --> [????????????]. %conditional
so_da_con_aux_suffix --> [???????????????]. %ta

%"to make/let someone do something."
%seru/saseru negative(godan) turns ichidan
seru_aux_suffix --> [???]. %negative
seru_aux_suffix --> [???]. %conjunctive
seru_aux_suffix --> [??????]. %plain
seru_aux_suffix --> [??????]. %conditional
seru_aux_suffix --> [??????]. %imperative
seru_aux_suffix --> [??????]. %imperative
seru_aux_suffix --> [?????????]. %volitional
seru_aux_suffix --> [??????]. %te
seru_aux_suffix --> [??????]. %ta

%Reru/rareru Negative
reru_aux_suffix --> [???]. %negative
reru_aux_suffix --> [???]. %conjunctive
reru_aux_suffix --> [??????]. %plain
reru_aux_suffix --> [??????]. %te
reru_aux_suffix --> [??????]. %ta


/*
Alphabet table, used for substitutions not romanization
for example: 'what is the vowel u version of ka(???)':
    C-Consonant, u, S-Symbol
    jp_alphabet(C,_,???)
    jp_alphabet(C,u,S)
Not all of these entries need to be used but kept full
for all possibilities just incase 
*/

jp_alphabet(a, ???). %Special case: uses kana for wa instead of a
jp_alphabet(i, ???).
jp_alphabet(u, ???).
jp_alphabet(e, ???).
jp_alphabet(o, ???).

jp_alphabet(k, a, ???).
jp_alphabet(g, a, ???).
jp_alphabet(s, a, ???).
jp_alphabet(z, a, ???).
jp_alphabet(t, a, ???).
jp_alphabet(d, a, ???).
jp_alphabet(n, a, ???).
jp_alphabet(h, a, ???).
jp_alphabet(b, a, ???).
jp_alphabet(p, a, ???).
jp_alphabet(m, a, ???).
jp_alphabet(y, a, ???).
jp_alphabet(r, a, ???).
jp_alphabet(w, a, ???).

jp_alphabet(k, i, ???).
jp_alphabet(g, i, ???).
jp_alphabet(s, i, ???).
jp_alphabet(z, i, ???).
jp_alphabet(t, i, ???).
jp_alphabet(d, i, ???).
jp_alphabet(n, i, ???).
jp_alphabet(h, i, ???).
jp_alphabet(b, i, ???).
jp_alphabet(p, i, ???).
jp_alphabet(m, i, ???).
jp_alphabet(r, i, ???).

jp_alphabet(k, u, ???).
jp_alphabet(g, u, ???).
jp_alphabet(s, u, ???).
jp_alphabet(z, u, ???).
jp_alphabet(t, u, ???).
jp_alphabet(d, u, ???).
jp_alphabet(n, u, ???).
jp_alphabet(h, u, ???).
jp_alphabet(b, u, ???).
jp_alphabet(p, u, ???).
jp_alphabet(m, u, ???).
jp_alphabet(y, u, ???).
jp_alphabet(r, u, ???).

jp_alphabet(k, e, ???).
jp_alphabet(g, e, ???).
jp_alphabet(s, e, ???).
jp_alphabet(z, e, ???).
jp_alphabet(t, e, ???).
jp_alphabet(d, e, ???).
jp_alphabet(n, e, ???).
jp_alphabet(h, e, ???).
jp_alphabet(b, e, ???).
jp_alphabet(p, e, ???).
jp_alphabet(m, e, ???).
jp_alphabet(r, e, ???).

jp_alphabet(k, o, ???).
jp_alphabet(g, o, ???).
jp_alphabet(s, o, ???).
jp_alphabet(z, o, ???).
jp_alphabet(t, o, ???).
jp_alphabet(d, o, ???).
jp_alphabet(n, o, ???).
jp_alphabet(h, o, ???).
jp_alphabet(b, o, ???).
jp_alphabet(p, o, ???).
jp_alphabet(m, o, ???).
jp_alphabet(y, o, ???).
jp_alphabet(r, o, ???).
jp_alphabet(w, o, ???).
