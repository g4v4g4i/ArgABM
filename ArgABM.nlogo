; this file contains:
; 1. the definitions of the turtles, links
;    and variables;
; 2. it includes the other files; and
; 3. the procedures that correspond to
;    the buttons in the interface:
;    setup, go and reset





; three different kinds of turtles
; arguments and starts form the landscape
; agents are the scientists that explore the landscape
breed [arguments argument]
breed [starts start]
breed [agents agent]

; two different kinds of relations on the arguments
; a discovery relation and an attack relation
directed-link-breed [discoveries discovery]
directed-link-breed [attacks attack]

; the trees have to be connected in order to be visible
undirected-link-breed [starters starter]

; connections between agents are undirected
undirected-link-breed [collaborators collaborator]

; properties of the arguments, each argument "knows":
; the theory it belongs to, during the setup if it should
; be considered, how many ticks an agent was working on it
; and when it was fully researched (when it turned red)
; the roots also know how many agents are working on that theory
starts-own [mytheory current-start myscientists researcher-ticks full-research]
arguments-own [mytheory current-argument researcher-ticks full-research]

; every agent keeps track of how often it thinks
; that it should jump to another theory, the social network it belongs to,
; its current subjective landscape, the current best theory,
; if it received information at the current time
; the information in its neighborhood and whether it moved
agents-own [theory-jump collaborator-network
  subjective-arguments subjective-relations current-theory-info cur-best-th
  admissible-subj-argu th-args th-relations communicating neighborargs moved]

; the global variables are all concerned with the
; the initialization of hidden variables
globals [undirected-communication small-movement color-move]

; includes
__includes ["setup.nls" "behavior.nls" "strategies.nls"]





; the setup procedure:
; the hidden variables (not set in the interface) are initialized
; it creates a landscape of arguments and a discovery relation
; on this landscape; attacks are defined;
; the agents are distributed over the theories
to setup
  clear-all
  initialize-hidden-variables
  create-discovery-landscape
  define-attack-relation
  distribute-agents
  reset-ticks
end





