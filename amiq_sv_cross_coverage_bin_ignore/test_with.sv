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
* PROJECT:     How to Ignore Cross Coverage Bins Using Expressions in SystemVerilog
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        http://www.amiq.com/consulting/2014/09/17/how-to-ignore-cross-coverage-bins-using-expressions-in-systemverilog/
*******************************************************************************/

class my_s;
     rand bit[3:0] x, y;

     covergroup cover_me;
          x_cp : coverpoint x;
          y_cp : coverpoint y;

          x_y_cross: cross x_cp, y_cp {
               ignore_bins ignore_x_values_higher_than_y = x_y_cross with (x_cp > y_cp);
          }
     endgroup

     function new();
          cover_me = new();
     endfunction
endclass

module top;
     my_s obj;
     initial begin
          obj = new;
          for (int i=0; i<100; i++) begin
               assert(obj.randomize());
               obj.cover_me.sample();
          end
     end
endmodule
