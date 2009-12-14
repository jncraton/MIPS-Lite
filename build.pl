opendir DIRH, "." or die "couldn't open: $!"; 
foreach (sort readdir DIRH) { 
    $filename = $_;
    if (rindex($filename, ".vhdl") > -1 and rindex($filename, ".vhdl~") == -1) {
        print "ghdl -a $filename\n";
        `ghdl -a $filename`;
        $filename=~ s/\..*//; 
        print "ghdl -m $filename\n";
        `ghdl -m $filename`;
    }
}
closedir DIRH;