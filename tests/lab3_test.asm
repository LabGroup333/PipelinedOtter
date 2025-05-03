addi x7, x0, 7         # x7 = 7
li   x5, 0x6000          # x5 = 40 (make sure 0x28 is a valid data memory address)
nop
nop

add  x8, x5, x0        # x8 = x5 (== 40)
addi x10, x0, 10       # x10 = 10
nop
nop

or   x11, x7, x10      # x11 = 7 | 10 = 15
nop
nop

sw   x11, 0(x8)        # mem[40] = 15
