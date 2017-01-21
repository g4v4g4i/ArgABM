; this file contains:
; 1. the definitions of the turtles, links
;    and variables;
; 2. it includes the other files; and
; 3. the procedures that correspond to
;    the buttons in the interface:
;    setup, go and reset





; three different kinds of turtles
; arguments and starts form the landscape
; researchers are the scientists that explore the landscape
breed [arguments argument]
breed [starts start]
breed [researchers researcher]

; two different kinds of relations on the arguments
; a discovery relation and an attack relation
directed-link-breed [discoveries discovery]
directed-link-breed [attacks attack]

; the trees have to be connected in order to be visible
undirected-link-breed [starters starter]

; connections between researchers are undirected
undirected-link-breed [collaborators collaborator]

; properties of the arguments, each argument "knows":
; the theory it belongs to, during the setup if it should
; be considered, how many ticks an researcher was working on it
; and when it was fully researched (when it turned red)
; the roots also know how many researchers are working on that theory
starts-own [mytheory current-start myscientists researcher-ticks full-research]
arguments-own [mytheory current-argument researcher-ticks full-research]

; every researcher keeps track of how often it thinks
; that it should jump to another theory, how many times it jumped,
; the social network it belongs to, its current subjective landscape,
; the current best theory, if it received information at the current time
; the information in its neighborhood, whether it moved, if it is the representative
; researcher of its network and the new arguments/relations that are to be added
researchers-own [theory-jump times-jumped collaborator-network
  subjective-arguments subjective-relations current-theory-info cur-best-th
  admissible-subj-argu th-args th-relations communicating neighborargs moved
  rep-researcher to-add-mem-argu to-add-mem-rel lastalist lastblist lastalistafter flag-updated-memory conference-attended non-admiss-subj-argu]

; the global variables are all concerned with the
; run-many procedure, or the initialization of hidden variables
globals [times-right number-of-theories-many theory-depth-many
  scientists-many setup-successful-m setup-successful-p setup-time
  setup-discovered setup-discovered-best setup-jumps
  max-learn small-movement color-move colla-networks share-structure]

; includes
__includes ["setup.nls" "behavior.nls" "strategies.nls" "run-many.nls" "testprocedures.nls"]



; procedure that lets the program run, after the landscape was setup
; every five time steps researchers update their memory and compute the
; best strategy
; researchers always move around and update the landscape (with the probabilities
; as set in the interface)
to go
  update-memories
  duplicate-remover
  if ticks mod 5 = 4 [
    compute-strategies-researchers
    act-on-strategy-researchers
  ]
  move-around
  update-landscape
  compute-popularity
  tick
end









@#$#@#$#@
GRAPHICS-WINDOW
210
135
881
807
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-25
25
-25
25
1
1
1
ticks
30.0

BUTTON
10
10
65
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
10
45
65
78
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
70
45
125
78
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
210
50
382
83
number-of-theories
number-of-theories
2
3
3.0
1
1
NIL
HORIZONTAL

SLIDER
210
90
382
123
theory-depth
theory-depth
1
5
3.0
1
1
NIL
HORIZONTAL

SLIDER
10
125
182
158
scientists
scientists
5
100
50.0
5
1
NIL
HORIZONTAL

TEXTBOX
210
25
360
43
Landscape settings
13
0.0
1

SLIDER
390
50
560
83
attack-probability-2nd
attack-probability-2nd
0
1
0.3
0.01
1
NIL
HORIZONTAL

TEXTBOX
15
95
165
113
researcher settings
13
0.0
1

SLIDER
10
165
182
198
move-probability
move-probability
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
10
205
182
238
visibility-probability
visibility-probability
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
10
245
182
278
research-speed
research-speed
0
50
5.0
5
1
NIL
HORIZONTAL

TEXTBOX
580
25
730
43
Strategy settings
13
0.0
1

SLIDER
580
50
752
83
strategy-threshold
strategy-threshold
0
1
0.9
0.1
1
NIL
HORIZONTAL

SLIDER
580
90
752
123
jump-threshold
jump-threshold
1
25
10.0
1
1
NIL
HORIZONTAL

SLIDER
390
10
560
43
attack-probability-best
attack-probability-best
0
1
0.3
0.01
1
NIL
HORIZONTAL

