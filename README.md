to run sim  

vcs -R -sverilog tb.sv dut.sv -full64 -debug_acc+all +v2k | tee test.log  

open tool and run fv
jaspergold &
source name.tcl
