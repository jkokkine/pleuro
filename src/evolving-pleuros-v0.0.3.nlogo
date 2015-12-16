;; BREEDS

breed [hermis hermi]       ;; Food
breed [probos proboscis]   ;; Mouth
breed [pleuros pleuro]     ;; Basic unevolving pleuro
breed [pleuros_e pleuro_e] ;; Evolving form of pleuro

;; OBJECTS BREEDS OWN
probos-own [parent phase]

pleuros-own [
  sns-betaine-left sns-betaine-right 
  sns-pleuro-right sns-pleuro-left
  sns-pleuro_e-right sns-pleuro_e-left
  action speed turn-angle 
  stimpleuro stimpleuro_e 
  nutrition satiation fear incentive aggression
  incentive_coe aggression_coe fear_coe mate_coe
  sense_dist absorbtion_eff burn_rate my-patches]

pleuros_e-own [
  sns-betaine-left sns-betaine-right 
  sns-pleuro-right sns-pleuro-left 
  sns-pleuro_e-right sns-pleuro_e-left
  action speed turn-angle 
  stimpleuro stimpleuro_e
  nutrition satiation fear incentive aggression
  incentive_coe aggression_coe fear_coe mate_coe
  sense_dist absorbtion_eff burn_rate my-patches]

patches-own [betaine-level odor-pleuro odor-pleuro_e my-turtle]

;; GLOBAL VARIABLES
globals [
  spawn_x spawn_y time 
  pleuros_e_kills pleuros_kills 
  
  max_pleuro_count
  max_pleuro_e_count
  experiment_number

  total_pleuros_e_spawns
  total_pleuros_spawns
  
  filename
  
  ] 

to startup
  setup
end

to find_open_experiment_file_name
  
  file-close ;; close any previously open files
  
  set experiment_number 1
  set filename (word "genetic_experiment_" experiment_number ".csv")
  while [file-exists? filename and experiment_number <= batch_size]
  [
    set experiment_number experiment_number + 1
    set filename (word "genetic_experiment_" experiment_number ".csv")
  ]
  
  ;; Put header into file
  file-open filename 
  let header (word "Ticks,Incentive Coefficient,Aggression Coefficient,Fear Coefficient,")
  set header (word header "Sense Distance,Energy Absorbtion Efficiency,Energy Burn Efficiency,")
  set header (word header "Pleuros_e Spawned,Pleuros Spawned, Pleuros_e Kills, Pleuros Kills")
  file-print header
  file-close
end

;; Save genetics of respawned pleuros
to print_peuro_e_genetics
  
  file-open filename ;; Opens file
  
  let x (word ticks ",")
  ifelse (count pleuros_e) > 0 [
    set x (word x (sum [incentive_coe] of pleuros_e / (count pleuros_e)) ",")
    set x (word x (sum [aggression_coe] of pleuros_e / (count pleuros_e)) ",")
    set x (word x (sum [fear_coe] of pleuros_e / (count pleuros_e)) ",")
    set x (word x (sum [sense_dist] of pleuros_e / (count pleuros_e)) ",")
    set x (word x (sum [absorbtion_eff] of pleuros_e / (count pleuros_e)) ",")
    set x (word x (sum [burn_rate] of pleuros_e / (count pleuros_e)) ",")
  ]
  [
    set x (word x 0 ",") ;; incentive_coe
    set x (word x 0 ",") ;; aggression_coe
    set x (word x 0 ",") ;; fear_coe
    set x (word x 0 ",") ;; sense_dist
    set x (word x 0 ",") ;; absorbtion_eff
    set x (word x 0 ",") ;; burn_rate
  ]
  
  set x (word x total_pleuros_e_spawns ",")
  set x (word x total_pleuros_spawns ",")
  set x (word x pleuros_e_kills ",")
  set x (word x pleuros_kills)
  
  file-print x
  file-close
end

to spawn_new_pleuro_e
  hatch 1
  hatch-probos 1 [
    set shape "airplane"
    set size 5
    set parent myself
  ]
end

