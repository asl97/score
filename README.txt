Score game for the Minetest engine
===================================

NOTE: THIS IS JUST A RANDOM BENCHMARK FORK OF SCORE, USE THIS INSTEAD: https://github.com/PilzAdam/score

benchmark:
---------

# lua

## no edit
total: 1.941311
setup: 0.097215000000002
noise gen: 0.083457999999997
stone gen: 1.033111
set data: 0.035484
ore gen: 0.658409
lighting: 0.012712000000001
write: 0.020921999999999

## pregen stone list
total: 1.403789
setup: 0.077977999999998
noise gen: 0.057618000000002
stone gen: 0.826007
set data: 0.026978999999997
ore gen: 0.395575
lighting: 0.0077980000000011
write: 0.011834

## move ything outside loop
total: 1.362564
setup: 0.079744000000005
noise gen: 0.056473999999994
stone gen: 0.774935
set data: 0.026923999999994
ore gen: 0.405624
lighting: 0.0076530000000048
write: 0.011210000000005

## move level calc inside the if noise
total: 1.2672
setup: 0.081075999999999
noise gen: 0.058318
stone gen: 0.564066
set data: 0.029131999999999
ore gen: 0.51141
lighting: 0.0081059999999997
write: 0.015091999999999

# luajit

## no edit
total: 0.665125
setup: 0.045493
noise gen: 0.055298000000001
stone gen: 0.023987999999996
set data: 0.033272000000004
ore gen: 0.477891
lighting: 0.012331000000003
write: 0.016852

## after everything
total: 0.616139
setup: 0.043431999999999
noise gen: 0.051199
stone gen: 0.021277999999999
set data: 0.029759000000002
ore gen: 0.449325
lighting: 0.0080600000000004
write: 0.013086000000001

Installation:
-------------
Place it in $path_user/games/ and select it in the main menu.

Gameplay:
---------
- The main goal is to mine Score
- Mine iron to upgrade your pick
- Mine coal to get more light
- Move farther away from the spawn to get to advanced "levels"

License of sourcecode:
----------------------
Score
Copyright (C) 2015 PilzAdam <pilzadam@minetest.net>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

License of textures:
--------------------
Copyright (C) 2013 PilzAdam <pilzadam@minetest.net>
CC BY-SA 3.0: http://creativecommons.org/licenses/by-sa/3.0/

License of sound effects:
-------------------------
Copyright (C) 2013 Mito551
CC BY-SA 3.0: http://creativecommons.org/licenses/by-sa/3.0/

License of background music (score_background.ogg):
---------------------------------------------------
Copyright (C) 2006 natlyea https://libre.fm/artist/natlyea/
CC BY 2.5: http://creativecommons.org/licenses/by/2.5/
