# UNDER CONSTRUCTION

# ArgABM
An agent-based model for scientific inquiry based on abstract argumentation

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

* _defense-from-leaves_ if turned on: creates a more difficult landscape in which the best theory is largely defended by the leaves-arguments

Strategy settings

* _strategy-threshold_ defines the threshold within which the number of admissible arguments is still considered good, if this threshold gets higher, the interval of acceptable values gets smaller

* _jump-threshold_ is the number of times an researcher has to consider jumping before it really jumps to another theory

Researcher settings

* _collaborative-groups_ the number of groups (teams of researchers) that will explore the landscape. 

* _col-group-size_ each group (team of researchers) consists of this many researchers

* _move-probability_ the probability that researchers move to a next argument while exploring the landscape

* _visibility-probability_ the probability that new attacks are discovered by researchers

* _research-speed_ the time an researcher has to work on an argument before it will change color

* _within-theory_ here the kind of collaborative network is set to researchers that start on the same theory (on) or randomly chosen researchers (off)

* _social-actions_ here the behavior of the researchers that communicate with researchers outside their own can be set: "reliable" is the setting where they share all information about the current theory: including attacks; "biased" researchers do not share the attacks to their current theory

* _network-structure_ determines the structure in which the collaborator-networks are connected and with how many researchers information is shared

* _knowledge-tracking_ if turned on: during the run information on the current state of beliefs and knowledge is collected every time researchers update their beliefs. When a run ends this information is written to an external csv file. **Warning:** This data will get corrupted if multiple instances of this model with knowledge-tracking turned on are run in parallel (e.g. via BehaviorSpace). Therefore only use single threaded runs when collecting data via knowledge-tracking!

* _controlled-spread-of-researchers_ if turned on: a number of researchers, determined by the slider _col-groups-on-best-t_, is placed on the best theory (these researchers are pink); the remainder of researchers is distributed randomly on the remaining theories (these researchers are blue).  This is meant to 
;be used only in conjunction with  homogeneous groups (i.e. 
;`within-theory` = true).


Plots

* the _Popularity_ plot shows for every theory the number of researchers working on it

* the _Current avg. com. costs_ plot shows the average communication costs from the most recent inter-group sharing in days per researcher

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

### Researchers

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

# Changes to be integrated into the doc (wip)
- This should be put into the appropriate places; maybe do this together with the documentation merge from HSR?
- Add formal definition of "defended"
- Needs also to be integrated into the readme.

## Interface

### evaluation

* type: chooser

The evaluation criterion researchers apply when determining the score they assign to theory x (always according to their subjective memory). The four options are:

* "defended-args": score = number of defended arguments in theory x. Higher score = better. 

* "non-defended-args": score = number of non-defended arguments in theory x. Lower score = better.

* "non-defended-normalized": score = number of non-defended arguments in theory x / number of all arguments in theory x. Lower score = better.

* "non-defended-multiplied": score = number of non-defended arguments in theory x * number of all arguments in theory x. Lower score = better.

## Setup

  * _initialize-hidden-variables_