to setup

  __clear-all-and-reset-ticks
  
  set pleuros_e_kills 0
  set pleuros_kills 0
  
  set max_pleuro_count 3
  set max_pleuro_e_count 25
  
  set total_pleuros_e_spawns 3
  set total_pleuros_spawns 3
  
  find_open_experiment_file_name
  
;; Pleuro_e Species (the evolving one)-----------------------------
  create-pleuros_e total_pleuros_e_spawns [
    
    set shape "pleuro" 
    set color orange - 2 
    set size 10
    set action "wander"
    setxy random-xcor random-ycor 
    set time 0     ;; time for stimulus to zero

    ;; State related variables
    set nutrition 0
    set satiation 0
    set fear 0
    set incentive 0 
    set aggression 0 
        
    ;; Coefficient variables
    set incentive_coe 0.5
    set aggression_coe 0.5
    set fear_coe 0.5
    set mate_coe 0.99
    set sense_dist 0.5
    set absorbtion_eff 0.5
    set burn_rate 0.5

    hatch-probos 1 [
      set shape "airplane"
      set size 5
      set parent myself
    ]
    
    ;; pen-down draws trails following movement
  ]
;; END Pleuro_e Species -------------------------------------------
  
;;--------------- CREATE PLEUROS -----------------
  create-pleuros total_pleuros_spawns [
    
    set shape "pleuro" 
    set color blue - 2 
    set size 10
    set action "wander"
    setxy random-xcor random-ycor
    set time 0      ;; time for stimulus to zero
    
    ;; State related variables
    set nutrition 0
    set satiation 0
    set fear 0
    set incentive 0 
    set aggression 0 
    
    ;; Coefficient variables
    set incentive_coe 0.5
    set aggression_coe 0.75
    set fear_coe 0.5
    set mate_coe 0.99
    set sense_dist 0.5
    set absorbtion_eff 0.5
    set burn_rate 0.5
  
    hatch-probos 1 [
      set shape "airplane"
      set size 5
      set parent myself
    ]
    
    ;; pen-down
  ]
;; -------------- END PLEURO SPAWNS
  
  set spawn_x random-xcor ;; set variable spawn_x with random-xcor starting point
  set spawn_y random-ycor ;; set variable spawn_y with random-ycor starting point
  
  create-hermis 7 [
    set shape "circle"
    set size 1
    set color green + 2
    setxy (spawn_x + random-float 3) (spawn_y + random-float 3) ;; created spawning pool w/ diameter of 3
  ]
  
  ;; initialize odors
  repeat 10 [
    ask hermis [set betaine-level 0.5]
    ;; ask pleuros [set odor-pleuro 0.5]
    ;; diffuse betaine-level 0.5
    ;; diffuse odor-pleuro 0.5
  ]
  
  ask patches [recolor-patches]
 
end

to go

  ;; allow user to drag things around: mouse-down? means mouse button is down
  if mouse-down? [
    ask pleuros [
      if distancexy mouse-xcor mouse-ycor < 3 [setxy mouse-xcor mouse-ycor]
    ]
    ask hermis [
      if distancexy mouse-xcor mouse-ycor < 3 [setxy mouse-xcor mouse-ycor]
    ]
    ask pleuros_e [
      if distancexy mouse-xcor mouse-ycor < 3 [setxy mouse-xcor mouse-ycor]
    ]      
  ]
  
  ;; deposit odors
  ask hermis [set betaine-level 0.99]
  ask pleuros [
    set odor-pleuro 0.8
  ]
  
  ask pleuros_e [
    set odor-pleuro_e 0.8
  ] 
  
  ;; diffuse odors
  diffuse betaine-level 0.5
  diffuse odor-pleuro 0.5
  diffuse odor-pleuro_e 0.5

  ;; evaporate odors
  ask patches [
    set betaine-level 0.99 * betaine-level
    set odor-pleuro 0.9 * odor-pleuro
    set odor-pleuro_e 0.9 * odor-pleuro_e 
    recolor-patches
  ]

