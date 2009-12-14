#!/usr/bin/perl

#------------------------------------------------------------------------------ 
# VHDL Test Bench Generation
#        by Jeremy Webb
#        
#        Rev 1.5, April 1, 2007
#
#        This utility is intended to make creating new VHDL modules easier using
#        a good editor, such as VI.
#        
#        As long as you set the top line to correctly point to your perl binary,
#        and place this script in a directory in your path, you can invoke it from VI.
#        Simply use the !! command and call this script with the filename you wish
#        to instantiate.  This script will create a new text file called 
#        "new_module_name_tb.vhd" when you type the following command:
#        
#                !! vhdl_tb.pl new_module_name.vhd
#                
#        The script will generate the VHDL test bench template for you with the port
#        contents of "new_module_name.vhd". Note:  "new_module_name.vhd" is the name 
#        of the existing VHDL file, and "new_module_name_tb.vhd" is the new test bench 
#        file.
#
#        The script will retrieve the module definition from the "new_module_name.vhd"
#        file you specify and provide the instantiation for you in the new 
#        "new_module_name_tb.vhd" file.
#
#        The keyword "entity" must be left justified in the vhdl file you are 
#        instantiating to work.
#
#        Revision History:
#                1.0        11/14/2004        Initial release
#                1.1     11/22/2004      Added usage display
#               1.2     12/2/2004       Changed the username grab to use getlogin();
#               1.3     06/01/2005      Changed Confidential in header.
#               1.4     06/30/2006      Changed copyright date to update automatically
#               1.5     04/01/2007      Changed company header.
#               
#        Please report bugs, errors, etc.
#------------------------------------------------------------------------------

#        Retrieve command line argument
#
use strict;
my $file = $ARGV[0];

# check to see if the user entered a file name.
die "syntax: [perl] vhdl_tb.pl existing_file.vhdl\n" if ($file eq "");

# Read in the target file into an array of lines
open(inF, $file) or dienice ("file open failed");
my @data = <inF>;
close(inF);

# Make Date int MM/DD/YYYY
my $year      = 0;
my $month     = 0;
my $day       = 0;
($day, $month, $year) = (localtime)[3,4,5];


# Grab username from PC:
my $author= "$^O user";
if ($^O =~ /mswin/i)
{ 
  $author= $ENV{USERNAME} if defined $ENV{USERNAME};
}
else
{ 
  $author = getlogin();
}


#        Strip newlines
foreach my $i (@data) {
        chomp($i);
        $i =~ s/--.*//;                #strip any trailing -- comments
}

#        initialize counters
my $lines = scalar(@data);                #number of lines in file
my $line = 0;
my $entfound = -1;

#        find 'entity' left justified in file
for ($line = 0; $line < $lines; $line++) {
        if ($data[$line] =~ m/^entity/) {
                $entfound = $line;
                $line = $lines;        #break out of loop
        }
}

# find 'end $file', so that when we're searching for ports we don't include local signals.
my $entendfound = 0;
$file =~ s/\.vhdl$//;
for ($line = 0; $line < $lines; $line++) {
        if ($data[$line] =~ m/^end $file/) {
                $entendfound = $line;
                $line = $lines;        #break out of loop
        }
}


#        if we didn't find 'entity' then quit
if ($entfound == -1) {
        print("Unable to instantiate-no occurance of 'entity' left justified in file.\n");
        exit;
}

#find opening paren for port list
$entendfound = $entendfound + 1;
my $pfound = -1;
print($entfound." ".$entendfound."\n");

