//lcd setup
34 io
32 io

34 io
32 io
130 io
128 io

2 io
0 io
98 io
96 io

2 io
0 io
242 io
240 io

//SUBROUTINE print a base-10 number

branch :sub_dprint_skip 1
.sub_dprint
::sub_dprint_val rh
rh,:sub_dprint_val a
255 rh
a rh,0
//hundreds place
0 flags

1 rl
100 rh,rl
2 rl
0 rh,rl

rh,0 a
rh,1 b
branch :sub_dprint_3_end a<b
.sub_dprint_3_loop
0 flags
rh,1 a
100 b
add rh,1
branch :sub_dprint_3_o flags
branch :sub_dprint_3_oe 1
.sub_dprint_3_o
1 rl
255 rh,rl
.sub_dprint_3_oe
rh,2 a
1 b
0 flags
add rh,2

rh,0 a
rh,1 b
branch :sub_dprint_3_end a<b
branch :sub_dprint_3_loop 1

.sub_dprint_3_end
0b00110011 io
0b00110001 io
rh,2 a
0 flags
a b
add a
a b
add a
a b
add a
a b
add a
0 flags
3 b
add io
1 b
add io

//subtract (rh,2) * 100
0 flags
rh,2 a
// * 10
a b
add a
a b
add a
a b
add a
rh,2 b
add a
rh,2 b
add a
// * 10
a rh,255
a b
add a
a b
add a
a b
add a
rh,255 b
add a
rh,255 b
add a
//two's comp
255 b
xor a
1 b
0 flags
add b
0 flags
rh,0 a
add rh,0

//tens place
0 flags

1 rl
10 rh,rl
2 rl
0 rh,rl

rh,0 a
rh,1 b
branch :sub_dprint_2_end a<b
.sub_dprint_2_loop
0 flags
rh,1 a
10 b
add rh,1
rh,2 a
1 b
0 flags
add rh,2

rh,0 a
rh,1 b
branch :sub_dprint_2_end a<b
branch :sub_dprint_2_loop 1

.sub_dprint_2_end
0b00110011 io
0b00110001 io
rh,2 a
0 flags
a b
add a
a b
add a
a b
add a
a b
add a
0 flags
3 b
add io
1 b
add io

//subtract (rh,2) * 100
0 flags
rh,2 a
// * 10
a b
add a
a b
add a
a b
add a
rh,2 b
add a
rh,2 b
add a
//two's comp
255 b
xor a
1 b
add b
0 flags
rh,0 a
add rh,0

//ones place
0 flags

1 rl
1 rh,rl
2 rl
0 rh,rl

rh,0 a
rh,1 b
branch :sub_dprint_1_end a<b
.sub_dprint_1_loop
0 flags
rh,1 a
1 b
add rh,1
rh,2 a
1 b
0 flags
add rh,2

rh,0 a
rh,1 b
branch :sub_dprint_1_end a<b
branch :sub_dprint_1_loop 1

.sub_dprint_1_end
0b00110011 io
0b00110001 io
rh,2 a
0 flags
a b
add a
a b
add a
a b
add a
a b
add a
0 flags
3 b
add io
1 b
add io

//ret
::sret_high rh
rh,:sret_high iph
::sret_low rh
rh,:sret_low ipl
1 branch

//vars
.sub_dprint_val
dw 0
.sub_dprint_skip

.entry

//init vars
::_min rh
:_min rl
0 rh,rl
::_max rh
:_max rl
200 rh,rl

//clear screen
2 io
0 io
18 io
16 io

wait 16

lcd 'G'
lcd 'u'
lcd 'e'
lcd 's'
lcd 's'
lcd ' '
lcd 't'
lcd 'h'
lcd 'e'
lcd ' '
lcd 'n'
lcd 'u'
lcd 'm'
lcd 'b'
lcd 'e'
lcd 'r'

wait 255
wait 255
wait 255
wait 255

//go to second line
//195 io
//193 io
//3 io
//1 io

//clear screen
2 io
0 io
18 io
16 io

wait 16

lcd 'P'
lcd 'i'
lcd 'c'
lcd 'k'
lcd ' '
lcd 'a'
lcd ' '
lcd '#'
lcd ' '

//min val
::_min rh
rh,:_min a
::sub_dprint_val rh
:sub_dprint_val rl
a rh,rl

