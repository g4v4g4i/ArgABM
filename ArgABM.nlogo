extensions[profiler]

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
  max-learn small-movement color-move colla-networks share-structure ctiho startsargum]

; includes
; __includes ["setup.nls" "behavior.nls" "strategies.nls" "run-many.nls" "testprocedures.nls"]



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

; run-many.nls starts here
; the run-many procedure is used to obtain results
; it lets the program run several times for a few 
; setups at once
; the results are put into a .txt file that can be
; used for comparison and making plots for papers/slides





; the procedure that lets the program run several times
to run-many
  clear-all
  let try 0  ; the number of the run with the same setup
  let cycle 0  ; the number of ticks
  let max-cycle 0  ; time limit for one try/run
  ; lists that collect for each setup the percentage of 
  ; discovered arguments (of the best theory)
  let perc-disc-argu []  
  let perc-disc-best-argu []
  let find-good-m 0  ; number of successful runs, monist
  let find-good-p 0  ; number of successful runs, pluralist
  let steps-needed []  ; time steps needed for one run
  let popularity []  ; list with the number of researchers per theory
  let tot-arguments 0  ; the total number of arguments
  set number-of-theories-many 2  ; initial number of theories
  set theory-depth-many 3  ; initial depth
  set scientists-many 10  ; initial number of scientists
  let disc-arguments 0  ; number of discovered arguments
  let disc-best-arguments 0  ; number of discovered best arguments
  let tot-best-arguments 0  ; total number of best arguments
  let jumps 0  ; number of jumps
  
  ; different setups write results to different files
  ifelse network-structure = "cycle" [
    ifelse social-actions = "biased" [
      ifelse within-theory [
        file-open "Resultscycb_within.txt"
      ][
      file-open "Resultscycb_off.txt"
      ]
    ][
    ifelse within-theory [
      file-open "Resultscycr_within.txt"
    ][
    file-open "Resultscycr_off.txt"
    ]
    ]
  ][
  ifelse network-structure = "wheel" [
    ifelse social-actions = "biased" [
      ifelse within-theory [
        file-open "Resultswhb_within.txt"
      ][
      file-open "Resultswhb_off.txt"
      ]
    ][
    ifelse within-theory [
      file-open "Resultswhr_within.txt"
    ][
    file-open "Resultswhr_off.txt"
    ]
    ]
  ][
  if network-structure = "complete" [
    ifelse social-actions = "biased" [
      ifelse within-theory [
        file-open "Resultscomb_within.txt"
      ][
      file-open "Resultscomb_off.txt"
      ]
    ][
    ifelse within-theory [
      file-open "Resultscomr_within.txt"
    ][
    file-open "Resultscomr_off.txt"
    ]
    ]
  ]
  ]
  ]
  
  ; the settings from the interface are 
  ; written in the .txt files
  file-write "New run for results times "
  file-print date-and-time
  file-print ""
  file-write "Probability of attacks towards the best theory"
  file-print attack-probability-best
  file-print ""
  file-write "Probability of attacks towards the sencond theory:"
  file-print attack-probability-2nd
  file-print ""
  file-write "Probability of attacks towards the thrid theory:"
  file-print attack-probability-3rd
  file-print ""
  file-write "Probability that new arguments pop-up: "
  file-print visibility-probability
  file-print ""
  file-write "Change that an researcher moves to the next argument: "
  file-print move-probability
  file-print ""
  file-write "Threshold of best values for strategies"
  file-print strategy-threshold
  file-print ""
  file-write "Number of times an researchers has to consider jumping before jumping: "
  file-print jump-threshold
  file-print ""
  file-write "Number of steps before the color of an argument changes: "
  file-print research-speed
  file-print ""
  file-write "Network structure of the collaborator-networks: "
  file-print network-structure
  file-print "" 
  file-print "actions, within theory: "
  file-print social-actions
  file-print within-theory
  file-print ""
  file-print ""
  file-print ""
  
  while [number-of-theories-many != 4][
    while [theory-depth-many != 4][
      set setup-time []
      set setup-discovered []
      set setup-successful-m []
      set setup-successful-p []
      set setup-discovered-best []
      set setup-jumps []
      clear-turtles
      create-discovery-landscape number-of-theories-many theory-depth-many
      set tot-arguments count turtles with [breed = arguments or breed = starts]
      set max-cycle precision (15 * tot-arguments) -3
      
      while [scientists-many <= 100][
        while [try != 100][ 
          
          ; to keep track of the current setup of the run
          write "#theories, depth, scientists, actions, structure, within-theory, try: "
          print ""
          show number-of-theories-many
          show theory-depth-many
          show scientists-many
          show social-actions
          show network-structure
          show within-theory
          show try
          
          setup-many
          set cycle 1
          go
          ; the program is stopped once all researchers are working 
          ; on a fully discovered theory
          while [cycle != max-cycle and any? arguments with [color != red and
            [myscientists] of mytheory !=  0]][
            go
            set cycle cycle + 1
          ]
          
          set steps-needed lput cycle steps-needed
          ; compute researcher distribution over the theories
          ask starts [
            set popularity lput myscientists popularity
          ]
          ask start 0 [
            if max popularity = myscientists and max popularity = scientists-many [
              set find-good-m find-good-m + 1
            ]
            if max popularity = myscientists [
              set find-good-p find-good-p + 1
            ]
          ]
          ask researchers [
            set jumps times-jumped + jumps
          ]
          
          ; for the computation of the output
          set disc-arguments count turtles with [(breed = arguments or
	    breed = starts) and color != gray and color != turquoise]
          set disc-best-arguments count turtles with [(breed = arguments or
	    breed = starts) and color != gray and color != turquoise and
	    mytheory = start 0]
          set tot-best-arguments count turtles with [(breed = arguments or
	    breed = starts) and mytheory = start 0]
          set perc-disc-argu lput ((disc-arguments / tot-arguments) * 100)
	    perc-disc-argu
          set perc-disc-best-argu lput ((disc-best-arguments /
	    tot-best-arguments) * 100) perc-disc-best-argu
          set popularity []
          set colla-networks []
          set share-structure []
          set try try + 1
        ]
        
        ; add the results from the current setup to the
        ; list of already obtained results
        set setup-time lput mean steps-needed setup-time
        set setup-successful-m lput ((find-good-m / try) * 100)
	  setup-successful-m
        set setup-successful-p lput ((find-good-p / try) * 100)
	  setup-successful-p
        set setup-discovered lput mean perc-disc-argu
	  setup-discovered
        set setup-discovered-best lput mean perc-disc-best-argu
	  setup-discovered-best
        set setup-jumps lput ((jumps / try) / scientists-many)
	  setup-jumps
        
        ; reset some of the variables
        set try 0
        set perc-disc-argu []
        set perc-disc-best-argu []
        set find-good-m 0
        set find-good-p 0
        set steps-needed []
        set disc-arguments 0
        set disc-best-arguments 0
        set tot-best-arguments 0
        set jumps 0
        ifelse scientists-many < 40[
          set scientists-many scientists-many + 10
        ][
        set scientists-many scientists-many + 30
        ]
      ]
      
      ; add the results to the file
      file-write "Time, successful, discovered, discovered of best, jumps: "
      file-print ""
      file-write "time"
      file-type number-of-theories-many
      file-type theory-depth-many
      file-type " = "
      file-print setup-time
      file-write "suc-m"
      file-type number-of-theories-many
      file-type theory-depth-many
      file-type " = "
      file-print setup-successful-m
      file-write "suc-p"
      file-type number-of-theories-many
      file-type theory-depth-many
      file-type " = "
      file-print setup-successful-p
      file-write "disc"
      file-type number-of-theories-many
      file-type theory-depth-many
      file-type " = "
      file-print setup-discovered
      file-write "discb"
      file-type number-of-theories-many
      file-type theory-depth-many
      file-type " = "
      file-print setup-discovered-best
      file-write "jumps"
      file-type number-of-theories-many
      file-type theory-depth-many
      file-write " = "
      file-print setup-jumps
      file-print ""
      file-print ""
      file-print ""
      file-print ""
      set scientists-many 10
      set theory-depth-many theory-depth-many + 1
    ]
    set theory-depth-many 3
    set number-of-theories-many number-of-theories-many + 1
  ]
  let k 0
  while [k < 6][
    ifelse k mod 6 = 0 [
      ;file-print "plot x, time23, 'x--r', x, time24, 'p:m', x, time33, '^-.k', x, time34, '*-c');"
      ;file-print "legend ($th2, depth 3$, $th2, depth 4$, $th3, depth 3$, $th3, depth 4$);"
      file-print "plot (x, time23, 'x--r', x, time33, '^-.k');"
      file-print "legend ($th2, depth 3$, $th3, depth 3$);"
      file-print "ylabel ($Time-steps needed$);"
      file-print "axis ([5, 105, 0, 1000]);"
      file-write "title ($Time needed for: "
    ][
    ifelse k mod 6 = 1 [
      ;file-print "plot (x, suc23, 'x--r', x, suc24, 'p:m', x, suc33, '^-.k', x, suc34, '*-c');"
      file-print "plot (x, suc-m23, 'x--r', x, suc-m33, '^-.k');"
      file-print "ylabel ($Number of successful runs$);"
      file-print "axis ([5, 105, 0, 105]);"
      file-write "title ($Monist success for: "
    ][
    ifelse k mod 6 = 2 [
      ;file-print "plot (x, suc23, 'x--r', x, suc24, 'p:m', x, suc33, '^-.k', x, suc34, '*-c');"
      file-print "plot (x, suc-p23, 'x--r', x, suc-p33, '^-.k');"
      file-print "ylabel ($Number of successful runs$);"
      file-print "axis ([5, 105, 0, 105]);"
      file-write "title ($Pluralist success for: "
    ][
    ifelse k mod 6 = 3 [
      ;file-print "plot (x, disc23, 'x--r', x, disc24, 'p:m', x, disc33, '^-.k', x, disc34, '*-c');"
      file-print "plot (x, disc23, 'x--r', x, disc33, '^-.k');"
      file-print "ylabel ($Percentage of discovered arguments$);"
      file-print "axis ([5, 105, 0, 105]);"
      file-write "title ($Percentage discovered arguments for: "
    ][
    ifelse k mod 6 = 4[
      ;file-print "plot (x, discb23, 'x--r', x, discb24, 'p:m', x, discb33, '^-.k', x, discb34, '*-c');"
      file-print "plot (x, discb23, 'x--r', x, discb33, '^-.k');"
      file-print "ylabel ($Percentage of discovered arguments, best theory$);"
      file-print "axis ([5, 105, 0, 105]);"
      file-write "title ($Percentage discovered arguments, best theory, for: "
    ][
    ;file-print "plot (x, jumps23, 'x--r', x, jumps24, 'p:m', x, jumps33, '^-.k', x, jumps34, '*-c');"
    file-print "plot x, jumps23, 'x--r', x, jumps33, '^-.k');"
    file-print "ylabel ($Average number of jumps per researcher$);"
    file-print "axis ([5, 105, 0, 2.5]);"
    file-write "title ($Average number of jumps per researcher for: "
    ]
    ]
    ]
    ]
    ]
    file-write social-actions
    file-write "researchers, within th.: "
    file-write within-theory
    file-print "$);"
    if k mod 5 != 0 [
      ;file-print "legend ($th2, depth 3$, $th2, depth 4$, $th3, depth 3$, $th3, depth 4$, $location$, $southeast$);"
      file-print "legend ($th2, depth 3$, $th3, depth 3$, $location$, $southeast$);"
    ]
    file-print "xlabel ($Number of scientists$);"
    file-print ""
    file-print ""
    file-print ""
    file-print ""
    file-print ""
    set k k + 1
  ]
  file-flush
end


; the setup for a run-many
to setup-many
  ; instead of clear-all, the globals should not be cleared
	setupcore task [
		clear-turtles
		clear-patches
		clear-drawing
		clear-all-plots
		clear-output
	]
	number-of-theories-many theory-depth-many scientists-many
end
;run-many.nls ends here

;setup.nls starts here
; the setup procedures for
; 1. the hidden variables (not set in the interface)
; 2. building the argumentative landscape with
;    attacks and discovery relations
; 3. populate the landscape with researchers


; the core-setup procedure:
; the hidden variables (not set in the interface)
; it creates a landscape of arguments and a discovery relation
; on this landscape; attacks are defined;
; the researchers are distributed over the theories
to setupcore [clearing numberoftheories theorydepth scientistsno]
  run clearing
  initialize-hidden-variables
  create-discovery-landscape numberoftheories theorydepth
  define-attack-relation
  distribute-researchers scientistsno
  reset-ticks
	ask researchers [
		set lastalist []
		set lastblist []
		set lastalistafter []
	]	
end

; the setup for a normal run
to setup
	setupcore task [clear-all] number-of-theories theory-depth scientists
end


; procedure in which the variables that are not mentioned 
; in the interface can be set
to initialize-hidden-variables
  ; the number of arguments that an researcher can learn
  ; each tick
  set max-learn 10
 
  ; the probability that researchers move every round is
  ; only small-movement * move-probability
  set small-movement 0.2
 
  ; influence color on move probability
  set color-move 200
end





; a landscape of arguments and a discovery relation
; on these arguments is defined
to create-discovery-landscape [numberoftheories theorydepth]
  ; at the start arguments and starts are a circle
  set-default-shape arguments "circle"
  set-default-shape starts "circle"
  
  repeat numberoftheories [ ; trees are created theory for theory
    create-starts 1 [
      ; variables for color, the theory it belongs to
      ; and whether it just turned red are initialized
      set color lime
      set current-start true
      set mytheory self
      set full-research false
    ]
    let i 0
    while [i < theorydepth] [
      create-arguments ( 4 ^ (theorydepth - i))[
        ; variables for color, the theory it belongs to
        ; and whether it just turned red are initialized
        set color gray
        set current-argument true
        set mytheory one-of starts with [current-start]
        set full-research false
      ]
      set i i + 1
    ]
    
    ; with the created turtles (arguments and roots)
    ; trees are build, one for each start/root
    create-discovery-trees
    
    ask starts [ ; to make sure that all theories are visible
      create-starters-with other starts [set color black]
      set current-start false
    ]
    ask arguments [set current-argument false]
  ]
  ; set the shape of the arguments of the best theory different from a circle
  ask turtles with [(breed = starts or breed = arguments) and
    mytheory = start 0 ][
    set shape "triangle"
  ]
end





; create the theory discovery trees
; each node has 0 or 4 child-arguments
; starting from the starts as root
to create-discovery-trees
  ; first level with starts as roots
  ask starts with [count out-discovery-neighbors = 0 and current-start][
    repeat 4 [
      if any? arguments with [count in-discovery-neighbors = 0 and
        current-argument] [
        create-discovery-to one-of arguments with [
          count in-discovery-neighbors = 0 and current-argument]
      ]
    ]
  ]
  ; then adding all the normal arguments
  while [any? arguments with [count in-discovery-neighbors = 0 and
    current-argument]][
    ask arguments with [count in-discovery-neighbors = 1 and
      count out-discovery-neighbors < 4 and current-argument][
      let curarg self
      repeat (4 - count out-discovery-neighbors) [
        if any? other arguments with [count in-discovery-neighbors = 0 and
          current-argument and not out-discovery-neighbor? curarg][
          create-discovery-to one-of other arguments with
	        [count in-discovery-neighbors = 0 and current-argument]
          ]
      ]
    ]
  ]
end





; on the created landscape an attack relation is defined
; attacks occur only between theories
; the probability that an argument is attacked by another argument
; depends on the attack-probability for the theory the attacked
; argument belongs to, as can be set in the interface
; one theory, the objective best, defends all its arguments
to define-attack-relation
  ; first the random attacks are defined
  define-attack-relation-create-attacks
  
  ; then the best theory defends itself
  define-attack-relation-defend-best
  
  ; the arguments and relations are spread over the patches
  define-attack-relation-visualize
end





; this procedure creates the random attacks from one theory to another
to define-attack-relation-create-attacks
  ask turtles with [breed = starts or breed = arguments][
    ; variables for the current argument, the theory it belongs to,
    ; a random number between 0.00 and 1.00 and a list of theories
    let askargu self
    let curtheory mytheory
    let attack-random random-float 1.00
    let starts-list []
    ask starts [
      set starts-list lput who starts-list
    ]
    set starts-list sort starts-list
    
    ; with attack-probability-2nd from the interface an attack towards
    ; the current argument is created
    ifelse number-of-theories = 2[
      if attack-random < attack-probability-2nd and curtheory != start 0 [
        create-attack-from one-of other turtles with [(breed = starts or
	      breed = arguments)and mytheory != curtheory and not
	      (in-discovery-neighbor? askargu or in-attack-neighbor? askargu or
	      out-discovery-neighbor? askargu or out-attack-neighbor? askargu)][
        set color gray
            ]
      ]
    ][
    
    ; when there are three theories both attack-probability-2nd and -3rd are
    ; considered to create attacks, depending on the theory the current argument
    ; belongs to first for the third theory
    ifelse [who] of curtheory = max starts-list and attack-random <
      attack-probability-3rd [
      create-attack-from one-of other turtles with [(breed = starts or
        breed = arguments) and mytheory != curtheory and not
	      (in-discovery-neighbor? askargu or in-attack-neighbor? askargu or
	      out-discovery-neighbor? askargu or out-attack-neighbor? askargu)][
        set color gray
          ]
    ][
    ; then attacks towards arguments of the 2nd theory are created
    if [who] of curtheory != max starts-list and curtheory != start 0 and
      attack-random < attack-probability-2nd [
      create-attack-from one-of other turtles with [(breed = starts or
      breed = arguments) and mytheory != curtheory and not
      (in-discovery-neighbor? askargu or in-attack-neighbor? askargu or
	    out-discovery-neighbor? askargu or out-attack-neighbor? askargu)][
        set color gray
          ]
    ]
    ]
    ]
    
    ; if the current argument belongs to the objective best theory
    ; an attack towards this argument is created with attack-probability-best
    if attack-random < attack-probability-best and curtheory = start 0 [
      create-attack-from one-of other turtles with [(breed = starts or
      breed = arguments) and mytheory != curtheory and not
	    (in-discovery-neighbor? askargu or in-attack-neighbor? askargu or
	    out-discovery-neighbor? askargu or out-attack-neighbor? askargu)][
        set color gray
          ]
    ]
  ]
end





; after the random attacks are created, attacks coming from the best theory
; are added such that it defends itself completely
to define-attack-relation-defend-best
  ask turtles with [(breed = starts or breed = arguments) and
    mytheory = start 0][
    ; variable for the current argument
    let askargu self
    
    if any? in-attack-neighbors [
      ask in-attack-neighbors [
        ; variable for the attacking argument, if such an argument exists
        let askattack self
        ; a defending attack is only created if there is not yet an attack
        ; from an argument of the best theory towards the attacking argument
        if not any? in-attack-neighbors with [mytheory = start 0][
          create-attack-from one-of turtles with [(breed = starts or
	        breed = arguments) and mytheory = start 0 and not
	        (in-discovery-neighbor? askattack or in-attack-neighbor?
	        askattack or out-discovery-neighbor? askattack or
	        out-attack-neighbor? askattack) and not (self = askargu)][
            set color gray
          ]
        ]
      ]
    ]
  ]
end





; creates the visible tree, centered around 
; the root of the best theory
to define-attack-relation-visualize
  layout-radial
  turtles with [breed = arguments or breed = starts]
  links with [breed = discoveries or breed = starters]
  start 0
end





; in this procedure the researchers are created,
; including their memory and the social netoworks
; and they are distributed randomly over the theories
to distribute-researchers [scientistsno]
  set-default-shape researchers "person"
  
  ; the right number of researchers is created
  ; and the researcher variables are initialized
  researchers-create-scientists scientistsno
  
  ; create the network of collaborators
  ; if in the interface "within-theory" is on, collaborative networks are created
  ; among researchers that start from the same theory
  ; a network has at most 5 researchers in it
  ifelse within-theory [
    distribute-researchers-within-theory-on
  ][
  ; if "within-theory" is off in the interface, random collaborative networks
  ; are created, all of size 5
  distribute-researchers-within-theory-off    
  ]
  
  ; the memory of the researchers is created
  researchers-create-memory
  
  ; the networks in which researchers share with other groups is created
  create-networks
end