PLOT
5
450
205
600
Popularity
Time steps
No. of researchers
0.0
100.0
0.0
8.0
true
false
"" ""
PENS
"best theory" 1.0 0 -2674135 true "" "let all-theories []\nask starts [ set all-theories lput self all-theories ]\nset all-theories sort all-theories\nif length all-theories >= 1[\nplotxy ticks [myscientists] of first all-theories]"
"start 2" 1.0 0 -955883 true "" "let all-theories []\nask starts [ set all-theories lput self all-theories ]\nset all-theories sort all-theories\nif length all-theories >= 2[\nplot [myscientists] of first (but-first all-theories)\n]"
"start 3" 1.0 0 -1184463 true "" "let all-theories []\nask starts [ set all-theories lput self all-theories ]\nset all-theories sort all-theories\nif length all-theories >= 3 [\nplot [myscientists] of first (but-first (but-first all-theories))\n]"
"start 4" 1.0 0 -10899396 true "let all-theories []\nask starts [ set all-theories lput self all-theories ]\nset all-theories sort all-theories" "let all-theories []\nask starts [ set all-theories lput self all-theories ]\nset all-theories sort all-theories\nif length all-theories >= 4 [\nplot [myscientists] of last all-theories\n]"

TEXTBOX
10
395
160
413
NIL
13
0.0
1

TEXTBOX
10
425
160
443
Plots
13
0.0
1

SWITCH
10
285
100
318
within-theory
within-theory
1
1
-1000

CHOOSER
10
325
148
370
social-actions
social-actions
"reliable" "biased"
0

SLIDER
390
90
562
123
attack-probability-3rd
attack-probability-3rd
0
1
0.3
0.01
1
NIL
HORIZONTAL

BUTTON
130
10
185
43
NIL
run-many
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
9
374
147
419
network-structure
network-structure
"cycle" "wheel" "complete"
2

BUTTON
70
10
125
43
go-stop
setup\ngo\nwhile [any? arguments with\n  [color != red and\n    [myscientists] of mytheory !=  0]][\n  go\n]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
# Motivation

# Introduction

# Documentation

## Interface

Buttons

* _setup_ creates the landscape, including attacks and distributes the scientists/researchers over this landscape

* _go_ lets the program run one time step

* _go (infinite, has a small circle)_ lets the program run infinitely many steps, or until the button is clicked again

* _go-stop_ lets the program run until all researchers are working on a fully researched theory

Landscape settings

* _number-of-theories_ sets the number of theories/trees that will be created

* _theory-depth_ sets the depth of the tree

* _attack-probability-best_ the probability that an argument of the objective best theory has an incoming attack

* _attack-probability-2nd_ the probability that an argument of the 2nd theory has an incoming attack

* _attack-probability-3rd_ if there are three theories, the probability that an argument of the 3rd theory has an incoming attack

Strategy settings

* _strategy-threshold_ defines the threshold within which the number of admissible arguments is still considered good, if this threshold gets higher, the interval of acceptable values gets smaller

* _jump-threshold_ is the number of times an researcher has to consider jumping before it really jumps to another theory

researcher settings

* _scientists_ the number of researchers that will explore the landscape

* _move-probability_ the probability that researchers move to a next argument while exploring the landscape

* _visibility-probability_ the probability that new attacks are discovered by researchers

* _research-speed_ the time an researcher has to work on an argument before it will change color

* _within-theory_ here the kind of collaborative network is set to researchers that start on the same theory (on) or randomly chosen researchers (off)

* _social-actions_ here the behavior of the researchers that communicate with researchers outside their own can be set: "reliable" is the setting where they share all information about the current theory: including attacks; "biased" researchers do not share the attacks to their current theory

* _network-structure_ determines the structure in which the collaborator-networks are connected and with how many researchers information is shared

Plots

* the _Popularity_ plot shows for every theory the number of researchers working on it

## Some language definitions

_Discovered arguments_: an argument that is not gray anymore nor turquoise (discovered by discovering an attack relation)
_(Not) fully researched arguments_: the level at which an argument is explored, a fully researched argument will be red
_Root/start_: refers to the root of a theory

## Setup of the landscape

### Building the objective landscape

For each theory a tree is built, its root is called "start". The depth of the theory, as can be chosen in the interface, sets the number of arguments. The root has 4 child-arguments, after that, if a next layer exists, each argument has also 4 child-arguments, otherwise 0. Each of these child-arguments is connected by a directed discovery relation.