Procedure in which the variables that are not mentioned in the interface can be set.
 1. This determines amount of information learned via intergroup-communication (_share-with-other-networks_)that a researcher can digest each tick. To learn one argument which was unknown before (= cyan = 85) all the way to the highest degree of exploration (= red = 15) costs 70. By default an attack relation costs as much as one color step of an argument (`rel-costfactor` = 10) and researchers can digest two full arguments per day (`max-learn`).
 2. only every 5 ticks (= days) researchers move with full move-probability during the _move-around_ procedure. In between the move-probability is lower by the factor `small-movement` i.e. by default they move only with 1/5 th of the move probability on the days in between.
 3. During the _move-around_ procedure the move probability is influenced by the color of the argument a researcher is standing on (`color-move`). The further researched an argument is (= lower color) the higher the move-probability is. Researchers move if
 `move-random < move-probability * (1 - ([color] of myargu / color-move))` where `move-random` is a random float on the interval [0,1] and myargu is the argument the researcher is currently standing/working on.

  * _compute-popularity_
  Computations for the popularity plot and the reporters in behaviorspace runs. It computes for every theory the number of researchers working on it (myscientists) and how many researchers consider a theory to be among the best (myscientists-pluralist). This values are added up in their respective global variables: research-time-monist/pluralist (cf. Variables).
  Arguments: update-pluralist? format: boolean. Determines whether the myscientists-pluralist value has to be updated (only true if ticks mod 5 = 4 or at the end of a run)
  1.  mystart is the theory the current researcher is investigating
  2. For each researcher the myscientists variable of the theory this researcher is working on is increased by one
  3. The `myscientists-pluralist` variable (cf. Variables) is updated. 
  4. If there is more than one best theory in the memory of the researcher the start will count this researcher as adding 1 / (number of best theories) to its `myscientists-pluralist` counter. (cf. Variables - myscientists-pluralist)
  5. As long as researchers haven't done any admissibility calculations it is assumed that they think the theory they're currently working on is the single best theory
  6. The values are added up in their respective global variables: research-time-monist/pluralist (cf. Variables)


## Strategies

  * _admissibility-calc-core_
The core of the admissibility calculation procedure. It takes a link-set
(attackset) for a certain theory (i.e. all attacks which are either
outgoing or incoming to this theoy) as input and reports the arguments
which are successfully attacked i.e. non-admissible as a turtle-set
processed? is a boolean dummy variable which marks attacks which have
sucessfully attacked during the secondary-attackers phase (cf. also global variables).

1. take the attacks which are themselves uncontested in  the objective landscape. The destination of this attacks will be non-admissible and attacks coming from there are void.

2. the attacks which are not uncontested but also were not rendered void by
  the prime attackers form the secondary-attackers link-set. If they don't
  have any incoming attack from the secondary-attackers themselves their
  attack is successfull and therefore they set their `processed?` variable to `true`

 3. Of those secondary-attackers which were successfull, the destination
  (= end2) gets added to the non-admissible turtle-set and attacks
  starting from there are rendered void and are therefore removed from
  the set. Then the successfull secondary attacks themselves are removed.
  This repeats until there are no secondary-attackers left or non of the
  left is able to attack successfully anymore.

  * _compute-subjective-attacked_
procedure that computes for each collaborator network (= groups) which of the arguments in their memory are admissible because researcher in a collaborator network share all information with each other only one agent needs to do the admissibility calculations (the calc-researcher) and the others (except for the rep-researcher) can just copy the results from her

1. if a researcher of the group already calculated admissibility other group members can copy the results into their memory

2. if no group member has done the admissibility calculations, the current researcher does the calculations i.e. she becomes the groups calc-researcher

3. if there are only two theories the admissibility calculation can be  done on the whole attackset at once

4. if there are more than two theories the calculation has to be done once for each attack set of a theory sepearately. A attack set of a theory corresponds to all the attacks in the set which are either incoming or outgoing to/from this theory

## Behavior

  * _update-memories_
Researchers will update their memory every week right before the sharing with other researchers (intra- and inter-group-sharing) takes place. In between researchers will update their memory if needed, i.e. if they move. For this _update-memories_ will be called by the _move-to-nextargu_ procedure.
The memory management is comprised of two parts:
(a) The researchers save arguments and relations in the form of turtle-sets / link-sets in their memory (cf. infotab Variables -> `to-add-mem-argu` `to-add-mem-rel`) which will be synchronized every week with the group in the `share-with-group` procedure
(b) the status in which the argument / relation is known to a certain collaborative network (=group) is saved in the argument / link itself.  (cf. infotab Variables -> `group-color-mem`, `in-group-i-memory`). For links this will be facilitated during the `share-with-group` procedure, while for arguments the color is updated right when the researchers update their memory.

  * _move-to-nextargu_
Procedure which is called by researchers when they move (to nextargu). It makes sure that the researcher has an updated memory of her surrounding before moving by calling _update-memories_.
Then `mygps` (cf. Variables) - i.e. the argument she is working on - will be set to her new destination ( = nextargu).

  * _share-with-group_