;; ----------------------------------------------------------------------------
;; ---- PLEURO_E ---------------------------------------------------------------
;; ----------------------------------------------------------------------------

  ask pleuros_e [
    
    update-sensors
    update-proboscis
    app-state pleuros_e       ;; this function sets movement variables
    
    if nutrition < min_nutrition [
     kill-pleuro
    ]
    
    rt turn-angle
    fd speed
    
    ;; prey consumption
    let targetherm other (turtle-set hermis) in-cone (0.4 * size) 45 ;; if hermis within this vicinity, eat them
    if any? targetherm [
      set nutrition nutrition + (count targetherm) * absorbtion_eff
      set time 0
      ask targetherm [setxy spawn_x spawn_y] ;; RESPAWN HERMIS
    ]
  ]

;; ---------------------------------------------------------------------------
;; ---- PLEURO ---------------------------------------------------------------
;; ---------------------------------------------------------------------------
  
  ask pleuros [
  
    update-sensors
    update-proboscis
    app-state pleuros     ;; this function is the incentive for approach/avoid food
    
    if nutrition < min_nutrition [
     kill-pleuro
    ]
  
    rt turn-angle ;; turns right a number of degrees
    fd speed ;; moves forward a number of degrees
    
    ;; prey consumption
    let targetherm other (turtle-set hermis) in-cone (0.4 * size) 45 ;; if hermis within this vicinity, eat them
    if any? targetherm [
      set nutrition nutrition + 10 * absorbtion_eff
      set time 0
      ask targetherm [setxy spawn_x spawn_y] ;; RESPAWN HERMIS
    ]
  ]
 
  ask pleuros [
    if ticks mod 20 < 1 [
        set nutrition nutrition - burn_rate
    ]
  ]
  
  ask hermis [
    ;; formula to keep the hermis in a particular location
    rt -1 - (random-float 3) + (random-float 2) + sqrt(((spawn_x - xcor) ^ 2) + ((spawn_y - ycor) ^ 2))
    fd 0.1
  ]
  
  ask pleuros_e [
    if ticks mod 20 < 1 [
        set nutrition nutrition - burn_rate
    ]
  ]
  
  set time time + 1
  
  if ticks mod 1000 < 1 [
    print_peuro_e_genetics 
  ]
  
  if ticks > max_ticks [
    setup
  ]
  
  if experiment_number > batch_size [
   stop 
  ]
  
  tick
end

;; END UPDATE PLEURO2 ------------------------------------------


to update-proboscis
  ask probos [
    set heading [heading] of parent
    setxy ([xcor] of parent) ([ycor] of parent)
    ifelse ([sns-betaine-left] of parent > 5.5) or ([sns-betaine-right] of parent > 5.5)
      [set phase (phase + 1) mod 20]
      [set phase 0]
    fd (0.15 * size) + (0.1 * phase)  
  ]
end

to kill-pleuro
  
  ifelse count breed > 3 
    [ ;; more than 3 of breed, kill the pleuro
      ask probos[ die ]
      die
    ]                  
    [ ;; 3 or less of breed, respawn
      set nutrition 0
      setxy random-xcor random-ycor 
    ] 
end

to update-sensors
  
  ;; hermi odors!  
  
  let odor-betaine-left [betaine-level] of patch-left-and-ahead 40 (0.4 * size)
  ifelse odor-betaine-left > 1e-7 
    [set sns-betaine-left 7 + (log odor-betaine-left 10)]
    [set sns-betaine-left 0] 
    
  
  let odor-betaine-right [betaine-level] of patch-right-and-ahead 40 (0.4 * size)
  ifelse odor-betaine-right > 1e-7 
    [set sns-betaine-right 7 + (log odor-betaine-right 10)] 
    [set sns-betaine-right 0]
    
  let odor-pleuro_e-left [odor-pleuro_e] of patch-left-and-ahead 40 (0.4 * size)
  let odor-pleuro_e-right [odor-pleuro_e] of patch-right-and-ahead 40 (0.4 * size)
  let odor-pleuro-left [odor-pleuro] of patch-left-and-ahead 40 (0.4 * size)
  let odor-pleuro-right [odor-pleuro] of patch-right-and-ahead 40 (0.4 * size)
  
  ifelse breed = pleuros_e [
    set odor-pleuro_e-left [odor-pleuro_e] of patch-left-and-ahead 38 (0.6 * size)
    set odor-pleuro_e-right [odor-pleuro_e] of patch-right-and-ahead 38 (0.6 * size)
  ]
  [
    set odor-pleuro-left [odor-pleuro] of patch-left-and-ahead 38 (0.6 * size)
    set odor-pleuro-right [odor-pleuro] of patch-right-and-ahead 38 (0.6 * size)
  ]
  
  ;; pleuros_e odors!
  ifelse odor-pleuro_e-left > 1.5e-3
    [set sns-pleuro_e-left 7 - (log odor-pleuro_e-left 10)] 
    [set sns-pleuro_e-left 0]
 
  ifelse odor-pleuro_e-right > 1.5e-3
    [set sns-pleuro_e-right 7 - (log odor-pleuro_e-right 10)] 
    [set sns-pleuro_e-right 0]
    
  ;; pleuros odors!
  ifelse odor-pleuro-left > 1.5e-3
    [set sns-pleuro-left 7 + (log odor-pleuro-left 10)] 
    [set sns-pleuro-left 0]
  
  ifelse odor-pleuro-right > 1.5e-3
    [set sns-pleuro-right 7 + (log odor-pleuro-right 10)] 
    [set sns-pleuro-right 0]

