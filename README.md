# PLEASE NOTE: this documentation is work in progress!

# ArgABM
An agent-based model for scientific inquiry based on abstract argumentation.

## Published papers based on this model

_Epistemic effects of scientific interaction: approaching the question with an argumentative agent-based model_
In: HSR Vol. 43, No. 1: Special Issue: _Agent-Based Modeling in Social Science, History, and Philosophy_, 2018, pp. 285-307, [[doi:
10.12759/hsr.43.2018.1.285-307][https://dx.doi.org/10.12759/hsr.43.2018.1.285-307]]

The question whether increased interaction among scientists is beneficial or harmful for their efficiency in acquiring knowledge has in recent years been tackled by means of agent-based models (ABMs) (e.g. Zollman 2007, 2010; Grim 2009; Grim et al. 2013). Nevertheless, the relevance of some of these results for actual scientific practice has been questioned in view of specific parameter choices used in the simulations (Rosenstock et al. 2016). In this paper we present a novel ABM that aims at tackling the same question, while representing scientific interaction in terms of argumentative exchange. In this way we examine the robustness of previously obtained results under different modeling choices.

_Examining Network Effects in an Argumentative Agent-Based Model of Scientific Inquiry_ 
In: Baltag, A., Seligman, J., Yamada, T. (eds) _Logic, Rationality, and Interaction, LORI 2017 (Lecture Notes in Computer Science, Vol. 10455)_, 2017, pp. 391-406, [[doi: 10.1007/978-3-662-55665-8 27][http://dx.doi.org/10.1007/978-3-662-55665-8_27]]

In this paper we present an agent-based model (ABM) of scientific inquiry aimed at investigating how different social networks
impact the efficiency of scientists in acquiring knowledge. The model is an improved variant of our previous ABM, which is based on
abstract argumentation frameworks. The current model employs a more refined notion of social networks and a more realistic representation of knowledge acquisition than the previous variant. Moreover, it includes two criteria of success: a monist and a pluralist one, reflecting different desiderata of scientific inquiry. Our findings suggest that, given a reasonable ratio between research time and time spent on communication, increasing the degree of connectedness of the social network tends to improve the efficiency of scientists

_An Argumentative Agent-Based Model of Scientific Inquiry_
In: Benferhat, S., Tabia, K., Ali, M. (eds) _Advances in Artificial Intelligence: From Theory to Practice, IEA/AIE 2017 (Lecture Notes in Computer Science, Vol. 10350)_, 2017, pp. 507-510, [[doi: 10.1007/978-3-319-60042-0 56][http://dx.doi.org/10.1007/978-3-319-60042-0_56]

In this paper we present an agent-based model (ABM) of scientific inquiry aimed at investigating how different social networks impact the efficiency of scientists in acquiring knowledge. As such, the ABM is a computational tool for tackling issues in the domain of scientific methodology and science policy. In contrast to existing ABMs of science, our model aims to represent the argumentative dynamics that underlies scientific practice. To this end we employ abstract argumentation theory as the core design feature of the model.

## Collaborators and funding

AnneMarie Borg (Institute for Philosophy II, Ruhr-University Bochum)
Daniel Frey (Faculty of Economics and Social Sciences, Heidelberg University)
Dunja Šešelja (Munich Center for Mathematical Philosophy, LMU Munich)
Christian Straßer (Institute for Philosophy II, Ruhr-University Bochum)


The research by AnneMarie Borg and Christian Straßer is supported by a Sofja Kovalevskaja award of the Alexander von Humboldt Foundation and by the German Ministry for Education and Research.

# Documentation

## Interface

### Buttons

#### setup
Creates the landscape, including attacks and distributes the scientists/researchers over this landscape

#### go
Lets the program run one time step

#### go (infinite, has a small circle)
Lets the program run infinitely many steps, or until the button is clicked again

#### go-stop (infinite, has a small circle)
Lets the program run until the `exit-condition` is met or until the button is clicked again

### Landscape settings

#### number-of-theories

* type: slider

Sets the number of theories/trees that will be created

#### theory-depth

* type: slider

Sets the depth of the tree

#### defense-from-leaves

* type: switch

If turned on: creates a more difficult landscape in which the best theory is largely defended by the leaves-arguments

#### attack-probability-best

* type: slider

The probability that an argument of the objective best theory has an incoming attack

#### attack-probability-2nd

* type: slider

The probability that an argument of the 2nd theory has an incoming attack

#### attack-probability-3rd

* type: slider

If there are three theories, the probability that an argument of the 3rd theory has an incoming attack

### Strategy settings

#### strategy-threshold

* type: slider

Defines the threshold within which the number of admissible arguments is still considered good, if this threshold gets higher, the interval of acceptable values gets smaller

#### jump-threshold

* type: slider

Is the number of times a researcher has to consider jumping before she really jumps to another theory

#### heuristic-non-block

* type: switch

If turned on: researchers working on an argument which is not admissible according to their evaluation, don't have to work on that argument until it is fully explored (=red) but can instead move on in the same way as if working on any other argument

#### evaluation

* type: chooser

The evaluation criterion researchers apply when determining the score they assign to theory x (always according to their subjective memory). The four options are:

* "defended-args": score = number of defended arguments in theory x. Higher score = better. 

* "non-defended-args": score = number of non-defended arguments in theory x. Lower score = better.

* "non-defended-normalized": score = number of non-defended arguments in theory x / number of all arguments in theory x. Lower score = better.

* "non-defended-multiplied": score = number of non-defended arguments in theory x * number of all arguments in theory x. Lower score = better.

### Researcher settings

#### collaborative-groups

* type: slider

The number of groups (teams of researchers) that will explore the landscape. 

#### col-group-size

* type: slider

Each group (team of researchers) consists of this many researchers

#### move-probability

* type: slider

The probability that researchers move to a next argument while exploring the landscape

#### visibility-probability

* type: slider

The probability that new attacks are discovered by researchers

#### research-speed

* type: slider

The time an researcher has to work on an argument before it will change color

#### within-theory

* type: switch

Here the kind of collaborative network is set to researchers that start on the same theory (on) or randomly chosen researchers (off)

#### social-actions

* type: chooser

Here the behavior of the researchers that communicate with researchers outside their own can be set: "reliable" is the setting where they share all information about the current theory: including attacks; "biased" researchers do not share the attacks to their current theory

#### network-structure

* type: chooser

Determines the structure in which the collaborator-networks are connected and with how many researchers information is shared

#### knowledge-tracking 

* type: switch

If turned on: during the run information on the current state of beliefs and knowledge is collected every time researchers update their beliefs. When a run ends this information is written to an external csv file. **Warning:** This data will get corrupted if multiple instances of this model with knowledge-tracking turned on are run in parallel (e.g. via BehaviorSpace). Therefore only use single threaded runs when collecting data via knowledge-tracking!

#### necessary-convergence 

* type: switch

If turned on: the run will only end once all researchers converged on the best theory and at least one theory is fully explored (=red). Researchers also don't perform a final evaluation with the possibility to switch theories once a theory turns red or the run ends. If at least one theory is fully explored in the objective landscape the way how agents learn information changes: 

* if some researchers are working on not fully explored theories (`g-exit-case` 1) those researchers share information as usual and rep-researchers on red theories share as if they were standing on an random argument of their theory

* if all researchers are on red theories (`g-exit-case` 2) they all learn once a month (= every 30 ticks) a random bit of information regarding the objective landscape (cf. `learn-random-item`).

#### controlled-spread-of-researchers

* type: switch

If turned on: a number of researchers, determined by the slider _col-groups-on-best-t_, is placed on the best theory (these researchers are pink); the remainder of researchers is distributed randomly on the remaining theories (these researchers are blue). This is meant to be used only in conjunction with homogeneous groups (i.e. `within-theory` = true).

### Plots

#### Popularity
The _popularity_ plot shows for every theory the number of researchers working on it

#### Current avg. com. costs
The _Current avg. com. costs_ plot shows the average communication costs from the most recent inter-group sharing in days per researcher


## Some language definitions

### Discovered arguments
An argument that is not gray anymore nor turquoise (discovered by discovering an attack relation)

### (Not) fully researched arguments
The level at which an argument is explored, a fully researched argument will be red

### Root/start
Refers to the root of a theory

### Fully explored theory
A theory that has all its argument explored to the maximal degree (i.e. red) in the objective landscape

### [attack] belonging [to theory x]
An attack belongs to two theories: the theory the attack is attacking from (`mytheory-end1`) and the theory it attacks (`mytheory-end2`)

### Admissibility and degree of defensibility

#### Admissible sets
A subset of arguments A of a given theory T is _admissible_ iff for each attacker b of some a in A there is an a' in A that attacks b (a' is said to defend a from the attack by b).

#### Defended argument
An argument a in T is said to be _defended in T_ iff it is a member of an admissible subset of T.

#### The degree of defensibility of T
– equal to the number of defended arguments in T.

## Variables

Below a short description of the variables used in ArgABM.

### Globals

#### startsargum
* format: turtle-set
* example: (agentset, 255 turtles)

This variable will contain all the arguments including all starts.

#### disc-startsargum-non-red
* format: turtle-set
* example: (agentset, 50 turtles)

This variable contains all those those arguments including starts (=startsargum) which are non red and properly discovered (i.e. non gray and non turquoise) at the current time.

#### rel-costfactor
* format: float
* default value: 70

This is a hidden variable which determines how costly it is to learn relations via inter-group communication cf. _initialize-hidden-variables_

#### rep-researchers
* format: turtle-set
* example: (agentset, 13 turtles)

This variable will contain all the actual representative researchers (i.e. those who share information during the inter-group sharing). It is set during the `create-share-memory` procedure.

#### rndseed
* format: integer
* example: -2147452934

Stores the random-seed of the current run.

#### g-cum-com-costs 
* format: integer
* example: 211770

The sum of all communication cost that accrued during the run.

#### g-max-com-costs
* format: integer-list
* example: [13459 74]

First entry: amount of communication costs that accrued in the round which had the highest communication costs. 
Second entry: the number of the round where the highest communication costs accrued.

#### g-unpaid-com-costs
* format: integer
* example: 0

The cumulative communication costs which couldn’t be paid by the researchers. This value should usually be zero, and serves more as a check which signals to us that our max-learn value is too low for the chosen parameters.

#### g-cur-avg-com-costs
* format: float
* example: 1.1394

Average communication costs from the most recent inter-group sharing in days per researcher.

#### round-converged
* format: integer
* example: 124

The last round in which researchers converged. If they did not converge, the value will be `-1`.

#### last-converged-th
* format: turtle
* example: (start 0)

The theory the researchers converged on, the last time they converged. If they did not converge, the value will be `-1`.

#### g-knowledge
* format: nested list
* example: [[5 0 1 0 1 2] [5 0 2 1 1 1] [5 1 1 0 0 0] [5 1 2 1 1 2]]

Collects information on the state of beliefs and knowledge every time researchers update their beliefs. Each entry is a list containing: round in which the data was recorded, group-id of the recording group (group-y), theory-x (theory for which the data-point is recorded) , number of defended arguments theory-x has at this point according to group-y's evaluation, number of arguments from th-x which group-y knows at this point , number of arguments from th-x weighted by color (1 = turquoise - 7 = red) which group-y knows at this point.

#### g-max-ticks
* format: integer
* default: 500000

This is a hidden variable which determines the time-limit for the runs i.e. how many ticks a run can maximally last before being forced to stop.

#### g-exit-condition?

* format: boolean
* example: false

If the `exit-condition` reporter is evaluated the variable will be set to `true` in case the the exit-condition is met, `false` otherwise. Positive evaluation of the exit-condition marks the end of a run.

#### g-red-theories

* format: turtle-set
* example: (agentset, 2 turtles)

The set of theories (= starts) which are fully explored in the objective landscape (i.e. consist only of red arguments).

#### g-exit-case

* format: integer
* example: 0

The state of the current run in case `necessary-convergence` is selected in the interface. The possible states are the following:

* 0: no theory in the objective landscape is fully explored (= red).
* 1: there is at least one fully explored theory but not all researchers are working on fully explored theories
* 2: there is at least one fully explored theory and all researchers are working on fully explored theories

#### g-learn-set

* format: list
* example: [(start 0) (argument 1) (argument 2) (attack 246 3)]

The list from which researchers learn random items in case that `necessary-convergence` is selected in the interface and all researchers are converged on fully explored theories (g-exit-case = 2). This list contains all arguments from and attacks from- and to `g-learn-set-theories`.

#### g-learn-set-theories

* format: turtle-set
* example: (agentset, 2 turtles)

The theories (= starts) about which agents slowly learn during `g-exit-case` 2. These theories are: theory 1 (= start 0) and any theory which is not fully explored in the objective landscape.

#### g-learn-frequency

* format: integer
* default: 30

This is a hidden variable which determines how frequently researchers learn some random information about the landscape during `g-exit-case` 2. By default every 30 rounds (= once a month) researchers might learn some item from `g-learn-set`.

#### g-exit-case-start

* format: nested list
* example: [[9930] [276 9980]]

Protocols the rounds in which the particular exit-case started. The first list is for exit-case 1 the 2nd for exit-case 2. See `g-exit-case-duration` below for more details.

#### g-exit-case-duration

* format: nested list
* example: [[50] [9654 1030]]

Protocols for how long the particular exit-case lasted. The first list is for exit-case 1 the 2nd for exit-case 2. In the example here (using the `g-exit-case-start` data from above), the run went through one period of exit-case 1 and two periods of exit-case 2 in the following way: 

* round 1 - 276: exit-case 0
* round 276 - 9930 exit-case 2
* round 9930 - 9980: exit-case 1
* round 9980 - 11010: exit-case 2

#### g-comp-pop-counter

* format: integer
* example: 218

Protocols how often `compute-popularity` was run. This information is important for procedures which use the start owned `research-time-x` tracking like the `in-run-performance` reporter, because this variable is advanced/updated during compute-popularity.

#### g-active-colla-networks

* format: nested list
* example: [[(researcher 257) (researcher 258)] [(researcher 255) (researcher 256)]]

Each entry in the list contains one group. In the above example there are two groups each consisting of two researchers. This is the same list as `colla-networks` but it only contains those groups which need to run `compute-subjective-attacked` because they received new information since running it the last time. This list is not guaranteed to be minimal (there can be groups in the list which did not receive new information). The purpose of this list is to reduce computational load in long phases of scarce information during `exit-case` 2.

#### g-static-phase

* format: integer
* example: 2

This is a variable indicating the world state in order to reduce computational effort. The variable can take the following values:

* **0**: in case of `g-exit-case` 0 or 1
* **1**: in case of `g-exit-case` 2 and `compute-subjective-attacked` run only once since switching from g-static-phase 0
* **2**: in case of `g-exit-case` 2 and researchers receiving a random item via `learn-random-item` for which they have not yet run `compute-subjective-attacked`
* **3**: in case of `g-exit-case` 2 and researchers not having received any new information since they ran `compute-subjective-attacked` the last time

#### g-convergence-start

* format: list
* example [10 150]

Protocols the rounds in which each convergence episode (= all researchers on one theory) started. See `g-convergence-duration` below for more details.

#### g-convergence-duration

* format: list
* example: [5 20]

Protocols for how long the convergence episodes (= all researchers continuously on the same theory) were lasting. In the example here (using the `g-convergence-start` data from above) there were two episodes of convergence: 

* round 10 - 15: all scientists are converged on one theory
* round 150 - 170: all scientists are converged on one theory

The rest of the time researchers were spread among more than one theory i.e. diversity was maintained.


### Researchers-own

#### flag-updated-memory
* format: boolean
* initialization value: false

This is a flag which researchers will set when they refresh their memory during the `update-memories` procedure. It will be reset when the landscape is updated later this round. This is used to reduce redundant calls of the `update-memories` procedure.

#### non-admiss-subj-argu
* format: turtle-set
* example: (agentset, 10 turtles)

Will contain all the arguments which are not admissible according to the researchers subjective memory.

#### mygps
* format: turtle
* example: (argument 55)

Contains the argument the researcher is currently working on i.e. the argument at her position in the landscape.

#### group-id
* format: integer
* example: 0

Contains the number of the group this researcher belongs to. This number is equal to her groups position in the `colla-networks` list.

#### argu-cache
* format: turtle-set
* example: (agentset, 10 turtles)

Contains the arguments the researcher has learned via inter-group communication(i.e. `share-with-other-networks`) and is currently digesting. This information will be consolidated into her memory one week later during the `share-with-group` procedure.

#### to-add-mem-argu
* format: turtle-set
* example: (agentset, 3 turtles)

Contains the arguments a researcher learned via the `update-memories` procedure, i.e. arguments she learned by conducting her research. This information is will be synchronized every week with her group during the `share-with-group` procedure. The status (=color) of the arguments is saved seperately in the argument-owned variable `group-color-mem`.

#### to-add-mem-rel
* format: link-set
* example: (agentset, 2 links)

Contains the relations (= attacks) a researcher learned via the `update-memories` procedure - i.e. relations she learned by conducting her research - or via inter-group communication during `share-with-other-networks`. This information is will be synchronized every week with her group during the `share-with-group` procedure.

#### th-args
* format: turtle-set
* example: (agentset, 3 turtles)

Contains the arguments which the rep-researcher from every group will share with rep-researchers from other groups during the inter-group-sharing phase (= `share-with-other-networks`). Those arguments are the one the researcher is currently working on (cf. mygps) as well as all the arguments which are directly connected to her current argument by a non-gray (i.e. discovered) link: a discovery or an attack (in any direction for reliable-researchers and outgoing-only for biased-researchers).


#### th-relations
* format: link-set
* example: (agentset, 1 link)

Contains all the relations (= attacks) the rep-researcher from every group will share with rep-researchers from other groups during the inter-group-sharing phase (= `share-with-other-networks`). In case of "reliable" social-actions the attacks are all non-gray attacks **to- and from** the argument the researcher is currently working on (cf. mygps), while in the case of "biased" social-actions this will only be the outgoing non-gray attacks **from** her current argument.

#### subjective-arguments
* format: turtle-set
* example: (agentset, 55 turtles)

Contains all arguments the researcher knows.

#### subjective-relations
* format: link-set
* example: (agentset, 27 links)

Contains all attacks the researcher knows.

#### on-red-theory?
* format: boolean
* example: false

This variable is true if the researcher is working on a theory which is fully explored (=red) and false otherwise.

### Arguments-own, Starts-own

#### group-color-mem
* format: list
* example: [85 85 65 15]

Contains the status in which group-i knows the argument in. 85 (= cyan) corresponds to the group not knowing the argument at all. The position of the entry corresponds to the position of the group in the `colla-networks` list (= `group-id` cf. above). In this example group 0 and group 1 wouldn't know the argument while group 2 knows it as lime and group 3 as red.

#### group-color-mem-cache
* format: list
* example: [85 85 65 15]

This is the same format as `group-color-mem`. It is used to cache information which researchers learned via inter-group communication and are currently digesting. This information will be consolidated into `group-color-mem` one week later during the `share-with-group` procedure.

### Additionally Starts-own

#### research-time-monist
* format: integer
* example: 3200

This is the amount of time researchers spent so far on this theory. Every tick during the `compute-popularity` procedure the starts check for the number of researchers on their theory and increase their `research-time-monist` value by this number (i.e. this is a time integral over `myscientists`).

#### research-time-pluralist
* format: float
* example: 2000.51

This is how long and by how many researchers the theory has been considered to be among the best theories (i.e. it is a time integral over `myscientists-pluralists`). Each tick this theory is considered to be best by a particular researcher this counter will increase by one. If there is more than one best theory in the memory of a particular researcher the start will add 1 / (number of best theories) to this counter for this researcher. This is done by the `compute-popularity` procedure.

#### myscientists-pluralist
* format: float
* example: 74.5 

How many researchers currently consider this theory to be a best theory. If there is more than one best theory in the memory of a particular researcher the start will count this researcher as adding 1 / (number of best theories) to its `myscientists-pluralist` counter. This is done by the `compute-popularity` procedure.

#### objective-admissibility
* format: integer
* example: 85

This is how many admissible arguments this theory has. The best theory always has full admissibility which corresponds e.g. in the case of theory-depth 3 to a number of 85. This is calculated at the beginning of the run during the setup.

#### initial-scientists
* format: integer
* example: 25

Records the number of scientists on each start at the beginning of the run.


### Attacks-own

#### mytheory-end1
* format: turtle
* example: (start 0)

This is the mytheory value of end1 of the attack relation i.e. the theory this attack is attacking from.

#### mytheory-end2
* format: turtle
* example: (start 85)

This is the mytheory value of end2 of the attack relation i.e. the theory which will be attacked by this attack.

#### uncontested
* format: boolean
* initialization value: true

Tracks whether this attack relations startargument (end1) has a discovered (= red) attack from the theory this attack is attacking incoming. If this is not the case the attack is uncontested and is guaranteed to be successful. This value is updated during the `update-landscape` procedure and used during the `compute-subjective-attacked` procedure.


#### in-group-i-memory
* format: list of booleans
* example: [true true false]

As with `group-color-mem` this contains the status in which group-i knows argument i.e. if they know it (= true) or not (= false). The position of the entry corresponds to the position of the group in the `colla-networks` list (= `group-id` cf. above). In this example group 0 and group 1 wouldn't know the attack while group 2 knows it.

#### processed?
* format: boolean
* initialization-value: false

This is a helper variable utilized during the `compute-subjective-attacked` procedure. It will mark whether a certain attack has already been processed during the calculations. For details cf. the procedure itself.

## Setup of the landscape

### _initialize-hidden-variables_

Procedure in which the variables that are not mentioned in the interface can be set.
 1. This determines amount of information learned via intergroup-communication (_share-with-other-networks_)that a researcher can digest each tick. To learn one argument which was unknown before (= cyan = 85) all the way to the highest degree of exploration (= red = 15) costs 70. By default an attack relation costs as much as one color step of an argument (`rel-costfactor` = 10) and researchers can digest two full arguments per day (`max-learn`).
 2. only every 5 ticks (= days) researchers move with full move-probability during the _move-around_ procedure. In between the move-probability is lower by the factor `small-movement` i.e. by default they move only with 1/5 th of the move probability on the days in between.
 3. During the _move-around_ procedure the move probability is influenced by the color of the argument a researcher is standing on (`color-move`). The further researched an argument is (= lower color) the higher the move-probability is. Researchers move if
 `move-random < move-probability * (1 - ([color] of myargu / color-move))` where `move-random` is a random float on the interval [0,1] and myargu is the argument the researcher is currently standing/working on.

### Building the objective landscape

For each theory a tree is built, its root is called "start". The depth of the theory, as can be chosen in the interface, sets the number of arguments. The root has 4 child-arguments, after that, if a next layer exists, each argument has also 4 child-arguments, otherwise 0. Each of these child-arguments is connected by a directed discovery relation.

Each argument has a memory for the theory it belongs to, how often it is visited/researched by an researcher and whether it was just fully researched (turned red in the current round).

### Defining the attack relation

On the created landscape an attack relation is added. Each argument has, with attack-probability corresponding to the theory the argument belongs to, an incoming attack from an argument belonging to another theory. Once the random attacks are created, the best theory (theory 0), has to make sure that it is fully defended. It creates attacks to arguments that attack one of its arguments, until it has defended all its attacked arguments.

### Researchers

researchers are randomly distributed over the available theories. Then they form "collaborator-networks". If the switch "within-theory" is on in the interface, such networks are created with researchers that start on the same theory, if the switch is off networks are randomly created. Such networks have at most 5 researchers. In case the networks are random all networks have exactly 5 researchers, if the networks are created within theories there can be networks with less than 5 researchers.

A list of all collaborator-networks is saved in the global variable colla-networks:

`[[(researchers a1) ... (researcher a5)] ... [(researcher i1) ... (researcher i5)] ... ]`

The collaborator-networks are connected to each other, according to the choice in the interface: cycle (every network is connected to two other networs); wheel (every network is connected to two other networks and the royal network, which is connected to all other networks); or complete (every network is connected to every other network). These stuctures will be used when the representative researcher from one network communicates with representative researchers from other networks.

The social structures are saved in the global variable share-structure, which for the cycle has the form:

`[[[(researchers aa1) ... (researcher aa5)] ... [(researchers ac1) ... (researcher ac5)]] ... [[(researchers ia1) ... (researcher ia5)] ... [(researcher ic1) ... (researcher ic5)]] ... ]`

researchers have a memory in which they keep track of the following:

* _collaborator-network_: a list of other researchers and herself that form the network she communicates with i.e. her group

* _times-jumped_ and _theory-jump_: the first to keep track of how often researchers in general jump with a given strategy, the second to keep track of how often an researcher considers jumping

* _current-theory-info_: this list contains for each theory an entry that has the following elements, the second depending on the memory of the researcher: 1. the theory the entry belongs to; and 2. the number of admissible (not attacked) arguments:

`[[(start 0) ad0] [(start 2nd) ad2nd] ...]`

* _cur-best-th_: the current best theory according to the current memory of the researcher, this is updated every 5 time steps

* _th-args_ and th_relations_: lists of arguments and relations, that the researcher is prepared to share with researchers from other collaborative networks

* _to-add-mem-argu_ and _to-add-mem-rel_: lists of arguments and relations that the researcher has to add to its own memory as a result of communication

* _admissibile-subj-args_: the list of arguments from the subjective-arguments that are admissible (not attacked or attacked and defended)

* _moved_: true if the researcher moved already in that time step

* _rep-researcher_ and _communicating_: if the researcher is in that communication round the representative researcher and how many time steps it takes this researcher to process all the new information it has obtained.

### _compute-popularity_

Computations for the popularity plot and the reporters in BehaviorSpace runs. It computes for every theory the number of researchers working on it (myscientists) and how many researchers consider a theory to be among the best (myscientists-pluralist). This values are added up in their respective global variables: research-time-monist/pluralist (cf. Variables).

Arguments: update-pluralist? format: boolean. Determines whether the myscientists-pluralist value has to be updated (only true if ticks mod 5 = 4 or at the end of a run)

1. mystart is the theory the current researcher is investigating
2. For each researcher the myscientists variable of the theory this researcher is working on is increased by one
3. The `myscientists-pluralist` variable (cf. Variables) is updated. 
4. If there is more than one best theory in the memory of the researcher the start will count this researcher as adding 1 / (number of best theories) to its `myscientists-pluralist` counter. (cf. Variables - myscientists-pluralist)
5. As long as researchers haven't done any admissibility calculations it is assumed that they think the theory they're currently working on is the single best theory
6. The values are added up in their respective global variables: research-time-monist/pluralist (cf. Variables)

## Basic behavior of researchers and the landscape

### Update of the memory

Every time step the researchers update their memory. The current argument is added to the list of subjective-arguments, then the relations are updated (including the subjective arguments that are discovered by these relations). The current argument, the relations to/from it and the arguments these relations connect belong to the neighborhood information of that argument and are saved in the memory of the researcher as "neighborargs".

Every five plus four time steps (4, 9, 14, ...), researchers share their memory with other researchers. First researchers share what they know within their own collaborator-network. In this network they share all information with everyone: after this round of sharing the researchers in the same network have the same memory.

After this, from every network one random researcher is chosen that will be the representative researcher of that network in communicating with other networks. These representative researchers create a list of arguments and a list of relations that they are prepared to share with other representative researchers. How this is done depends on the social behavior of the researchers (reliable or biased).

Then the representative researchers share the part of the memory they want to share with the researchers from the networks that neighbor their own in the network structure. The researchers collect all the new arguments and relations. At most 30 new entries are added to their memory and at most 10 entries per day.

The time step that the researchers share their information is already lost. Depending on how many new entries the value of the variable communicating is increased, with a maximum of three. For communicating time steps the researchers cannot do research: they do not move around and the landscape is not affected by their presence. Every fifth round (0, 5, 10, ...) all researchers do not communicate: every researcher can move around and affects the landscape.

After updating the memory and sharing information, the researcher removes all duplicate arguments from its memory. This also includes entries with arguments that were part of the memory but for which a new entry with better research color is found.

#### _update-memories [spoof-gps]_

Researchers will update their memory every week right before the sharing with other researchers (intra- and inter-group-sharing) takes place. In between researchers will update their memory if needed, i.e. if they move. For this _update-memories_ will be called by the _move-to-nextargu_ procedure.

The memory management is comprised of two parts:
(a) The researchers save arguments and relations in the form of turtle-sets / link-sets in their memory (cf. infotab Variables -> `to-add-mem-argu` `to-add-mem-rel`) which will be synchronized every week with the group in the `share-with-group` procedure
(b) the status in which the argument / relation is known to a certain collaborative network (=group) is saved in the argument / link itself. (cf. infotab Variables -> `group-color-mem`, `in-group-i-memory`). For links this will be facilitated during the `share-with-group` procedure, while for arguments the color is updated right when the researchers update their memory.

Argument: spoof-gps, type: turtle. Determines whether the researcher should update her memory according to the argument she's standing on (spoof-gps = `nobody`) or as if she was standing on "argument x" (spoof-gps = `argument-x`).

#### _learn-random-item_

Once a month (every 30 ticks) if all researchers are on fully explored theories (`g-exit-case` 2) they learn a random item from `g-learn-set` which can be either an argument or an attack. If they learn an attack they also learn the arguments at both ends of this attack. 

### Researchers move around

Each time step researchers, that did not communicate with researchers from other networks and are not working on a not fully researched not-admissible argument, consider the arguments which they can work on next. Such an argument has to be a child-argument of the current argument, should be discovered, it should not be discovered by discovering an attack relation that involves the argument, it should not be red with another researcher already working on it and the discovery relation should be discovered as well.

The probability that an researcher moves to such a possible next argument depends on the color of the argument it is currently working on (but the color influences this probability only a little) and the time step. Every time step an researcher moves with a probability of 1/5 of the total move-probability to a next argument. Every 5th time step (5, 10, 15, ...) the researcher moves with the full move-probability that is set in the interface.

If an researcher is working on an argument that is fully researched, the color is red, it will try to move to a next argument, if that is not possible, it will move one step back (if no other researcher is working on that argument) and if that is not possible, it will move to a discovered, not fully researched and attacked argument in the same theory with no researcher working on it.

researchers, that did not communicate and are working on a not fully researched and not-admissible argument try to find a defense for their argument. This is done by staying on the current argument until it is red (then everything is discovered that can be discovered) or a defense from one of its child-arguments is discovered. Such a defense attack does not have to be discovered yet. If such a defending-child-argument exists, the researcher will move to this argument. researchers that move like this cannot move in the regular way that time step.

#### _move-to-nextargu_

Procedure which is called by researchers when they move (to nextargu). It makes sure that the researcher has an updated memory of her surrounding before moving by calling _update-memories_.
Then `mygps` (cf. Variables) - i.e. the argument she is working on - will be set to her new destination ( = nextargu).

### Researchers share information

#### _share-with-group_

Intra-group sharing: researchers share their memory with other researchers from their collaborator-network (=group). The memory update is twofold (cf. update-memories)
(a) the agentset which contains the arguments / relations themselves and
(b) the information saved within the arguments /relations on how the item is remembered by the group
For arguments (b) has already been done during `update-memories` so only (a) needs to be performed, while for relations (=attacks) both (a) + (b) will be performed

#### _share-with-other-networks_

Inter-group sharing: representative researchers of the networks share information according to the social structure.
In cases where the network structure is de-facto complete i.e. all complete cases + when there are equal or less than 3 groups + when there are equal or less than 4 groups and the structure is not a ‘cycle’ it calls the subprocedure `inter-group-sharing-complete`, else `inter-group-sharing-default`.

#### _inter-group-sharing-complete_

The inter-group-sharing (= share-with-other-networks) procedure for de-facto complete networks. The memory update is twofold (cf. update-memories)
(a) the agentset which contains the arguments / relations themselves and
(b) the information saved within the arguments /relations on how the item is remembered by the group
all information gets cached and will be integrated into the group memory during the next intra-group-sharing (= share-with-group) one week later
1. The absolute costs each group has to pay to incorporate the information learned via this inter-group sharing (format: list e.g. [ 0 0 0 ] = 3 groups). This costvector is initialized with the value 0 for each group and for each information which is new to the group the respective absolute costs will be added to their entry. The i-th entry is the absolute cost the rep-researcher from group i has to pay (cf. group-id and distribute-com-costs).
2. For each argument the most researched version (= lowest color) will be exchanged: i.e. cached until it is consolidated into the group memory during the next intra-group-sharing (= share-with-group) one week later cf. infotab group-color-mem-cache.
3. Each group pays the difference between the version (= color) they know an argument in and the most recent version. For details on the costs cf. _initialize-hidden-variables_
4. For each relation (= attack) the researcher didn't know she has to pay the absolute costs of rel-costfactor (cf. infotab `rel-costfactor` and _initialize-hidden-variables_)
5. The absolute costs are transformed into relative costs (in days) and distributed among the group

#### _inter-group-sharing-default_

The inter-group-sharing (= share-with-other-networks) procedure for non-complete networks. The memory update is twofold (cf. update-memories)
(a) the agentset which contains the arguments / relations themselves and
(b) the information saved within the arguments /relations on how the item is remembered by the group
all information gets cached and will be integrated into the group memory during the next intra-group-sharing (= share-with-group) one week later
1. for all arguments the rep-researchers are going to share the cache is updated to contain the most recent version (=color) they know the arguments in (b).
2. The rep-researcher from the first group in the current share-structure entry is the askresearcher
3. The askresearcher collects all the information from the other rep-researchers she is to sharing with i.e. the share-researchers from the other groups in her share-structure entry (= the entry where her group is first).
4. The arguments which are known by the askresearcher in a less recent version (= higher color) are selected
5. The difference between the more recent color and the less recent one gets added to the absolute communication costs
6. The more recent version of the argument gets cached ((a) & (b))
7. The relations (= attacks) which were unknown to the askresearcher get cached (a)
8. The absolute communication costs are those paid for the difference to the more recent arguments + (the newly learned relations * rel-costfactor cf. `rel-costfactor`)
9. The absolute costs are transformed into relative costs (in days) and distributed among the group

#### _distribute-com-costs_

Distributes the absolute communication costs (com-costs) among the group and transform them into relative costs (in days) which are then saved in the researcher-owned variable `communicating`.
The absolute costs are the difference between the information the rep-researcher posessed before vs. after the inter-group-sharing. For details on the costsfunction cf. infotab: initialize-hidden-variables. The researchers have to digest all information within a work-week (= 5 days/ticks) while still reserving one day for doing their own research, which leaves them with 4 days for digesting. The rep researcher herself only has 3 days b/c the day she visits the conference (inter-group-sharing) is also lost. Every day a researcher can digest information of value `max-learn` (a hidden variable, default: 3 * 70). The researcher-owned variable will be set to how many days the researcher will be occupied by digesting information (+ one day in the case of the rep-researchers: the day of visiting the conference itself)
1. the rep-researcher pays for as much information as she can.
2. If the (absolute) costs are higher than what she can pay (= 3 * max-learn), the next researcher from her group will be picked and pay for as much of the rest of the communication costs as she can ( = 4 * max-learn). She will also become a rep-researcher and therefore exempt from pursuing strategies this week. If there are still communication costs left this continues until all researchers of the group have paid the maximum relative costs (= communicating 4 = 4 days) or all communication costs have been paid.

### Update of the landscape

The landscape is updated every five time steps (5, 10, 15, ...). A new child-argument becomes visible for arguments that are yellow, brown, orange or red and still have an undiscovered child-argument. With visibility-probability (depending a little bit, even less than with the move probability, on the color) attacks are discovered. First the in-attacks, then the out-attacks.

If researchers have been working for research-speed time steps on an argument, the argument changes color, if the argument was not yet fully researched. Discovery relations that connect two non-gray colored arguments (one may be turquoise, discovered by attack) are also discovered.

An argument that was fully researched in this time step (it turned red), discovers immediately all its relations: attacks and discoveries + the other ends.

## Strategies

### Computations for the strategies

After updating the memory of the researchers, researchers will reconsider working on the theory they are working on. How they do this depends on the strategy. The criterion on which they base this is the number of admissible arguments of the theory: the number of discovered, admissible arguments (they may be attacked, but then they are also defended).

Each researcher computes for its "current-theory-info" the number of admissible arguments, with respect to its current memory. Based on the information from the current-theory-info the best theory is calculated. The best theory can be unique, in that case there is no other theory that has a number of admissible arguments that is close enough to the number of admissible arguments of this best theory (close enough depends on the "strategy-threshold" in the interface).

#### _admissibility-calc-core_

The core of the admissibility calculation procedure. It takes a link-set (attackset) for a certain theory (i.e. all attacks which are either outgoing or incoming to this theory) as input and reports the arguments which are successfully attacked i.e. non-admissible as a turtle-set processed? is a boolean dummy variable which marks attacks which have successfully attacked during the secondary-attackers phase (cf. also global variables).

1. take the attacks which are themselves uncontested in the objective landscape. The destination of this attacks will be non-admissible and attacks coming from there are void.

2. the attacks which are not uncontested but also were not rendered void by the prime attackers form the secondary-attackers link-set. If they don't have any incoming attack from the secondary-attackers themselves their attack is successful and therefore they set their `processed?` variable to `true`

 3. Of those secondary-attackers which were successful, the destination (= end2) gets added to the non-admissible turtle-set and attacks starting from there are rendered void and are therefore removed from the set. Then the successful secondary attacks themselves are removed. This repeats until there are no secondary-attackers left or non of the left is able to attack successfully anymore.

#### _compute-subjective-attacked_

Procedure that computes for each collaborator network (= groups) which of the arguments in their memory are admissible because researcher in a collaborator network share all information with each other only one agent needs to do the admissibility calculations (the calc-researcher) and the others (except for the rep-researcher) can just copy the results from her

1. if a researcher of the group already calculated admissibility other group members can copy the results into their memory

2. if no group member has done the admissibility calculations, the current researcher does the calculations i.e. she becomes the groups calc-researcher

3. if there are only two theories the admissibility calculation can be done on the whole attackset at once

4. if there are more than two theories the calculation has to be done once for each attack set of a theory separately. A attack set of a theory corresponds to all the attacks in the set which are either incoming or outgoing to/from this theory

#### _set-g-learn-set_

Creates the list (`g-learn-set`) from which items are drawn in case that `necessary-convergence` is selected in the interface and all researchers are converged on fully explored theories (`g-exit-case` 2). This list contains all arguments and attacks belonging to not fully explored theories and the best theory (`g-learn-set-theories`)

### Acting on the strategy

Once the current best theory is computed, researchers will reconsider the theory they are working on. If that is not the current best theory, they consider to jump.

If researchers think often enough that they should jump to another theory, often enough depends on the "jump-threshold" of the interface, the researcher jumps to a/the current best theory and starts working on that theory. If the researcher is aware of an argument from that theory, it will jump to a random, argument of that theory in its memory, otherwise it will jump to the root.

## Protocol

### _exit-condition_

 The exit-condition is a reporter that determines when a given run is considered to be finished. A run is over as soon as there exists one theory which is fully discovered (i.e. has only red arguments). When this happens researchers can one final time jump to a best theory (irrespective of their `theory-jump` value) if they’re not already on a theory they consider best. This is facilitated by the `final-commands` procedure which is called as soon as `exit-condition` reports `true` and therefore ends the run.

### _final-commands_

 As soon as a run is finished (cf. _exit-condition_) researchers can one final time jump to a best theory (irrespective of their `theory-jump` value) if they’re not already on a theory they consider best. To determine what their final best theories are, they do a final update of their memory, share with their group and do an admissibility calculation.

### _in-run-performance [parameter]_

 * parameter: "monist" or "pluralist"

This metric tracks how well researchers perform during a run as opposed to 'at the end' - and therefore also after - a run like the `pluralist-/monist-success` metric does. It also takes the objective admissibility of the landscape into account and is normalized to a [0,100] interval where 100 corresponds to the best performance. The metric is calculated by using either the `research-time-monist` ("monist") or `research-time-pluralist` ("pluralist") Variable (cf. Variables). This variable (for each theory) together with their different admissibilities form the basis of the in-run-performance metric.

 * research-time-x is either research-time-monist or research-time-pluralist (cf. Variables) depending on the parameter with which the procedure was called.
 * th<sub>i</sub>: Theory<sub>i</sub> where i \in {1,2,3} i.e. there exist up to three theories
 * researchers: number of researchers in this run
 * compute-popularity-counter: How often compute-popularity has been executed during the run and therefore how often research-time-x has been updated. 
 
 The formula of the in-run-performance metric is:
 
100 * Σ<sub>i</sub> (research-time-x-th<sub>i</sub> * objective-admissibility-th<sub>i</sub>) / (researchers * compute-popularity-counter * objective-admissibility-best-theory)

The denominator corresponds to the best score the researchers could get. This score is the product of the admissibility of the best theory , the length of the run and the number of researchers. 
The numerator on the other hand is the score the researchers actually archived this run. As the denominator is the maximum score, the whole fraction can take a maximum value of 1 which would be the case when all researchers actually spent all their time on the best theory ("monist") / considered the best theory to be their single subjective best theory for the whole run ("pluralist"). Any deviations from this will lower the score correspondingly. Some examples make this clearer:

 * If the researchers spend all their time on a theory which only has half the admissibility of the best theory the fraction would be 1/2 ( => in-run-performance = 50 ).
 * The same would be true if half of the researchers spent all their time on a theory which has an admissibility of 0 while the other half spent their time on the best-th.
 * If all theories had full admissibility researchers would always get the maximum score (in-run-performance = 100).	
 * If all researchers spend all their time on a theory which has an admissibility of 0, in-run-performance would be 0.

### _heatmap_

This procedure draws a heatmap where the brightness of a patch is proportional to the proportion of researcher which know the arguments (and optionally attacks) concerning this patch.
In order to properly see the heatmap you can reduce the clutter of the world by making the links & arguments invisible via `ask links [set hidden? true] ask startsargum [set hidden? true]`

* argument: including-attacks?, type: boolean
 whether or not knowledge about the attack relations connected to arguments on this patch is taken into account for drawing the heatmap
 
### _save-tracked-knowledge_ and _track-knowledge_

If `knowledge-tracking` is enabled the information on beliefs and knowledge which has been collected during the run by `track-knowledge` is written to a external csv file. There is one data point for each group and each theory at each point in time they update their beliefs (usually every five rounds). 
Example run: 

* 10 groups
* 3 theories
* each group updated their belief 100 times (i.e. conducted 100 times `compute-subjective-attacked`) 

This run would produce 3000 data points (10 * 3 * 100)

Each data point has the following format:
BehaviorSpace-run-number, number of arguments per theory, objective defensibility of theory-x, round in which the data was recorded, group-id of the recording group (group-y), theory-x (theory for which the data-point is recorded) , number of defended arguments theory-x has at this point according to group-y's evaluation, number of arguments from th-x which group-y knows at this point , number of arguments from th-x weighted by color (1 = turquoise - 7 = red) which group-y knows at this point.

Example for one data point: 1,85,85,15,10,1,1,1,3 
Interpretation: In the first BehaviorSpace run there are 85 arguments per theory (-> depth = 3), theory 1 has objectively 85 admissible arguments, at round 15 group 10 evaluated theory 1 to have one defended argument, group 10 knows one argument from theory 1 and their weighted knowledge regarding theory 1 is 3 (i.e. they know the one argument at color-level 'green').


