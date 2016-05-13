/******************************************************************************
* (C) Copyright 2016 AMIQ Consulting
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
* PROJECT:     How To Implement Flexible Coverage Definitions (Part 1)
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        http://www.amiq.com/consulting/2016/05/13/how-to-implement-flexible-coverage-definitions-part-1/
*******************************************************************************/

class cg_wrapper;
  covergroup size_cg(int max) with function sample(int size);
    option.per_instance = 1;
    type_option.merge_instances = 1;

    burst_size: coverpoint size {
      bins one_item      = { 1 };
      bins several_items = { [2:max-1] } with (max >= 3);
      bins max_items     = { max }       with (max >= 2);
      illegal_bins illegal_val = default;
    }
  endgroup

  function new(int max_size);
    size_cg = new(max_size);
    size_cg.set_inst_name($sformatf("size_cg_max_size_%0d", max_size));
  endfunction
endclass

module test;
  initial begin
    cg_wrapper cgs[5];

    foreach (cgs[max_size]) begin
      cgs[max_size] = new(max_size + 1);

      for (int size = 1; size <= max_size + 1; size++)
        cgs[max_size].size_cg.sample(size);
    end
  end
endmodule