; procedure that lets the program run, after the landscape was setup
; every five time steps agents update their memory and compute the
; best strategy
; agents always move around and update the landscape (with the probabilities
; as set in the interface)
to go
  ask agents [
    set communicating false
  ]
  update-memories
  duplicate-remover
  if ticks mod 5 = 4 [
    compute-strategies-agents
    act-on-strategy-agents
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
883
829
25
25
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
0
0
1
ticks
30.0

BUTTON
35
50
90
83
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
35
85
90
118
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
95
85
150
118
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
2
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
2
1
1
NIL
HORIZONTAL

SLIDER
10
170
182
203
scientists
scientists
5
100
10
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
140
165
158
Agent settings
13
0.0
1

SLIDER
10
210
182
243
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
250
182
283
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
290
182
323
research-speed
research-speed
0
50
5
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
10
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
540
205
690
Popularity
Time steps
No. of agents
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
"start 4" 1.0 0 -10899396 true "let all-theories []\nask starts [ set all-theories lput self all-theories ]\nset all-theories sort all-theories" "let all-theories []\nask starts [ set all-theories lput self all-theories ]\nset all-theories sort all-theories\nif length all-theories >= 4 [ \nplot [myscientists] of last all-theories\n]"

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
515
160
533
Plots
13
0.0
1

SWITCH
10
330
180
363
within-theory
within-theory
1
1
-1000

SLIDER
10
370
182
403
social-collaboration
social-collaboration
0
1
0.3
0.01
1
NIL
HORIZONTAL

CHOOSER
10
410
180
455
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

CHOOSER
10
460
180
505
sharing
sharing
"all" "neighborhood"
1

BUTTON
95
50
150
83
go-stop
 setup\n go\n while [any? arguments with [color != red and\n            [myscientists] of mytheory !=  0]][\n            go\n          ]
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
# UNDER CONSTRUCTION

Documentation of the program ArgABM for the paper _An argumentative agent-based model of
scientific inquiry_ by AnneMarie Borg, Daniel Frey, Dunja Šešelja and Christian Straßer

# 1. Motivation and Introduction

With this model we present an agent-based model (ABM) of scientific inquiry aimed at investigating how different social networks impact the efficiency of scientists in acquiring knowledge. As such, the ABM is a computational tool for tackling issues in the domain of scientific methodology and science policy. In contrast to existing ABMs of science, our model aims to represent the argumentative dynamics that underlies scientific practice. To this end we employ abstract argumentation theory as the core design feature of the model. This helps to avoid a number of problematic idealizations which are present in other ABMs of science and which impede their relevance for actual scientific practice.

## 1.1 Some assumptions and definitions

* _Discovered arguments_: an argument that is connected by a cyan discovery relation to the rest of the theory (the argument is not gray anymore nor turquoise).

* _Turquoise arguments_: arguments that are discovered by discovering an attack relation, but agents did not yet find the discovery relation that connects it to the other arguments in the theory.

* _Neighborhood_: the agent's direct neighborhood includes the argument the agent is currently working on and all arguments (and relations) that are discovered and connected to the current argument.

* _Admissibility_: an argument `a` is admissible (or defended) in a theory if each attacker `b` from another theory is itself attacked by some argument `c` in the current theory, the terms _admissibility_ and _defensibility_ are used interchangeably.

* _Root/start_: refers to the root of a theory.

* _rounds_ = _ticks_ = _time steps_ (these terms are used interchangeably).

* _Degree of exploration_: the level at which an argument is explored, gray arguments (level 0) are unknown to agents and red arguments (level 6) are fully explored. The levels in between are: lime (1); green (2); yellow (3); brown (4); and orange (5). A way to interpret this is to assume that each time step corresponds to one research day. Each of the 6 levels of an argument can be explored in _research-speed_ steps (per default: 5 steps), and hence each argument represents a hypothesis that needs per default 30 research days to be fully investigated. (cf. 2.4.3 "Update of the landscape").

### 1.1.1 Research week

The way the procedures are executed is repeated every five steps. That is why we speak of a _research week_, not all the code is executed in the same way every day of the week (all time steps). Every day of the week each agent updates its memory, by adjusting her memory about the arguments and relations in her neighborhood that might have changed. Then:

0 On Mondays agents are completely devoted to moving further in their research. The chance that the move to a next argument and that new attack relations are discovered are the full probabilities from the interface.

1-3 On Tuesday - Thursday, the move probability is only a part of the full probability (this depends on the hidden variable _small-movement_).

4 On Fridays the agents communicate with agents from their own network and possibly with agents from other networks. Then they evaluate the theory they are currently working on. If this theory was not among the best theories for some weeks, they change the theory they are working on. Agents that have received information from agents outside their own network cannot do research in this round. The other agents do research as described in 1-3.

# 2. The Program

## 2.1 Interface

Buttons

* _setup_: creates the landscape, including attacks and distributes the scientists/agents over this landscape

* _go_: lets the program run one time step

* _go (infinite, has a small circle)_: lets the program run infinitely many steps, or until the button is clicked again

* _go-stop_: lets the program run until all agents are working on a fully researched theory

Landscape settings (cf. 2.3 "Setup of the landscape")

* _number-of-theories_: sets the number of theories/trees that will be created

* _theory-depth_: sets the depth of the trees, the number of arguments from root to a leave, without the root itself

* _attack-probability-best_: the probability that an argument of the objective best theory has an incoming attack

* _attack-probability-2nd_: the probability that an argument of the 2nd theory has an incoming attack, before the best theory defends itself

* _attack-probability-3rd_: if there are three theories, the probability that an argument of the 3rd theory has an incoming attack, before the best theory defends itself

Strategy settings (cf. 2.5 "Strategies")

* _strategy-threshold_: defines the interval within which the number of admissible arguments is still considered good, if this threshold gets higher, the interval of acceptable values gets smaller

* _jump-threshold_: is the number of times an agent has to consider jumping before she really jumps to another theory

Agent settings

* _scientists_: the number of agents that will explore the landscape

* _move-probability_: the probability that agents move to a next argument while exploring the landscape (cf. 2.4.2 "Agents move around")

* _visibility-probability_: the probability that new attacks are discovered by agents (cf. 2.4.3 "Update of the landscape")

* _research-speed_: the time an agent has to work on an argument before it will change color (cf. 2.4.3 "Update of the landscape")

* _within-theory_: here the kind of collaborative network is set to agents that start on the same theory (on) or randomly chosen agents (off) (cf. 2.3.3 "Agents")

* _social-collaboration_: the probability that an agent communicates with an agent from a network outside her own (cf. 2.4.1 "Update of the memory")

* _social-actions_: setting how agents communicate with agents outside their own network:
	* "reliable" is the setting where they share specific information about the current theory: including attacks; and
	* "biased" agents do not share the attacks to their current theory (cf. 2.4.1 "Update of the memory")

* _sharing_: makes it possible to choose what the agents share with agents from other networks: either their whole memory ("all") or only the information in their direct "neighborhood" (cf. 2.4.1 "Update of the memory")

Plots

* the _Popularity_ plot shows for every theory the number of agents working on it, the red line is that of the objective best theory, the other theories are plotted as orange and yellow (if there is a third theory)

### 2.1.1 Hidden variables

There are three variables that cannot be set in the interface, but are defined as global variables and set in the procedure `initialize-hidden-variables`. These variables are:

* _undirected-communication_: the chance that the communication with an agent from another collaborative network is bidirectional, by default 0.5, i.e. the change of that the communication is unidirectional is 1-_undirected-communication_ (cf. 2.4.1 "Update of the memory");

* _small-movement_: the multiplier of the `move-probability` from the interface that is the probability that agents move every round except the 0 rounds (0, 5, 10, ...), by default 0.2 (cf. 2.4.2 "Agents move around"); and

* _color-movement_: the multiplier of the `move-probability` from the interface that determines the influence the color has on the chance that agents move to a next arguments, by default 0.5% (value 200) (cf. "Agents move around").

## 2.2 Setup of the landscape

At the beginning of a run a landscape is created. Trees of arguments (the theories) are built, attack relations on the arguments are defined and the agents are created and distributed over the theories.

### 2.2.1 Building the objective discovery landscape

For each theory a tree is built, its root is called `start`. The depth of the theory, as can be chosen in the interface, sets the number of arguments: `theory-depth` = x means x layers of arguments. The root has 4 child-arguments, after that, if a next layer exists, each argument has also 4 child-arguments, otherwise 0. Each of these child-arguments is connected by a directed discovery relation.

Each argument has a memory for:

* the theory it belongs to (`(start x)`);
* _researcher-ticks_: the number of times the argument has been visited/researched by an agent (cf. 2.4.3 "Update of the landscape"); and
* whether it was just fully researched (turned red in the current round) (`true` or `false`).

### 2.2.2 Defining the attack relation

On the created landscape an attack relation is added. Each argument has, with `attack-probability` corresponding to the theory the argument belongs to, an incoming attack from an argument belonging to another theory. Once the random attacks are created, the best theory (`(start 0)`), has to make sure that it is fully defended. It creates attacks to arguments that attack one of its arguments, until it has defended all its attacked arguments.

### 2.2.3 Agents

Agents are randomly distributed over the available roots of the theories. Then they form `collaborator-networks`. If the switch `within-theory` is on in the interface, such networks are created with agents that start on the same theory, if the switch is off networks are randomly created. Such networks have at most 5 agents. In case the networks are random all networks have exactly 5 agents, if the networks are created within theories there can be networks with less than 5 agents.

Agents have a memory in which they keep track of the following:

* `collaborator-network`: a list of at most four other agents and herself that form the network she communicates with:

`[(agent a) ... (agent i)]`;

* `subjective-relations`: a list of relations that an agent knows of, an entry has three elements, the first is either an "a" (the relation is an attack) or a "d" (the relation is a discovery), the second is the argument from which the relation starts and the last element is the argument that is attacked/the child-argument:

`[["a" (argument attacking) (argument attacked)] ... ["d" (argument parent-argument) (argument child-argument)] ...]`;

* `subjective-arguments`: a list of arguments that an agent knows of, an entry has two elements: 1. the argument; 2. the color of the argument (this can be a color representing a lower degree of exploration than the one in the current objective landscape, depending on the agent's subjective memory of the given argument):

`[[(argument a) colora] ... [(argument i) colori] ...]`;

* `theory-jump` (a number): stands for how often an agent has considered jumping since the last jump (cf. 2.5.2 "Acting on the evaluation");

* `current-theory-info`: this list contains for each theory an entry that has the following elements: 1. the theory the entry belongs to (`(start x)`); and 2. the number of admissible (not attacked) arguments, depending on the memory of the agent;

`[[(start 0) ad0] [(start 2nd) ad2nd] ...]`;

* `cur-best-th`: a list with the current best theories according to the current memory of the agent, this is updated every 5 time steps (cf. 2.5.1 Computations for the evaluation):

`[(start i1) ... (start ij)]`;

* `th-args`: a sublist of the _subjective-arguments_ the agent is prepared to share with agents from other collaborative networks:

`[[(argument 1) color1] ... [(argument i) colori]]`;

* `th_relations`: a list of relations the agent is prepared to share with agents from other collaborative networks:

`[["d" (argument a1) (argument a2)] ... ["a" (argument i1) (argument i2)] ...]`; and

* `admissibile-subj-args`: the list of arguments from the `subjective-arguments` that are admissible (not attacked or attacked and defended) (cf. 2.5.1 Computations for the evaluation):

`[(argument a) ... (argument k)]`.

## 2.3 Basic behavior of agents and the landscape

After the landscape is setup the run starts. Agents start exploring the landscape, new arguments and relations are found and agents can move to visible arguments in the landscape. Every five rounds agents communicate with agents from their own collaborative network and possibly with agents from outside their network.

### 2.3.1 Update of the memory

Every time step the agents update their memory. The current argument (i.e. the one which the agent currently explores) is added to the list of `subjective-arguments`, then the relations are updated (including the subjective arguments that are discovered by these relations). The current argument, the relations to/from it and the arguments these relations connect belong to the neighborhood information of that argument and are saved in the memory of the agent as `neighborargs`.

Every five plus four time steps (4, 9, 14, ...), once the agents have an updated memory they create a list of arguments and a list of relations that they are prepared to share with agents from other networks (`th-args` and `th-relations`). How this is done depends on the _social-actions_ of the agents (`reliable` or `biased`) and whether they share `all` or just the information from their current `neighborhood` (i.e. the `neighborargs`) (cf. 2.1 "Interface" and 2.2 "Some assumptions and definitions").

First agents share what they know within their own `collaborator-network`. In this network they share all information with everyone: after this round of sharing the agents in the same network have the same memory. Then, with probability `social-collaboration` from the interface, each agent shares information with an agent from another network. With a chance of `undirected-communication` -one of the "hidden variables"- this is done directed: the agent only provides information, as by writing a paper. Otherwise, the two agents share information bidirectionally, just like they would in a discussion.

Agents that receive information from an agent in another network cannot do research in the same time step (i.e. information sharing is time costly). This means that they do not move around or contribute towards the changing of the color of the argument. Only if the exchange is bidirectional, the current agent will not do research. For these agents `communicating` is set to `true`. The section 2.4.2 "Agents move around" does not apply to the `communicating` agents.

After updating the memory and sharing information, the agent removes all duplicate arguments from her memory. For each argument only the entry representing the highest level of exploration is kept.

### 2.3.2 Agents move around

Each time step agents, with `communicating` = `false` and that are not working on a not fully researched not-admissible argument, consider the arguments which they can work on next. Such an argument:

* has to be a child-argument of the current argument;
* must be a discovered argument (cf. 2.2 "Some assumptions and definitions");
* it must not be red ; and
* there must not be another agent from the same collaborative network working on it at that moment.

The probability that an agent moves to such a possible next argument depends on the color of the argument she is currently working on and the time step. How much the color influences the probability depends on the value of `color-move`, one of the "hidden variables", the probability that an agent moves to the next argument is defined as:

`move-probability * (1 - (color / color-move))`.

Every time step an agent moves with a probability of `small-movement` (a "hidden variable") of the total `move-probability` to a next argument. Every 5th time step (5, 10, 15, ...) the agent moves with the full `move-probability` that is set in the interface.

If an agent is working on an argument that is fully researched, the color is red, she will try to move to a next argument. If that is not possible, she will move one step back (if no other agent from the same network is working on that argument) and if that is not possible, she will move to a discovered and not fully researched argument in the same theory with no agent from the same network working on it.

Agents, that did not communicate and are working on a not fully researched and not-admissible argument try to find a defense for their argument. This is done by staying on the current argument until it is red (then everything is discovered that can be discovered) or a defense from one of its child-arguments is discovered. Such a defense attack does not have to be discovered yet. If such a defending-child-argument exists, the agent will move to this argument. Agents that move like this cannot move in the regular way that time step.

### 2.3.3 Update of the landscape

If agents have been working for `research-speed` time steps on an argument, the argument changes color, if the argument was not yet fully researched (not red). A new child-argument (if there is one) becomes visible for arguments that have just turned yellow, brown, orange or red.

The landscape is updated every five time steps (5, 10, 15, ...). If there are attack relations that are not discovered yet, agents can find these. With `visibility-probability` attacks (in or out) are found.

Discovery relations that connect two discovered (not gray nor turquoise) arguments are also discovered. An argument that was fully researched in this time step (it has turned red), immediately reveals all its relations: attacks and discoveries + the arguments connected by these relations.

## 2.4 Strategies

Agents do not always keep working on the same theory. When their memory suggest that another theory is better, they will consider jumping to that theory. What it means for a theory to be better depends on the evaluation procedure.

### 2.4.1 Computations for the evaluation

Every 5th plus 4 time steps (4, 9, 14, ...), agents updat their memories and share information with agents in (and possibly outside) their own network. Then they perform an evaluative procedure, which determines the number of admissible arguments of each theory, according to the agent's subjective memory.

Each agent computes for her `current-theory-info` the number of admissible arguments, with respect to her current memory. This is done in a recursive manner, in which everytime not defended attacked arguments are added to the not-admissible list of arguments. The `current-theory-info` is updated with for each theory the number of admissible arguments (either not attacked or defended arguments).

Based on the information from the updated `current-theory-info` the best theory is calculated. The best theory is the theory with the highest number of admissible arguments. At the moment this is absolute: the total number of discovered arguments in that theory does not influence this. Other theories can qualify as one of the best theories as well. This is the case if `strategy-threshold` * (number of admissible arguments of best theory) <= (number of admissible arguments of this theory). The best theory can also be unique, in that case there is no other theory that has a number of admissible arguments that is close enough to the number of admissible arguments of this best theory.

### 2.4.2 Acting on the evaluation

Once the current best theories are computed, agents will reconsider the theory they are working on. If that is not one of the current best theories, they consider to jump.

If an agents evaluation results often enough in a list of current best theories without the theory she is currently working on, often enough depends on the `jump-threshold` the agent jumps to a current best theory and starts working on that theory. If the agent is aware of an argument from that theory, she will jump to a random, argument of that theory in her memory, otherwise she will jump to the root.
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

cat
false
0
Line -7500403 true 285 240 210 240
Line -7500403 true 195 300 165 255
Line -7500403 true 15 240 90 240
Line -7500403 true 285 285 195 240
Line -7500403 true 105 300 135 255
Line -16777216 false 150 270 150 285
Line -16777216 false 15 75 15 120
Polygon -7500403 true true 300 15 285 30 255 30 225 75 195 60 255 15
Polygon -7500403 true true 285 135 210 135 180 150 180 45 285 90
Polygon -7500403 true true 120 45 120 210 180 210 180 45
Polygon -7500403 true true 180 195 165 300 240 285 255 225 285 195
Polygon -7500403 true true 180 225 195 285 165 300 150 300 150 255 165 225
Polygon -7500403 true true 195 195 195 165 225 150 255 135 285 135 285 195
Polygon -7500403 true true 15 135 90 135 120 150 120 45 15 90
Polygon -7500403 true true 120 195 135 300 60 285 45 225 15 195
Polygon -7500403 true true 120 225 105 285 135 300 150 300 150 255 135 225
Polygon -7500403 true true 105 195 105 165 75 150 45 135 15 135 15 195
Polygon -7500403 true true 285 120 270 90 285 15 300 15
Line -7500403 true 15 285 105 240
Polygon -7500403 true true 15 120 30 90 15 15 0 15
Polygon -7500403 true true 0 15 15 30 45 30 75 75 105 60 45 15
Line -16777216 false 164 262 209 262
Line -16777216 false 223 231 208 261
Line -16777216 false 136 262 91 262
Line -16777216 false 77 231 92 261

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

exclamation
false
0
Circle -7500403 true true 103 198 95
Polygon -7500403 true true 135 180 165 180 210 30 180 0 120 0 90 30

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
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <go>run-many</go>
    <timeLimit steps="1"/>
    <enumeratedValueSet variable="within-theory">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-actions">
      <value value="&quot;kind&quot;"/>
      <value value="&quot;biased&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-collaboration">
      <value value="0"/>
      <value value="0.3"/>
      <value value="0.5"/>
      <value value="1"/>
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
