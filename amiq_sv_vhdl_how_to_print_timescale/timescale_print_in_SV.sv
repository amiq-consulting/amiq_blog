// timescale
`timescale 1ns/10ps

// top testbench module
module tb();

   // DUT instance
   dut dut_i();

   initial begin
      $printtimescale($root.tb); // prints the timescale of this module
      $printtimescale($root.tb.dut_i);// prints the timescale dut_i module instance
      $printtimescale($root.tb.dut_i.cpu_i);// prints the timescale dut_i.cpu_i module instance
   end 

endmodule