intra-group sharing: researchers share their memory with other researchers from their collaborator-network (=group). The memory update is twofold (cf. update-memories)
(a) the agentset which contains the arguments / relations themselves and
(b) the information saved within the arguments /relations on how the item is remembered by the group
For arguments (b) has already been done during `update-memories` so only (a) needs to be performed, while for relations (=attacks) both (a) + (b) will be performed

  * _share-with-other-networks_
inter-group sharing: representative researchers of the networks share information according to the social structure.
In  cases where the network structure is de-facto complete i.e. all complete cases + when there are equal or less than 3 groups + when there are equal or less than 4 groups and the structure is not a ‘cycle’ it calls the  subprocedure `inter-group-sharing-complete`, else `inter-group-sharing-default`.

  * _inter-group-sharing-complete_
The inter-group-sharing (= share-with-other-networks) procedure for de-facto complete networks. The memory update is twofold (cf. update-memories)
(a) the agentset which contains the arguments / relations themselves and
(b) the information saved within the arguments /relations on how the item is remembered by the group
all information gets cached and will be integrated into the group memory during the next intra-group-sharing (= share-with-group) one week later
1.  The absolute costs each group has to pay to incorporate the information learned via this inter-group sharing (format: list e.g. [ 0 0 0 ] = 3 groups). This costvector is initialized with the value 0 for each group and for each information which is new to the group the respective absolute costs will be added to their entry. The i-th entry is the absolute cost the rep-researcher from group i has to pay (cf. group-id and distribute-com-costs).
2. For each argument the most researched version (= lowest color) will be exchanged: i.e. cached until it is consolidated  into the group memory during the next intra-group-sharing (= share-with-group) one week later cf. infotab group-color-mem-cache.
3. Each group pays the difference between the version (= color) they know an argument in and the most recent version. For details on the costs cf.  _initialize-hidden-variables_
4. For each relation (= attack) the researcher didn't know she has to pay the absolute costs of rel-costfactor (cf. infotab `rel-costfactor` and _initialize-hidden-variables_)
5. The absolute costs are transformed into relative costs (in days) and distributed among the group

  * _inter-group-sharing-default_
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

  * _distribute-com-costs_
Distributes the absolute communication costs (com-costs) among the group and transform them into relative costs (in days) which are then saved in the researcher-owned variable `communicating`.
The absolute costs are the difference between the information the rep-researcher posessed before vs. after the inter-group-sharing. For details on the costsfunction cf. infotab: initialize-hidden-variables. The researchers have to digest all information within a work-week (= 5 days/ticks) while still reserving one day for doing their own research, which leaves them with 4 days for digesting. The rep researcher herself only has 3 days b/c the day she visits the conference (inter-group-sharing) is also lost. Every day a researcher can digest information of value `max-learn` (a hidden variable, default: 3 * 70). The researcher-owned variable will be set to how many days the researcher will be occupied by digesting information (+ one day in the case of the rep-researchers: the day of visiting the conference itself)
1. the rep-researcher pays for as much information as she can.
2. If the (absolute) costs are higher than what she can pay (= 3 * max-learn), the next researcher from her group will be picked and pay for as much of the rest of the communication costs as she can ( = 4 * max-learn). She will also become a rep-researcher and therefore exempt from pursuing strategies this week. If there are still communication costs left this continues until all researchers of the group have paid the maximum relative costs (= communicating 4 = 4 days) or all communication costs have been paid.


## Protocol

### _exit-condition_
  The exit-condition is a reporter that determines when a given run is considered to be finished. A run is over as soon as there exists one theory which is fully discovered (i.e. has only red arguments). When this happens researchers can one final time jump to a best theory (irrespective of their `theory-jump` value) if they’re not already on a theory they consider best. This is facilitated by the `final-commands` procedure which is called as soon as  `exit-condition` reports `true` and therefore ends the run.

### _final-commands_
 As soon as a run is finished (cf. _exit-condition_) researchers can one final time jump to a best theory (irrespective of their `theory-jump` value) if they’re not already on a theory they consider best. To determine what their final best theories are, they do a final update of their memory, share with their group and do an admissibility calculation.

