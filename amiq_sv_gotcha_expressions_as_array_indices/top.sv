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
 * PROJECT:     Gotcha: Using SystemVerilog Expressions as Array Indices
 * Description: This is a code snippet from the Blog article mentioned on PROJECT
 * Link:        http://www.amiq.com/consulting/2015/08/26/gotcha-using-systemverilog-expressions-as-array-indices/
 *******************************************************************************/
 
module top;
  initial begin
    automatic int array[10] = {0,1,2,3,4,5,6,7,8,9};
    automatic bit idx1 = 1;
    automatic bit[1:0] idx2 = 3;
    
    // Is idx1+idx2 equal to 4 ?
    if (array[idx1+idx2] != array[4]) begin
      $error($sformatf("array[%0d] != array[4]",idx1+idx2));
    end
  end
endmodule
