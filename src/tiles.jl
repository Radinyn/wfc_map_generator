module Setup

#=

Possible tiles

=# 

const OCEAN = 1         #OCE
const DEEP_OCEAN = 2    #DOC
const GRASS = 3         #GRS
const FOREST = 4        #FRS
const THICK_FOREST = 5  #TFR
const DESERT = 6        #DSR
const HOT_DESERT = 7    #HDS
const SNOW = 8          #SNW
const SNOWY_FOREST = 9  #SFR
const MOUNTAINS = 10    #MNT
const BEACH =11         #BCH

#=

Neighbouring tiles along with their respective probabilities

=#

PROBABILITIES = [
            # OCE # DOC # GRS # FRS # TFR # DSR # HDS # SNW # SFR # MNT # BCH #
#= OCE =#   [  0.4,  0.3,    0,    0,    0,    0,    0,    0,    0,    0,  0.3],
#= DOC =#   [  0.2,  0.8,    0,    0,    0,    0,    0,    0,    0,    0,    0],
#= GRS =#   [    0,    0,  0.5,  0.3,    0, 0.05,    0, 0.05,    0, 0.05, 0.05],
#= FRS =#   [    0,    0, 0.15, 0.55,  0.2,    0,    0,    0, 0.05, 0.05,    0],
#= TFR =#   [    0,    0,    0,  0.3, 0.55,    0,    0,    0, 0.05,  0.1,    0],
#= DSR =#   [    0,    0,  0.2,    0,    0,  0.6,  0.2,    0,    0,    0,    0],
#= HDS =#   [    0,    0,    0,    0,    0,  0.5,  0.5,    0,    0,    0,    0],
#= SNW =#   [    0,    0,  0.2,    0,    0,    0,    0, 0.55,  0.2, 0.05,    0],
#= SFR =#   [    0,    0,    0, 0.05, 0.05,    0,    0, 0.25, 0.60, 0.05,    0],
#= MNT =#   [    0,    0, 0.07, 0.13, 0.15,    0,    0, 0.07, 0.13, 0.45,    0],
#= BCH =#   [  0.5,    0,  0.2,    0,    0,    0,    0,    0,    0,    0,  0.3],
]

COLOR_MAP = [
    #= OCE =#   (0/255,   105/255, 148/255),
    #= DOC =#   (0/255,   60/255,  95/255 ),
    #= GRS =#   (126/255, 200/255, 80/255 ),
    #= FRS =#   (11/255,  102/255, 35/255 ),
    #= TFR =#   (0/255,   51/255,  20/255 ),
    #= DSR =#   (237/255, 201/255, 175/255),
    #= HDS =#   (194/255, 168/255, 99/255 ),
    #= SNW =#   (255/255, 250/255, 250/255),
    #= SFR =#   (203/255, 203/255, 203/255),
    #= MNT =#   (122/255, 115/255, 114/255),
    #= BCH =#   (248/255, 240/255, 164/255),
]

normalise(v) = v/sum(v)

BIOMS =  [ # OCE # DOC # GRS # FRS # TFR # DSR # HDS # SNW # SFR # MNT # BCH #
normalise( [  4  ,  2  ,  0  ,  0  ,  0  ,  0  ,  0  ,  0  ,  0  ,  0  ,  1  ] ),
normalise( [  2  ,  1  ,  1  ,  0  ,  0  ,  0  ,  0  ,  0  ,  0  ,  0  ,  2  ] ),
normalise( [  1  ,  0  ,  2  ,  1  ,  1  ,  0  ,  0  ,  0  ,  0  ,  0  ,  1  ] ),
normalise( [  0  ,  0  ,  1  ,  1  ,  1  ,  0  ,  0  ,  0  ,  0  ,  1  ,  0  ] ),
normalise( [  0  ,  0  ,  1  ,  2  ,  2  ,  0  ,  0  ,  0  ,  0  ,  3  ,  0  ] ),
]

end