/******************************************************************************
* (C) Copyright 2015 AMIQ Consulting
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
* PROJECT:     Gotcha: Using a==b==c in SystemVerilog Constraints
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        http://www.amiq.com/consulting/2015/09/30/gotcha-using-abc-in-systemverilog-constraints
*******************************************************************************/

class abc;
  rand int unsigned a,b,c;
  constraint abc_constr{
    a==b==c;
  }
endclass

class abc_good;
  rand int unsigned a,b,c;
  constraint abc_constr{
    a==b;
    b==c;
  }
endclass

module top;
  initial begin
    abc abc_inst = new();
    abc abc_inst2 = new();
    abc_good abc_inst_good = new();
    
    if(abc_inst.randomize())
      $display("a = %0d, b = %0d, c = %0d", abc_inst.a, abc_inst.b, abc_inst.c);
    else
      $display("ERR: Could not randomize abc_inst");
    
    if(abc_inst2.randomize() with {
      c==10;
    })
      $display("a=%0d, b=%0d, c=%0d", abc_inst2.a, abc_inst2.b, abc_inst2.c);
    else
      $error("Could not randomize abc_inst2");
      
    if(abc_inst_good.randomize())
      $display("a = %0d, b = %0d, c = %0d", abc_inst_good.a, abc_inst_good.b, abc_inst_good.c);
    else
      $display("ERR: Could not randomize abc_inst_good");
  end
endmodule
