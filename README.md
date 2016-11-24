# ArgABM
An agent-based model for scientific inquiry based on abstract argumentation

Documentation of the program ArgABM for the paper _An argumentative agent-based model of
scientific inquiry_ by AnneMarie Borg, Daniel Frey, Dunja Šešelja and Christian Straßer

# Motivation and Introduction

# The Program

## Interface

Buttons

* _setup_ creates the landscape, including attacks and distributes the scientists/agents over this landscape

* _go_ lets the program run one time step

* _go (infinite, has a small circle)_ lets the program run infinitely many steps, or until the button is clicked again

* _go-stop_ lets the program run until all agents are working on a fully researched theory

Landscape settings

* _number-of-theories_ sets the number of theories/trees that will be created

* _theory-depth_ sets the depth of the trees, the number of arguments from root to a leave, without the root itself

* _attack-probability-best_ the probability that an argument of the objective best theory has an incoming attack

* _attack-probability-2nd_ the probability that an argument of the 2nd theory has an incoming attack

* _attack-probability-3rd_ if there are three theories, the probability that an argument of the 3rd theory has an incoming attack

Strategy settings

* _strategy-threshold_ defines the threshold within which the number of admissible arguments is still considered good, if this threshold gets higher, the interval of acceptable values gets smaller

* _jump-threshold_ is the number of times an agent has to consider jumping before she really jumps to another theory

Agent settings

* _scientists_ the number of agents that will explore the landscape

* _move-probability_ the probability that agents move to a next argument while exploring the landscape

* _visibility-probability_ the probability that new attacks are discovered by agents

* _research-speed_ the time an agent has to work on an argument before it will change color

* _within-theory_ here the kind of collaborative network is set to agents that start on the same theory (on) or randomly chosen agents (off)

* _social-collaboration_ the probability that an agent communicates with an agent or network outside her own

* _social-actions_ here the behavior of the agents that communicate with agents outside their own can be set: "reliable" is the setting where they share all information about the current theory: including attacks; "biased" agents do not share the attacks to their current theory

* _sharing_ makes it possible to choose what the agents share with agents from other networks: either their whole memory ("all") or only the information in their direct "neighborhood"

Plots

* the _Popularity_ plot shows for every theory the number of agents working on it

### Hidden variables

There are three variables that cannot be set in the interface, but are defined as global variables and set in the procedure `initialize-hidden-variables`. These variables are:

* _undirected-communication_: the chance that the communication with agents from other collaborative networks is undirected, by default 0.5;

* _small-movement_: the part of the `move-probability` from the interface that is the probability that agents move every round except the 0 rounds (0, 5, 10, ...), by default 0.2; and

* _color-movement_: the influence the color has on the chance that agents move to a next arguments, by default 200.

## Some assumptions and definitions

**Maybe move this somehow to the motivation/introduction, that people have a general idea what the model is about before they get into details?**

* _Discovered arguments_: an argument that is connected by a cyan discovery relation to the rest of the theory (the argument is not gray anymore nor turquoise).

* _Turquoise arguments_: arguments that are discovered by discovering an attack relation, but agents did not yet find the discovery relation that connects it to the other arguments in the theory.

* _Degree of exploration_: the level at which an argument is explored, gray arguments (level 0) are unknown to agents and red arguments (level 6) are fully explored. The levels in between are: lime (1); green (2); yellow (3); brown (4); and orange (5). A way to interpret this is to assume that each time step corresponds to one research day. Each of the 6 levels of an argument can be explored in 5 steps, and hence each argument represents a hypothesis that needs 30 research day to be fully investigated.

* _Root/start_: refers to the root of a theory

**We can also add what it means to be attacked/defended/admissible, should solve the "defensibility"-question, maybe wait for the definition in the paper**

**Definition of social networks seems to fit here as well, do we want to add something about promising theories in the documentation?**

## Setup of the landscape

At the beginning of a run a landscape is created. Trees of arguments (the theories) are built, attack relations on the arguments are defined and the agents are created and distributed over the theories.

### Building the objective discovery landscape

For each theory a tree is built, its root is called `start`. The depth of the theory, as can be chosen in the interface, sets the number of arguments: `theory-depth` = x means x layers of arguments. The root has 4 child-arguments, after that, if a next layer exists, each argument has also 4 child-arguments, otherwise 0. Each of these child-arguments is connected by a directed discovery relation.

Each argument has a memory for:

* the theory it belongs to (`(start x)`);
* how often it is visited/researched by an agent (a number); and
* whether it was just fully researched (turned red in the current round) (`true` or `false`).