### _in-run-performance [parameter]_
  * parameter: "monist" or "pluralist"

This metric tracks how well researchers perform during a run as opposed to 'at the end' - and therefore also after - a run like the `pluralist-/monist-success` metric does. It also takes the objective admissibility of the landscape into account and is normalized to a [0,100] interval where 100 corresponds to the best performance. The metric is calculated by using either the `research-time-monist` ("monist") or `research-time-pluralist` ("pluralist") Variable (cf. Variables). This variable (for each theory) together with their different admissibilities form the basis of the in-run-performance metric.

  * research-time-x is either research-time-monist or research-time-pluralist (cf. Variables) depending on the parameter with which the procedure was called.
  * th<sub>i</sub>: Theory<sub>i</sub> where i \in {1,2,3}  i.e. there exist up to three theories
  * researchers: number of researchers in this run
  * ticks: length of the run in ticks. 
  Technically it's the number of ticks + 1 b/c final-commands called by the exit condition (cf. final-commands) are adding to the research-time-x counters like an additional tick would.
  
  The formula of the in-run-performance metric is:
  
100 * Σ<sub>i</sub> (research-time-x-th<sub>i</sub> * objective-admissibility-th<sub>i</sub>)  / (researchers * ticks * objective-admissibility-best-theory)

The denominator corresponds to the best score the researchers could get. This score is the product of the admissibility of the best theory , the length of the run and the number of researchers. 
The numerator on the other hand is the score the researchers actually archived this run. As the denominator is the maximum score, the whole fraction can take a maximum value of 1 which would be the case when all researchers actually spent all their time on the best theory ("monist") / considered the best theory to be their single subjective best theory for the whole run ("pluralist"). Any deviations from this will lower the score correspondingly. Some examples make this clearer:
  
  * If the researchers spend all their time on a theory which only has half the admissibility of the best theory the fraction would be 1/2 ( => in-run-performance = 50 ).
  * The same would be true if half of the researchers spent all their time on a theory which has an admissibility of 0 while the other half spent their time on the best-th.
  * If all theories had full admissibility researchers would always get the maximum score (in-run-performance = 100).	
  * If all researchers spend all their time on a theory which has an admissibility of 0, in-run-performance would be 0.

### _heatmap_

This procedure draws a heatmap where the brightness of a patch is proportional to the proportion of researcher which know the arguments (and optionally attacks) concerning this patch.  
In order to properly see the heatmap you can reduce the clutter of the world by making the links & arguments invisible via `ask links [set hidden? true] ask startsargum [set hidden? true]`

*  argument: including-attacks?, type: boolean  
 whether or not knowledge about the attack relations connected to arguments on this patch is taken into account for drawing the heatmap
 
### _save-tracked-knowledge_ and _track-knowledge_

If `knowledge-tracking` is enabled the information on beliefs and knowledge which has been collected during the run by `track-knowledge` is written to a external csv file. There is one data point for each group and each theory at each point in time they update their beliefs (usually every five rounds).  
Example run:  

* 10 groups
* 3 theories
* each group updated their belief 100 times (i.e. conducted 100 times `compute-subjective-attacked`)  

This run would produce 3000 data points (10 * 3 * 100)

Each data point has the following format:
BehaviorSpace-run-number, number of arguments per theory, objective defensibility of theory-x, round in which the data was recorded, group-id of the recording group (group-y), theory-x (theory for which the data-point is recorded) , number of defended arguments theory-x has at this point according to group-y's evaluation, number of arguments from th-x which group-y knows at this point , number of arguments from th-x weighted by color (1 = turquoise - 7 = red) which group-y knows at this point  

Example for one data point: 1,85,85,15,10,1,1,1,3  
Interpretation: In the first BehaviorSpace run there are 85 arguments per theory (-> depth = 3), theory 1 has objectively 85 admissible arguments, at round 15 group 10 evaluated theory 1 to have one defended argument, group 10 knows one argument from theory 1 and their weighted knowledge regarding theory 1 is 3 (i.e. they know the one argument at color-level 'green').


## Variables

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
