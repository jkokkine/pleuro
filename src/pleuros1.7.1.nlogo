breed [pleuros pleuro]  
breed [pleuros2 pleuro] ;; this creates one animal of the breed pleuros with the name pleuro
breed [probos proboscis]
breed [hermis hermi]
probos-own [parent phase]
pleuros-own [sns-betaine-left sns-betaine-right action speed turn-angle stimpleuro2 nutrition 
              sns-pleuro-right sns-pleuro-left satiation fear] ;; TODO added satiation

pleuros2-own [sns-betaine-left sns-betaine-right action speed turn-angle stimpleuro nutrition
             sns-pleuro-right sns-pleuro-left satiation fear]

patches-own [betaine-level odor-pleuro odor-pleuro2] ;;TODO added pleuro2 odor
globals [spawn_x spawn_y time incentive] ;; incentive added & the stimulus global variable

to startup
  setup
end

to setup

  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  
  create-pleuros 2 [
    set shape "pleuro" 
    set color orange - 2 
    set size 10
    set action "wander"
    setxy random-xcor random-ycor
    ;;set stimherm 0 ;; setting herm stimulus to zero
    set nutrition 0  ;; changed energy to "nutrition" 
    set satiation  0
    set time 0      ;; time for stimulus to zero
    set incentive 0 ;; set app-state 
    set fear 0
  

    hatch-probos 1 [
      set shape "airplane"
      set size 5
      set parent myself
    ]
    
    pen-down
  ]
  
;; Pleuro Species 2 -------------------------------------------------
  create-pleuros2 2 [
    set shape "pleuro" 
    set color blue - 2 
    set size 10
    set action "wander"
    setxy random-xcor random-ycor
    set nutrition 0  
    set time 0     ;; time for stimulus to zero
    set satiation 0 
    set incentive 0
    set fear 0

    hatch-probos 1 [
      set shape "airplane"
      set size 5
      set parent myself
    ]
    
    pen-down
  ]
;; END Pleuro Species 2 -------------------------------------------
  
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
    ask pleuros [set odor-pleuro 0.5]
    diffuse betaine-level 0.5
    diffuse odor-pleuro 0.5
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
    ask pleuros2 [
      if distancexy mouse-xcor mouse-ycor < 3 [setxy mouse-xcor mouse-ycor]
    ]      
  ]
  
  ;; deposit odors
  ask hermis [set betaine-level 0.99]
  ask pleuros [set odor-pleuro 0.5]
  ask pleuros2 [set odor-pleuro2 0.8] ;; TODO pleuro2 are stinkier
  
  ;; diffuse odors
  diffuse betaine-level 0.5
  diffuse odor-pleuro 0.5
  diffuse odor-pleuro2 0.5
  
  ;; evaporate odors
  ask patches [
    set betaine-level 0.99 * betaine-level
    set odor-pleuro 0.5 * odor-pleuro
    set odor-pleuro2 0.9 * odor-pleuro2 ;; TODO pleuro2 are stinkier
    recolor-patches
  ]

;; ---------------------------------------------------------------------------
;; ---- PLEURO ---------------------------------------------------------------
;; ---------------------------------------------------------------------------
  
  ask pleuros [
  
    update-sensors
    update-proboscis
    
    set satiation 2 / (1 + e ^ (-(0.5 * nutrition))) ;; satiation is a sigmoid function
    
    ; default action
    set action "wander"
    set speed 0.05
    set turn-angle -1 + random-float 2
    
    ;;colorcode orange        ;; this function colors: red, pink, orange accordingly
    app-state pleuros2      ;; this function is the incentive for approach/avoid food
  
    rt turn-angle ;; turns right a number of degrees
    fd speed ;; moves forward a number of degrees
    ;; prey consumption
    let targetherm other (turtle-set hermis) in-cone (0.4 * size) 45 ;; if there are any hermis within this vicinity of the pleuro, eat them
    if any? targetherm [
      set nutrition nutrition + count targetherm
      set time 0
      ask targetherm [setxy spawn_x spawn_y]
    ]
  ]
  
  ask hermis [
    ;; formula to keep the hermis in a particular location
    rt -1 - (random-float 3) + (random-float 2) + sqrt(((spawn_x - xcor) ^ 2) + ((spawn_y - ycor) ^ 2))
    fd 0.1
  ]
  ask pleuros [
    if ticks mod 20 < 1 [
        set nutrition nutrition - .5 
    ]
  ]
  set time time + 1