end  

to recolor-patches
  set pcolor scale-color green betaine-level 0 1
end

to show-sensors
  ask pleuros_e [
    ask patch-left-and-ahead 35 (0.65 * size) [set pcolor yellow]
    ask patch-right-and-ahead 35 (0.65 * size) [set pcolor yellow]
  ]
end

;; Incentive for food/attack
;; No longer removes sense of food. 
;; Instead, it now simply calculates agression and this "OVER RIDES" 
;; the desire for food.
;; @ INPUT: pleuro_species = species of pleuro
to app-state [pleuro_species]
  
  ;; Order of Operations
  ;; ===================================
  ;;  
  
  ;; Rival and Mate Pleuros
  let rival_pleuros pleuros
  let mate_pleuros pleuros_e
  if pleuro_species = pleuros [
    set rival_pleuros pleuros_e
    set mate_pleuros pleuros
  ]
  
  ;; Populate senses
  let sns-betaine ((sns-betaine-left + sns-betaine-right) / 2) * sense_dist
  
  let sns-ally-left 0
  let sns-ally-right 0
  let sns-rival-left 0
  let sns-rival-right 0
  
  ;; Calculate fear of rival (if pleuro first, if pleuro_e second)
  ifelse ( pleuro_species = pleuros )
    [ 
      set sns-ally-left sns-pleuro-left
      set sns-ally-right sns-pleuro-right
      set sns-rival-left sns-pleuro_e-left
      set sns-rival-right sns-pleuro_e-right
    ]
    [ 
      set sns-ally-left sns-pleuro_e-left
      set sns-ally-right sns-pleuro_e-right 
      set sns-rival-left sns-pleuro-left
      set sns-rival-right sns-pleuro-right
    ] 
 
  let sns-rival ((sns-rival-left + sns-rival-right) / 2) * sense_dist
  let sns-ally ((sns-ally-left + sns-ally-right) / 2) * sense_dist
  
  ;; Calculate satiation of pleuro
  set satiation (2 / (1 + e ^ (-(nutrition)))) - 1 ;; a sigmoid function
  
  ;; Calculate fear of rival
  set fear (2 / (1 + e ^ (-(sns-rival)))) - 1 ;; a sigmoid function
  
  ;; Calculate aggression towards rival
  ;; set aggression fear + satiation * sns-rival ;; a sigmoid function
  set aggression (2 / (1 + e ^ (-(sns-rival / (satiation + 1))))) - 1
  
  ;; Calculate insentive to not attack ally: 
  ;;     If the fear is high, satiation is low, 
  ;;     and there is aggression towards rivals,
  ;;     they should work together.
  ;; set incentive (fear - satiation) + aggression
  set incentive (2 / (1 + e ^ (-(sns-ally * fear))))- 1

  ;; If incentive is greater than the incentive coefficient
  ;; the allies pleuros scent drops to zero because they are not
  ;; concerned about their allies movements, as they don't want to attack them.
  ifelse incentive < incentive_coe [ 
    ;; orients to pleuro to attack
    set sns-pleuro-left (aggression * sns-rival-left)
    set sns-pleuro-right (aggression * sns-rival-right)
  ]
  [
    ;; orients to pleuro to attack
    set sns-pleuro-left (aggression * (sns-rival-left + sns-ally-left))
    set sns-pleuro-right (aggression * (sns-rival-right + sns-ally-right))
  ]
  
  ;; default action
  set action "wander"
  set speed 0.1
  let appstate-switch 1
  let sns-left random-float 2
  let sns-right random-float 2
  
  ;; Determines incentive to get food
  let incentive-food (2 / (1 + e ^ (-(sns-betaine)))) - 1   
  ;; incentive to hunt food
  ifelse (incentive-food > satiation and sns-betaine > 0.1) 
  [
    set action "consume"
    set sns-left sns-betaine-left
    set sns-right sns-betaine-right 
    set speed 0.11
  ]
  [
    
    ;; Incentive to group 
    if incentive > incentive_coe and sns-ally > 1
    [
      set action "group"
      set sns-left (sns-betaine-left + sns-ally-left)
      set sns-right (sns-betaine-right + sns-ally-right)
    ]
    
    ;; Find a mate
    if satiation > mate_coe and sns-ally > 1.2
    [
      set action "mate"
      set sns-left sns-ally-left
      set sns-right sns-ally-right
    ]
    
    ;; Avoids rival pleuro if it is too scared
    if fear > fear_coe
    [
      set appstate-switch -1
      set sns-left sns-pleuro-right
      set sns-right sns-pleuro-left
      set action "avoid rival"
      set speed .12
    ]
    
    ;; Attacks rival pleuro if it gets too close
    if aggression > aggression_coe 
    [
      set appstate-switch 1
      set sns-left sns-pleuro-left
      set sns-right sns-pleuro-right
      set action "attack rival"
      set speed .15
    ]
  ]  

  set turn-angle appstate-switch * 3.5 * (sns-right - sns-left)
  
  ;; Mate Pleuros
  let matepleuro other (turtle-set mate_pleuros) in-cone (0.5 * size) 90
  if any? matepleuro and satiation > mate_coe [
    set nutrition 0
    setxy random-xcor random-ycor 
    ask matepleuro [ 
      set nutrition 0
    ]
    
    ifelse ( pleuro_species != pleuros )
    [
      ;; Set mating variables prior to hatching a new pluero_e
      
      ;; set new variables based on evolution rate
      ;; It will changed by a random number between negative mutation_rate and positive mutation_rate
      ;; There is 1/3 chance it will be 0, if it is, there will be no change.
      set incentive_coe abs(incentive_coe + ((random 3) - 1) * mutation_rate)
      if incentive_coe > 0.9999 [ set incentive_coe 0.9999 ]
      
      set aggression_coe abs(aggression_coe + ((random 3) - 1) * mutation_rate)
      if aggression_coe > 0.9999 [ set aggression_coe 0.9999 ]
      
      set fear_coe abs(fear_coe + ((random 3) - 1) * mutation_rate)
      if fear_coe > 0.9999 [ set fear_coe 0.9999 ]
      
      set sense_dist abs(sense_dist + ((random 3) - 1) * mutation_rate)
      if sense_dist > 1.5 [ set sense_dist 1.5 ]
      
      set absorbtion_eff abs(absorbtion_eff  + ((random 3) - 1) * mutation_rate)
      if absorbtion_eff > 0.9999 [ set absorbtion_eff 0.9999 ]
      
      set burn_rate abs(burn_rate + ((random 3) - 1) * mutation_rate)
      if burn_rate > 0.9999 [ set burn_rate 0.9999 ]
      if burn_rate < 0.1 [ set burn_rate 0.1 ]
      
      ;; Update totals
      set total_pleuros_e_spawns total_pleuros_e_spawns + 1
    ]
    [
      set total_pleuros_spawns total_pleuros_spawns + 1
    ]
    
    if breed = pleuros_e and count breed < max_pleuro_e_count [
      hatch 1 [
        hatch-probos 1 [
          set shape "airplane"
          set size 5
          set parent myself
        ]
      setxy random-xcor random-ycor 
      ]
    ]
    
    if breed = pleuros and count breed < max_pleuro_count [
      hatch 1 [
        hatch-probos 1 [
          set shape "airplane"
          set size 5
          set parent myself
        ]
      setxy random-xcor random-ycor 
      ]
    ]
  ]

  ;; IF BITTEN BY OTHER PLEURO
  let targetpleuro other (turtle-set rival_pleuros) in-cone (0.4 * size) 45 
  
  if any? targetpleuro [
    
    ;; If target is not the same species and incentive to cooperate is high enough
    ;; do not eat them.
    ;; TODO: Not right, should be something like above for checking breed
    if targetpleuro != pleuro_species or incentive <= incentive_coe [
      
      ifelse breed = pleuros_e 
      [set pleuros_e_kills (pleuros_e_kills + 1)]
      [set pleuros_kills (pleuros_kills + 1)]
      
      set time 0
      set nutrition nutrition + absorbtion_eff
      ask targetpleuro [
        kill-pleuro
      ]
    ]
  ]
