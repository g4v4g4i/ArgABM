# ArgABM
An agent-based model for scientific inquiry based on abstract argumentation

# Motivation

# Introduction

# Documentation

## Interface

Buttons

* _setup_ creates the landscape, including attacks and distributes the scientists/agents over this landscape

* _go_ lets the program run one time step

* _go (infinite, has a small circle)_ lets the program run infinitely many steps, or until the button is clicked again

Landscape settings

* _number-of-theories_ sets the number of theories/trees that will be created

* _theory-depth_ sets the depth of the tree

* _attack-probability-best_ the probability that an argument of the objective best theory has an incoming attack

* _attack-probability-2nd_ the probability that an argument of the 2nd theory has an incoming attack

* _attack-probability-3rd_ if there are three theories, the probability that an argument of the 3rd theory has an incoming attack

Strategy settings

* _strategy-threshold_ defines the threshold within which the number of admissible arguments is still considered good, if this threshold gets higher, the interval of acceptable values gets smaller

* _jump-threshold_ is the number of times an agent has to consider jumping before it really jumps to another theory

Agent settings

* _scientists_ the number of agents that will explore the landscape

* _move-probability_ the probability that agents move to a next argument while exploring the landscape

* _visibility-probability_ the probability that new attacks are discovered by agents

* _research-speed_ the time an agent has to work on an argument before it will change color

* _within-theory_ here the kind of collaborative network is set to agents that start on the same theory (on) or randomly chosen agents (off)

* _social-collaboration_ the probability that an agent communicates with an agent or network outside its own

* _social-actions_ here the behavior of the agents that communicate with agents outside their own can be set: "reliable" is the setting where they share all information about the current theory: including attacks; "biased" agents do not share the attacks to their current theory

* _sharing_ makes it possible to choose what the agents share with agents from other networks: either their whole memory ("all") or only the information in their direct "neighborhood"

* _network-structure_ determines the structure in which the collaborator-networks are connected and with how many agents information is shared

Plots

* the _Popularity_ plot shows for every theory the number of agents working on it

## Some language definitions

_Discovered arguments_: an argument that is not gray anymore nor turquoise (discovered by discovering an attack relation)
_(Not) fully researched arguments_: the level at which an argument is explored, a fully researched argument will be red
_Root/start_: refers to the root of a theory

## Setup of the landscape

### Building the objective landscape

For each theory a tree is built, its root is called "start". The depth of the theory, as can be chosen in the interface, sets the number of arguments. The root has 4 child-arguments, after that, if a next layer exists, each argument has also 4 child-arguments, otherwise 0. Each of these child-arguments is connected by a directed discovery relation.

Each argument has a memory for the theory it belongs to, how often it is visited/researched by an agent and whether it was just fully researched (turned red in the current round).

### Defining the attack relation

On the created landscape an attack relation is added. Each argument has, with attack-probability corresponding to the theory the argument belongs to, an incoming attack from an argument belonging to another theory. Once the random attacks are created, the best theory (theory 0), has to make sure that it is fully defended. It creates attacks to arguments that attack one of its arguments, until it has defended all its attacked arguments.

### Agents

Agents are randomly distributed over the available theories. Then they form "collaborator-networks". If the switch "within-theory" is on in the interface, such networks are created with agents that start on the same theory, if the switch is off networks are randomly created. Such networks have at most 5 agents. In case the networks are random all networks have exactly 5 agents, if the networks are created within theories there can be networks with less than 5 agents.

A list of all collaborator-networks is saved in the global variable colla-networks:

`[[(agents a1) ... (agent a5)] ... [(agent i1) ... (agent i5)] ... ]`

The collaborator-networks are connected to each other, according to the choice in the interface: cycle (every network is connected to two other networs); wheel (every network is connected to two other networks and the royal network, which is connected to all other networks); or complete (every network is connected to every other network). These stuctures will be used when the representative agent from one network communicates with representative agents from other networks.

The social structures are saved in the global variable share-structure, which for the cycle has the form:

`[[[(agents aa1) ... (agent aa5)] ... [(agents ac1) ... (agent ac5)]] ... [[(agents ia1) ... (agent ia5)] ... [(agent ic1) ... (agent ic5)]] ... ]`

Agents have a memory in which they keep track of the following:

* _collaborator-network_: a list of at most four other agents and itself that form the network it communicates with

* _subjective-relations_: a list of relations that an agent knows of, an entry has three elements, the first is either an "a" (the relation is an attack) or an "d" (the relation is a discovery), the second is the argument from which the relation starts and the last element is the argument that is attacked/the child-argument:

`[["a" (argument attacking) (argument attacked)] ... ["d" (argument parent-argument) (argument child-argument)] ...]`

* _subjective-arguments_: a list of arguments that an agent knows of, an entry has two elements: 1. the argument; 2. the color of the argument (this might be a color with higher value, less researched, than the current color, because it only remembers the color it saw/heard of):

`[[(argument a) colora] ... [(argument i) colori] ...]`

* _times-jumped_ and _theory-jump_: the first to keep track of how often agents in general jump with a given strategy, the second to keep track of how often an agent considers jumping

* _current-theory-info_: this list contains for each theory an entry that has the following elements, the second depending on the memory of the agent: 1. the theory the entry belongs to; and 2. the number of admissible (not attacked) arguments:

`[[(start 0) ad0] [(start 2nd) ad2nd] ...]`

* _cur-best-th_: the current best theory according to the current memory of the agent, this is updated every 5 time steps

* _th-args_ and th_relations_: lists of arguments and relations, that the agent is prepared to share with agents from other collaborative networks

* _to-add-mem-argu_ and _to-add-mem-rel_: lists of arguments and relations that the agent has to add to its own memory as a result of communication

* _admissibile-subj-args_: the list of arguments from the subjective-arguments that are admissible (not attacked or attacked and defended)

* _neighborhood_: the neighboring arguments and relations of the argument it is currently working on

* _moved_: true if the agent moved already in that time step

* _rep-agent_ and _communicating_: if the agent is in that communication round the representative agent and how many time steps it takes this agent to process all the new information it has obtained

## Basic behavior of agents and the landscape

### Update of the memory

Every time step the agents update their memory. The current argument is added to the list of subjective-arguments, then the relations are updated (including the subjective arguments that are discovered by these relations). The current argument, the relations to/from it and the arguments these relations connect belong to the neighborhood information of that argument and are saved in the memory of the agent as "neighborargs".

Every five plus four time steps (4, 9, 14, ...), agents share their memory with other agents. First agents share what they know within their own collaborator-network. In this network they share all information with everyone: after this round of sharing the agents in the same network have the same memory.

After this, from every network one random agent is chosen that will be the representative agent of that network in communicating with other networks. These representative agents create a list of arguments and a list of relations that they are prepared to share with other representative agents. How this is done depends on the social behavior of the agents (reliable or biased) and whether they share all or just the information from their current neighborhood.

Then the representative agents share the part of the memory they want to share with the agents from the networks that neighbor their own in the network structure. The agents collect all the new arguments and relations. At most 30 new entries are added to their memory and at most 10 entries per day.

The time step that the agents share their information is already lost. Depending on how many new entries the value of the variable communicating is increased, with a maximum of three. For communicating time steps the agents cannot do research: they do not move around and the landscape is not affected by their presence. Every fifth round (0, 5, 10, ...) all agents do not communicate: every agent can move around and affects the landscape.

After updating the memory and sharing information, the agent removes all duplicate arguments from its memory. This also includes entries with arguments that were part of the memory but for which a new entry with better research color is found.

### Agents move around

Each time step agents, that did not communicate with agents from other networks and are not working on a not fully researched not-admissible argument, consider the arguments which they can work on next. Such an argument has to be a child-argument of the current argument, should be discovered, it should not be discovered by discovering an attack relation that involves the argument, it should not be red with another agent already working on it and the discovery relation should be discovered as well.

The probability that an agent moves to such a possible next argument depends on the color of the argument it is currently working on (but the color influences this probability only a little) and the time step. Every time step an agent moves with a probability of 1/5 of the total move-probability to a next argument. Every 5th time step (5, 10, 15, ...) the agent moves with the full move-probability that is set in the interface.

If an agent is working on an argument that is fully researched, the color is red, it will try to move to a next argument, if that is not possible, it will move one step back (if no other agent is working on that argument) and if that is not possible, it will move to a discovered, not fully researched and attacked argument in the same theory with no agent working on it.

Agents, that did not communicate and are working on a not fully researched and not-admissible argument try to find a defense for their argument. This is done by staying on the current argument until it is red (then everything is discovered that can be discovered) or a defense from one of its child-arguments is discovered. Such a defense attack does not have to be discovered yet. If such a defending-child-argument exists, the agent will move to this argument. Agents that move like this cannot move in the regular way that time step.

### Update of the landscape

The landscape is updated every five time steps (5, 10, 15, ...). A new child-argument becomes visible for arguments that are yellow, brown, orange or red and still have an undiscovered child-argument. With visibility-probability (depending a little bit, even less than with the move probability, on the color) attacks are discovered. First the in-attacks, then the out-attacks.

If agents have been working for research-speed time steps on an argument, the argument changes color, if the argument was not yet fully researched. Discovery relations that connect two non-gray colored arguments (one may be turquoise, discovered by attack) are also discovered.

An argument that was fully researched in this time step (it turned red), discovers immediately all its relations: attacks and discoveries + the other ends.

## Strategies

### Computations for the strategies

After updating the memory of the agents, agents will reconsider working on the theory they are working on. How they do this depends on the strategy. The criterion on which they base this is the number of admissible arguments of the theory: the number of discovered, admissible arguments (they may be attacked, but then they are also defended).

Each agent computes for its "current-theory-info" the number of admissible arguments, with respect to its current memory. Based on the information from the current-theory-info the best theory is calculated. The best theory can be unique, in that case there is no other theory that has a number of admissible arguments that is close enough to the number of admissible arguments of this best theory (close enough depends on the "strategy-threshold" in the interface).

### Acting on the strategy

Once the current best theory is computed, agents will reconsider the theory they are working on. If that is not the current best theory, they consider to jump.

If agents think often enough that they should jump to another theory, often enough depends on the "jump-threshold" of the interface, the agent jumps to a/the current best theory and starts working on that theory. If the agent is aware of an argument from that theory, it will jump to a random, argument of that theory in its memory, otherwise it will jump to the root.