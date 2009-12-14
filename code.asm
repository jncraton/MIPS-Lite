: 00000000
; nops to clear things out
nop
nop
nop
nop
nop
nop
; test memory access followed by nops
lw 0 8 8000
nop ;ID
nop ;EX
nop ;MEM
nop ;WB
; test r-type followed by nops
add 0 8 9
nop ;ID
nop ;EX
nop ;MEM
nop ;WB
; test sw
sw 0 9 8004
nop ;ID
nop ;EX
nop ;MEM
nop ;WB
lw 0 10 8004
lw 0 11 8008
nop ;ID
nop ;EX
nop ;MEM
nop ;WB
; three instructions in a row without data hazards
sub 10 11 12
sll 10 0 13 1
srl 10 0 14 1
nop ;ID
nop ;EX
nop ;MEM
nop ;WB
j 100
; this command should run in the jump delay slot
; it create an address register to use for jr
ori 0 15 0200

: 00000100
; nops for the ori to complete completely
nop ;ID
nop ;EX
nop ;MEM
nop ;WB
jr 15 0 0 0

: 00000200
nop
slt 0 15 16 0
nop ;ID
nop ;EX
nop ;MEM 
nor 0 16 17 0 ;WB
nop ;ID
nop ;EX
nop ;MEM 
nop ;WB
halt
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
beq 0 0 000c

: 00000328
; this is the branch address
nop
ori 0 8 1
add 8 8 9
sw 0 9 0000800c
add 8 9 10
nop
sw 0 10 0000800c
halt

: 00000400
ret

; data area starts here

: 00008000
data f0f0f0f0

: 00008008
data ffffffff