end
    
@#$#@#$#@
GRAPHICS-WINDOW
200
10
1089
584
78
48
5.6
1
10
1
1
1
0
1
1
1
-78
78
-48
48
1
1
1
ticks
30.0

BUTTON
74
10
129
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
137
10
192
43
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

MONITOR
8
540
94
585
NIL
pleuros_kills
17
1
11

MONITOR
107
540
194
585
NIL
pleuros_e_kills
17
1
11

SLIDER
8
143
194
176
mutation_rate
mutation_rate
0.01
0.2
0.02
0.01
1
NIL
HORIZONTAL

MONITOR
8
232
194
277
Avg. Incentive Coefficient
sum [incentive_coe] of pleuros_e / (count pleuros_e)
2
1
11

MONITOR
8
284
194
329
Avg. Aggression Coefficient
sum [aggression_coe] of pleuros_e / (count pleuros_e)
2
1
11

MONITOR
8
338
194
383
Avg. Fear Coefficient
sum [fear_coe] of pleuros_e / (count pleuros_e)
2
1
11

MONITOR
8
389
194
434
Avg. Sensing Distance
sum [sense_dist] of pleuros_e / (count pleuros_e)
2
1
11

MONITOR
8
440
194
485
Avg. Absorbtion Efficency
sum [absorbtion_eff] of pleuros_e / (count pleuros_e)
2
1
11