### Defining the attack relation

On the created landscape an attack relation is added. Each argument has, with `attack-probability` corresponding to the theory the argument belongs to, an incoming attack from an argument belonging to another theory. Once the random attacks are created, the best theory (`(start 0)`), has to make sure that it is fully defended. It creates attacks to arguments that attack one of its arguments, until it has defended all its attacked arguments.

### Agents

Agents are randomly distributed over the available roots of the theories. Then they form `collaborator-networks`. If the switch `within-theory` is on in the interface, such networks are created with agents that start on the same theory, if the switch is off networks are randomly created. Such networks have at most 5 agents. In case the networks are random all networks have exactly 5 agents, if the networks are created within theories there can be networks with less than 5 agents.

Agents have a memory in which they keep track of the following:

* `collaborator-network`: a list of at most four other agents and herself that form the network she communicates with:

`[(agent a) ... (agent i)]`;

* `subjective-relations`: a list of relations that an agent knows of, an entry has three elements, the first is either an "a" (the relation is an attack) or a "d" (the relation is a discovery), the second is the argument from which the relation starts and the last element is the argument that is attacked/the child-argument:

`[["a" (argument attacking) (argument attacked)] ... ["d" (argument parent-argument) (argument child-argument)] ...]`;

* `subjective-arguments`: a list of arguments that an agent knows of, an entry has two elements: 1. the argument; 2. the color of the argument (this might be a color with higher value, less researched, than the current color, because she only remembers the color she saw/heard):

`[[(argument a) colora] ... [(argument i) colori] ...]`;

* `times-jumped` and `theory-jump` (both numbers): the first to keep track of how often agents in general jump with a given strategy, the second to keep track of how often an agent considers jumping;

* `current-theory-info`: this list contains for each theory an entry that has the following elements, the second depending on the memory of the agent: 1. the theory the entry belongs to; and 2. the number of admissible (not attacked) arguments:

`[[(start 0) ad0] [(start 2nd) ad2nd] ...]`;

* `cur-best-th`: a list with the current best theories according to the current memory of the agent, this is updated every 5 time steps:

`[(start i1) ... (start ij)]`;

* `th-args` and `th_relations`: lists of arguments and relations, that the agent is prepared to share with agents from other collaborative networks

`[(argument 1) ... (argument i)]`

and

`[["d" (argument a1) (argument a2)] ... ["a" (argument i1) (argument i2)] ...]`; and

* `admissibile-subj-args`: the list of arguments from the `subjective-arguments` that are admissible (not attacked or attacked and defended):

`[(argument a) ... (argument k)]`.

## Basic behavior of agents and the landscape

After the landscape is setup the run starts. Agents start exploring the landscape, new arguments are relations are found and agents can move to visible arguments in the landscape. Every five rounds agents communicate with agents from their own collaborative network and possibly with agents from outside their network.

### Update of the memory

Every time step the agents update their memory. The current argument is added to the list of `subjective-arguments`, then the relations are updated (including the subjective arguments that are discovered by these relations). The current argument, the relations to/from it and the arguments these relations connect belong to the neighborhood information of that argument and are saved in the memory of the agent as `neighborargs`.

Every five plus four time steps (4, 9, 14, ...), once the agents have an updated memory they create a list of arguments and a list of relations that they are prepared to share with agents from other networks (`th-args` and `th-relations`). How this is done depends on the social behavior of the agents (`reliable` or `biased`) and whether they share `all` or just the information from their current `neighborhood` (the `neighborargs`).

First agents share what they know within their own `collaborator-network`. In this network they share all information with everyone: after this round of sharing the agents in the same network have the same memory. Then, with probability `social-collaboration` from the interface, agents share information with agents from other networks. With a chance of `undirected-communication`, one of the "hidden variables", this is done directed: the agent only provides information, as by writing a paper. In the other cases agents share information, as in a discussion. The information that is shared depends on what the agent is willing to share.

Agents that receive information from an agent in another network cannot do research in the same time step. This means that they do not move around or contribute towards the changing of the color of the argument. Only if the exchange is undirected, the current agent will not do research. For these agents `communicating` is set to `true`. The sections _Agents move around_ and _Update of the landscape_ do not apply to the `communicating` agents.

After updating the memory and sharing information, the agent removes all duplicate arguments from her memory. This also includes entries for the same argument but with different colors, only the entry better research color is kept.

### Agents move around

Each time step agents, with `communicating` = `false` and that are not working on a not fully researched not-admissible argument, consider the arguments which they can work on next. Such an argument:

* has to be a child-argument of the current argument;
* should be discovered, it should not be discovered by discovering an attack relation that involves the argument;
* it should not be red with another agent from the same network already working on it; and
* the discovery relation should be discovered as well.

The probability that an agent moves to such a possible next argument depends on the color of the argument she is currently working on and the time step. How much the color influences the probability depends on the value of `color-move`, one of the "hidden variables".

Every time step an agent moves with a probability of `small-movement` (a "hidden variable") of the total `move-probability` to a next argument. Every 5th time step (5, 10, 15, ...) the agent moves with the full `move-probability` that is set in the interface.

If an agent is working on an argument that is fully researched, the color is red, she will try to move to a next argument. If that is not possible, she will move one step back (if no other agent from the same network is working on that argument) and if that is not possible, she will move to a discovered, not fully researched and attacked argument in the same theory with no agent from the same network working on it.

Agents, that did not communicate and are working on a not fully researched and not-admissible argument try to find a defense for their argument. This is done by staying on the current argument until it is red (then everything is discovered that can be discovered) or a defense from one of its child-arguments is discovered. Such a defense attack does not have to be discovered yet. If such a defending-child-argument exists, the agent will move to this argument. Agents that move like this cannot move in the regular way that time step.

### Update of the landscape

If agents have been working for `research-speed` time steps on an argument, the argument changes color, if the argument was not yet fully researched (not red). A new child-argument becomes visible for arguments that just turned yellow, brown, orange or red and still have 4, 3, 2 resp. 1 undiscovered child-argument.

The landscape is updated every five time steps (5, 10, 15, ...). If there are attack relations that are not discovered yet, agents can find these. With `visibility-probability` attacks (in or out) are found.

An argument that was fully researched in this time step (it turned red), discovers immediately all its relations: attacks and discoveries + the other ends. Discovery relations that connect two discovered (not gray nor turquoise) arguments are also discovered.

## Strategies

Agents do not always keep working on the same theory. When there memory suggest that another theory is better, they will consider jumping to that theory. What it means for a theory to be better depends on the strategy.

### Computations for the strategy

Every 5th plus 4 time steps (4, 9, 14, ...), after agents updated their memories and shared with agents in (and outside) their own network, agents will reconsider working on the theory they are working on. The criterion on which they base this is the number of admissible arguments of the theory: the number of discovered, admissible arguments (they may be attacked, but then they are also defended).

Each agent computes for her `current-theory-info` the number of admissible arguments, with respect to her current memory. This is done in a recursive manner, in which everytime not defended attacked arguments are added to the not-admissible list of arguments. The `current-theory-info` is updated with for each theory the number of admissible arguments (either not attacked or defended arguments).

Based on the information from the updated `current-theory-info` the best theory is calculated. The best theory is the theory with the highest number of admissible arguments. At the moment this is absolute: the total number of discovered arguments in that theory does not influence this. Other theories can qualify as one of the best theories as well. This is the case if `strategy-threshold` * (number of admissible arguments of best theory) <= (number of admissible arguments of this theory). The best theory can also be unique, in that case there is no other theory that has a number of admissible arguments that is close enough to the number of admissible arguments of this best theory.

### Acting on the strategy

Once the current best theory is computed, agents will reconsider the theory they are working on. If that is not one of the current best theories, they consider to jump.

If agents think often enough that they should jump to another theory, often enough depends on the `jump-threshold` of the interface, the agent jumps to a/the current best theory and starts working on that theory. If the agent is aware of an argument from that theory, she will jump to a random, argument of that theory in her memory, otherwise she will jump to the root.

# The Results

**TODO, maybe discuss how we want this, then I can adjust some things**

We ran the program with the following fixed variable settings:

* _attack-probability-best_, _attack-probability-2nd_ and _attack-probability-3rd_: 0.30;
* _strategy-threshold_: 0.9;
* _jump-threshold_: 10;
* _move-probability_: 0.5;
* _visibility-probability_: 0.5;
* _research-speed_: 5; and
* _sharing_: neighborhood.

The following settings were varied:

* _number-of-theories_: 2 and 3;
* _theory-depth_: 2, 3 and 4;
* _scientists_: 10, 20, 30, 40, 70 and 100;
* _within-theory_: on and off;
* _social-collaboration_: 0.0, 0.3, 0.5 and 1.0; and
* _social-actions_: reliable and biased.

**TODO: definition of success**

See the paper for a discussion of the obtained results.

**These are old plots**

![Success, reliable, homogeneous groups](file:Successrelhomog.jpg)

![Success, reliable, heterogeneous groups](file:Successrelheterog.jpg)