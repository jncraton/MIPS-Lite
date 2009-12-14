: 00000000
nop
lw 0 8 8000
add 0 8 9
sw 0 9 8004
lw 0 10 8004
lw 0 11 8008
sub 10 11 12
sll 12 0 13 1
srl 13 0 14 1
j 100

: 00000100
nop
ori 0 15 0200
jr 15 0 0 0

: 00000200
nop
slt 0 15 16 0
nor 0 16 17 0 
jal 300

: 00000300
nop
call 400
nop
: 0000030c
nop
: 00000310
; this branch should never be taken
beq 0 17 0010
nop
: 00000318
beq 0 0 0010

: 00000328
; this is the branch address
nop
ori 0 8 1
add 8 8 9
sw 0 9 0000800c
halt

: 00000400
ret

; data area starts here

: 00008000
data f0f0f0f0

: 00008008
data ffffffff