MONITOR
8
491
195
536
Avg. Burn Rate
sum [burn_rate] of pleuros_e / (count pleuros_e)
2
1
11

SLIDER
7
183
194
216
min_nutrition
min_nutrition
-50
0
-13
1
1
NIL
HORIZONTAL

BUTTON
8
10
63
43
Folder
set-current-directory user-directory
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
7
62
193
95
batch_size
batch_size
0
100
15
1
1
NIL
HORIZONTAL

SLIDER
8
102
193
135
max_ticks
max_ticks
5000
250000
250000
1000
1
NIL
HORIZONTAL

BUTTON
208
599
328
632
NIL
show-sensors
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
## WHAT IS IT?

This section could give a general understanding of what the model is trying to show or explain.

## HOW IT WORKS

This section could explain what rules the agents use to create the overall behavior of the model.

## HOW TO USE IT

This section could explain how to use the model, including a description of each of the items in the interface tab.

## THINGS TO NOTICE

This section could give some ideas of things for the user to notice while running the model.

## THINGS TO TRY

This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.

## EXTENDING THE MODEL

This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## RELATED MODELS

This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.

## CREDITS AND REFERENCES

This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
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

pleuro
true
0
Polygon -7500403 true true 135 285 165 285 210 240 240 165 225 105 210 90 195 75 105 75 90 90 75 105 60 165 90 240
Polygon -7500403 true true 150 60 240 60 210 105 90 105 60 60
Polygon -7500403 true true 195 120 255 90 195 90
Polygon -7500403 true true 105 120 45 90 105 90

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
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
0
@#$#@#$#@
