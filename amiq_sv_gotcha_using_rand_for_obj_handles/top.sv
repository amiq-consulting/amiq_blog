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
* PROJECT:     Gotcha: Using “rand” Modifier for Object Handles is not enough!
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        http://www.amiq.com/consulting/2015/05/25/gotcha-using-rand-modifier-for-object-handles-is-not-enough/
*******************************************************************************/

module top;
   initial begin
      automatic node a_node = new();
      void'(a_node.randomize());
   end
endmodule