;; ----------------------------------------------------------------------------
;; ---- PLEURO2 ---------------------------------------------------------------
;; ----------------------------------------------------------------------------

ask pleuros2 [
  
    update-sensors2
    update-proboscis
    
    ; default action
    set action "wander"
    set speed 0.05
    set turn-angle -1 + random-float 2
    
    ;;colorcode blue          ;; this function colors: blue, purple, etc. accordingly
    app-state pleuros       ;; this function is the incentive for approach/avoid food
    
    rt turn-angle
    fd speed
    
    ;; prey consumption
    let targetherm other (turtle-set hermis) in-cone (0.4 * size) 45
    set satiation 2 / (1 + e ^ (-(0.5 * nutrition)))  ;; todo fix so not negative
    if any? targetherm [
      set nutrition nutrition + count targetherm
      set time 0
      ask targetherm [setxy spawn_x spawn_y]
    ]
  ]
  
  ask hermis [
    ;; formula to keep the hermis in a particular location
    rt -1 - (random-float 3) + (random-float 2) + sqrt(((spawn_x - xcor) ^ 2) + ((spawn_y - ycor) ^ 2))
    fd 0.1
  ]
  ask pleuros2 [
    if ticks mod 20 < 1 [
        set nutrition nutrition - .5 
    ]
  ]
  set time time + 1
  
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

to update-sensors2

  ;; hermi odors!  
  
  let odor-betaine-left [betaine-level] of patch-left-and-ahead 40 (0.4 * size)
  ifelse odor-betaine-left > 1e-7 
    [set sns-betaine-left 7 + (log odor-betaine-left 10)] 
    [set sns-betaine-left 0]
  
  let odor-betaine-right [betaine-level] of patch-right-and-ahead 40 (0.4 * size)
  ifelse odor-betaine-right > 1e-7 
    [set sns-betaine-right 7 + (log odor-betaine-right 10)] 
    [set sns-betaine-right 0]
  
  ;; pleuros odors!
  
  let odor-pleuro-left [odor-pleuro] of patch-left-and-ahead 40 (0.4 * size)
  ifelse odor-pleuro-left > 1e-7
    [set sns-pleuro-left 7 + (log odor-pleuro-left 10)] 
    [set sns-pleuro-left 0]
  
  let odor-pleuro-right [odor-pleuro] of patch-right-and-ahead 40 (0.4 * size)
  ifelse odor-pleuro-right > 1e-7
    [set sns-pleuro-right 7 + (log odor-pleuro-right 10)] 
    [set sns-pleuro-right 0]
    
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
    
    
  ;; pleuros2 odors!
    
  let odor-pleuro-left [odor-pleuro2] of patch-left-and-ahead 40 (0.4 * size)
  ifelse odor-pleuro-left > 1e-7
    [set sns-pleuro-left 7 + (log odor-pleuro-left 10)] 
    [set sns-pleuro-left 0]
    
  let odor-pleuro-right [odor-pleuro2] of patch-right-and-ahead 40 (0.4 * size)
  ifelse odor-pleuro-right > 1e-7 
    [set sns-pleuro-right 7 + (log odor-pleuro-right 10)] 
    [set sns-pleuro-right 0]
    
end  


;; could add color for pleuros

to recolor-patches
   set pcolor scale-color green betaine-level 0 1
end


to show-sensors
  ask pleuros [
    ask patch-left-and-ahead 40 (0.4 * size) [set pcolor yellow]
    ask patch-right-and-ahead 40 (0.4 * size) [set pcolor yellow]
  ]
end

;; color update function
to colorcode[base]
    
    set color (base + (10 * satiation))
    