; create researchers and initialize their variables
to researchers-create-scientists [scientistsno]
  create-researchers scientistsno [
    ; the researchers are blue-colored
    ; and start on one of the roots
    set color blue
    move-to one-of starts
    
    ; the researcher-own variables are initialized
    set collaborator-network []
    set subjective-relations []
    set subjective-arguments []
    set times-jumped 0
    set communicating 0
    set moved false
    set rep-researcher false
    
    ; an researcher is always aware of all the theories
    ; the information the researcher has about a theory
    ; is collected in current-theory-info which has
    ; the form [[(start 0) no. adm args] ...]
    let theories []
    ask starts [
      let start-add []
      set start-add lput self start-add
      set start-add lput 0 start-add
      set theories lput start-add theories
    ]
    set current-theory-info theories
  ]
end





; create the memory of the researcher
; keep track of the theories and arguments that the researcher has visited
; an argument memory entry has two elements: the argument and its color:
; [[(argument a) colora] ... [(argument i) colori] ...]
to researchers-create-memory
  ask researchers [
    ; variables for the x and y coordinate and the theory of
    ; the current researcher
    let myx xcor
    let myy ycor
    let cur-theory one-of starts with [xcor = myx and ycor = myy]
    
    ; the current theory is added to the subjective-arguments list:
    ; [[(start x) lime]]
    let add-cur []
    set add-cur lput cur-theory add-cur
    set add-cur lput [color] of cur-theory add-cur
    set subjective-arguments lput add-cur subjective-arguments
  ]
end





; if in the interface "within-theory" is on, collaborative networks are created
; among researchers that start from the same theory
; a network has at most 5 researchers in it
to distribute-researchers-within-theory-on
  ask starts [
    ; variables for the x and y coordinates of the root
    ; and an empty list for the created network
    let myx xcor
    let myy ycor
    let cur-col []
    
    ; while there are more than five researchers on the root without a network
    ; networks of exactly five researchers are created
    if any? researchers with [xcor = myx and ycor = myy and
      empty? collaborator-network][
      while [count researchers with [xcor = myx and ycor = myy and
        empty? collaborator-network] > 5][
        ; five researchers are added to the list cur-col
        ; which is then set as the collaborator-network of each of these researchers
        ask n-of 5 researchers with [xcor = myx and ycor = myy and
	        empty? collaborator-network] [
          set cur-col lput self cur-col
        ]
        ask researchers with [member? self cur-col][
          set collaborator-network cur-col
        ]
        set cur-col []
      ]
      ; once there are five or less researchers without a network
      ; they form a network together
      ask researchers with [xcor = myx and ycor = myy and
        empty? collaborator-network] [
        set cur-col lput self cur-col
      ]
      ask researchers with [member? self cur-col][
        set collaborator-network cur-col
      ]
    ]
  ]
end





; if "within-theory" is off in the interface random collaborative networks
; are created, all of size 5
to distribute-researchers-within-theory-off
  while [any? researchers with [empty? collaborator-network]][
    ; variable that collects exactly five researchers for a network
    let cur-col []
    ask n-of 5 researchers with [empty? collaborator-network][
      set cur-col lput self cur-col
    ]
    ask researchers with [member? self cur-col][
      set collaborator-network cur-col
    ]
  ]
end





; computations for the Popularity plot
; it computes for every theory the number of
; researchers working on it
to compute-popularity
  ; initialize the variable at 0 
  ask starts [ set myscientists 0 ]
  
  ask researchers [
    ; variables for x and y coordinate of the current researcher,
    ; the argument it is currently working on and the 
    ; theory this argument belongs to
    let myx xcor
    let myy ycor
    let myargu one-of turtles with [(breed = starts or breed = arguments) and
      xcor = myx and ycor = myy]
    let mystart [mytheory] of myargu
    
    ; the myscientists variable of the theory the researcher
    ; is working on is increased by one
    ask mystart [
      set myscientists myscientists + 1
    ]
  ]
end




; the social network structures for collaborator networks
; is created according to the choice made in the interface:
; cycle, wheel or complete
to create-networks
  ; initialize variables for the collection of the networks
  ; and the networks that will share with each other
  set colla-networks []
  ; an entry in share-structure starts with the network that
  ; is the network that initializes the sharing
  set share-structure []
  
  ; list of all sorted collaborator-networks
  let networks []
  ask researchers [
    set networks lput sort collaborator-network networks
  ]
  set colla-networks remove-duplicates networks
  
  ; in the case that the choice in the interface is cycle
  ifelse network-structure = "cycle" [
    let connect-networks colla-networks
    
    ; when there are only two collaborator-networks
    ; they always share with each other
    ifelse length colla-networks = 2 [
      set share-structure lput colla-networks share-structure
      set share-structure lput reverse colla-networks share-structure
    ][ 
    
    ; in all other cases networks share with two neighboring networks
    ; for three networks this is still a complete case
    while [length connect-networks > 2] [
      ; first the entries for the beginning and end of the list
      ifelse empty? share-structure[
        let to-add-structure1 []
        let to-add-structure2 []
        set to-add-structure1 lput first connect-networks to-add-structure1
        set to-add-structure1 lput first but-first connect-networks to-add-structure1
        set to-add-structure1 lput last connect-networks to-add-structure1
        set to-add-structure2 lput last connect-networks to-add-structure2
        set to-add-structure2 lput first connect-networks to-add-structure2
        set to-add-structure2 lput last but-last connect-networks to-add-structure2
        set share-structure lput to-add-structure1 share-structure
        set share-structure lput to-add-structure2 share-structure
      ][
      ; then the networks in between
      let to-add-structure []
      set to-add-structure lput first but-first connect-networks to-add-structure
      set to-add-structure lput first connect-networks to-add-structure
      set connect-networks remove-item 0 connect-networks
      set to-add-structure lput first but-first connect-networks to-add-structure
      set share-structure lput to-add-structure share-structure 
      ]
    ]
    ]
  ][
  
  ; in the case that the choice in the interface is wheel
  ifelse network-structure = "wheel" [
    let connect-networks colla-networks
    
    ; when there are only two or three collaborator-networks
    ; they always share with each other
    ifelse length colla-networks < 4 [
      set share-structure lput colla-networks share-structure
      set share-structure lput reverse colla-networks share-structure
      if length colla-networks = 3 [
        let add-colla-networks []
        set add-colla-networks lput first but-first colla-networks add-colla-networks
        set add-colla-networks lput first colla-networks add-colla-networks
        set add-colla-networks lput last colla-networks add-colla-networks
        set share-structure lput add-colla-networks share-structure
      ]
    ][ 
    
    ; the first network is defined to be the royal family:
    ; the network that shares with all other networks
    let middle first connect-networks
    set connect-networks remove-item 0 connect-networks
    let add-middle []
    set add-middle lput middle add-middle
    foreach connect-networks [
      if ? != middle [
        set add-middle lput ? add-middle
      ]
    ]
    ; the other networks are put in a cycle, with the
    ; addition that every networks shares with middle (the royal family)
    while [length connect-networks > 2] [
      ifelse empty? share-structure[
        let to-add-structure1 []
        let to-add-structure2 []
        set to-add-structure1 lput first connect-networks to-add-structure1
        set to-add-structure1 lput first but-first connect-networks to-add-structure1
        set to-add-structure1 lput last connect-networks to-add-structure1
        set to-add-structure1 lput middle to-add-structure1
        set to-add-structure2 lput last connect-networks to-add-structure2
        set to-add-structure2 lput first connect-networks to-add-structure2
        set to-add-structure2 lput last but-last connect-networks to-add-structure2
        set to-add-structure2 lput middle to-add-structure2
        set share-structure lput to-add-structure1 share-structure
        set share-structure lput to-add-structure2 share-structure
      ][
      let to-add-structure []
      set to-add-structure lput first but-first connect-networks to-add-structure
      set to-add-structure lput first connect-networks to-add-structure
      set connect-networks remove-item 0 connect-networks
      set to-add-structure lput first but-first connect-networks to-add-structure
      set to-add-structure lput middle to-add-structure
      set share-structure lput to-add-structure share-structure
      ]
    ]
    
    ; the first entry of share-structure is the royal family entry
    set share-structure fput add-middle share-structure
    ]
  ][
  
  ; the other cases: a completely connected graph
  ; for each collaborator-network an entry is created with at the 
  ; first position the network and then all others
  foreach colla-networks [
    let cur-network ? 
    let to-add-structure []
    set to-add-structure lput cur-network to-add-structure
    foreach colla-networks [
      if ? != cur-network [
        set to-add-structure lput ? to-add-structure
      ]
    ]
    set share-structure lput to-add-structure share-structure
  ]
  ]
  ]
end
;setup.nls ends here

; testprocedures.nls starts here
; extensions[profiler]

; procedures for probing, testing and giving additional insights into the model.
; experimental: this file is not properly commented


; globals [ctiho startsargum] ;current-theory(2)-info-hand-over (sorted)

to calc-global-admiss-core [vis] ;vis for visibility
	let new-info []
  let new-cur-info []
  let not-admissible []
	let subjective-arguments2 []
  let args-cur-arguments []
	let admissible-subj-argu2 []
  let attacked-by-me []
	let attack-relations []
	let cur-attacked []
	let cur-attacker []
  let theories []
  ask starts [
    let start-add []
    set start-add lput self start-add
    set start-add lput 0 start-add
    set theories lput start-add theories
  ]
  let current-theory-info2 theories
  ask attacks with [runresult vis] [
		set attack-relations lput self attack-relations
    set cur-attacked lput end2 cur-attacked
    set cur-attacker lput end1 cur-attacker
  ]
  ask turtles with [(breed = starts or breed = arguments) and runresult vis][
   set args-cur-arguments lput self args-cur-arguments
	 set subjective-arguments2 lput self subjective-arguments2
  ]
  foreach current-theory-info2 [
   set new-info lput replace-item 1 ? 0 new-info
  ]
	set current-theory-info2 new-info
 
 ; the computation of the admissible arguments is done recursively
 ; a list of arguments that are currently considered attacked
	let open-rec []
    ; variable that lets the loop run at least one time
  let i 0
  foreach current-theory-info2 [
  ; the theory that is considered in this loop
  ; and the root of that theory (the start)
		let cur-theory ?
    let askstart item 0 cur-theory
    while [ i < 1 or not empty? open-rec][
			set not-admissible sentence not-admissible open-rec
      set open-rec []
      set attacked-by-me []
        
      ; create a list of arguments that are attacked by the current theory
      ; based on the memory of the current researcher
      if not empty? attack-relations [
				ask turtles with [member? self args-cur-arguments and mytheory = askstart][
					if member? self cur-attacker and not member? self not-admissible [
					; the argument considered and a list of arguments
					; attacked by that argument
						let cur-turtle self
						let my-attacked []
						foreach attack-relations [
							if [end1] of ? = cur-turtle [
								set my-attacked lput [end2] of ? my-attacked
							]
						]
						set attacked-by-me sentence my-attacked attacked-by-me
					]
				]
          
        ; arguments that are attacked by arguments from another theory that are
        ; not attacked by non-attacked arguments from the current theory
        ; are added to the open-rec list, the list of attacked-arguments
        ask turtles with [member? self args-cur-arguments and mytheory = askstart and not member? self not-admissible and member? self cur-attacked][
          let cur-turtle self
          foreach attack-relations [
            if [end2] of ? = cur-turtle [
              if not member? [end1] of ? attacked-by-me [
                set open-rec lput cur-turtle open-rec
              ]
            ]
          ]
        ]
      ]
      set i i + 1
    ]
    set i 0
      
    ; for the update of the information in current-theory-info
    set new-cur-info lput replace-item 1 cur-theory (count turtles with [member? self args-cur-arguments and mytheory = askstart] - count turtles with [member? self not-admissible and mytheory = askstart]) new-cur-info
  ]
    
    ; arguments that are part of the not-admissible list
    ; are not part of the admissible subjective arguments and hence removed
    set admissible-subj-argu2 subjective-arguments2
    foreach subjective-arguments2 [
			let cur-argu ?
			if member? cur-argu not-admissible [
				set admissible-subj-argu2 remove cur-argu admissible-subj-argu2
			]
		]
		
    ; update the current-theory-info
    set current-theory-info2 new-cur-info
		set ctiho sort-by [item 0 ? < item 0 ?2] current-theory-info2
end


; cadmis= calc-admissibility input can be red for the discovered landscape or
; anything else (e.g. 1) for the general landscape
to cadmis [input] 
	ifelse input = red [
		calc-global-admiss-core task [color != gray]
	][
		calc-global-admiss-core task [true]
	]
end



; prints the admissibility input the same as for cadmis (gets handed over)
to cadmisp [input]
	cadmis input
	print ctiho
end



; prints the admissibility of theory 170 - 85
to compare-two-with-three [times]
	repeat times [
		setup
		cadmis 1
		print (item 1 item 2 ctiho - item 1 item 1 ctiho)
	]
end



to test1
	let cur-attacked []
	ask attacks [
		set cur-attacked lput end2 cur-attacked
	]
  print cur-attacked
	
end

to test2 ; one random researcher shows her attack-relations
  ask one-of researchers [
    ; variables for lists that contain:
    ; the current-theory-info with 0 admissible arguments; an updated number
    ; of admissible arguments during the recursive computation; the arguments
    ; that are not admissible; the arguments that the researchers knows about; and
    ; the arguments that are attacked by the current theory 
    let new-info []
    let new-cur-info []
    let not-admissible []
    let args-cur-arguments []
    let attacked-by-me []
    
    ; create a list of only the attacks
    let attack-relations []
    foreach subjective-relations [
      if first ? = "a" [
        set attack-relations lput ? attack-relations
      ]
    ]
		show attack-relations
    ; create lists of attacked and attacking arguments
    let cur-attacked []
    let cur-attacker []
    foreach attack-relations [
      set cur-attacked lput last ? cur-attacked
      set cur-attacker lput first but-first ? cur-attacker
    ]
    
    ; create a list of the arguments the researchers knows about and 
    ; set the number of admissible arguments for each theory to 0
    foreach subjective-arguments [
      set args-cur-arguments lput first ? args-cur-arguments
    ]
    foreach current-theory-info [
      set new-info lput replace-item 1 ? 0 new-info
    ]
    set current-theory-info new-info
    
    ; the computation of the admissible arguments is done recursively
    ; a list of arguments that are currently considered attacked
    let open-rec []
    ; variable that lets the loop run at least one time
    let i 0
    foreach current-theory-info [
      ; the theory that is considered in this loop
      ; and the root of that theory (the start)
      let cur-theory ?
      let askstart item 0 cur-theory
      while [ i < 1 or not empty? open-rec][
        set not-admissible sentence not-admissible open-rec
        set open-rec []
        set attacked-by-me []
        
        ; create a list of arguments that are attacked by the current theory
        ; based on the memory of the current researcher
        if not empty? attack-relations [
          ask turtles with [member? self args-cur-arguments and
	        mytheory = askstart][
            if member? self cur-attacker and not member? self not-admissible [
              ; the argument considered and a list of arguments
              ; attacked by that argument
              let cur-turtle self
              let my-attacked []
              foreach attack-relations [
                if first but-first ? = cur-turtle [
                  set my-attacked lput last ? my-attacked
                ]
              ]
              set attacked-by-me sentence my-attacked attacked-by-me
            ]
          ]
          
          ; arguments that are attacked by arguments from another theory that are
          ; not attacked by non-attacked arguments from the current theory
          ; are added to the open-rec list, the list of attacked-arguments
          ask turtles with [member? self args-cur-arguments and
	          mytheory = askstart and not member? self not-admissible and
	          member? self cur-attacked][
          let cur-turtle self
          foreach attack-relations [
            if last ? = cur-turtle [
              if not member? last but-last ? attacked-by-me [
                set open-rec lput cur-turtle open-rec
              ]
            ]
          ]
            ]
        ]
        set i i + 1
      ]
      set i 0
      
      ; for the update of the information in current-theory-info
      set new-cur-info lput replace-item 1 cur-theory (count turtles with
        [member? self args-cur-arguments and mytheory = askstart] -
	      count turtles with [member? self not-admissible and mytheory = askstart])
	        new-cur-info
    ]
    
    ; arguments that are part of the not-admissible list
    ; are not part of the admissible subjective arguments and hence removed
    set admissible-subj-argu subjective-arguments
    foreach subjective-arguments [
      let cur-argu ?
      if member? first cur-argu not-admissible [
        set admissible-subj-argu remove cur-argu admissible-subj-argu
      ]
    ]
    ; update the current-theory-info
    set current-theory-info new-cur-info
  ]
end

to test3 [input]
	ifelse input = red [
		calc-global-admiss-core task [color != gray]
	][
		calc-global-admiss-core task [true]
	]
end

to test4 [input1]
	ask attacks with [runresult input1] [print self]
end

; performs the setup times often and each time shows the admissibility for
; all theories
to test5 [times]
	repeat times [
		setup
		cadmisp 1
	]
end


; setup for the errorneous attack-relations
to setup-test-error
	clear-all
  initialize-hidden-variables
  create-discovery-landscape number-of-theories theory-depth
  define-attack-relation-error
  distribute-researchers scientists
  reset-ticks
end


to define-attack-relation-error
  ; first the random attacks are defined
  define-attack-relation-create-attacks-error
  
  ; then the best theory defends itself
  define-attack-relation-defend-best
  
  ; the arguments and relations are spread over the patches
  define-attack-relation-visualize
end


to define-attack-relation-create-attacks-error
  ask turtles with [breed = starts or breed = arguments][
    ; variables for the current argument, the theory it belongs to,
    ; a random number between 0.00 and 1.00 and a list of theories
    let askargu self
    let curtheory mytheory
    let attack-random random-float 1.00
    let starts-list []
    ask starts [
      set starts-list lput who starts-list
    ]
    set starts-list sort starts-list
    
    ; with attack-probability-2nd from the interface an attack towards
    ; the current argument is created
    ifelse number-of-theories = 2[
      if attack-random < attack-probability-2nd and curtheory != start 0 [
        create-attack-from one-of other turtles with [(breed = starts or
	      breed = arguments)and mytheory != curtheory and not
	      (in-discovery-neighbor? askargu or in-attack-neighbor? askargu or
	      out-discovery-neighbor? askargu or out-attack-neighbor? askargu)][
        set color gray
            ]
      ]
    ][
    
    ; when there are three theories both attack-probability-2nd and -3rd are
    ; considered to create attacks, depending on the theory the current argument
    ; belongs to first for the third theory
    ifelse [who] of curtheory = max starts-list and attack-random <
      attack-probability-3rd [
      create-attack-to one-of other turtles with [(breed = starts or
        breed = arguments) and mytheory != curtheory and not
	      (in-discovery-neighbor? askargu or in-attack-neighbor? askargu or
	      out-discovery-neighbor? askargu or out-attack-neighbor? askargu)][
        set color gray
          ]
    ][
    ; then attacks towards arguments of the 2nd theory are created
    if [who] of curtheory != max starts-list and curtheory != start 0 and
      attack-random < attack-probability-2nd [
      create-attack-from one-of other turtles with [(breed = starts or
      breed = arguments) and mytheory != curtheory and not
      (in-discovery-neighbor? askargu or in-attack-neighbor? askargu or
	    out-discovery-neighbor? askargu or out-attack-neighbor? askargu)][
        set color gray
          ]
    ]
    ]
    ]
    
    ; if the current argument belongs to the objective best theory
    ; an attack towards this argument is created with attack-probability-best
    if attack-random < attack-probability-best and curtheory = start 0 [
      create-attack-from one-of other turtles with [(breed = starts or
      breed = arguments) and mytheory != curtheory and not
	    (in-discovery-neighbor? askargu or in-attack-neighbor? askargu or
	    out-discovery-neighbor? askargu or out-attack-neighbor? askargu)][
        set color gray
          ]
    ]
  ]
end

to compare-error-with-new [times]
	repeat times [
		setup
		cadmis 1
		print (word "fixed:      " ctiho " #attacks: "count attacks)
		setup-test-error
		cadmis 1
		print (word "errorneous: " ctiho " #attacks: "count attacks)
	]
end

to compare-error-with-new-statistics [times]
	repeat times [
		file-open "testprocedure_adm_fixed.txt"
		setup
		cadmis 1
		file-print (word item 1 item 1 ctiho " " item 1 item 2 ctiho)
		file-open "testprocedure_attack_fixed.txt"
		file-print count attacks
		file-open "testprocedure_adm_error.txt"
		setup-test-error
		cadmis 1
		file-print (word item 1 item 1 ctiho " " item 1 item 2 ctiho)
		file-open "testprocedure_attack_error.txt"
		file-print count attacks
	]
	file-close-all
end


to check-full-adm [times]
	file-open "testprocedure_full_adm.txt"
	repeat times [
		setup
		cadmis 1
		file-print item 1 item 0 ctiho
	]
	file-close-all
end

