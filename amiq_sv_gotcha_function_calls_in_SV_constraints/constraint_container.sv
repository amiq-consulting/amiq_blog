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
* PROJECT:     Gotcha: Function Calls in SystemVerilog Constraints
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        http://www.amiq.com/consulting/2015/03/12/gotcha-function-calls-in-systemverilog-constraints/
*******************************************************************************/

class constraint_container;
   rand int unsigned a, b, c;

   function int unsigned get_a();
      return a;
   endfunction

   function int unsigned value_of(int unsigned value);
      return value;
   endfunction

   constraint a_constraint {
      a == 5;
      // I expect "b" to be equal to "a", but, surprise, surprise...
      b == get_a();
      // I expect "c" will be equal to "a"
      c == value_of(a);
   }
endclass
