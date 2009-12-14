open (MEMORY, '>memory.dat');

# load the assembler
open (ASM, 'code.asm');

$memory_address = -4;

while (<ASM>) {
    chomp;
    my @args = split(' ', $_);
    $op = @args[0];
    $rs = @args[1];
    $addr = @args[1];
    $data = @args[1];
    $rt = @args[2];
    $address = @args[2];
    $rd = @args[3];
    $immediate = @args[3];
    $shamt = @args[4];
    
    $bin = 0;
    $print = 0;
    
    if($op eq ":") {
        $memory_address = hex($addr) - 4;
    }
    
    # I-types
    
    if($op eq "lw") {
        $bin += 0x23 << 26;
        $bin += $rs << 21;
        $bin += $rt << 16;
        $bin += hex($immediate);
        $print=1;
        $memory_address += 4;
    }
    
    if($op eq "sw") {
        $bin += 0x2b << 26;
        $bin += $rs << 21;
        $bin += $rt << 16;
        $bin += hex($immediate);
        $print=1;
        $memory_address += 4;
    }
    
    if($op eq "ori") {
        $bin += 0x0d << 26;
        $bin += $rs << 21;
        $bin += $rt << 16;
        $bin += hex($immediate);
        $print=1;
        $memory_address += 4;
    }

    if($op eq "beq") {
        $bin += 0x04 << 26;
        $bin += $rs << 21;
        $bin += $rt << 16;
        $bin += hex($immediate);
        $print=1;
        $memory_address += 4;
    }

    # R-types
    
    if($op eq "add") {
        $bin += 0x00 << 26;
        $bin += $rs << 21;
        $bin += $rt << 16;
        $bin += $rd << 11;
        $bin += 0x20;
        $print=1;
        $memory_address += 4;
    }
    
    if($op eq "sub") {
        $bin += 0x00 << 26;
        $bin += $rs << 21;
        $bin += $rt << 16;
        $bin += $rd << 11;
        $bin += 0x22;
        $print=1;
        $memory_address += 4;
    }
    
    if($op eq "nor") {
        $bin += 0x00 << 26;
        $bin += $rs << 21;
        $bin += $rt << 16;
        $bin += $rd << 11;
        $bin += 0x27;
        $print=1;
        $memory_address += 4;
    }

    if($op eq "sll") {
        $bin += 0x00 << 26;
        $bin += $rs << 21;
        $bin += $rt << 16;
        $bin += $rd << 11;
        $bin += $shamt << 6;
        $bin += 0x00;
        $print=1;
        $memory_address += 4;
    }
    
    if($op eq "srl") {
        $bin += 0x00 << 26;
        $bin += $rs << 21;
        $bin += $rt << 16;
        $bin += $rd << 11;
        $bin += $shamt << 6;
        $bin += 0x02;
        $print=1;
        $memory_address += 4;
    }
    
    if($op eq "slt") {
        $bin += 0x00 << 26;
        $bin += $rs << 21;
        $bin += $rt << 16;
        $bin += $rd << 11;
        $bin += $shamt << 6;
        $bin += 0x2a;
        $print=1;
        $memory_address += 4;
    }

    if($op eq "jr") {
        $bin += 0x00 << 26;
        $bin += $rs << 21;
        $bin += $rt << 16;
        $bin += $rd << 11;
        $bin += $shamt << 6;
        $bin += 0x08;
        $print=1;
        $memory_address += 4;
    }

    # J-types
    if($op eq "j") {
        $bin += 0x02 << 26;
        $bin += hex($addr) >> 2;
        $print=1;
        $memory_address += 4;
    }
    
    if($op eq "jal") {
        $bin += 0x03 << 26;
        $bin += hex($addr) >> 2;
        $print=1;
        $memory_address += 4;
    }

    # Special Stuff
    
    if($op eq "data") {
        $bin = hex($data);
        $print=1;
        $memory_address += 4;
    }
    
    if($op eq "halt") {
        $bin = 0xffffffff;
        $print=1;
        $memory_address += 4;
    }

    # Psuedo Instructions
    if($op eq "nop") {
        $bin = 0x00;
        $print=1;
        $memory_address += 4;
    }
    
    if($op eq "call") {
        $bin += 0x03 << 26;
        $bin += hex($addr) >> 2;
        $print=1;
        $memory_address += 4;
    }

    if($op eq "ret") {
        $bin += 0x00 << 26;
        $bin += 31 << 21;
        $bin += 0 << 16;
        $bin += 0 << 11;
        $bin += 0 << 6;
        $bin += 0x08;
        $print=1;
        $memory_address += 4;
    }

    # Write the word to memory
    
    if ($print == 1) {
        printf(MEMORY "%08x %08x\n",$memory_address, $bin);
    }

}
close (ASM);
close (MEMORY);