end

;; Incentive for food/attack
;; No longer removes sense of food. 
;; Instead, it now simply calculates agression and this "OVER RIDES" 
;; the desire for food.
;; @ INPUT: pleurosnum = species of pleuro
to app-state [pleurosnum]
  
     ;; hermisenda approach
      let sns-betaine ((sns-betaine-left + sns-betaine-right)) 
      set incentive 1 / (1 + e ^ (- (0.5 * (sns-betaine - 5))))
      let incentive-pleuro ((sns-pleuro-left + sns-pleuro-right) / 2) * satiation ;; satiation = 2 / (1 + e ^ (-(0.5 * nutrition)))
      
      ;; Added version 1.6.4, this (1 + incentive-pleuro) keeps appstate-switch between 0 and 2 vs -1 and 1
      ;; There may be an improved equation for this, however, for now this is working.
      let appstate-switch ((sns-betaine / incentive)  + incentive-pleuro)     
      
      ;; removed if statement for attack, attempting to make it all function based
      ;; no longer shows action
      ;; KNOWN ISSUE:
      ;; The turn angle requires that sns-pleuro is included, but since there are no if statements it can/will always turn towards pleuro.
      ;; POSSIBLE FIX: add a multiplier somewhere for sns-pleuro based off incentive. 
      
      ;; avoids other pleuro if hungry
      if (satiation < 1.5) and ((sns-pleuro-left + sns-pleuro-right) > 2)[
           set appstate-switch -1
           set action "avoid"
      ]
        
      
      ;; orients to pleuro to attack
      set sns-pleuro-left (incentive-pleuro * sns-pleuro-left)
      set sns-pleuro-right (incentive-pleuro * sns-pleuro-right)
      set turn-angle appstate-switch * ((1 / (1 + exp (3 * ((sns-pleuro-left + sns-betaine-left) - (sns-pleuro-right + sns-betaine-right))))) - 0.5)
      
      if ( fear > 0 ) [ 
        ;; Turn based on fear/bites
        set turn-angle -1 * ((1 / (1 + exp (3 * (sns-pleuro-left - sns-pleuro-right)))) - 0.5) 
        ;; Turn based on hunger in relation to fear/bites 
        set turn-angle turn-angle + (((1 - nutrition) / 20) * ((1 / (1 + exp (3 * (sns-pleuro-left - sns-pleuro-right)))) - 0.5)) 
      ]
      
      set speed .11
      
      ;; IF BITTEN BY OTHER PLEURO
      let targetpleuro other (turtle-set pleurosnum) in-cone (0.4 * size) 45
      if any? targetpleuro [
         set time 0
         ask targetpleuro[set nutrition 0]
         set fear 1
          ;;ask targetpleuro [setxy random-xcor random-ycor]
       ]
      
      let appetitive-state (incentive - incentive-pleuro)
      if (appetitive-state > .3) [
        set action "approach"
         set turn-angle 5 * ((1 / (1 + exp (3 * (sns-betaine-left - sns-betaine-right)))) - 0.5)
         set speed 0.1
      ]
end


    
@#$#@#$#@
GRAPHICS-WINDOW
201
17
996
533
78
48
5.0
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
129
26
192
59
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
131
69
194
102
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
3
271
94
316
action - pleuro 0
[action] of turtle 0
17
1
11

BUTTON
130
108
193
141
step
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
48
461
156
494
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

MONITOR
39
327
178
372
nutrition of pleuro 0
[nutrition] of turtle 0
1
1
11

MONITOR
98
272
199
317
action - pleuro 1
[action] of turtle 1
17
1
11

MONITOR
11
25
92
70
sns-pleuro 1
[sns-pleuro-right] of turtle 0
2
1
11

MONITOR
14
84
123
129
satiation pleuro 0
[satiation] of turtle 0
17
1
11

MONITOR
27
213
167
258
incentive of pleuro 0
[incentive] of turtle 0
17
1
11

MONITOR
14
143
122
188
satiation pleuro 1
[satiation] of turtle 1
17
1
11

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
