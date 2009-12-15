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
jal 300
nop ;ID

: 00000300
nop ;EX ;300
nop ;MEM ;304
nop ;WB ;308
call 400 ;30c
nop ;branch delay slot 310
; function returns here 
; this branch should never be taken 
nop ;314
beq 0 17 0010 ;318
nop ;31c
: 00000320 
beq 0 0 000c

: 00000334
; this is the branch address
nop
ori 0 8 1
nop
nop
nop
nop
add 8 8 9
nop
nop
nop
nop
sw 0 9 0000800c
nop
nop
nop
nop
j 500
nop

: 00000400
; nops are required to wb the return address without forwarding/stalling
nop ;EX
nop ;MEM
nop ;WB
ret
nop

; forwarding testing goes here
: 00000500
nop
; test data hazard
ori 0 8 0001
ori 0 9 0002
add 8 9 10
nop ;ID
nop ;EX
nop ;MEM
sw 0 10 8100
nop
nop
nop
nop

: 0000600
halt

; data area starts here

: 00008000
data f0f0f0f0

: 00008008
data ffffffff