to test6 
	let i 0
	repeat 10 [
		set i (i + 1)
	]
	print i
end

to profilecore [repetitions go-version]               
	profiler:start         ;; start profiling
	repeat repetitions [ run go-version ]       ;; run something you want to measure
	profiler:stop          ;; stop profiling
	print profiler:report  ;; view the results
	profiler:reset         ;; clear the data
end

to profile [repetitions version]
	let go-version 0
	if version = "old" [set go-version task go]
	if version = "v1" [set go-version task go-test-v1]
	if version = "v2" [set go-version task go-test-v2]
	if version = "v31" [set go-version task go-test-v31]
	if version = "v32" [set go-version task go-test-v32]
	if version = "old3" [set go-version task go-test-oldv3]
	if version = "v41" [set go-version task go-test-v41]
	if version = "v51" [set go-version task go-test-v51]
	if version = "v61" [set go-version task go-test-v61]
	if version = "v71" [set go-version task go-test-v71]
	profilecore repetitions go-version
end


to duplicate-remover-test
  ask researchers [
    ; list of arguments of which the duplicates will be removed
    let new-args subjective-arguments
    foreach new-args [
      ; the argument of the current entry and its color
      let argu first ?
      let my-color first but-first ?
      ; list of entries with the same argument, but maybe different color
      let color-argu filter [first ? = argu] new-args
      ; remove entries of arguments that are also present as
      ; better researched entries
      set color-argu sort-by [first but-first ?1 < first but-first ?2] color-argu
      while [length color-argu != 1] [
				show "idiots!"
				show (word "last a list: ")
				analize-list lastalist
				show (word "last b list: ")
				analize-list lastblist
				show (word "last a list after: ")
				analize-list lastalistafter
        set new-args remove last color-argu new-args
        set color-argu but-last color-argu
      ]
    ]
    ; update the researcher's memory
    set subjective-arguments new-args
  ]
end

to analize-list [inputlist]
	foreach inputlist [
		let temp ?
		foreach temp [
		show ?
		]
		show ""
	]
end

