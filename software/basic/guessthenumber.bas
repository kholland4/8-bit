1 let m=1
2 let n=1000
3 print "Pick a # ",m,"-",n
4 input x

5 let g=(n-m)/2+m
6 print "Guessing ",g,"?"
7 print "less=1 yes=2 more=3"
8 input c
9 if c=1 then let n=g
10 if c=2 then goto 15
11 if c=3 then let m=g
12 if (n-m)=2 then goto 14
13 goto 5
14 let g=(n-m)/2+m

15 print "Your # is ",g
16 end
