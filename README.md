# UNDER CONSTRUCTION

# ArgABM
An agent-based model for scientific inquiry based on abstract argumentation

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