::sret_high rh
:sret_high rl
::ret1 rh,rl
::sret_low rh
:sret_low rl
:ret1 rh,rl

branch :sub_dprint 1
.ret1

lcd '-'

//max val
::_max rh
rh,:_max a
::sub_dprint_val rh
:sub_dprint_val rl
a rh,rl

::sret_high rh
:sret_high rl
::ret2 rh,rl
::sret_low rh
:sret_low rl
:ret2 rh,rl

branch :sub_dprint 1
.ret2

//wait for button press and release
.loopButtonWait1
0b111 b
io a
and a
0 b
branch :loopButtonWait1_end a>b
branch :loopButtonWait1 1
.loopButtonWait1_end
.loopButtonWait1b
0b111 b
io a
and a
0 b
branch :loopButtonWait1b_end a=b
branch :loopButtonWait1b 1
.loopButtonWait1b_end

//---GUESSING---

.guessLoop
//clear screen
2 io
0 io
18 io
16 io

wait 16

//guess is ((max - min) / 2) + min
::_min rh
rh,:_min b
255 a
xor b
1 a
0 flags
add b
::_max rh
rh,:_max a
0 flags
add b
//if (max - min) == 2, we know the number
2 a
branch :correct_pre a=b
//
bsr a
//add min
::_min rh
rh,:_min b
0 flags
add a

lcd 'G'
lcd 'u'
lcd 'e'
lcd 's'
lcd 's'
lcd 'i'
lcd 'n'
lcd 'g'
lcd ' '

//store guess
254 rh
a rh,0

//print guess (it's in a)
::sub_dprint_val rh
:sub_dprint_val rl
a rh,rl

::sret_high rh
:sret_high rl
::ret3 rh,rl
::sret_low rh
:sret_low rl
:ret3 rh,rl

branch :sub_dprint 1
.ret3

lcd '?'

//wait for input
.loopButtonWait2
io a
0b111 b
and a
0 b
branch :loopButtonWait2_end a>b
branch :loopButtonWait2 1
.loopButtonWait2_end

0b100 b
branch :button2_o_lt a=b
0b010 b
branch :button2_o_eq a=b
0b001 b
branch :button2_o_gt a=b
branch :loopButtonWait2 1

//button lt
.button2_o_lt
//actual number is LESS than the guess
//set max to the guess
254 rh
rh,0 a
::_max rh
a rh,:_max
branch :button2_end 1

//button eq
.button2_o_eq
//gotsit
branch :correct 1
//branch :button2_end 1

//button gt
.button2_o_gt
//actual number is GREATER than the guess
//set min to the guess
254 rh
rh,0 a
::_min rh
a rh,:_min
branch :button2_end 1

.button2_end

//wait for all buttons to be released
.loopButtonWait3
io a
0b111 b
and a
0 b
branch :loopButtonWait3_end a=b
branch :loopButtonWait3 1
.loopButtonWait3_end

branch :guessLoop 1

.correct_pre
//finish code from above
bsr a
//add min
::_min rh
rh,:_min b
0 flags
add a
254 rh
a rh,0

.correct
//wait for all buttons to be released
.loopButtonWait3b
io a
0b111 b
and a
0 b
branch :loopButtonWait3b_end a=b
branch :loopButtonWait3b 1
.loopButtonWait3b_end

//guess is correct
//clear screen
2 io
0 io
18 io
16 io

wait 16

lcd 'Y'
lcd 'o'
lcd 'u'
lcd 'r'
lcd ' '
lcd '#'
lcd ' '
lcd 'i'
lcd 's'
lcd ' '

//print guess
254 rh
rh,0 a
::sub_dprint_val rh
:sub_dprint_val rl
a rh,rl

::sret_high rh
:sret_high rl
::ret4 rh,rl
::sret_low rh
:sret_low rl
:ret4 rh,rl

branch :sub_dprint 1
.ret4

//wait for button press and release
.loopButtonWait4
0b111 b
io a
and a
0 b
branch :loopButtonWait4_end a>b
branch :loopButtonWait4 1
.loopButtonWait4_end
.loopButtonWait4b
0b111 b
io a
and a
0 b
branch :loopButtonWait4b_end a=b
branch :loopButtonWait4b 1
.loopButtonWait4b_end

//restart
branch :entry 1

.loopEnd
branch :loopEnd 1

//vars
._min
dw 0
._max
dw 200

.sret_high
dw 0
.sret_low
dw 0
