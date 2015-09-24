/******************************************************************************
* (C) Copyright 2014 AMIQ Consulting
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*
* MODULE:      BLOG
* PROJECT:     How to print `timescale in Verilog, SystemVerilog and VHDL
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        http://www.amiq.com/consulting/2014/10/31/how-to-print-timescale-in-verilog-systemverilog-and-vhdl/
*******************************************************************************/

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