to update-memories-test
  ask researchers [
    let myx xcor
    let myy ycor
    let cur-argum one-of turtles with [(breed = starts or breed = arguments)
      and xcor = myx and ycor = myy]
    let cur-researcher self
    ; information of current argument in the format of the memory
    let add-cur (sentence cur-argum [color] of cur-argum)
;    set subjective-arguments lput add-cur subjective-arguments
    ; list of relations (resp. arguments) that are added
    let to-add []
		let to-add-argu []
    set to-add-argu lput add-cur to-add-argu
    ; list of neighborhood arguments of the current argument
    set neighborargs []
    set neighborargs lput cur-argum neighborargs
    
    ; for the current argument
    ; add the neighboring discovered arguments and relations
    ; (attacks and discovery) to a to-add list
    ask cur-argum [
       if any? my-in-discoveries with [color != gray][
        ask my-in-discoveries with [color != gray][
          let add-other-end other-end
          ask cur-researcher [
            set neighborargs lput add-other-end neighborargs
          ]
          ; construction of the to be added discovery relation
          let add-rel []
          set add-rel lput "d" add-rel
          set add-rel lput add-other-end add-rel
          set add-rel lput cur-argum add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
      
      ; add the child argument of the discovery relation
      if any? my-out-discoveries with [color != gray][
        ask my-out-discoveries with [color != gray][
	  let add-other-end other-end
	  ask cur-researcher [
	    set neighborargs lput add-other-end neighborargs
	  ]
	  ; construction of the to be added discovery relation
	  let add-rel []
	  set add-rel lput "d" add-rel
          set add-rel lput cur-argum add-rel
          set add-rel lput add-other-end add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
     
      ; add the parent argument of the attack relation
      if any? my-in-attacks with [color != gray][
        ask my-in-attacks with [color != gray][
          let add-other-end other-end
          ask cur-researcher [
            set neighborargs lput add-other-end neighborargs
          ]
          ; construction of the to be added attack relation
          let add-rel []
          set add-rel lput "a" add-rel
          set add-rel lput add-other-end add-rel
          set add-rel lput cur-argum add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
      
      ; add the child argument of the attack relation
      if any? my-out-attacks with [color != gray][
        ask my-out-attacks with [color != gray][
          let add-other-end other-end
          ask cur-researcher [
            set neighborargs lput add-other-end neighborargs
          ]
          ; construction of the to be added attack relation
          let add-rel []
          set add-rel lput "a" add-rel
          set add-rel lput cur-argum add-rel
          set add-rel lput other-end add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
    ]
    
    ; remove duplicates from the list
    set subjective-relations remove-duplicates sentence
      subjective-relations to-add
		; show subjective-arguments	
		; foreach to-add-argu [
			; let argu first ?
			; ; show ?
			; let my-color first but-first ?
			; ; list of entries with the same argument, but maybe different color
			; let argu-old filter [first ? = argu] subjective-arguments
			; ; show argu-old
			; if not empty? argu-old [
				; set argu-old item 0 argu-old
				; if my-color < item 1 argu-old [
					; let argument-position position argu-old subjective-arguments
					; ; show argument-position
					; ; remove entries of arguments that are also present as
					; ; better researched entries
					; ; set color-argu sort-by [first but-first ?1 < first but-first ?2] color-argu 
					; if argument-position != false [
						
						; ; show (word "replacing position " argument-position " with " ?)
						; set subjective-arguments replace-item argument-position subjective-arguments ?
					; ]
				; ]
				; if my-color > item 1 argu-old [
							; show "plausi check error new arg is older"
				; ]
			; ]
		; ]
    ; set subjective-arguments remove-duplicates sentence
      ; subjective-arguments to-add-argu
		; ; show subjective-arguments
	set subjective-arguments (merge-arg-wo-duplicates subjective-arguments to-add-argu false)
	set flag-updated-memory true
  ]
  
  ; every 5 plus 4 time-steps the collected information
  ; is shared with other researchers
  if ticks mod 5 = 4 [
   share-with-others-test
  ] 
  
end


to update-memories-test2
  ask researchers [
    let myx xcor
    let myy ycor
    let cur-argum one-of turtles with [(breed = starts or breed = arguments)
      and xcor = myx and ycor = myy]
    let cur-researcher self
    ; information of current argument in the format of the memory
    let add-cur (sentence cur-argum [color] of cur-argum)
;    set subjective-arguments lput add-cur subjective-arguments
    ; list of relations (resp. arguments) that are added
    let to-add []
		let to-add-argu []
    set to-add-argu lput add-cur to-add-argu
    ; list of neighborhood arguments of the current argument
    set neighborargs []
    set neighborargs lput cur-argum neighborargs
    
    ; for the current argument
    ; add the neighboring discovered arguments and relations
    ; (attacks and discovery) to a to-add list
    ask cur-argum [
       if any? my-in-discoveries with [color != gray][
        ask my-in-discoveries with [color != gray][
          let add-other-end other-end
          ask cur-researcher [
            set neighborargs lput add-other-end neighborargs
          ]
          ; construction of the to be added discovery relation
          let add-rel []
          set add-rel lput "d" add-rel
          set add-rel lput add-other-end add-rel
          set add-rel lput cur-argum add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
      
      ; add the child argument of the discovery relation
      if any? my-out-discoveries with [color != gray][
        ask my-out-discoveries with [color != gray][
	  let add-other-end other-end
	  ask cur-researcher [
	    set neighborargs lput add-other-end neighborargs
	  ]
	  ; construction of the to be added discovery relation
	  let add-rel []
	  set add-rel lput "d" add-rel
          set add-rel lput cur-argum add-rel
          set add-rel lput add-other-end add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
     
      ; add the parent argument of the attack relation
      if any? my-in-attacks with [color != gray][
        ask my-in-attacks with [color != gray][
          let add-other-end other-end
          ask cur-researcher [
            set neighborargs lput add-other-end neighborargs
          ]
          ; construction of the to be added attack relation
          let add-rel []
          set add-rel lput "a" add-rel
          set add-rel lput add-other-end add-rel
          set add-rel lput cur-argum add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
      
      ; add the child argument of the attack relation
      if any? my-out-attacks with [color != gray][
        ask my-out-attacks with [color != gray][
          let add-other-end other-end
          ask cur-researcher [
            set neighborargs lput add-other-end neighborargs
          ]
          ; construction of the to be added attack relation
          let add-rel []
          set add-rel lput "a" add-rel
          set add-rel lput cur-argum add-rel
          set add-rel lput other-end add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
    ]
    
    ; remove duplicates from the list
    set subjective-relations remove-duplicates sentence
      subjective-relations to-add
		; show subjective-arguments	
		; foreach to-add-argu [
			; let argu first ?
			; ; show ?
			; let my-color first but-first ?
			; ; list of entries with the same argument, but maybe different color
			; let argu-old filter [first ? = argu] subjective-arguments
			; ; show argu-old
			; if not empty? argu-old [
				; set argu-old item 0 argu-old
				; if my-color < item 1 argu-old [
					; let argument-position position argu-old subjective-arguments
					; ; show argument-position
					; ; remove entries of arguments that are also present as
					; ; better researched entries
					; ; set color-argu sort-by [first but-first ?1 < first but-first ?2] color-argu 
					; if argument-position != false [
						
						; ; show (word "replacing position " argument-position " with " ?)
						; set subjective-arguments replace-item argument-position subjective-arguments ?
					; ]
				; ]
				; if my-color > item 1 argu-old [
							; show "plausi check error new arg is older"
				; ]
			; ]
		; ]
    ; set subjective-arguments remove-duplicates sentence
      ; subjective-arguments to-add-argu
		; ; show subjective-arguments
	set subjective-arguments (merge-arg-wo-duplicates subjective-arguments to-add-argu false)
	set flag-updated-memory true
  ]
  
  ; every 5 plus 4 time-steps the collected information
  ; is shared with other researchers
  if ticks mod 5 = 4 [
   share-with-others-test2
  ] 
  
end


to-report merge-arg-wo-duplicates [alist blist flag]

	if flag [
		set blist remove-duplicates blist
	]
	; set lastalist lput alist lastalist
	; set lastblist lput blist lastblist
	; if length lastalist > 2 [
		; set lastalist remove-item 0 lastalist
	; ]
	; if length lastblist > 2 [
		; set lastblist remove-item 0 lastblist
	; ]
	; if flag [
		; ; set blist list-cleaner blist
	; ]
	foreach blist [
		let argu first ?
		; show ?
		let my-color item 1 ?
		; list of entries with the same argument, but maybe different color
		if flag [
			let duplicate-check filter [first ? = argu] blist		
			foreach duplicate-check [
				if item 1 ? > my-color [
					set blist remove ? blist
				]
			]
		]
		let argu-old filter [first ? = argu] alist
		; show argu-old
		if not empty? argu-old [
			set argu-old item 0 argu-old
			
			if my-color < item 1 argu-old [		
			let argument-position position argu-old alist			
				; show argument-position
				; remove entries of arguments that are also present as
				; better researched entries
				; set color-argu sort-by [first but-first ?1 < first but-first ?2] color-argu 
				if argument-position != false [
					
					; show (word "replacing position " argument-position " with " ?)
					set alist replace-item argument-position alist ?
				]
			]
			if my-color >= item 1 argu-old [
				set blist remove ? blist
				;show (word my-color " " item 1 argu-old)
				;show (word "removed " ? " from " blist)
				; let argument-position position argu-old blist
				; set blist remove-item argument-position blist
				;set blist replace-item argument-position blist 
			]
		]
	]
  set alist remove-duplicates sentence
      alist blist
	
	; set lastalistafter lput alist lastalistafter
	; if length lastalistafter > 2 [
		; set lastalistafter remove-item 0 lastalistafter
	; ]
	report alist
end

to test-test [argu blist]
	let duplicate-check filter [first ? = argu] blist		
end

to-report list-cleaner [blist]
	let i 0
	let help []
	let blisth []
	foreach blist [
		set help lput 0 help	
		set blisth lput sentence ? i blisth
		set i i + 1
	]

	set i 0
	foreach blist [
		if item i help != 1 [
			let argu first ?
			; show ?
			let my-color item 1 ?
			; list of entries with the same argument, but maybe different color
				test-test argu blist
				let duplicate-check filter [first ? = argu] blisth		
				foreach duplicate-check [
					let argpos item 2 ? 
					set help replace-item argpos help 1
					if item 1 ? > my-color [
						set blist remove ? blist
					]
				]
			]
		set i i + 1
		]
		report blist

end

to go-test-v2
  ; update-memories-test
	; if ticks mod 10 = 4 [
		; duplicate-remover-test
	; ]  
  if ticks mod 5 = 4 [
    update-memories-test
		compute-strategies-researchers
    act-on-strategy-researchers-test
  ]
  move-around-test
  update-landscape
	ask researchers [
		set flag-updated-memory false
	]
  compute-popularity
  tick
end

to go-test-v32
  ; update-memories-test
	; if ticks mod 10 = 4 [
		; duplicate-remover-test
	; ]  
  if ticks mod 5 = 4 [
    update-memories-test
		compute-strategies-researchers-test
    act-on-strategy-researchers-test
  ]
  move-around-test
  update-landscape
	ask researchers [
		set flag-updated-memory false
	]
  compute-popularity
  tick
end

to go-test-v1
  update-memories-test
	; if ticks mod 10 = 4 [
		; duplicate-remover-test
	; ]  
  if ticks mod 5 = 4 [
    ; update-memories-test
		compute-strategies-researchers
    act-on-strategy-researchers
  ]
  move-around
  update-landscape
  compute-popularity
  tick
end

to go-test-v31
  update-memories-test
	; if ticks mod 10 = 4 [
		; duplicate-remover-test
	; ]  
  if ticks mod 5 = 4 [
    ; update-memories-test
		compute-strategies-researchers-test
    act-on-strategy-researchers
  ]
  move-around
  update-landscape
  compute-popularity
  tick
end

to go-test-oldv3
	update-memories
  duplicate-remover
  if ticks mod 5 = 4 [
    compute-strategies-researchers-test
    act-on-strategy-researchers
  ]
  move-around
  update-landscape
  compute-popularity
  tick
end

to go-test-v41
  update-memories-test2
	; if ticks mod 10 = 4 [
		; duplicate-remover-test
	; ]  
  if ticks mod 5 = 4 [
    ; update-memories-test
		compute-strategies-researchers-test
    act-on-strategy-researchers
  ]
  move-around
  update-landscape
  compute-popularity
  tick
end

to go-test-v51
  update-memories-test5

	; if ticks mod 10 = 4 [
		; duplicate-remover-test
	; ]  
  if ticks mod 5 = 4 [
		share-with-others-test5
		create-share-memory-test5
		share-with-other-networks-test5
		compute-time-costs-test5
    ; update-memories-test
		compute-strategies-researchers-test
    act-on-strategy-researchers
  ]
  move-around
  update-landscape
  compute-popularity
  tick
end


to go-test-v61
  update-memories-test5

	; if ticks mod 10 = 4 [
		; duplicate-remover-test
	; ]  
  if ticks mod 5 = 4 [
		share-with-others-test5
		create-share-memory-test5
		share-with-other-networks-test5
		compute-time-costs-test5
    ; update-memories-test
		compute-subj-attacked-test6
		compute-strategies-researchers-test6
    act-on-strategy-researchers
  ]
  move-around-test6
  update-landscape
  compute-popularity
  tick
end

to go-test-v71
  update-memories-test7

	; if ticks mod 10 = 4 [
		; duplicate-remover-test
	; ]  
  if ticks mod 5 = 4 [
		share-with-others-test5
		create-share-memory-test7
		share-with-other-networks-test5
		compute-time-costs-test5
    ; update-memories-test
		compute-subj-attacked-test7
		compute-strategies-researchers-test6
    act-on-strat-ag-tst7
  ]
  move-around-test7
  update-landscape-test7
	full-discovery-test7
	if ticks mod 5 != 0 [
		communication-regress
	]
  compute-popularity-tst7
  tick
end


to go-test
	go-test-v71
end

to go-stop-test
	setuprs new-seed
	go-test
	while [any? arguments with [
	color != red and [myscientists] of mytheory !=  0
	]
	][
		go-test
	]
end

to bla [times]
	repeat times [go-test-v71]
end

to setuprs [rs]
  clear-all
  random-seed rs
	print (word "random seed: " rs)
	print (word "no. scientists: " scientists)
  initialize-hidden-variables
  create-discovery-landscape number-of-theories theory-depth
  define-attack-relation
  distribute-researchers scientists
  reset-ticks
	set startsargum turtles with [breed = starts or breed = arguments]
	ask researchers [
		set lastalist []
		set lastblist []
		set lastalistafter []
		set flag-updated-memory false
		set conference-attended false
		set to-add-mem-argu []
		set to-add-mem-rel []
		
	]	
end




to share-with-others-test
  ask researchers [
    ; reset the variables
    set rep-researcher false 
    set to-add-mem-argu []
    set to-add-mem-rel []
    
    ; variables to keep track of the current researchers own memory
    ; and the combined memory of all the sharing researchers
    ; let own-memory-argu subjective-arguments
    ; let own-memory-rel subjective-relations
    let comb-memory-argu []
    let comb-memory-rel []
    ; collaborator network of the current researcher
    let cur-network collaborator-network
    
    ; the information in the memories of the single researchers in the network
    ; are combined 
    ask turtles with [member? self cur-network] [
      set comb-memory-argu sentence subjective-arguments comb-memory-argu
      set comb-memory-rel sentence subjective-relations comb-memory-rel
    ]
    
    ; each researcher adds the combined memory to its own
    ; then removing duplicates
		set subjective-arguments (merge-arg-wo-duplicates subjective-arguments comb-memory-argu true)
    set subjective-relations remove-duplicates sentence
      subjective-relations comb-memory-rel
  ]
  
  ; then researchers can share some of their information with researchers 
  ; from neighboring networks in the social structures
  create-share-memory-test
  share-with-other-networks-test
  
end




to create-share-memory-test
  
  ; for each collaborator-network one researcher is set to be
  ; the representative researcher
  foreach colla-networks [
    ifelse length ? > 1 [
      ask one-of researchers with [member? self ?][
        set rep-researcher true
      ] 	
    ][
    if ticks mod 25 = 4 [
      ask one-of researchers with [member? self ?][
        set rep-researcher true
      ]
    ]
    ]
  ]
  
  ; only the representative researchers create a memory 
  ; that they want to share with researchers from other networks
  ask researchers with [rep-researcher][
    let myx xcor
    let myy ycor
    ; variables for the argument the researcher is currently working on,
    ; the researcher itself and the theory it is working on
    let cur-argum one-of turtles with [(breed = starts or breed = arguments)
      and xcor = myx and ycor = myy]
    let cur-researcher self 
    let cur-th [mytheory] of cur-argum
    ; create a list of arguments and a list of relations that the researcher can
    ; share with researchers from other collaborative networks
    ; what researchers share depends on the "social-action" and "sharing"
    ; from the interface
    set th-args []
    set th-relations []
    
    ; researchers share only information obtained in the neighborhood 
    ; they are currently working on
    ; collect the arguments from the researcher's memory
    ; that belong also to the neighborargs
    foreach subjective-arguments [
      if member? item 0 ? [neighborargs] of cur-researcher [
        set th-args lput ? th-args
      ]
    ]
    ; collect the relations from/to the current argument
    ; from the researcher's memory
    foreach subjective-relations [
      if item 1 ? = cur-argum or item 2 ? = cur-argum [
        set th-relations lput ? th-relations
      ]
    ]
    
    ; if the researcher behaves biased it does not share the attack relations that
    ; attack its current theory, these relations are removed
    if social-actions = "biased"[
      foreach th-relations [
        if item 0 ? = "a" and [mytheory] of item 2 ? = cur-th [
          set th-relations remove ? th-relations
        ]
      ]
    ]
  ]
end




to share-with-other-networks-test 
  ask researchers with [rep-researcher][
    ; variables for the combined information (arguments and relations),
    ; the network of the current researcher and the theory it is working on
    let comb-memory-argu th-args
    let comb-memory-rel th-relations
    let cur-network sort collaborator-network
    let my-cur-theory [mytheory] of item 0 item 0 th-args
    
    ; create a list of the neighboring networks and then a 
    ; list of the representative researchers of these networks
    ; which will be the researchers the current researcher shares with
    let share-researchers []
    let share-neighbors []
    foreach share-structure [    
      if first ? = cur-network [
        set share-neighbors ?
      ]
    ]
    ask researchers with [rep-researcher][
      let cur-researcher self
      foreach share-neighbors [
        if member? cur-researcher ? [
          set share-researchers lput cur-researcher share-researchers
        ]
      ]
    ]
    
    ; create a list of arguments and a list of relations that is
    ; shared among the share-researchers
    foreach share-researchers [
      ; the combined memory is updated to contain that of the sharing researcher
      set comb-memory-argu sentence comb-memory-argu [th-args] of ?
      set comb-memory-rel sentence comb-memory-rel [th-relations] of ?
    ]
    ; create lists of arguments/relations that have to be added
    foreach share-researchers [
      set to-add-mem-argu remove-duplicates sentence subjective-arguments
        comb-memory-argu
      set to-add-mem-rel remove-duplicates sentence subjective-relations
        comb-memory-rel
    ]
  ] 
  
  ; to compute the time that researchers have to
  ; spend on communication
  compute-time-costs-test 
end



to compute-time-costs-test
  ask researchers with [rep-researcher][
    
    ; variables that contain the arguments and relations the
    ; researcher has to update in its memory
    let new-memory-args []
    let new-memory-rel []
		let to-add-argu []
    set new-memory-args filter [not member? ? subjective-arguments]
      to-add-mem-argu
    set new-memory-rel filter [not member? ? subjective-relations]
      to-add-mem-rel
    let comb-new sentence new-memory-args new-memory-rel
    ; every tick an researcher can obtain a maximum of 10 new entries
    ; the day that they received information is also lost
    ifelse length comb-new >= (3 * max-learn) [
      set communicating 4
    ][
    set communicating ((ceiling (length comb-new / max-learn)) + 1)
    ]
    
    ; every communication round an researcher can update a maximum of 
    ; 3 * max-learn new arguments/relations (corresponding to three ticks of
    ; communication) these new arguments and relations are added to the
    ; memory of the researcher
    ; when a new relation is added and the arguments are not part of the
    ; memory of the researcher, these arguments are added as well
    ifelse length comb-new > (3 * max-learn) [
      set comb-new shuffle comb-new
      let repeats length comb-new - (3 * max-learn)
      while [length comb-new > repeats] [
        let cur-entr first comb-new
        let new-mem-argargs filter [member? ? new-memory-args] comb-new
        set new-mem-argargs map [first ?] new-mem-argargs
        ifelse member? cur-entr new-memory-args [
          set to-add-argu lput cur-entr to-add-argu
          set comb-new remove cur-entr comb-new
        ][
        set subjective-relations lput cur-entr subjective-relations
        set comb-new remove cur-entr comb-new
        if member? item 1 cur-entr new-mem-argargs[
          let item-1-cur-entr item 1 cur-entr
          foreach comb-new [
            if item-1-cur-entr = item 0 ? [
              set to-add-argu lput ? to-add-argu
              set comb-new remove ? comb-new
            ]
          ] 
        ]
        if member? item 2 cur-entr new-mem-argargs[
          let item-2-cur-entr item 2 cur-entr
          foreach comb-new [
            if item-2-cur-entr = item 0 ? [
              set to-add-argu lput ? to-add-argu
              set comb-new remove ? comb-new
            ]
          ] 
        ]
        ]
      ]
			set subjective-arguments (merge-arg-wo-duplicates subjective-arguments to-add-argu true)
    ][
		set subjective-arguments (merge-arg-wo-duplicates subjective-arguments new-memory-args true)
    set subjective-relations sentence subjective-relations new-memory-rel ;remove duplicates!? bug maybe -> probably no problem b/c remove duplicates for relations is run during "share-with-other-networks" 
    ]
  ]
end





to refresh-mem-set-move-parameter
	refresh-mem-before-move
	set moved true
end

to refresh-mem-before-move
	if not flag-updated-memory [
		let myx xcor
		let myy ycor
		let cur-argum one-of turtles with [(breed = starts or breed = arguments)
			and xcor = myx and ycor = myy]
		let cur-researcher self
		; information of current argument in the format of the memory
		let add-cur (sentence cur-argum [color] of cur-argum)
	;    set subjective-arguments lput add-cur subjective-arguments
		; list of relations (resp. arguments) that are added
		let to-add []
		let to-add-argu []
		set to-add-argu lput add-cur to-add-argu
		; list of neighborhood arguments of the current argument
		set neighborargs []
		set neighborargs lput cur-argum neighborargs
		
		; for the current argument
		; add the neighboring discovered arguments and relations
		; (attacks and discovery) to a to-add list
		ask cur-argum [
			 if any? my-in-discoveries with [color != gray][
				ask my-in-discoveries with [color != gray][
					let add-other-end other-end
					ask cur-researcher [
						set neighborargs lput add-other-end neighborargs
					]
					; construction of the to be added discovery relation
					let add-rel []
					set add-rel lput "d" add-rel
					set add-rel lput add-other-end add-rel
					set add-rel lput cur-argum add-rel
					set to-add lput add-rel to-add
					; the to be added argument
					let add-other (sentence add-other-end [color] of add-other-end)
					set to-add-argu lput add-other to-add-argu
				]
			]
			
			; add the child argument of the discovery relation
			if any? my-out-discoveries with [color != gray][
				ask my-out-discoveries with [color != gray][
		let add-other-end other-end
		ask cur-researcher [
			set neighborargs lput add-other-end neighborargs
		]
		; construction of the to be added discovery relation
		let add-rel []
		set add-rel lput "d" add-rel
					set add-rel lput cur-argum add-rel
					set add-rel lput add-other-end add-rel
					set to-add lput add-rel to-add
					; the to be added argument
					let add-other (sentence add-other-end [color] of add-other-end)
					set to-add-argu lput add-other to-add-argu
				]
			]
		 
			; add the parent argument of the attack relation
			if any? my-in-attacks with [color != gray][
				ask my-in-attacks with [color != gray][
					let add-other-end other-end
					ask cur-researcher [
						set neighborargs lput add-other-end neighborargs
					]
					; construction of the to be added attack relation
					let add-rel []
					set add-rel lput "a" add-rel
					set add-rel lput add-other-end add-rel
					set add-rel lput cur-argum add-rel
					set to-add lput add-rel to-add
					; the to be added argument
					let add-other (sentence add-other-end [color] of add-other-end)
					set to-add-argu lput add-other to-add-argu
				]
			]
			
			; add the child argument of the attack relation
			if any? my-out-attacks with [color != gray][
				ask my-out-attacks with [color != gray][
					let add-other-end other-end
					ask cur-researcher [
						set neighborargs lput add-other-end neighborargs
					]
					; construction of the to be added attack relation
					let add-rel []
					set add-rel lput "a" add-rel
					set add-rel lput cur-argum add-rel
					set add-rel lput other-end add-rel
					set to-add lput add-rel to-add
					; the to be added argument
					let add-other (sentence add-other-end [color] of add-other-end)
					set to-add-argu lput add-other to-add-argu
				]
			]
		]
	
		; remove duplicates from the list
		set subjective-relations remove-duplicates sentence
			subjective-relations to-add
		; show subjective-arguments	
		; foreach to-add-argu [
			; let argu first ?
			; ; show ?
			; let my-color first but-first ?
			; ; list of entries with the same argument, but maybe different color
			; let argu-old filter [first ? = argu] subjective-arguments
			; ; show argu-old
			; if not empty? argu-old [
				; set argu-old item 0 argu-old
				; if my-color < item 1 argu-old [
					; let argument-position position argu-old subjective-arguments
					; ; show argument-position
					; ; remove entries of arguments that are also present as
					; ; better researched entries
					; ; set color-argu sort-by [first but-first ?1 < first but-first ?2] color-argu 
					; if argument-position != false [
						
						; ; show (word "replacing position " argument-position " with " ?)
						; set subjective-arguments replace-item argument-position subjective-arguments ?
					; ]
				; ]
				; if my-color > item 1 argu-old [
							; show "plausi check error new arg is older"
				; ]
			; ]
		; ]
		; set subjective-arguments remove-duplicates sentence
			; subjective-arguments to-add-argu
		; ; show subjective-arguments
		set subjective-arguments (merge-arg-wo-duplicates subjective-arguments to-add-argu false)
		set flag-updated-memory true
  ]
end

to move-around-test
  ; variable to make sure that the procedure find-defense
  ; is only run once
  let run-find-defense false 
  ; at the beginning of the procedure no researcher has moved yet
  ask researchers [
    set moved false
  ]
  ask researchers [
    let curresearcher self
    if [communicating] of curresearcher = 0 or ticks mod 5 = 0 [
      let myx xcor
      let myy ycor
      ; variable for the argument the researcher is currently working on and
     ; the researcher itself
        let myargu one-of turtles with [(breed = starts or breed = arguments) and
        xcor = myx and ycor = myy]
      
      ; a list of not-admissible arguments is created
      let not-admissible []
      if admissible-subj-argu != 0 and not empty? admissible-subj-argu [
        let info-not-admissible filter [not member? ? admissible-subj-argu]
          subjective-arguments
        foreach info-not-admissible [
          set not-admissible lput item 0 ? not-admissible
        ]
      ]
   
      ; an researcher working on an attacked argument will try to find a defense for
      ; this attack, by working further on the attacked argument, unless it
      ; discoveres a child-argument that that has a defense for the attack
      ; (it is not necessarily the case that this defense is already discovered)
      ; the find-defense runs immediately for all researchers working on a not
      ; fully researched not-admissible argument, hence it is only once executed
      if member? myargu not-admissible and not moved[
      
        if not run-find-defense [
          find-defense-test
          set run-find-defense true
        ]
      ]
    
      if not moved and not member? myargu not-admissible or 
        (member? myargu not-admissible and [color] of myargu = red)[
        
        ; when an argument exists that:
        ; a) is a child-argument of the current argument;
        ; b) is not gray, red or turquoise; and
        ; c) no researcher from the same collaborator-network is working on it
        ; the researcher moves there, with certain probability
        ifelse any? turtles with [(breed = starts or breed = arguments) and
          in-discovery-neighbor? myargu and color != gray and color != red and
    	  color != turquoise and not (any? turtles with [breed = researchers and
	  xcor = [xcor] of myself and ycor = [ycor] of myself and member? self
	  [collaborator-network] of curresearcher])] [
        let move-random random-float 1.0
      

        ; every time step with small-movement of the move-probability
        ; the researcher moves
        ifelse move-random < (small-movement * move-probability *
          (1 - (color / color-move))) [ refresh-mem-before-move
          move-to one-of turtles with [(breed = starts or breed = arguments) and
            in-discovery-neighbor? myargu and color != gray and color != red and
            color != turquoise and not ( any? turtles with [breed = researchers and
            xcor = [xcor] of myself and ycor = [ycor] of myself and member? self
  	    [collaborator-network] of curresearcher])]
          set moved true
        ][
      
        ; every 5th time step the researcher mover with the full move-probability,
        ; that depends a bit on the color
        if ticks != 0 and ticks mod 5 = 0 and move-random <
          move-probability * (1 - (color / color-move)) [ refresh-mem-before-move
          move-to one-of turtles with [(breed = starts or breed = arguments) and
            in-discovery-neighbor? myargu and color != gray and color != red and
	    color != turquoise and not ( any? turtles with [breed = researchers
	    and xcor = [xcor] of myself and ycor = [ycor] of myself and
	    member? self [collaborator-network] of curresearcher])]
          set moved true
        ]
        ]
            ][

        ; if there is no next argument and the current argument is
        ; fully researched, the researcher moves a step back
        ifelse [color] of myargu = red and any? turtles with [color != gray and
          color != turquoise and out-discovery-neighbor? myargu and not any?
	  turtles with [breed = researchers and xcor = [xcor] of myself and
	  ycor = [ycor] of myself and member? self [collaborator-network]
	  of curresearcher]][ refresh-mem-before-move
        move-to one-of turtles with [color != gray and out-discovery-neighbor?
          myargu and not any? turtles with [breed = researchers and xcor = [xcor] of
          myself and ycor = [ycor] of myself and member? self
          [collaborator-network] of curresearcher]]
        set moved true
          ][
      
        ; if moving back is not possible, it jumps to another argument in
        ; the same tree/theory that is discovered but not fully researched
        if [color] of myargu = red[
          let askstart [mytheory] of myargu
          if any? turtles with [(breed = starts or breed = arguments) and
	    color != gray and color != turquoise and color != red and
	    mytheory = askstart and not any? turtles with [breed = researchers and
  	    xcor = [xcor] of myself and ycor = [ycor] of myself and member?
	    self [collaborator-network] of curresearcher]][ refresh-mem-before-move
          move-to one-of turtles with [(breed = starts or breed = arguments) and
	   color != turquoise and color != gray and color != red and
  	   mytheory = askstart and not any? turtles with [breed = researchers and
	   xcor = [xcor] of myself and ycor = [ycor] of myself and member? self
           [collaborator-network] of curresearcher]]
          set moved true
            ]
        ]
          ]
            ]
      ]
    ]	
  ]
end


to find-defense-test
  ask researchers with [not moved][    
    let curresearcher self
    if [communicating] of curresearcher = 0 or ticks mod 5 = 0 [
      let myx xcor
      let myy ycor
      ; variables for the argument the researcher is working on and
      ; for the researcher itself
      let myargu one-of turtles with [(breed = starts or breed = arguments) and
        xcor = myx and ycor = myy]
    
      ; lists of arguments that are not admissible
      let not-admissible []
      if admissible-subj-argu != 0 and not empty? admissible-subj-argu [
        let info-not-admissible filter [not member? ? admissible-subj-argu]
          subjective-arguments
        foreach info-not-admissible [
          set not-admissible lput item 0 ? not-admissible
        ]
      ]
    
      ; if the current argument is not fully researched and not admissible
      ; and it is a 5th time step or the researcher is not communicating
      ; the researcher tries to move prospectively to a child-argument of the current 
      ; argument that provides a defense for the current argument
      if member? myargu not-admissible[
        ask myargu [
          ask my-in-attacks [
            ask end1 [
              ; create a set of arguments that provide a defense for the current
	      ; argument, these:
              ; a) attack the attacker of the current argument;
	      ; b) are a child-argument of the current argument;
              ; c) are discovered; and
	      ; d) no researcher from the same network is working on it
              let nextargu in-attack-neighbors with [in-discovery-neighbor?
	        myargu and color != gray and color != turquoise and not (any?
		researchers with [xcor = [xcor] of myself and ycor = [ycor] of myself
		and member? self [collaborator-network] of curresearcher])]
              ; if such an argument exists the researcher moves there
              ; and cannot move anymore this time step
              if any? nextargu [
                ask curresearcher [
									refresh-mem-before-move
                  move-to one-of nextargu
                  set moved true
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end


to act-on-strategy-researchers-test
  ask researchers with [not rep-researcher][
    ; only when there is a current best theory
    ; it makes sense for the researchers to want to work on that theory
    if not empty? cur-best-th and not member? nobody cur-best-th [
      let myx xcor
      let myy ycor
      
      ; if the researcher is not currently working on the best theory
      ; it considers jumping
      foreach subjective-arguments [
        if [xcor] of item 0 ? = myx and [ycor] of item 0 ? = myy and
        not member? [mytheory] of item 0 ? cur-best-th [
          set theory-jump theory-jump + 1
        ]
      ]
      
      ; if the researcher has considered jumping jump-threshold times
      ; it jumps to one of the theories it considers best, based
      ; on its memory and the computations
      if theory-jump >= jump-threshold [
        let ch-best one-of cur-best-th
        let subj-argus []
        foreach subjective-arguments [
          set subj-argus lput item 0 ? subj-argus
        ]
        
        ; if one of the arguments from the best theory is in its memory
        ; the researcher will jump there
        ifelse any? turtles with [(breed = starts or breed = arguments) and
	        member? self subj-argus and mytheory = ch-best and color != turquoise][
            move-to one-of turtles with [(breed = starts or breed = arguments) and
              member? self subj-argus and mytheory = ch-best and color != turquoise]
          ][ ; otherwise the researcher jumps to the root of the theory
					refresh-mem-before-move
          move-to ch-best
          ]
        
        set times-jumped times-jumped + 1
        set theory-jump 0
      ]
    ]
  ]
end


to compute-subj-attacked-test
	foreach colla-networks [
		let calc-done false
		let calc-researcher []
		let cur-group ?
		foreach cur-group [
			let cur-researcher ?
			if not [rep-researcher] of cur-researcher [
				ifelse calc-done [
					ask cur-researcher [
						set admissible-subj-argu [admissible-subj-argu] of calc-researcher
						set current-theory-info [current-theory-info] of calc-researcher
					]
				][
					set calc-done true
					set calc-researcher cur-researcher
					ask cur-researcher [
						; variables for lists that contain:
						; the current-theory-info with 0 admissible arguments; an updated number
						; of admissible arguments during the recursive computation; the arguments
						; that are not admissible; the arguments that the researchers knows about; and
						; the arguments that are attacked by the current theory 
						let new-info []
						let new-cur-info []
						let not-admissible []
						let args-cur-arguments []
						let attacked-by-me []
						
						; create a list of only the attacks
						let attack-relations []
						foreach subjective-relations [
							if first ? = "a" [
								set attack-relations lput ? attack-relations
							]
						]
						; create lists of attacked and attacking arguments
						let cur-attacked []
						let cur-attacker []
						foreach attack-relations [
							set cur-attacked lput last ? cur-attacked
							set cur-attacker lput first but-first ? cur-attacker
						]
						
						; create a list of the arguments the researchers knows about and 
						; set the number of admissible arguments for each theory to 0
						foreach subjective-arguments [
							set args-cur-arguments lput first ? args-cur-arguments
						]
						foreach current-theory-info [
							set new-info lput replace-item 1 ? 0 new-info
						]
						set current-theory-info new-info
						
						; the computation of the admissible arguments is done recursively
						; a list of arguments that are currently considered attacked
						let open-rec []
						; variable that lets the loop run at least one time
						let i 0
						foreach current-theory-info [
							; the theory that is considered in this loop
							; and the root of that theory (the start)
							let cur-theory ?
							let askstart item 0 cur-theory
							while [ i < 1 or not empty? open-rec][
								set not-admissible sentence not-admissible open-rec
								set open-rec []
								set attacked-by-me []
								
								; create a list of arguments that are attacked by the current theory
								; based on the memory of the current researcher
								if not empty? attack-relations [
									ask turtles with [member? self args-cur-arguments and
									mytheory = askstart][
										if member? self cur-attacker and not member? self not-admissible [
											; the argument considered and a list of arguments
											; attacked by that argument
											let cur-turtle self
											let my-attacked []
											foreach attack-relations [
												if first but-first ? = cur-turtle [
													set my-attacked lput last ? my-attacked
												]
											]
											set attacked-by-me sentence my-attacked attacked-by-me
										]
									]
									
									; arguments that are attacked by arguments from another theory that are
									; not attacked by non-attacked arguments from the current theory
									; are added to the open-rec list, the list of attacked-arguments
									ask turtles with [member? self args-cur-arguments and
										mytheory = askstart and not member? self not-admissible and
										member? self cur-attacked][
									let cur-turtle self
									foreach attack-relations [
										if last ? = cur-turtle [
											if not member? last but-last ? attacked-by-me [
												set open-rec lput cur-turtle open-rec
											]
										]
									]
										]
								]
								set i i + 1
							]
							set i 0
							
							; for the update of the information in current-theory-info
							set new-cur-info lput replace-item 1 cur-theory (count turtles with
								[member? self args-cur-arguments and mytheory = askstart] -
								count turtles with [member? self not-admissible and mytheory = askstart])
									new-cur-info
						]
						
						; arguments that are part of the not-admissible list
						; are not part of the admissible subjective arguments and hence removed
						set admissible-subj-argu subjective-arguments
						foreach subjective-arguments [
							let cur-argu ?
							if member? first cur-argu not-admissible [
								set admissible-subj-argu remove cur-argu admissible-subj-argu
							]
						]
						; update the current-theory-info
						set current-theory-info new-cur-info
					]
				]
			]
		]
	]
end


to compute-strategies-researchers-test
  
  ; researchers start with figuring out which argument in their
  ; memory are admissible and which are attacked
  compute-subj-attacked-test
 
  ask researchers with [not rep-researcher][
    set cur-best-th []
    ; variables for the list that contains the number admissible arguments 
    ; per theory and a sublist which contains only the numbers that are
    ; within the strategy-threshold
    let list-admissible-arguments []
    let threshold-admissible-arguments []
    
    ; create a list with the number of admissible arguments
    ; of each of the theories
    foreach current-theory-info [
      set list-admissible-arguments lput item 1 ? list-admissible-arguments
    ]
    set list-admissible-arguments sort list-admissible-arguments
    
    ; a list of theories with values within the strategy threshold is constructed
    set threshold-admissible-arguments filter [? >=
      ((max list-admissible-arguments) * strategy-threshold)]
        list-admissible-arguments
    set threshold-admissible-arguments sort threshold-admissible-arguments
    
    ; computation of the current best theory
    ; theories with a number of admissible arguments that are
    ; within the threshold can be considered as current best theory
    foreach current-theory-info [
      if member? item 1 ? threshold-admissible-arguments [
        set cur-best-th lput item 0 ? cur-best-th
      ]
    ]
  ]
end




to share-with-others-test2
	foreach colla-networks [
		let group-sharing-done false
		let grp-share-researcher []
		let cur-group ?
		foreach cur-group [
			let cur-researcher ?
				ifelse group-sharing-done [
					ask cur-researcher [			
						set rep-researcher false 
						set subjective-arguments [subjective-arguments] of grp-share-researcher
						set subjective-relations [subjective-relations] of grp-share-researcher
					]
				][
					set group-sharing-done true
					set grp-share-researcher cur-researcher
					ask cur-researcher [
						; reset the variables
						set rep-researcher false 
						set to-add-mem-argu []
						set to-add-mem-rel []
						
						; variables to keep track of the current researchers own memory
						; and the combined memory of all the sharing researchers
						; let own-memory-argu subjective-arguments
						; let own-memory-rel subjective-relations
						let comb-memory-argu []
						let comb-memory-rel []
						; collaborator network of the current researcher
						let cur-network collaborator-network
						
						; the information in the memories of the single researchers in the network
						; are combined 
						
						foreach cur-group [
							let input-researcher ?						
							set comb-memory-argu sentence [subjective-arguments] of input-researcher comb-memory-argu
							set comb-memory-rel sentence [subjective-relations] of input-researcher comb-memory-rel
						]	
						
						; each researcher adds the combined memory to its own
						; then removing duplicates
						set subjective-arguments (merge-arg-wo-duplicates subjective-arguments comb-memory-argu true)
						set subjective-relations remove-duplicates sentence
							subjective-relations comb-memory-rel
							
							]
						]
					]]
  
  ; then researchers can share some of their information with researchers 
  ; from neighboring networks in the social structures
  create-share-memory-test
  share-with-other-networks-test
  

	
end


to update-memories-test5
  ask researchers [
    let myx xcor
    let myy ycor
    let cur-argum one-of turtles with [(breed = starts or breed = arguments)
      and xcor = myx and ycor = myy]
    let cur-researcher self
    ; information of current argument in the format of the memory
    let add-cur (sentence cur-argum [color] of cur-argum)
;    set subjective-arguments lput add-cur subjective-arguments
    ; list of relations (resp. arguments) that are added
    let to-add []
		let to-add-argu []
    set to-add-argu lput add-cur to-add-argu
    ; list of neighborhood arguments of the current argument
    set neighborargs []
    set neighborargs lput cur-argum neighborargs
    
    ; for the current argument
    ; add the neighboring discovered arguments and relations
    ; (attacks and discovery) to a to-add list
    ask cur-argum [
       if any? my-in-discoveries with [color != gray][
        ask my-in-discoveries with [color != gray][
          let add-other-end other-end
          ask cur-researcher [
            set neighborargs lput add-other-end neighborargs
          ]
          ; construction of the to be added discovery relation
          let add-rel []
          set add-rel lput "d" add-rel
          set add-rel lput add-other-end add-rel
          set add-rel lput cur-argum add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
      
      ; add the child argument of the discovery relation
      if any? my-out-discoveries with [color != gray][
        ask my-out-discoveries with [color != gray][
	  let add-other-end other-end
	  ask cur-researcher [
	    set neighborargs lput add-other-end neighborargs
	  ]
	  ; construction of the to be added discovery relation
	  let add-rel []
	  set add-rel lput "d" add-rel
          set add-rel lput cur-argum add-rel
          set add-rel lput add-other-end add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
     
      ; add the parent argument of the attack relation
      if any? my-in-attacks with [color != gray][
        ask my-in-attacks with [color != gray][
          let add-other-end other-end
          ask cur-researcher [
            set neighborargs lput add-other-end neighborargs
          ]
          ; construction of the to be added attack relation
          let add-rel []
          set add-rel lput "a" add-rel
          set add-rel lput add-other-end add-rel
          set add-rel lput cur-argum add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
      
      ; add the child argument of the attack relation
      if any? my-out-attacks with [color != gray][
        ask my-out-attacks with [color != gray][
          let add-other-end other-end
          ask cur-researcher [
            set neighborargs lput add-other-end neighborargs
          ]
          ; construction of the to be added attack relation
          let add-rel []
          set add-rel lput "a" add-rel
          set add-rel lput cur-argum add-rel
          set add-rel lput other-end add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
    ]
    
    ; remove duplicates from the list
    set subjective-relations remove-duplicates sentence
      subjective-relations to-add
		; show subjective-arguments	
		; foreach to-add-argu [
			; let argu first ?
			; ; show ?
			; let my-color first but-first ?
			; ; list of entries with the same argument, but maybe different color
			; let argu-old filter [first ? = argu] subjective-arguments
			; ; show argu-old
			; if not empty? argu-old [
				; set argu-old item 0 argu-old
				; if my-color < item 1 argu-old [
					; let argument-position position argu-old subjective-arguments
					; ; show argument-position
					; ; remove entries of arguments that are also present as
					; ; better researched entries
					; ; set color-argu sort-by [first but-first ?1 < first but-first ?2] color-argu 
					; if argument-position != false [
						
						; ; show (word "replacing position " argument-position " with " ?)
						; set subjective-arguments replace-item argument-position subjective-arguments ?
					; ]
				; ]
				; if my-color > item 1 argu-old [
							; show "plausi check error new arg is older"
				; ]
			; ]
		; ]
    ; set subjective-arguments remove-duplicates sentence
      ; subjective-arguments to-add-argu
		; ; show subjective-arguments
	set subjective-arguments (merge-arg-wo-duplicates subjective-arguments to-add-argu false)
	set flag-updated-memory true
  ]
  
  ; every 5 plus 4 time-steps the collected information
  ; is shared with other researchers  
end



to share-with-others-test5
	foreach colla-networks [
		let group-sharing-done false
		let grp-share-researcher []
		let cur-group ?
		foreach cur-group [
			let cur-researcher ?
				ifelse group-sharing-done [
					ask cur-researcher [			
						set rep-researcher false 
						set subjective-arguments [subjective-arguments] of grp-share-researcher
						set subjective-relations [subjective-relations] of grp-share-researcher
					]
				][
					set group-sharing-done true
					set grp-share-researcher cur-researcher
					ask cur-researcher [
						; reset the variables
						set rep-researcher false 
						set to-add-mem-argu []
						set to-add-mem-rel []
						
						; variables to keep track of the current researchers own memory
						; and the combined memory of all the sharing researchers
						; let own-memory-argu subjective-arguments
						; let own-memory-rel subjective-relations
						let comb-memory-argu []
						let comb-memory-rel []
						; collaborator network of the current researcher
						let cur-network collaborator-network
						
						; the information in the memories of the single researchers in the network
						; are combined 
						
						foreach cur-group [
							let input-researcher ?						
							set comb-memory-argu sentence [subjective-arguments] of input-researcher comb-memory-argu
							set comb-memory-rel sentence [subjective-relations] of input-researcher comb-memory-rel
						]	
						
						; each researcher adds the combined memory to its own
						; then removing duplicates
						set subjective-arguments (merge-arg-wo-duplicates subjective-arguments comb-memory-argu true)
						set subjective-relations remove-duplicates sentence
							subjective-relations comb-memory-rel
							
							]
						]
		]
	]
  
  ; then researchers can share some of their information with researchers 
  ; from neighboring networks in the social structures
end


to create-share-memory-test5
  
  ; for each collaborator-network one researcher is set to be
  ; the representative researcher
  foreach colla-networks [
    ifelse length ? > 1 [
      ask one-of researchers with [member? self ?][
        set rep-researcher true
      ] 	
    ][
			if ticks mod 25 = 4 [
				ask one-of researchers with [member? self ?][
					set rep-researcher true
      ]
    ]
    ]
  ]
  
  ; only the representative researchers create a memory 
  ; that they want to share with researchers from other networks
  ask researchers with [rep-researcher][
    let myx xcor
    let myy ycor
    ; variables for the argument the researcher is currently working on,
    ; the researcher itself and the theory it is working on
    let cur-argum one-of turtles with [(breed = starts or breed = arguments)
      and xcor = myx and ycor = myy]
    let cur-researcher self 
    let cur-th [mytheory] of cur-argum
    ; create a list of arguments and a list of relations that the researcher can
    ; share with researchers from other collaborative networks
    ; what researchers share depends on the "social-action" and "sharing"
    ; from the interface
    set th-args []
    set th-relations []
    
    ; researchers share only information obtained in the neighborhood 
    ; they are currently working on
    ; collect the arguments from the researcher's memory
    ; that belong also to the neighborargs
    foreach subjective-arguments [
      if member? item 0 ? [neighborargs] of cur-researcher [
        set th-args lput ? th-args
      ]
    ]
    ; collect the relations from/to the current argument
    ; from the researcher's memory
    foreach subjective-relations [
      if item 1 ? = cur-argum or item 2 ? = cur-argum [
        set th-relations lput ? th-relations
      ]
    ]
    
    ; if the researcher behaves biased it does not share the attack relations that
    ; attack its current theory, these relations are removed
    if social-actions = "biased"[
      foreach th-relations [
        if item 0 ? = "a" and [mytheory] of item 2 ? = cur-th [
          set th-relations remove ? th-relations
        ]
      ]
    ]
  ]
end



; we have the problem here that researchers which learn arguments with a older color than the one they already know in their subjective memory pay for them still although they never will include them in their memory
to share-with-other-networks-test5 
  ask researchers with [rep-researcher][
		if not conference-attended [
			; let share-group-leader self
		
			; variables for the combined information (arguments and relations),
			; the network of the current researcher and the theory it is working on
			let comb-memory-argu th-args
			let comb-memory-rel th-relations
			let cur-network sort collaborator-network
			let my-cur-theory [mytheory] of item 0 item 0 th-args
			
			; create a list of the neighboring networks and then a 
			; list of the representative researchers of these networks
			; which will be the researchers the current researcher shares with
			let share-researchers []
			let share-neighbors []
			foreach share-structure [    
				if first ? = cur-network [
					set share-neighbors ?
				]
			]
			ask researchers with [rep-researcher][
				let cur-researcher self
				foreach share-neighbors [
					if member? cur-researcher ? [
						set share-researchers lput cur-researcher share-researchers
					]
				]
			]
			
			; create a list of arguments and a list of relations that is
			; shared among the share-researchers
			foreach share-researchers [
				; the combined memory is updated to contain that of the sharing researcher
				set comb-memory-argu remove-duplicates sentence comb-memory-argu [th-args] of ?
				set comb-memory-rel remove-duplicates sentence comb-memory-rel [th-relations] of ?		
			]
			; create lists of arguments/relations that have to be added
			foreach share-researchers [
				ask ? [
					set to-add-mem-argu comb-memory-argu
					set to-add-mem-rel comb-memory-rel
					set conference-attended true
				]
			]			
		] 
		
		; to compute the time that researchers have to
		; spend on communication
	]
	
end




to compute-time-costs-test5 
	ask researchers with [rep-researcher][
		; variables that contain the arguments and relations the
		; researcher has to update in its memory
		let new-memory-args []
		let new-memory-rel []
		let to-add-argu []
		set new-memory-args filter [not member? ? subjective-arguments]
			to-add-mem-argu
		set new-memory-rel filter [not member? ? subjective-relations]
			to-add-mem-rel
		let comb-new sentence new-memory-args new-memory-rel
		; every tick an researcher can obtain a maximum of 10 new entries
		; the day that they received information is also lost
		ifelse length comb-new >= (3 * max-learn) [
			set communicating 4
		][
		set communicating ((ceiling (length comb-new / max-learn)) + 1)
		]
		
		; every communication round an researcher can update a maximum of 
		; 3 * max-learn new arguments/relations (corresponding to three ticks of
		; communication) these new arguments and relations are added to the
		; memory of the researcher
		; when a new relation is added and the arguments are not part of the
		; memory of the researcher, these arguments are added as well
		ifelse length comb-new > (3 * max-learn) [
			set comb-new shuffle comb-new
			let repeats length comb-new - (3 * max-learn)
			while [length comb-new > repeats] [
				let cur-entr first comb-new
				let new-mem-argargs filter [member? ? new-memory-args] comb-new
				set new-mem-argargs map [first ?] new-mem-argargs
				ifelse member? cur-entr new-memory-args [
					set to-add-argu lput cur-entr to-add-argu
					set comb-new remove cur-entr comb-new
				][
				set subjective-relations lput cur-entr subjective-relations
				set comb-new remove cur-entr comb-new
				if member? item 1 cur-entr new-mem-argargs[
					let item-1-cur-entr item 1 cur-entr
					foreach comb-new [
						if item-1-cur-entr = item 0 ? [
							set to-add-argu lput ? to-add-argu
							set comb-new remove ? comb-new
						]
					] 
				]
				if member? item 2 cur-entr new-mem-argargs[
					let item-2-cur-entr item 2 cur-entr
					foreach comb-new [
						if item-2-cur-entr = item 0 ? [
							set to-add-argu lput ? to-add-argu
							set comb-new remove ? comb-new
						]
					] 
				]
				]
			]
			set subjective-arguments (merge-arg-wo-duplicates subjective-arguments to-add-argu true)
		][
		set subjective-arguments (merge-arg-wo-duplicates subjective-arguments new-memory-args true)
		set subjective-relations sentence subjective-relations new-memory-rel ;remove duplicates!? bug maybe -> probably no problem b/c remove duplicates for relations is run during "share-with-other-networks" 
		]	
		set conference-attended false
	]
end

to-report gps
	let myx xcor
	let myy ycor
	; variable for the argument the researcher is currently working on and
 ; the researcher itself
	let myargu one-of startsargum with [xcor = myx and ycor = myy]
	; let myargu one-of turtles with [xcor = myx and ycor = myy and (breed = starts or breed = arguments)]
	report myargu
end

to-report non-admiss-args
	; let not-admissible []
	; let info-not-admissible filter [not member? ? admissible-subj-argu]
		; subjective-arguments
	; foreach info-not-admissible [
		; set not-admissible lput item 0 ? not-admissible
	; ]	
	report non-admiss-subj-argu
end

; move, but not both
to move-around-test6
  ; variable to make sure that the procedure find-defense
  ; is only run once
  let run-find-defense false 
  ; at the beginning of the procedure no researcher has moved yet
  ask researchers [
    set moved false
  ]
  ask researchers [
    let curresearcher self
    if [communicating] of curresearcher = 0 or ticks mod 5 = 0 [
			let myargu gps
      ; let myx xcor
      ; let myy ycor
      ; ; variable for the argument the researcher is currently working on and
     ; ; the researcher itself
        ; let myargu one-of turtles with [(breed = starts or breed = arguments) and
        ; xcor = myx and ycor = myy]
      
      ; a list of not-admissible arguments is created
      let not-admissible []			
      if admissible-subj-argu != 0 and not empty? admissible-subj-argu [
				set not-admissible non-admiss-args
        ; let info-not-admissible filter [not member? ? admissible-subj-argu]
          ; subjective-arguments
        ; foreach info-not-admissible [
          ; set not-admissible lput item 0 ? not-admissible
        ; ]
      ]
   
      ; an researcher working on an attacked argument will try to find a defense for
      ; this attack, by working further on the attacked argument, unless it
      ; discoveres a child-argument that that has a defense for the attack
      ; (it is not necessarily the case that this defense is already discovered)
      ; the find-defense runs immediately for all researchers working on a not
      ; fully researched not-admissible argument, hence it is only once executed
      if member? myargu not-admissible and not moved[
      
        if not run-find-defense [
          find-defense-test6
          set run-find-defense true
        ]
      ]
    
      if not moved and not member? myargu not-admissible or 
        (member? myargu not-admissible and [color] of myargu = red)[
        
        ; when an argument exists that:
        ; a) is a child-argument of the current argument;
        ; b) is not gray, red or turquoise; and
        ; c) no researcher from the same collaborator-network is working on it
        ; the researcher moves there, with certain probability
        ifelse any? turtles with [(breed = starts or breed = arguments) and
          in-discovery-neighbor? myargu and color != gray and color != red and
    	  color != turquoise and not (any? turtles with [breed = researchers and
	  xcor = [xcor] of myself and ycor = [ycor] of myself and member? self
	  [collaborator-network] of curresearcher])] [
        let move-random random-float 1.0
      

        ; every time step with small-movement of the move-probability
        ; the researcher moves
        ifelse move-random < (small-movement * move-probability *
          (1 - (color / color-move))) [
          move-to one-of turtles with [(breed = starts or breed = arguments) and
            in-discovery-neighbor? myargu and color != gray and color != red and
            color != turquoise and not ( any? turtles with [breed = researchers and
            xcor = [xcor] of myself and ycor = [ycor] of myself and member? self
  	    [collaborator-network] of curresearcher])]
          set moved true
        ][
      
        ; every 5th time step the researcher mover with the full move-probability,
        ; that depends a bit on the color
        if ticks != 0 and ticks mod 5 = 0 and move-random <
          move-probability * (1 - (color / color-move)) [
          move-to one-of turtles with [(breed = starts or breed = arguments) and
            in-discovery-neighbor? myargu and color != gray and color != red and
	    color != turquoise and not ( any? turtles with [breed = researchers
	    and xcor = [xcor] of myself and ycor = [ycor] of myself and
	    member? self [collaborator-network] of curresearcher])]
          set moved true
        ]
        ]
            ][

        ; if there is no next argument and the current argument is
        ; fully researched, the researcher moves a step back
        ifelse [color] of myargu = red and any? turtles with [color != gray and
          color != turquoise and out-discovery-neighbor? myargu and not any?
	  turtles with [breed = researchers and xcor = [xcor] of myself and
	  ycor = [ycor] of myself and member? self [collaborator-network]
	  of curresearcher]][
        move-to one-of turtles with [color != gray and out-discovery-neighbor?
          myargu and not any? turtles with [breed = researchers and xcor = [xcor] of
          myself and ycor = [ycor] of myself and member? self
          [collaborator-network] of curresearcher]]
        set moved true
          ][
      
        ; if moving back is not possible, it jumps to another argument in
        ; the same tree/theory that is discovered but not fully researched
        if [color] of myargu = red[
          let askstart [mytheory] of myargu
          if any? turtles with [(breed = starts or breed = arguments) and
	    color != gray and color != turquoise and color != red and
	    mytheory = askstart and not any? turtles with [breed = researchers and
  	    xcor = [xcor] of myself and ycor = [ycor] of myself and member?
	    self [collaborator-network] of curresearcher]][
          move-to one-of turtles with [(breed = starts or breed = arguments) and
	   color != turquoise and color != gray and color != red and
  	   mytheory = askstart and not any? turtles with [breed = researchers and
	   xcor = [xcor] of myself and ycor = [ycor] of myself and member? self
           [collaborator-network] of curresearcher]]
          set moved true
            ]
        ]
          ]
            ]
      ]
    ]	
  ]
end





; researchers working on a not fully researched attacked argument will try to find a
; defense for that attack, by staying on the current argument
; if a child-argument is discovered that can provide a defense, the 
; researcher moves there
; once an argument is fully researched all its relations are discovered,
; then an researcher can move on and can try to find a defense in another branch,
; further away
to find-defense-test6
  ask researchers with [not moved][    
    let curresearcher self
    if [communicating] of curresearcher = 0 or ticks mod 5 = 0 [
			let myargu gps
      ; let myx xcor
      ; let myy ycor
      ; ; variables for the argument the researcher is working on and
      ; ; for the researcher itself
      ; let myargu one-of turtles with [(breed = starts or breed = arguments) and
        ; xcor = myx and ycor = myy]
    
      ; lists of arguments that are not admissible
			let not-admissible []			
      if admissible-subj-argu != 0 and not empty? admissible-subj-argu [
				set not-admissible non-admiss-args        
      ]
      ; let not-admissible []
      ; if admissible-subj-argu != 0 and not empty? admissible-subj-argu [
        ; let info-not-admissible filter [not member? ? admissible-subj-argu]
          ; subjective-arguments
        ; foreach info-not-admissible [
          ; set not-admissible lput item 0 ? not-admissible
        ; ]
      ; ]
    
      ; if the current argument is not fully researched and not admissible
      ; and it is a 5th time step or the researcher is not communicating
      ; the researcher tries to move prospectively to a child-argument of the current 
      ; argument that provides a defense for the current argument
      if member? myargu not-admissible[
        ask myargu [
          ask my-in-attacks [
            ask end1 [
              ; create a set of arguments that provide a defense for the current
	      ; argument, these:
              ; a) attack the attacker of the current argument;
	      ; b) are a child-argument of the current argument;
              ; c) are discovered; and
	      ; d) no researcher from the same network is working on it
              let nextargu in-attack-neighbors with [in-discovery-neighbor?
	        myargu and color != gray and color != turquoise and not (any?
		researchers with [xcor = [xcor] of myself and ycor = [ycor] of myself
		and member? self [collaborator-network] of curresearcher])]
              ; if such an argument exists the researcher moves there
              ; and cannot move anymore this time step
              if any? nextargu [
                ask curresearcher [
                  move-to one-of nextargu
                  set moved true
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end





to compute-subj-attacked-test6
	foreach colla-networks [
		let calc-done false
		let calc-researcher []
		let cur-group ?
		foreach cur-group [
			let cur-researcher ?
			if not [rep-researcher] of cur-researcher [
				ifelse calc-done [
					ask cur-researcher [
						set admissible-subj-argu [admissible-subj-argu] of calc-researcher
						set current-theory-info [current-theory-info] of calc-researcher
						set non-admiss-subj-argu [non-admiss-subj-argu] of calc-researcher
					]
				][
					set calc-done true
					set calc-researcher cur-researcher
					ask cur-researcher [
						; variables for lists that contain:
						; the current-theory-info with 0 admissible arguments; an updated number
						; of admissible arguments during the recursive computation; the arguments
						; that are not admissible; the arguments that the researchers knows about; and
						; the arguments that are attacked by the current theory 
						let new-info []
						let new-cur-info []
						let not-admissible []
						let args-cur-arguments []
						let attacked-by-me []
						
						; create a list of only the attacks
						let attack-relations []
						foreach subjective-relations [
							if first ? = "a" [
								set attack-relations lput ? attack-relations
							]
						]
						; create lists of attacked and attacking arguments
						let cur-attacked []
						let cur-attacker []
						foreach attack-relations [
							set cur-attacked lput last ? cur-attacked
							set cur-attacker lput first but-first ? cur-attacker
						]
						
						; create a list of the arguments the researchers knows about and 
						; set the number of admissible arguments for each theory to 0
						foreach subjective-arguments [
							set args-cur-arguments lput first ? args-cur-arguments
						]
						foreach current-theory-info [
							set new-info lput replace-item 1 ? 0 new-info
						]
						set current-theory-info new-info
						
						; the computation of the admissible arguments is done recursively
						; a list of arguments that are currently considered attacked
						let open-rec []
						; variable that lets the loop run at least one time
						let i 0
						foreach current-theory-info [
							; the theory that is considered in this loop
							; and the root of that theory (the start)
							let cur-theory ?
							let askstart item 0 cur-theory
							while [ i < 1 or not empty? open-rec][
								set not-admissible sentence not-admissible open-rec
								set open-rec []
								set attacked-by-me []
								
								; create a list of arguments that are attacked by the current theory
								; based on the memory of the current researcher
								if not empty? attack-relations [
									ask turtles with [member? self args-cur-arguments and
									mytheory = askstart][
										if member? self cur-attacker and not member? self not-admissible [
											; the argument considered and a list of arguments
											; attacked by that argument
											let cur-turtle self
											let my-attacked []
											foreach attack-relations [
												if first but-first ? = cur-turtle [
													set my-attacked lput last ? my-attacked
												]
											]
											set attacked-by-me sentence my-attacked attacked-by-me
										]
									]
									
									; arguments that are attacked by arguments from another theory that are
									; not attacked by non-attacked arguments from the current theory
									; are added to the open-rec list, the list of attacked-arguments
									ask turtles with [member? self args-cur-arguments and
										mytheory = askstart and not member? self not-admissible and
										member? self cur-attacked][
									let cur-turtle self
									foreach attack-relations [
										if last ? = cur-turtle [
											if not member? last but-last ? attacked-by-me [
												set open-rec lput cur-turtle open-rec
											]
										]
									]
										]
								]
								set i i + 1
							]
							set i 0
							
							; for the update of the information in current-theory-info
							set new-cur-info lput replace-item 1 cur-theory (count turtles with
								[member? self args-cur-arguments and mytheory = askstart] -
								count turtles with [member? self not-admissible and mytheory = askstart])
									new-cur-info
						]
						
						; arguments that are part of the not-admissible list
						; are not part of the admissible subjective arguments and hence removed
						set admissible-subj-argu subjective-arguments
						set non-admiss-subj-argu []
						foreach subjective-arguments [
							let cur-argu ?
							if member? first cur-argu not-admissible [
								set admissible-subj-argu remove cur-argu admissible-subj-argu								
								set non-admiss-subj-argu lput item 0 cur-argu non-admiss-subj-argu
							]
						]
						; update the current-theory-info
						set current-theory-info new-cur-info
					]
				]
			]
		]
	]
end


to compute-strategies-researchers-test6
  
  ; researchers start with figuring out which argument in their
  ; memory are admissible and which are attacked
  ; compute-subj-attacked-test
 
  ask researchers with [not rep-researcher][
    set cur-best-th []
    ; variables for the list that contains the number admissible arguments 
    ; per theory and a sublist which contains only the numbers that are
    ; within the strategy-threshold
    let list-admissible-arguments []
    let threshold-admissible-arguments []
    
    ; create a list with the number of admissible arguments
    ; of each of the theories
    foreach current-theory-info [
      set list-admissible-arguments lput item 1 ? list-admissible-arguments
    ]
    set list-admissible-arguments sort list-admissible-arguments
    
    ; a list of theories with values within the strategy threshold is constructed
    set threshold-admissible-arguments filter [? >=
      ((max list-admissible-arguments) * strategy-threshold)]
        list-admissible-arguments
    set threshold-admissible-arguments sort threshold-admissible-arguments
    
    ; computation of the current best theory
    ; theories with a number of admissible arguments that are
    ; within the threshold can be considered as current best theory
    foreach current-theory-info [
      if member? item 1 ? threshold-admissible-arguments [
        set cur-best-th lput item 0 ? cur-best-th
      ]
    ]
  ]
end


to update-memories-test7
  ask researchers [
		let cur-argum gps
    ; let myx xcor
    ; let myy ycor
    ; let cur-argum one-of turtles with [(breed = starts or breed = arguments)
      ; and xcor = myx and ycor = myy]
    let cur-researcher self
    ; information of current argument in the format of the memory
    let add-cur (sentence cur-argum [color] of cur-argum)
;    set subjective-arguments lput add-cur subjective-arguments
    ; list of relations (resp. arguments) that are added
    let to-add []
		let to-add-argu []
    set to-add-argu lput add-cur to-add-argu
    ; list of neighborhood arguments of the current argument
    set neighborargs []
    set neighborargs lput cur-argum neighborargs
    
    ; for the current argument
    ; add the neighboring discovered arguments and relations
    ; (attacks and discovery) to a to-add list
    ask cur-argum [
       if any? my-in-discoveries with [color != gray][
        ask my-in-discoveries with [color != gray][
          let add-other-end other-end
          ask cur-researcher [
            set neighborargs lput add-other-end neighborargs
          ]
          ; construction of the to be added discovery relation
          let add-rel []
          set add-rel lput "d" add-rel
          set add-rel lput add-other-end add-rel
          set add-rel lput cur-argum add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
      
      ; add the child argument of the discovery relation
      if any? my-out-discoveries with [color != gray][
        ask my-out-discoveries with [color != gray][
	  let add-other-end other-end
	  ask cur-researcher [
	    set neighborargs lput add-other-end neighborargs
	  ]
	  ; construction of the to be added discovery relation
	  let add-rel []
	  set add-rel lput "d" add-rel
          set add-rel lput cur-argum add-rel
          set add-rel lput add-other-end add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
     
      ; add the parent argument of the attack relation
      if any? my-in-attacks with [color != gray][
        ask my-in-attacks with [color != gray][
          let add-other-end other-end
          ask cur-researcher [
            set neighborargs lput add-other-end neighborargs
          ]
          ; construction of the to be added attack relation
          let add-rel []
          set add-rel lput "a" add-rel
          set add-rel lput add-other-end add-rel
          set add-rel lput cur-argum add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
      
      ; add the child argument of the attack relation
      if any? my-out-attacks with [color != gray][
        ask my-out-attacks with [color != gray][
          let add-other-end other-end
          ask cur-researcher [
            set neighborargs lput add-other-end neighborargs
          ]
          ; construction of the to be added attack relation
          let add-rel []
          set add-rel lput "a" add-rel
          set add-rel lput cur-argum add-rel
          set add-rel lput other-end add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
    ]
    
    ; remove duplicates from the list
    set subjective-relations remove-duplicates sentence
      subjective-relations to-add
		; show subjective-arguments	
		; foreach to-add-argu [
			; let argu first ?
			; ; show ?
			; let my-color first but-first ?
			; ; list of entries with the same argument, but maybe different color
			; let argu-old filter [first ? = argu] subjective-arguments
			; ; show argu-old
			; if not empty? argu-old [
				; set argu-old item 0 argu-old
				; if my-color < item 1 argu-old [
					; let argument-position position argu-old subjective-arguments
					; ; show argument-position
					; ; remove entries of arguments that are also present as
					; ; better researched entries
					; ; set color-argu sort-by [first but-first ?1 < first but-first ?2] color-argu 
					; if argument-position != false [
						
						; ; show (word "replacing position " argument-position " with " ?)
						; set subjective-arguments replace-item argument-position subjective-arguments ?
					; ]
				; ]
				; if my-color > item 1 argu-old [
							; show "plausi check error new arg is older"
				; ]
			; ]
		; ]
    ; set subjective-arguments remove-duplicates sentence
      ; subjective-arguments to-add-argu
		; ; show subjective-arguments
	set subjective-arguments (merge-arg-wo-duplicates subjective-arguments to-add-argu false)
	set flag-updated-memory true
  ]
  
  ; every 5 plus 4 time-steps the collected information
  ; is shared with other researchers  
end



to create-share-memory-test7
  
  ; for each collaborator-network one researcher is set to be
  ; the representative researcher
  foreach colla-networks [
    ifelse length ? > 1 [
      ask one-of researchers with [member? self ?][
        set rep-researcher true
      ] 	
    ][
			if ticks mod 25 = 4 [
				ask one-of researchers with [member? self ?][
					set rep-researcher true
      ]
    ]
    ]
  ]
  
  ; only the representative researchers create a memory 
  ; that they want to share with researchers from other networks
  ask researchers with [rep-researcher][
		let cur-argum gps
    ; let myx xcor
    ; let myy ycor
    ; ; variables for the argument the researcher is currently working on,
    ; ; the researcher itself and the theory it is working on
    ; let cur-argum one-of turtles with [(breed = starts or breed = arguments)
      ; and xcor = myx and ycor = myy]
    let cur-researcher self 
    let cur-th [mytheory] of cur-argum
    ; create a list of arguments and a list of relations that the researcher can
    ; share with researchers from other collaborative networks
    ; what researchers share depends on the "social-action" and "sharing"
    ; from the interface
    set th-args []
    set th-relations []
    
    ; researchers share only information obtained in the neighborhood 
    ; they are currently working on
    ; collect the arguments from the researcher's memory
    ; that belong also to the neighborargs
    foreach subjective-arguments [
      if member? item 0 ? [neighborargs] of cur-researcher [
        set th-args lput ? th-args
      ]
    ]
    ; collect the relations from/to the current argument
    ; from the researcher's memory
    foreach subjective-relations [
      if item 1 ? = cur-argum or item 2 ? = cur-argum [
        set th-relations lput ? th-relations
      ]
    ]
    
    ; if the researcher behaves biased it does not share the attack relations that
    ; attack its current theory, these relations are removed
    if social-actions = "biased"[
      foreach th-relations [
        if item 0 ? = "a" and [mytheory] of item 2 ? = cur-th [
          set th-relations remove ? th-relations
        ]
      ]
    ]
  ]
end

; based on their own memory
to act-on-strat-ag-tst7
  ask researchers with [not rep-researcher][
    ; only when there is a current best theory
    ; it makes sense for the researchers to want to work on that theory
    if not empty? cur-best-th and not member? nobody cur-best-th [
			let myargu gps
      ; let myx xcor
      ; let myy ycor
      
      ; if the researcher is not currently working on the best theory
      ; it considers jumping
      foreach subjective-arguments [
				let cur-subj-argu item 0 ?
				if cur-subj-argu = myargu and not member? [mytheory] of cur-subj-argu cur-best-th [
          set theory-jump theory-jump + 1
				]
        ; if [xcor] of item 0 ? = myx and [ycor] of item 0 ? = myy and
        ; not member? [mytheory] of item 0 ? cur-best-th [
          ; set theory-jump theory-jump + 1
        ; ]
      ]
      
      ; if the researcher has considered jumping jump-threshold times
      ; it jumps to one of the theories it considers best, based
      ; on its memory and the computations
      if theory-jump >= jump-threshold [
        let ch-best one-of cur-best-th
        let subj-argus []
        foreach subjective-arguments [
          set subj-argus lput item 0 ? subj-argus
        ]
        
        ; if one of the arguments from the best theory is in its memory
        ; the researcher will jump there
        ifelse any? startsargum with [
	        member? self subj-argus and mytheory = ch-best and color != turquoise][
            move-to one-of startsargum with [
              member? self subj-argus and mytheory = ch-best and color != turquoise]
          ][ ; otherwise the researcher jumps to the root of the theory
          move-to ch-best
          ]
        
        set times-jumped times-jumped + 1
        set theory-jump 0
      ]
    ]
  ]
end


to compute-popularity-tst7
  ; initialize the variable at 0 
  ask starts [ set myscientists 0 ]  
  ask researchers [
    ; variables for x and y coordinate of the current researcher,
    ; the argument it is currently working on and the 
    ; theory this argument belongs to
		let myargu gps
    ; let myx xcor
    ; let myy ycor
    ; let myargu one-of turtles with [(breed = starts or breed = arguments) and
      ; xcor = myx and ycor = myy]
    let mystart [mytheory] of myargu
    
    ; the myscientists variable of the theory the researcher
    ; is working on is increased by one
    ask mystart [
      set myscientists myscientists + 1
    ]
  ]
end

; move, but not both
to move-around-test7
  ; variable to make sure that the procedure find-defense
  ; is only run once
  let run-find-defense false 
  ; at the beginning of the procedure no researcher has moved yet
  ask researchers [
    set moved false
  ]
  ask researchers [
    let curresearcher self
    if [communicating] of curresearcher = 0 or ticks mod 5 = 0 [
			let myargu gps
      ; let myx xcor
      ; let myy ycor
      ; ; variable for the argument the researcher is currently working on and
     ; ; the researcher itself
        ; let myargu one-of turtles with [(breed = starts or breed = arguments) and
        ; xcor = myx and ycor = myy]
      
      ; a list of not-admissible arguments is created
      let not-admissible []			
      if admissible-subj-argu != 0 and not empty? admissible-subj-argu [
				set not-admissible non-admiss-args
        ; let info-not-admissible filter [not member? ? admissible-subj-argu]
          ; subjective-arguments
        ; foreach info-not-admissible [
          ; set not-admissible lput item 0 ? not-admissible
        ; ]
      ]
   
      ; an researcher working on an attacked argument will try to find a defense for
      ; this attack, by working further on the attacked argument, unless it
      ; discoveres a child-argument that that has a defense for the attack
      ; (it is not necessarily the case that this defense is already discovered)
      ; the find-defense runs immediately for all researchers working on a not
      ; fully researched not-admissible argument, hence it is only once executed
      if member? myargu not-admissible and not moved[
      
        if not run-find-defense [
          find-defense-test7
          set run-find-defense true
        ]
      ]
    
      if not moved and not member? myargu not-admissible or 
        (member? myargu not-admissible and [color] of myargu = red)[
        
        ; when an argument exists that:
        ; a) is a child-argument of the current argument;
        ; b) is not gray, red or turquoise; and
        ; c) no researcher from the same collaborator-network is working on it
        ; the researcher moves there, with certain probability
        ifelse any? startsargum with [in-discovery-neighbor? myargu 
				and [not member? color [gray red turquoise]] of self 
					; and color != gray and color != red and color != turquoise 
					and not group-member-here curresearcher
					; (any? turtles with [breed = researchers and
	  ; xcor = [xcor] of myself and ycor = [ycor] of myself and member? self
	  ; [collaborator-network] of curresearcher])
		] [
        let move-random random-float 1.0
      

        ; every time step with small-movement of the move-probability
        ; the researcher moves
        ifelse move-random < (small-movement * move-probability *
          (1 - (color / color-move))) [
          move-to one-of startsargum with [
            in-discovery-neighbor? myargu
						and [not member? color [gray red turquoise]] of self
						; and color != gray and color != red and
            ; color != turquoise 
						and not group-member-here curresearcher
						; ( any? turtles with [breed = researchers and
            ; xcor = [xcor] of myself and ycor = [ycor] of myself and member? self
  	    ; [collaborator-network] of curresearcher])
				]
          set moved true
        ][
      
        ; every 5th time step the researcher mover with the full move-probability,
        ; that depends a bit on the color
        if ticks != 0 and ticks mod 5 = 0 and move-random <
          move-probability * (1 - (color / color-move)) [
          move-to one-of startsargum with [
            in-discovery-neighbor? myargu
						and [not member? color [gray red turquoise]] of self
						; and color != gray and color != red and
	    ; color != turquoise 
			and not group-member-here curresearcher
			; ( any? turtles with [breed = researchers
	    ; and xcor = [xcor] of myself and ycor = [ycor] of myself and
	    ; member? self [collaborator-network] of curresearcher])
			]
          set moved true
        ]
        ]
            ][

        ; if there is no next argument and the current argument is
        ; fully researched, the researcher moves a step back
        ifelse [color] of myargu = red and any? startsargum with [
				[not member? color [gray turquoise]] of self
				; color != gray and
          ; color != turquoise 
					and out-discovery-neighbor? myargu and not group-member-here curresearcher
					; any?
	  ; turtles with [breed = researchers and xcor = [xcor] of myself and
	  ; ycor = [ycor] of myself and member? self [collaborator-network]
	  ; of curresearcher]
		][
        move-to one-of startsargum with [
				[not member? color [gray turquoise]] of self
				; color != gray 
				and out-discovery-neighbor?
          myargu and not group-member-here curresearcher
					; any? turtles with [breed = researchers and xcor = [xcor] of
          ; myself and ycor = [ycor] of myself and member? self
          ; [collaborator-network] of curresearcher]
					]
        set moved true
          ][
      
        ; if moving back is not possible, it jumps to another argument in
        ; the same tree/theory that is discovered but not fully researched
        if [color] of myargu = red[
          let askstart [mytheory] of myargu
          if any? startsargum with [
					[not member? color [gray red turquoise]] of self
	    ; color != gray and color != turquoise and color != red 
			and
	    mytheory = askstart and not group-member-here curresearcher
			; any? turtles with [breed = researchers and
  	    ; xcor = [xcor] of myself and ycor = [ycor] of myself and member?
	    ; self [collaborator-network] of curresearcher]
			][
          move-to one-of startsargum with [
					[not member? color [gray red turquoise]] of self
					; and color != turquoise and color != gray and color != red 
		 and
  	   mytheory = askstart and not group-member-here curresearcher
			 ; any? turtles with [breed = researchers and
	   ; xcor = [xcor] of myself and ycor = [ycor] of myself and member? self
           ; [collaborator-network] of curresearcher]
					 ]
          set moved true
            ]
        ]
          ]
            ]
      ]
    ]	
  ]
end

to-report group-member-here [curresearcher] ;aargu = the argument which is asking whether a group member researcher is her 
	ifelse any? researchers with [
	   xcor = [xcor] of myself and ycor = [ycor] of myself and member? self
           [collaborator-network] of curresearcher]
	[
		report true
	][
		report false
	]
	
end


to find-defense-test7
  ask researchers with [not moved][    
    let curresearcher self
    if [communicating] of curresearcher = 0 or ticks mod 5 = 0 [
			let myargu gps
      ; let myx xcor
      ; let myy ycor
      ; ; variables for the argument the researcher is working on and
      ; ; for the researcher itself
      ; let myargu one-of turtles with [(breed = starts or breed = arguments) and
        ; xcor = myx and ycor = myy]
    
      ; lists of arguments that are not admissible
			let not-admissible []			
      if admissible-subj-argu != 0 and not empty? admissible-subj-argu [
				set not-admissible non-admiss-args        
      ]
      ; let not-admissible []
      ; if admissible-subj-argu != 0 and not empty? admissible-subj-argu [
        ; let info-not-admissible filter [not member? ? admissible-subj-argu]
          ; subjective-arguments
        ; foreach info-not-admissible [
          ; set not-admissible lput item 0 ? not-admissible
        ; ]
      ; ]
    
      ; if the current argument is not fully researched and not admissible
      ; and it is a 5th time step or the researcher is not communicating
      ; the researcher tries to move prospectively to a child-argument of the current 
      ; argument that provides a defense for the current argument
      if member? myargu not-admissible[
        ask myargu [
          ask my-in-attacks [
            ask end1 [
              ; create a set of arguments that provide a defense for the current
	      ; argument, these:
              ; a) attack the attacker of the current argument;
	      ; b) are a child-argument of the current argument;
              ; c) are discovered; and
	      ; d) no researcher from the same network is working on it
              let nextargu in-attack-neighbors with [in-discovery-neighbor?
	        myargu and 
					[not member? color [gray turquoise]] of self
					; color != gray and color != turquoise 
					and not group-member-here curresearcher
					; (any?
		; researchers with [xcor = [xcor] of myself and ycor = [ycor] of myself
		; and member? self [collaborator-network] of curresearcher])
		]
              ; if such an argument exists the researcher moves there
              ; and cannot move anymore this time step
              if any? nextargu [
                ask curresearcher [
                  move-to one-of nextargu
                  set moved true
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end

to-report non-comm-scientists-here [myx myy]
	ifelse any? researchers with [xcor = myx and ycor = myy and 
      communicating = 0] or (ticks mod 5 = 0 and any? researchers with [xcor = myx and ycor = myy])
	[
		report true
	][
		report false
	]
end
; every five time steps the landscape is updated:
; new arguments become visible and attacks are discovered
to update-landscape-test7
  ask startsargum [
    let myx xcor
    let myy ycor
    ; discoveries only occur when an researcher is working on that argument, 
    ; it is the 5th time step or the researcher does not communicate
    ; working on an argument means that the researcher did 
    ; not communicate in that round
    if non-comm-scientists-here myx myy
		; any? researchers with [xcor = myx and ycor = myy and 
      ; communicating = 0] or (any? researchers with [ 
      ; xcor = myx and ycor = myy] and ticks mod 5 = 0)
		[
      set researcher-ticks researcher-ticks + 1
      
      ; the color of an argument is changed if researchers have been working
      ; on that argument for research-speed time steps
      if researcher-ticks mod research-speed = 0 and color != red[
        set color color - 10
        if color = red [set full-research true]
      ]
        
      ; depending on the color a new child-argument is discovered, until all
      ; child-arguments are discovered
      if color = yellow and count out-discovery-neighbors with
	[color = gray or color = turquoise] >= 4 [
        ask one-of out-discovery-neighbors with
	  [color = gray or color = turquoise][
          set color lime
          ask my-in-discoveries [
            set color cyan
          ]
        ]
      ]
      if color = brown and count out-discovery-neighbors with
	[color = gray or color = turquoise] >= 3 [
        ask one-of out-discovery-neighbors with
	  [color = gray or color = turquoise][
          set color lime
          ask my-in-discoveries [
            set color cyan
          ]
        ]
      ]
      if color = orange and count out-discovery-neighbors with
	[color = gray or color = turquoise] >= 2 [
       ask one-of out-discovery-neighbors with
         [color = gray or color = turquoise][
          set color lime
          ask my-in-discoveries [
            set color cyan
          ]
        ]
      ]
      if color = red and count out-discovery-neighbors with
	[color = gray or color = turquoise] >= 1 [
        ask one-of out-discovery-neighbors with
  	 [color = gray or color = turquoise][
          set color lime
          ask my-in-discoveries [
            set color cyan
          ]
        ]
      ]

      ; for arguments that have still undiscovered relations/neighbors and are
      ; not fully researched
      if ticks mod 5 = 0 and color != red [
        let attack-random random-float 1.00
        
        ; with visibility-probability a new attacked/attacking argument is
        ; discovered
        if attack-random < visibility-probability [
          if any? my-links with [breed = attacks and color = gray][
            ask one-of my-links with [breed = attacks and color = gray][
              set color red
              ask other-end [if color = gray [set color turquoise]]
            ]
          ]
        ]
      ]
    ]
    
    ; once an argument is fully researched all its relations to other arguments
    ; are discovered as well
    ; full-discovery-test7
    
    ; if both ends of a discovery relation are discovered
    ; by research, the relation is discovered as well
    if color != gray [
      ask my-out-discoveries with [color = gray][
        if [not member? color [gray turquoise]] of other-end
				; [color] of other-end != gray and [color] of other-end != turquoise 
				[
          set color cyan
        ]
      ]
    ]
  ]
  
  ; at the end of the time steps 1, 2, 3 and 4 communicating researchers
  ; decrease their communicating value by 1
  ; if ticks mod 5 != 0 [
    ; ask researchers with [communicating > 0][
      ; set communicating communicating - 1
    ; ]
  ; ]
end

to communication-regress
    ask researchers with [communicating > 0][
      set communicating communicating - 1
    ]
end



; procedure that makes sure that fully researched arguments have a fully 
; discovered neighborhood
to full-discovery-test7 
  ask startsargum with [full-research][
    let myx xcor
    let myy ycor
    if non-comm-scientists-here myx myy
		; any? researchers with [xcor = myx and ycor = myy and 
      ; communicating = 0] or (ticks mod 5 = 0 and any? researchers with 
      ; [xcor = myx and ycor = myy])
			[
      
      ; once an argument is fully researched all its relations,
      ; attack and discovery, are discovered
      if any? out-discovery-neighbors with [color = gray or color = turquoise][
        ask out-discovery-neighbors with [color = gray or color = turquoise][
          set color lime
          ask my-in-discoveries [
            set color cyan
          ]
        ]
      ]
     
      ; note that in the case of an attack relation the other argument
      ; is not really discovered: it needs to be discovered by a discovery
      ; relation in the other theory to become lime
      if any? my-in-attacks with [color = gray][
        ask my-in-attacks with [color = gray][
          set color red
          ask other-end [if color = gray [set color turquoise]]
        ]
      ]
      if any? my-out-attacks with [color = gray][
        ask my-out-attacks with [color = gray][
          set color red
          ask other-end [if color = gray [set color turquoise]]
        ]
      ]
    ]
    set full-research false
  ]
end




to compute-subj-attacked-test7
	foreach colla-networks [
		let calc-done false
		let calc-researcher []
		let cur-group ?
		foreach cur-group [
			let cur-researcher ?
			if not [rep-researcher] of cur-researcher [
				ifelse calc-done [
					ask cur-researcher [
						set admissible-subj-argu [admissible-subj-argu] of calc-researcher
						set current-theory-info [current-theory-info] of calc-researcher
						set non-admiss-subj-argu [non-admiss-subj-argu] of calc-researcher
					]
				][
					set calc-done true
					set calc-researcher cur-researcher
					ask cur-researcher [
						; variables for lists that contain:
						; the current-theory-info with 0 admissible arguments; an updated number
						; of admissible arguments during the recursive computation; the arguments
						; that are not admissible; the arguments that the researchers knows about; and
						; the arguments that are attacked by the current theory 
						let new-info []
						let new-cur-info []
						let not-admissible []
						let args-cur-arguments []
						let attacked-by-me []
						
						; create a list of only the attacks
						let attack-relations []
						foreach subjective-relations [
							if first ? = "a" [
								set attack-relations lput ? attack-relations
							]
						]
						; create lists of attacked and attacking arguments
						let cur-attacked []
						let cur-attacker []
						foreach attack-relations [
							set cur-attacked lput last ? cur-attacked
							set cur-attacker lput first but-first ? cur-attacker
						]
						
						; create a list of the arguments the researchers knows about and 
						; set the number of admissible arguments for each theory to 0
						foreach subjective-arguments [
							set args-cur-arguments lput first ? args-cur-arguments
						]
						foreach current-theory-info [
							set new-info lput replace-item 1 ? 0 new-info
						]
						set current-theory-info new-info
						
						; the computation of the admissible arguments is done recursively
						; a list of arguments that are currently considered attacked
						let open-rec []
						; variable that lets the loop run at least one time
						let i 0
						foreach current-theory-info [
							; the theory that is considered in this loop
							; and the root of that theory (the start)
							let cur-theory ?
							let askstart item 0 cur-theory
							while [ i < 1 or not empty? open-rec][
								set not-admissible sentence not-admissible open-rec
								set open-rec []
								set attacked-by-me []
								
								; create a list of arguments that are attacked by the current theory
								; based on the memory of the current researcher
								if not empty? attack-relations [
									ask startsargum with [member? self args-cur-arguments and
									mytheory = askstart][
										if member? self cur-attacker and not member? self not-admissible [
											; the argument considered and a list of arguments
											; attacked by that argument
											let cur-turtle self
											let my-attacked []
											foreach attack-relations [
												if first but-first ? = cur-turtle [
													set my-attacked lput last ? my-attacked
												]
											]
											set attacked-by-me sentence my-attacked attacked-by-me
										]
									]
									
									; arguments that are attacked by arguments from another theory that are
									; not attacked by non-attacked arguments from the current theory
									; are added to the open-rec list, the list of attacked-arguments
									ask startsargum with [member? self args-cur-arguments and
										mytheory = askstart and not member? self not-admissible and
										member? self cur-attacked][
									let cur-turtle self
									foreach attack-relations [
										if last ? = cur-turtle [
											if not member? last but-last ? attacked-by-me [
												set open-rec lput cur-turtle open-rec
											]
										]
									]
										]
								]
								set i i + 1
							]
							set i 0
							
							; for the update of the information in current-theory-info
							set new-cur-info lput replace-item 1 cur-theory (count startsargum with
								[member? self args-cur-arguments and mytheory = askstart] -
								count startsargum with [member? self not-admissible and mytheory = askstart])
									new-cur-info
						]
						
						; arguments that are part of the not-admissible list
						; are not part of the admissible subjective arguments and hence removed
						set admissible-subj-argu subjective-arguments
						set non-admiss-subj-argu []
						foreach subjective-arguments [
							let cur-argu ?
							if member? first cur-argu not-admissible [
								set admissible-subj-argu remove cur-argu admissible-subj-argu								
								set non-admiss-subj-argu lput item 0 cur-argu non-admiss-subj-argu
							]
						]
						; update the current-theory-info
						set current-theory-info new-cur-info
					]
				]
			]
		]
	]
end
; testprocedures.nls ends here

; behavior.nls starts here
; the procedures that determine
; the basic behavior of the researchers:
; 1. how they update their memory
; 2. how they share information
; 3. how they walk around on the landscape
; 4. how the landscape is updated





; every round, the researchers update their memory:
; arguments that have changed color, new arguments/links
; every fifth round the researchers share their updated memory within their
; collaborator-network
to update-memories
  ask researchers [
    let myx xcor
    let myy ycor
    let cur-argum one-of turtles with [(breed = starts or breed = arguments)
      and xcor = myx and ycor = myy]
    let cur-researcher self
    ; information of current argument in the format of the memory
    let add-cur (sentence cur-argum [color] of cur-argum)
    set subjective-arguments lput add-cur subjective-arguments
    ; list of relations (resp. arguments) that are added
    let to-add []
    let to-add-argu []
    ; list of neighborhood arguments of the current argument
    set neighborargs []
    set neighborargs lput cur-argum neighborargs
    
    ; for the current argument
    ; add the neighboring discovered arguments and relations
    ; (attacks and discovery) to a to-add list
    ask cur-argum [
       if any? my-in-discoveries with [color != gray][
        ask my-in-discoveries with [color != gray][
          let add-other-end other-end
          ask cur-researcher [
            set neighborargs lput add-other-end neighborargs
          ]
          ; construction of the to be added discovery relation
          let add-rel []
          set add-rel lput "d" add-rel
          set add-rel lput add-other-end add-rel
          set add-rel lput cur-argum add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
      
      ; add the child argument of the discovery relation
      if any? my-out-discoveries with [color != gray][
        ask my-out-discoveries with [color != gray][
	  let add-other-end other-end
	  ask cur-researcher [
	    set neighborargs lput add-other-end neighborargs
	  ]
	  ; construction of the to be added discovery relation
	  let add-rel []
	  set add-rel lput "d" add-rel
          set add-rel lput cur-argum add-rel
          set add-rel lput add-other-end add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
     
      ; add the parent argument of the attack relation
      if any? my-in-attacks with [color != gray][
        ask my-in-attacks with [color != gray][
          let add-other-end other-end
          ask cur-researcher [
            set neighborargs lput add-other-end neighborargs
          ]
          ; construction of the to be added attack relation
          let add-rel []
          set add-rel lput "a" add-rel
          set add-rel lput add-other-end add-rel
          set add-rel lput cur-argum add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
      
      ; add the child argument of the attack relation
      if any? my-out-attacks with [color != gray][
        ask my-out-attacks with [color != gray][
          let add-other-end other-end
          ask cur-researcher [
            set neighborargs lput add-other-end neighborargs
          ]
          ; construction of the to be added attack relation
          let add-rel []
          set add-rel lput "a" add-rel
          set add-rel lput cur-argum add-rel
          set add-rel lput other-end add-rel
          set to-add lput add-rel to-add
          ; the to be added argument
          let add-other (sentence add-other-end [color] of add-other-end)
          set to-add-argu lput add-other to-add-argu
        ]
      ]
    ]
    
    ; remove duplicates from the list
    set subjective-relations remove-duplicates sentence
      subjective-relations to-add
    set subjective-arguments remove-duplicates sentence
      subjective-arguments to-add-argu
  ]
  
  ; every 5 plus 4 time-steps the collected information
  ; is shared with other researchers
  if ticks mod 5 = 4 [
    share-with-others
  ] 
  
end





; procedure in which researchers share (part of) their memory with other researchers
; first they share their whole memory with researchers from their
; collaborator-network
; second they share information with researchers from other networks
to share-with-others
  ask researchers [
    ; reset the variables
    set rep-researcher false 
    set to-add-mem-argu []
    set to-add-mem-rel []
    
    ; variables to keep track of the current researchers own memory
    ; and the combined memory of all the sharing researchers
    let own-memory-argu subjective-arguments
    let own-memory-rel subjective-relations
    let comb-memory-argu []
    let comb-memory-rel []
    ; collaborator network of the current researcher
    let cur-network collaborator-network
    
    ; the information in the memories of the single researchers in the network
    ; are combined 
    ask turtles with [member? self cur-network] [
      set comb-memory-argu sentence subjective-arguments comb-memory-argu
      set comb-memory-rel sentence subjective-relations comb-memory-rel
    ]
    
    ; each researcher adds the combined memory to its own
    ; then removing duplicates
    set subjective-arguments remove-duplicates sentence
      own-memory-argu comb-memory-argu
    set subjective-relations remove-duplicates sentence
      own-memory-rel comb-memory-rel
    
    foreach subjective-arguments [
      ; the argument of the current subjective-arguments entry
      let argu first ?
      ; the color of the current subjective-arguments entry
      let my-color first but-first ?
      ; a list of subjective-arguments entries that concern
      ; the same argument
      let color-argu filter [first ? = argu] subjective-arguments
      set color-argu sort-by [first but-first ?1 < first but-first ?2] color-argu
      ; keep only the argument-entry that is researched the most
      ; entries from the same argument but with higher color-value are deleted
      while [length color-argu != 1] [
        set subjective-arguments remove last color-argu subjective-arguments
        set color-argu but-last color-argu
      ]
    ]
  ]
  
  ; then researchers can share some of their information with researchers 
  ; from neighboring networks in the social structures
  create-share-memory
  share-with-other-networks
  
end





; procedure in which researchers collect the information from their
; memory that they want to share with researchers that do not 
; belong to their own collaborator-network
to create-share-memory
  
  ; for each collaborator-network one researcher is set to be
  ; the representative researcher
  foreach colla-networks [
    ifelse length ? > 1 [
      ask one-of researchers with [member? self ?][
        set rep-researcher true
      ] 	
    ][
    if ticks mod 25 = 4 [
      ask one-of researchers with [member? self ?][
        set rep-researcher true
      ]
    ]
    ]
  ]
  
  ; only the representative researchers create a memory 
  ; that they want to share with researchers from other networks
  ask researchers with [rep-researcher][
    let myx xcor
    let myy ycor
    ; variables for the argument the researcher is currently working on,
    ; the researcher itself and the theory it is working on
    let cur-argum one-of turtles with [(breed = starts or breed = arguments)
      and xcor = myx and ycor = myy]
    let cur-researcher self 
    let cur-th [mytheory] of cur-argum
    ; create a list of arguments and a list of relations that the researcher can
    ; share with researchers from other collaborative networks
    ; what researchers share depends on the "social-action" and "sharing"
    ; from the interface
    set th-args []
    set th-relations []
    
    ; researchers share only information obtained in the neighborhood 
    ; they are currently working on
    ; collect the arguments from the researcher's memory
    ; that belong also to the neighborargs
    foreach subjective-arguments [
      if member? item 0 ? [neighborargs] of cur-researcher [
        set th-args lput ? th-args
      ]
    ]
    ; collect the relations from/to the current argument
    ; from the researcher's memory
    foreach subjective-relations [
      if item 1 ? = cur-argum or item 2 ? = cur-argum [
        set th-relations lput ? th-relations
      ]
    ]
    
    ; if the researcher behaves biased it does not share the attack relations that
    ; attack its current theory, these relations are removed
    if social-actions = "biased"[
      foreach th-relations [
        if item 0 ? = "a" and [mytheory] of item 2 ? = cur-th [
          set th-relations remove ? th-relations
        ]
      ]
    ]
  ]
end





; procedure in which the representative researchers of the networks
; share information according to the social structure
to share-with-other-networks 
  ask researchers with [rep-researcher][
    ; variables for the combined information (arguments and relations),
    ; the network of the current researcher and the theory it is working on
    let comb-memory-argu th-args
    let comb-memory-rel th-relations
    let cur-network sort collaborator-network
    let my-cur-theory [mytheory] of item 0 item 0 th-args
    
    ; create a list of the neighboring networks and then a 
    ; list of the representative researchers of these networks
    ; which will be the researchers the current researcher shares with
    let share-researchers []
    let share-neighbors []
    foreach share-structure [    
      if first ? = cur-network [
        set share-neighbors ?
      ]
    ]
    ask researchers with [rep-researcher][
      let cur-researcher self
      foreach share-neighbors [
        if member? cur-researcher ? [
          set share-researchers lput cur-researcher share-researchers
        ]
      ]
    ]
    
    ; create a list of arguments and a list of relations that is
    ; shared among the share-researchers
    foreach share-researchers [
      ; the combined memory is updated to contain that of the sharing researcher
      set comb-memory-argu sentence comb-memory-argu [th-args] of ?
      set comb-memory-rel sentence comb-memory-rel [th-relations] of ?
    ]
    ; create lists of arguments/relations that have to be added
    foreach share-researchers [
      set to-add-mem-argu remove-duplicates sentence subjective-arguments
        comb-memory-argu
      set to-add-mem-rel remove-duplicates sentence subjective-relations
        comb-memory-rel
    ]
  ] 
  
  ; to compute the time that researchers have to
  ; spend on communication
  compute-time-costs 
end





; procedure that adds the new information to the memory of the 
; representative researchers and computes the time they have lost by
; communicating
to compute-time-costs
  ask researchers with [rep-researcher][
    
    ; variables that contain the arguments and relations the
    ; researcher has to update in its memory
    let new-memory-args []
    let new-memory-rel []
    set new-memory-args filter [not member? ? subjective-arguments]
      to-add-mem-argu
    set new-memory-rel filter [not member? ? subjective-relations]
      to-add-mem-rel
    let comb-new sentence new-memory-args new-memory-rel
    ; every tick an researcher can obtain a maximum of 10 new entries
    ; the day that they received information is also lost
    ifelse length comb-new >= (3 * max-learn) [
      set communicating 4
    ][
    set communicating ((ceiling (length comb-new / max-learn)) + 1)
    ]
    
    ; every communication round an researcher can update a maximum of 
    ; 3 * max-learn new arguments/relations (corresponding to three ticks of
    ; communication) these new arguments and relations are added to the
    ; memory of the researcher
    ; when a new relation is added and the arguments are not part of the
    ; memory of the researcher, these arguments are added as well
    ifelse length comb-new > (3 * max-learn) [
      set comb-new shuffle comb-new
      let repeats length comb-new - (3 * max-learn)
      while [length comb-new > repeats] [
        let cur-entr first comb-new
        let new-mem-argargs filter [member? ? new-memory-args] comb-new
        set new-mem-argargs map [first ?] new-mem-argargs
        ifelse member? cur-entr new-memory-args [
          set subjective-arguments lput cur-entr subjective-arguments
          set comb-new remove cur-entr comb-new
        ][
        set subjective-relations lput cur-entr subjective-relations
        set comb-new remove cur-entr comb-new
        if member? item 1 cur-entr new-mem-argargs[
          let item-1-cur-entr item 1 cur-entr
          foreach comb-new [
            if item-1-cur-entr = item 0 ? [
              set subjective-arguments lput ? subjective-arguments
              set comb-new remove ? comb-new
            ]
          ] 
        ]
        if member? item 2 cur-entr new-mem-argargs[
          let item-2-cur-entr item 2 cur-entr
          foreach comb-new [
            if item-2-cur-entr = item 0 ? [
              set subjective-arguments lput ? subjective-arguments
              set comb-new remove ? comb-new
            ]
          ] 
        ]
        ]
      ]
    ][
    set subjective-arguments sentence subjective-arguments new-memory-args
    set subjective-relations sentence subjective-relations new-memory-rel
    ]
  ]
end





; procedure that removes all duplicates from the memory of an researcher
; duplicates also include arguments that are part of the memory with
; different colors in these cases only the entry with the lowest color value
; is kept these arguments are furthest researched
to duplicate-remover
  ask researchers [
    ; list of arguments of which the duplicates will be removed
    let new-args subjective-arguments
    foreach new-args [
      ; the argument of the current entry and its color
      let argu first ?
      let my-color first but-first ?
      ; list of entries with the same argument, but maybe different color
      let color-argu filter [first ? = argu] new-args
      ; remove entries of arguments that are also present as
      ; better researched entries
      set color-argu sort-by [first but-first ?1 < first but-first ?2] color-argu
      while [length color-argu != 1] [
        set new-args remove last color-argu new-args
        set color-argu but-last color-argu
      ]
    ]
    ; update the researcher's memory
    set subjective-arguments new-args
  ]
end





; procedure that describes how the researchers move around over the landscape
; they only "see" the colored part of the landscape and hence can only move
; there, the probability of moving increases (a little) when the argument is
; further researched in one time step researchers can either receive information or
; move, but not both
to move-around
  ; variable to make sure that the procedure find-defense
  ; is only run once
  let run-find-defense false 
  ; at the beginning of the procedure no researcher has moved yet
  ask researchers [
    set moved false
  ]
  ask researchers [
    let curresearcher self
    if [communicating] of curresearcher = 0 or ticks mod 5 = 0 [
      let myx xcor
      let myy ycor
      ; variable for the argument the researcher is currently working on and
     ; the researcher itself
        let myargu one-of turtles with [(breed = starts or breed = arguments) and
        xcor = myx and ycor = myy]
      
      ; a list of not-admissible arguments is created
      let not-admissible []
      if admissible-subj-argu != 0 and not empty? admissible-subj-argu [
        let info-not-admissible filter [not member? ? admissible-subj-argu]
          subjective-arguments
        foreach info-not-admissible [
          set not-admissible lput item 0 ? not-admissible
        ]
      ]
   
      ; an researcher working on an attacked argument will try to find a defense for
      ; this attack, by working further on the attacked argument, unless it
      ; discoveres a child-argument that that has a defense for the attack
      ; (it is not necessarily the case that this defense is already discovered)
      ; the find-defense runs immediately for all researchers working on a not
      ; fully researched not-admissible argument, hence it is only once executed
      if member? myargu not-admissible and not moved[
      
        if not run-find-defense [
          find-defense
          set run-find-defense true
        ]
      ]
    
      if not moved and not member? myargu not-admissible or 
        (member? myargu not-admissible and [color] of myargu = red)[
        
        ; when an argument exists that:
        ; a) is a child-argument of the current argument;
        ; b) is not gray, red or turquoise; and
        ; c) no researcher from the same collaborator-network is working on it
        ; the researcher moves there, with certain probability
        ifelse any? turtles with [(breed = starts or breed = arguments) and
          in-discovery-neighbor? myargu and color != gray and color != red and
    	  color != turquoise and not (any? turtles with [breed = researchers and
	  xcor = [xcor] of myself and ycor = [ycor] of myself and member? self
	  [collaborator-network] of curresearcher])] [
        let move-random random-float 1.0
      

        ; every time step with small-movement of the move-probability
        ; the researcher moves
        ifelse move-random < (small-movement * move-probability *
          (1 - (color / color-move))) [
          move-to one-of turtles with [(breed = starts or breed = arguments) and
            in-discovery-neighbor? myargu and color != gray and color != red and
            color != turquoise and not ( any? turtles with [breed = researchers and
            xcor = [xcor] of myself and ycor = [ycor] of myself and member? self
  	    [collaborator-network] of curresearcher])]
          set moved true
        ][
      
        ; every 5th time step the researcher mover with the full move-probability,
        ; that depends a bit on the color
        if ticks != 0 and ticks mod 5 = 0 and move-random <
          move-probability * (1 - (color / color-move)) [
          move-to one-of turtles with [(breed = starts or breed = arguments) and
            in-discovery-neighbor? myargu and color != gray and color != red and
	    color != turquoise and not ( any? turtles with [breed = researchers
	    and xcor = [xcor] of myself and ycor = [ycor] of myself and
	    member? self [collaborator-network] of curresearcher])]
          set moved true
        ]
        ]
            ][

        ; if there is no next argument and the current argument is
        ; fully researched, the researcher moves a step back
        ifelse [color] of myargu = red and any? turtles with [color != gray and
          color != turquoise and out-discovery-neighbor? myargu and not any?
	  turtles with [breed = researchers and xcor = [xcor] of myself and
	  ycor = [ycor] of myself and member? self [collaborator-network]
	  of curresearcher]][
        move-to one-of turtles with [color != gray and out-discovery-neighbor?
          myargu and not any? turtles with [breed = researchers and xcor = [xcor] of
          myself and ycor = [ycor] of myself and member? self
          [collaborator-network] of curresearcher]]
        set moved true
          ][
      
        ; if moving back is not possible, it jumps to another argument in
        ; the same tree/theory that is discovered but not fully researched
        if [color] of myargu = red[
          let askstart [mytheory] of myargu
          if any? turtles with [(breed = starts or breed = arguments) and
	    color != gray and color != turquoise and color != red and
	    mytheory = askstart and not any? turtles with [breed = researchers and
  	    xcor = [xcor] of myself and ycor = [ycor] of myself and member?
	    self [collaborator-network] of curresearcher]][
          move-to one-of turtles with [(breed = starts or breed = arguments) and
	   color != turquoise and color != gray and color != red and
  	   mytheory = askstart and not any? turtles with [breed = researchers and
	   xcor = [xcor] of myself and ycor = [ycor] of myself and member? self
           [collaborator-network] of curresearcher]]
          set moved true
            ]
        ]
          ]
            ]
      ]
    ]	
  ]
end





; researchers working on a not fully researched attacked argument will try to find a
; defense for that attack, by staying on the current argument
; if a child-argument is discovered that can provide a defense, the 
; researcher moves there
; once an argument is fully researched all its relations are discovered,
; then an researcher can move on and can try to find a defense in another branch,
; further away
to find-defense
  ask researchers with [not moved][    
    let curresearcher self
    if [communicating] of curresearcher = 0 or ticks mod 5 = 0 [
      let myx xcor
      let myy ycor
      ; variables for the argument the researcher is working on and
      ; for the researcher itself
      let myargu one-of turtles with [(breed = starts or breed = arguments) and
        xcor = myx and ycor = myy]
    
      ; lists of arguments that are not admissible
      let not-admissible []
      if admissible-subj-argu != 0 and not empty? admissible-subj-argu [
        let info-not-admissible filter [not member? ? admissible-subj-argu]
          subjective-arguments
        foreach info-not-admissible [
          set not-admissible lput item 0 ? not-admissible
        ]
      ]
    
      ; if the current argument is not fully researched and not admissible
      ; and it is a 5th time step or the researcher is not communicating
      ; the researcher tries to move prospectively to a child-argument of the current 
      ; argument that provides a defense for the current argument
      if member? myargu not-admissible[
        ask myargu [
          ask my-in-attacks [
            ask end1 [
              ; create a set of arguments that provide a defense for the current
	      ; argument, these:
              ; a) attack the attacker of the current argument;
	      ; b) are a child-argument of the current argument;
              ; c) are discovered; and
	      ; d) no researcher from the same network is working on it
              let nextargu in-attack-neighbors with [in-discovery-neighbor?
	        myargu and color != gray and color != turquoise and not (any?
		researchers with [xcor = [xcor] of myself and ycor = [ycor] of myself
		and member? self [collaborator-network] of curresearcher])]
              ; if such an argument exists the researcher moves there
              ; and cannot move anymore this time step
              if any? nextargu [
                ask curresearcher [
                  move-to one-of nextargu
                  set moved true
                ]
              ]
            ]
          ]
        ]
      ]
    ]
  ]
end





; every five time steps the landscape is updated:
; new arguments become visible and attacks are discovered
to update-landscape
  ask turtles with [breed = arguments or breed = starts][
    let myx xcor
    let myy ycor
    ; discoveries only occur when an researcher is working on that argument, 
    ; it is the 5th time step or the researcher does not communicate
    ; working on an argument means that the researcher did 
    ; not communicate in that round
    if any? turtles with [breed = researchers and xcor = myx and ycor = myy and 
      communicating = 0] or (any? turtles with [breed = researchers and 
      xcor = myx and ycor = myy] and ticks mod 5 = 0)[
      set researcher-ticks researcher-ticks + 1
      
      ; the color of an argument is changed if researchers have been working
      ; on that argument for research-speed time steps
      if researcher-ticks mod research-speed = 0 and color != red[
        set color color - 10
        if color = red [set full-research true]
      ]
        
      ; depending on the color a new child-argument is discovered, until all
      ; child-arguments are discovered
      if color = yellow and count out-discovery-neighbors with
	[color = gray or color = turquoise] >= 4 [
        ask one-of out-discovery-neighbors with
	  [color = gray or color = turquoise][
          set color lime
          ask my-in-discoveries [
            set color cyan
          ]
        ]
      ]
      if color = brown and count out-discovery-neighbors with
	[color = gray or color = turquoise] >= 3 [
        ask one-of out-discovery-neighbors with
	  [color = gray or color = turquoise][
          set color lime
          ask my-in-discoveries [
            set color cyan
          ]
        ]
      ]
      if color = orange and count out-discovery-neighbors with
	[color = gray or color = turquoise] >= 2 [
       ask one-of out-discovery-neighbors with
         [color = gray or color = turquoise][
          set color lime
          ask my-in-discoveries [
            set color cyan
          ]
        ]
      ]
      if color = red and count out-discovery-neighbors with
	[color = gray or color = turquoise] >= 1 [
        ask one-of out-discovery-neighbors with
  	 [color = gray or color = turquoise][
          set color lime
          ask my-in-discoveries [
            set color cyan
          ]
        ]
      ]

      ; for arguments that have still undiscovered relations/neighbors and are
      ; not fully researched
      if ticks mod 5 = 0 and color != red [
        let attack-random random-float 1.00
        
        ; with visibility-probability a new attacked/attacking argument is
        ; discovered
        if attack-random < visibility-probability [
          if any? my-links with [breed = attacks and color = gray][
            ask one-of my-links with [breed = attacks and color = gray][
              set color red
              ask other-end [if color = gray [set color turquoise]]
            ]
          ]
        ]
      ]
    ]
    
    ; once an argument is fully researched all its relations to other arguments
    ; are discovered as well
    full-discovery
    
    ; if both ends of a discovery relation are discovered
    ; by research, the relation is discovered as well
    if color != gray [
      ask my-out-discoveries with [color = gray][
        if [color] of other-end != gray and [color] of other-end != turquoise [
          set color cyan
        ]
      ]
    ]
  ]
  
  ; at the end of the time steps 1, 2, 3 and 4 communicating researchers
  ; decrease their communicating value by 1
  if ticks mod 5 != 0 [
    ask researchers with [communicating > 0][
      set communicating communicating - 1
    ]
  ]
end





; procedure that makes sure that fully researched arguments have a fully 
; discovered neighborhood
to full-discovery 
  ask turtles with [breed = arguments or breed = starts and full-research][
    let myx xcor
    let myy ycor
    if any? turtles with [breed = researchers and xcor = myx and ycor = myy and 
      communicating = 0] or (ticks mod 5 = 0 and any? turtles with 
      [breed = researchers and xcor = myx and ycor = myy])[
      
      ; once an argument is fully researched all its relations,
      ; attack and discovery, are discovered
      if any? out-discovery-neighbors with [color = gray or color = turquoise][
        ask out-discovery-neighbors with [color = gray or color = turquoise][
          set color lime
          ask my-in-discoveries [
            set color cyan
          ]
        ]
      ]
     
      ; note that in the case of an attack relation the other argument
      ; is not really discovered: it needs to be discovered by a discovery
      ; relation in the other theory to become lime
      if any? my-in-attacks with [color = gray][
        ask my-in-attacks with [color = gray][
          set color red
          ask other-end [if color = gray [set color turquoise]]
        ]
      ]
      if any? my-out-attacks with [color = gray][
        ask my-out-attacks with [color = gray][
          set color red
          ask other-end [if color = gray [set color turquoise]]
        ]
      ]
    ]
    set full-research false
  ]
end





; behavior.nls ends here

; strategies.nls starts here
; the procedures that are involved in
; calculating the best theory for an researcher
; to work on:
; 1. computing the arguments in the memory 
;    that are not admissible
; 2. computing the best theory based on the
;    number of non-admissible arguments
; 3. procedure that lets researchers change
;    their current theory





; based on their memory researchers compute lists of attacked arguments
; with these lists the current best theory is computed
to compute-strategies-researchers
  
  ; researchers start with figuring out which argument in their
  ; memory are admissible and which are attacked
  compute-subjective-attacked
 
  ask researchers with [not rep-researcher][
    set cur-best-th []
    ; variables for the list that contains the number admissible arguments 
    ; per theory and a sublist which contains only the numbers that are
    ; within the strategy-threshold
    let list-admissible-arguments []
    let threshold-admissible-arguments []
    
    ; create a list with the number of admissible arguments
    ; of each of the theories
    foreach current-theory-info [
      set list-admissible-arguments lput item 1 ? list-admissible-arguments
    ]
    set list-admissible-arguments sort list-admissible-arguments
    
    ; a list of theories with values within the strategy threshold is constructed
    set threshold-admissible-arguments filter [? >=
      ((max list-admissible-arguments) * strategy-threshold)]
        list-admissible-arguments
    set threshold-admissible-arguments sort threshold-admissible-arguments
    
    ; computation of the current best theory
    ; theories with a number of admissible arguments that are
    ; within the threshold can be considered as current best theory
    foreach current-theory-info [
      if member? item 1 ? threshold-admissible-arguments [
        set cur-best-th lput item 0 ? cur-best-th
      ]
    ]
  ]
end





; procedure that computes for each researcher which of the arguments in its memory
; are admissible (and hence which are attacked)
to compute-subjective-attacked
  ask researchers with [not rep-researcher][
    ; variables for lists that contain:
    ; the current-theory-info with 0 admissible arguments; an updated number
    ; of admissible arguments during the recursive computation; the arguments
    ; that are not admissible; the arguments that the researchers knows about; and
    ; the arguments that are attacked by the current theory 
    let new-info []
    let new-cur-info []
    let not-admissible []
    let args-cur-arguments []
    let attacked-by-me []
    
    ; create a list of only the attacks
    let attack-relations []
    foreach subjective-relations [
      if first ? = "a" [
        set attack-relations lput ? attack-relations
      ]
    ]
    ; create lists of attacked and attacking arguments
    let cur-attacked []
    let cur-attacker []
    foreach attack-relations [
      set cur-attacked lput last ? cur-attacked
      set cur-attacker lput first but-first ? cur-attacker
    ]
    
    ; create a list of the arguments the researchers knows about and 
    ; set the number of admissible arguments for each theory to 0
    foreach subjective-arguments [
      set args-cur-arguments lput first ? args-cur-arguments
    ]
    foreach current-theory-info [
      set new-info lput replace-item 1 ? 0 new-info
    ]
    set current-theory-info new-info
    
    ; the computation of the admissible arguments is done recursively
    ; a list of arguments that are currently considered attacked
    let open-rec []
    ; variable that lets the loop run at least one time
    let i 0
    foreach current-theory-info [
      ; the theory that is considered in this loop
      ; and the root of that theory (the start)
      let cur-theory ?
      let askstart item 0 cur-theory
      while [ i < 1 or not empty? open-rec][
        set not-admissible sentence not-admissible open-rec
        set open-rec []
        set attacked-by-me []
        
        ; create a list of arguments that are attacked by the current theory
        ; based on the memory of the current researcher
        if not empty? attack-relations [
          ask turtles with [member? self args-cur-arguments and
	        mytheory = askstart][
            if member? self cur-attacker and not member? self not-admissible [
              ; the argument considered and a list of arguments
              ; attacked by that argument
              let cur-turtle self
              let my-attacked []
              foreach attack-relations [
                if first but-first ? = cur-turtle [
                  set my-attacked lput last ? my-attacked
                ]
              ]
              set attacked-by-me sentence my-attacked attacked-by-me
            ]
          ]
          
          ; arguments that are attacked by arguments from another theory that are
          ; not attacked by non-attacked arguments from the current theory
          ; are added to the open-rec list, the list of attacked-arguments
          ask turtles with [member? self args-cur-arguments and
	          mytheory = askstart and not member? self not-admissible and
	          member? self cur-attacked][
          let cur-turtle self
          foreach attack-relations [
            if last ? = cur-turtle [
              if not member? last but-last ? attacked-by-me [
                set open-rec lput cur-turtle open-rec
              ]
            ]
          ]
            ]
        ]
        set i i + 1
      ]
      set i 0
      
      ; for the update of the information in current-theory-info
      set new-cur-info lput replace-item 1 cur-theory (count turtles with
        [member? self args-cur-arguments and mytheory = askstart] -
	      count turtles with [member? self not-admissible and mytheory = askstart])
	        new-cur-info
    ]
    
    ; arguments that are part of the not-admissible list
    ; are not part of the admissible subjective arguments and hence removed
    set admissible-subj-argu subjective-arguments
    foreach subjective-arguments [
      let cur-argu ?
      if member? first cur-argu not-admissible [
        set admissible-subj-argu remove cur-argu admissible-subj-argu
      ]
    ]
    ; update the current-theory-info
    set current-theory-info new-cur-info
  ]
end





; procedure that lets the researchers act on the just computed best theory
; based on their own memory
to act-on-strategy-researchers
  ask researchers with [not rep-researcher][
    ; only when there is a current best theory
    ; it makes sense for the researchers to want to work on that theory
    if not empty? cur-best-th and not member? nobody cur-best-th [
      let myx xcor
      let myy ycor
      
      ; if the researcher is not currently working on the best theory
      ; it considers jumping
      foreach subjective-arguments [
        if [xcor] of item 0 ? = myx and [ycor] of item 0 ? = myy and
        not member? [mytheory] of item 0 ? cur-best-th [
          set theory-jump theory-jump + 1
        ]
      ]
      
      ; if the researcher has considered jumping jump-threshold times
      ; it jumps to one of the theories it considers best, based
      ; on its memory and the computations
      if theory-jump >= jump-threshold [
        let ch-best one-of cur-best-th
        let subj-argus []
        foreach subjective-arguments [
          set subj-argus lput item 0 ? subj-argus
        ]
        
        ; if one of the arguments from the best theory is in its memory
        ; the researcher will jump there
        ifelse any? turtles with [(breed = starts or breed = arguments) and
	        member? self subj-argus and mytheory = ch-best and color != turquoise][
            move-to one-of turtles with [(breed = starts or breed = arguments) and
              member? self subj-argus and mytheory = ch-best and color != turquoise]
          ][ ; otherwise the researcher jumps to the root of the theory
          move-to ch-best
          ]
        
        set times-jumped times-jumped + 1
        set theory-jump 0
      ]
    ]
  ]
end

; strategies.nls ends here
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
3
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
3
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
50
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
run-many\n
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
setup\ngo\nwhile [any? arguments with \n  [color != red and \n    [myscientists] of mytheory !=  0]][\n  go\n]
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
NetLogo 5.3.1
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