Each argument has a memory for the theory it belongs to, how often it is visited/researched by an researcher and whether it was just fully researched (turned red in the current round).

### Defining the attack relation

On the created landscape an attack relation is added. Each argument has, with attack-probability corresponding to the theory the argument belongs to, an incoming attack from an argument belonging to another theory. Once the random attacks are created, the best theory (theory 0), has to make sure that it is fully defended. It creates attacks to arguments that attack one of its arguments, until it has defended all its attacked arguments.

### researchers

researchers are randomly distributed over the available theories. Then they form "collaborator-networks". If the switch "within-theory" is on in the interface, such networks are created with researchers that start on the same theory, if the switch is off networks are randomly created. Such networks have at most 5 researchers. In case the networks are random all networks have exactly 5 researchers, if the networks are created within theories there can be networks with less than 5 researchers.

A list of all collaborator-networks is saved in the global variable colla-networks:

`[[(researchers a1) ... (researcher a5)] ... [(researcher i1) ... (researcher i5)] ... ]`

The collaborator-networks are connected to each other, according to the choice in the interface: cycle (every network is connected to two other networs); wheel (every network is connected to two other networks and the royal network, which is connected to all other networks); or complete (every network is connected to every other network). These stuctures will be used when the representative researcher from one network communicates with representative researchers from other networks.

The social structures are saved in the global variable share-structure, which for the cycle has the form:

`[[[(researchers aa1) ... (researcher aa5)] ... [(researchers ac1) ... (researcher ac5)]] ... [[(researchers ia1) ... (researcher ia5)] ... [(researcher ic1) ... (researcher ic5)]] ... ]`

researchers have a memory in which they keep track of the following:

* _collaborator-network_: a list of at most four other researchers and itself that form the network it communicates with

* _subjective-relations_: a list of relations that an researcher knows of, an entry has three elements, the first is either an "a" (the relation is an attack) or an "d" (the relation is a discovery), the second is the argument from which the relation starts and the last element is the argument that is attacked/the child-argument:

`[["a" (argument attacking) (argument attacked)] ... ["d" (argument parent-argument) (argument child-argument)] ...]`

* _subjective-arguments_: a list of arguments that an researcher knows of, an entry has two elements: 1. the argument; 2. the color of the argument (this might be a color with higher value, less researched, than the current color, because it only remembers the color it saw/heard of):

`[[(argument a) colora] ... [(argument i) colori] ...]`

* _times-jumped_ and _theory-jump_: the first to keep track of how often researchers in general jump with a given strategy, the second to keep track of how often an researcher considers jumping

* _current-theory-info_: this list contains for each theory an entry that has the following elements, the second depending on the memory of the researcher: 1. the theory the entry belongs to; and 2. the number of admissible (not attacked) arguments:

`[[(start 0) ad0] [(start 2nd) ad2nd] ...]`

* _cur-best-th_: the current best theory according to the current memory of the researcher, this is updated every 5 time steps

* _th-args_ and th_relations_: lists of arguments and relations, that the researcher is prepared to share with researchers from other collaborative networks

* _to-add-mem-argu_ and _to-add-mem-rel_: lists of arguments and relations that the researcher has to add to its own memory as a result of communication

* _admissibile-subj-args_: the list of arguments from the subjective-arguments that are admissible (not attacked or attacked and defended)

* _neighborhood_: the neighboring arguments and relations of the argument it is currently working on

* _moved_: true if the researcher moved already in that time step

* _rep-researcher_ and _communicating_: if the researcher is in that communication round the representative researcher and how many time steps it takes this researcher to process all the new information it has obtained

## Basic behavior of researchers and the landscape

### Update of the memory

Every time step the researchers update their memory. The current argument is added to the list of subjective-arguments, then the relations are updated (including the subjective arguments that are discovered by these relations). The current argument, the relations to/from it and the arguments these relations connect belong to the neighborhood information of that argument and are saved in the memory of the researcher as "neighborargs".

Every five plus four time steps (4, 9, 14, ...), researchers share their memory with other researchers. First researchers share what they know within their own collaborator-network. In this network they share all information with everyone: after this round of sharing the researchers in the same network have the same memory.