for ($line = $entfound; $line < $entendfound; $line++) { #start looking from where we found module
        $data[$line] =~ s/--.*//;                #strip any trailing --comment
        if ($data[$line] =~ m/\(/) {                #0x28 is '('
                $pfound = $line;
                $data[$line] =~ s/.*\x28//;        #consume up to first paren
                $line = $entendfound;                        #break out of loop
        }
}

#        if couldn't find '(', exit
if ($pfound == -1) {
        print("Unable to instantiate-no occurance of '(' after module keyword.\n");
        exit;
}

#collect port names
my @ports;

for ($line = $pfound; $line < $entendfound; $line++) {
        $data[$line] =~ s/--.*//;                #strip any trailing --comment

        next if not $data[$line] =~ /:.*/;
        push @ports , $data[$line];
}

#print out instantiation
#print ("component $file\n");        #print first line
#print (" port (\n");                #print second line
my $out= join "\n", @ports;
#print ("$out\t\n\t);\nend component;\n"); #print ports and last couple of lines

# Create the module instantiation.  A future enhancement would be to call the script vhdl_inst.pl instead.
my @ports2;
for ($line = $pfound; $line < $entendfound; $line++) {
        $data[$line] =~ s/--.*//;                #strip any trailing --comment

        #   next if not $data[$line] =~ /:.*;/;
        if ($data[$line] =~ /\s+(\w+)\s+:/)
        {
                push @ports2, $1;
        }
}


my @portlines;
foreach my $i (@ports2) {
  push @portlines, "$i \t=> $i";
}

my $out2= join ",\n\t", @portlines;


# check to make sure that the file doesn't exist.
my $new_file = join "_", $file, "tb";
my $new_file_vhd = join ".",$new_file,"vhdl";
die "Oops! A file called '$new_file.vhd' already exists.\n" if -e $new_file_vhd;
open(my $inF, ">", $new_file_vhd);
printf($inF "Library IEEE;\n");
printf($inF "use IEEE.STD_LOGIC_1164.all;\n");
printf($inF "use IEEE.std_logic_unsigned.all;\n");
printf($inF "use IEEE.std_logic_arith.all;\n");
printf($inF "use IEEE.Numeric_STD.all;\n");
printf($inF "\n");
printf($inF "library work;\n");
my $new_text = join "_", $file, "pkgs.all";
printf($inF "use work.$new_text;\n");
printf($inF "\n");
printf($inF "\n");
printf($inF "-- Declare module entity. Declare module inputs, inouts, and outputs.\n");
printf($inF "entity aa_$new_file is\n");
printf($inF "end aa_$new_file;\n");
printf($inF "\n");
printf($inF "-- Begin module architecture/code.\n");
printf($inF "architecture behave of aa_$new_file is\n");
printf($inF "\n");
printf($inF "-- UUT Port Signals.\n");
printf($inF "$out;\n"); #print ports and last couple of lines
printf($inF "\n");
printf($inF "-- Local parameter, wire, and register declarations go here.\n");
printf($inF "-- N/A\n");
printf($inF "-- general signals\n");
printf($inF "-- N/A\n");
printf($inF "\n");
printf($inF "-- *** Instantiate Constants ***\n");
printf($inF "constant clk_PERIOD: time := 12 ns;\n");
printf($inF "\n");
printf($inF "begin\n");
printf($inF "\n");
printf($inF "-- Instantiate the UUT module.\n");
printf($inF "$file : $file\nport map (");       #print first line
printf($inF "\n\t$out2);\n\n");
printf($inF "\n");
printf($inF "-- Toggle the resets.\n");
printf($inF "initial: process\n");
printf($inF "begin\n");
printf($inF "\trst_n <= '1';\n");
printf($inF "\twait for 200 ns;\n");
printf($inF "\trst_n <= '0';\n");
printf($inF "\twait for 200 ns;\n");
printf($inF "\trst_n <= '1';\n");
printf($inF "\twait;  -- process hangs forever.\n");
printf($inF "end process;\n");
printf($inF "\n");
printf($inF "-- Generate necessary clocks.\n");
printf($inF "clkgen: process\n");
printf($inF "begin\n");
printf($inF "\tclk <= '1';\n");
printf($inF "\twait for clk_PERIOD / 2;\n");
printf($inF "\tclk <= '0';\n");
printf($inF "\twait for clk_PERIOD / 2;\n");
printf($inF "end process;\n");
printf($inF "\n");
printf($inF "-- Insert Processes and code here.\n");
printf($inF "\n");
printf($inF "end behave; -- architecture\n");
printf($inF "\n");
printf($inF "\n");
my $new_text2 = join "_", $new_file, "cfg";
printf($inF "configuration $new_text2 of aa_$new_file is\n");
printf($inF "for behave\n");
printf($inF "end for;\n");
printf($inF "end $new_text2;\n");

close(inF); 

print("\nThe script has finished successfully! You can now use the file $new_file_vhd.\n\n");

 
exit;


#------------------------------------------------------------------------------ 
# Generic Error and Exit routine 
#------------------------------------------------------------------------------

sub dienice {
        my($errmsg) = @_;
        print"$errmsg\n";
        exit;
}