After this, from every network one random researcher is chosen that will be the representative researcher of that network in communicating with other networks. These representative researchers create a list of arguments and a list of relations that they are prepared to share with other representative researchers. How this is done depends on the social behavior of the researchers (reliable or biased).

Then the representative researchers share the part of the memory they want to share with the researchers from the networks that neighbor their own in the network structure. The researchers collect all the new arguments and relations. At most 30 new entries are added to their memory and at most 10 entries per day.

The time step that the researchers share their information is already lost. Depending on how many new entries the value of the variable communicating is increased, with a maximum of three. For communicating time steps the researchers cannot do research: they do not move around and the landscape is not affected by their presence. Every fifth round (0, 5, 10, ...) all researchers do not communicate: every researcher can move around and affects the landscape.

After updating the memory and sharing information, the researcher removes all duplicate arguments from its memory. This also includes entries with arguments that were part of the memory but for which a new entry with better research color is found.

### researchers move around

Each time step researchers, that did not communicate with researchers from other networks and are not working on a not fully researched not-admissible argument, consider the arguments which they can work on next. Such an argument has to be a child-argument of the current argument, should be discovered, it should not be discovered by discovering an attack relation that involves the argument, it should not be red with another researcher already working on it and the discovery relation should be discovered as well.

The probability that an researcher moves to such a possible next argument depends on the color of the argument it is currently working on (but the color influences this probability only a little) and the time step. Every time step an researcher moves with a probability of 1/5 of the total move-probability to a next argument. Every 5th time step (5, 10, 15, ...) the researcher moves with the full move-probability that is set in the interface.

If an researcher is working on an argument that is fully researched, the color is red, it will try to move to a next argument, if that is not possible, it will move one step back (if no other researcher is working on that argument) and if that is not possible, it will move to a discovered, not fully researched and attacked argument in the same theory with no researcher working on it.

researchers, that did not communicate and are working on a not fully researched and not-admissible argument try to find a defense for their argument. This is done by staying on the current argument until it is red (then everything is discovered that can be discovered) or a defense from one of its child-arguments is discovered. Such a defense attack does not have to be discovered yet. If such a defending-child-argument exists, the researcher will move to this argument. researchers that move like this cannot move in the regular way that time step.

### Update of the landscape

The landscape is updated every five time steps (5, 10, 15, ...). A new child-argument becomes visible for arguments that are yellow, brown, orange or red and still have an undiscovered child-argument. With visibility-probability (depending a little bit, even less than with the move probability, on the color) attacks are discovered. First the in-attacks, then the out-attacks.

If researchers have been working for research-speed time steps on an argument, the argument changes color, if the argument was not yet fully researched. Discovery relations that connect two non-gray colored arguments (one may be turquoise, discovered by attack) are also discovered.

An argument that was fully researched in this time step (it turned red), discovers immediately all its relations: attacks and discoveries + the other ends.

## Strategies

### Computations for the strategies

After updating the memory of the researchers, researchers will reconsider working on the theory they are working on. How they do this depends on the strategy. The criterion on which they base this is the number of admissible arguments of the theory: the number of discovered, admissible arguments (they may be attacked, but then they are also defended).

Each researcher computes for its "current-theory-info" the number of admissible arguments, with respect to its current memory. Based on the information from the current-theory-info the best theory is calculated. The best theory can be unique, in that case there is no other theory that has a number of admissible arguments that is close enough to the number of admissible arguments of this best theory (close enough depends on the "strategy-threshold" in the interface).

### Acting on the strategy

Once the current best theory is computed, researchers will reconsider the theory they are working on. If that is not the current best theory, they consider to jump.

If researchers think often enough that they should jump to another theory, often enough depends on the "jump-threshold" of the interface, the researcher jumps to a/the current best theory and starts working on that theory. If the researcher is aware of an argument from that theory, it will jump to a random, argument of that theory in its memory, otherwise it will jump to the root.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Zollman-networks run" repetitions="1" runMetricsEveryStep="true">
    <go>run-many</go>
    <timeLimit steps="1"/>
    <enumeratedValueSet variable="network-structure">
      <value value="&quot;cycle&quot;"/>
      <value value="&quot;wheel&quot;"/>
      <value value="&quot;complete&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-actions">
      <value value="&quot;reliable&quot;"/>
      <value value="&quot;biased&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="within-theory">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
