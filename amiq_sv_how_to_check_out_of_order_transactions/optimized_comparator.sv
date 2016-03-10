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
* PROJECT:     How To Check Out-of-Order Transactions
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        http://www.amiq.com/consulting/2016/03/10/how-to-check-out-of-order-transactions
*******************************************************************************/

// declare the implementation ports for incoming transactions
`uvm_analysis_imp_decl(_dut)
`uvm_analysis_imp_decl(_ref)

class comparator extends uvm_component;
  `uvm_component_utils(comparator)

  // implementation ports instances
  uvm_analysis_imp_dut#(my_trans, comparator)           dut_in_imp;
  uvm_analysis_imp_ref#(my_trans, comparator)           ref_in_imp;

  // queues holding the transactions from different sources
  my_trans dut_q[$];
  my_trans ref_q[$];

  function new(string name=”comparator”, uvm_component parent);
    super.new(name, parent);
    dut_in_imp    = new("dut_in_imp", this);
    ref_in_imp    = new("ref_in_imp", this);
  endfunction

  function void write_dut(my_transaction dut_trans);
    search_and_compare(dut_trans, 1);
  endfunction

  function void write_ref(my_transaction ref_trans);
    search_and_compare(ref_trans, 0);
  endfunction

  function void search_and_compare(my_transaction a_trans, bit is_dut);
    my_trans search_q = is_dut?ref_q:dut_q;
    my_trans save_q = is_dut?dut_q:ref_q;
    int indexes[$];
    int matching_index = -1;
  
    indexes = search_q.find_first_index(it) with (a_trans.shallow_match(it));
    if (indexes.size() == 0) begin
      save_q.push_back(a_trans);
      return;
    end
    foreach(indexes[i]) begin
      if (a_trans.deep_match(search_q[indexes[i]])) begin
        matching_index = i;
        break;
      end
    end
    // how you handle the case of partial match depends a lot on your context
    // you can trigger an error, warning or just save the transaction in the queue
    if (matching_index == -1) begin
      save_q.push_back(a_trans);
      `uvm_warning(“COMPARATOR_INCOMPLETE_MATCH_WRN”, $sformatf(“Found %d transactions that partially match the searched transaction”, indexes.size()))
    end
    // sample a_trans coverage
    search_q.delete(matching_index);
  endfunction

  // at the end of the test we need to check that the two queues are empty
  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    COMPARATOR_REF_Q_NOT_EMPTY_ERR : assert(ref_q.size() == 0) else
      `uvm_error(“COMPARATOR_REF_Q_NOT_EMPTY_ERR”, $sformatf(“ref_q is not empty!!! It still contains %d transactions!”, ref_q.size()))
    COMPARATOR_DUT_Q_NOT_EMPTY_ERR : assert(dut_q.size() == 0) else
      `uvm_error(“COMPARATOR_DUT_Q_NOT_EMPTY_ERR”, $sformatf(“dut_q is not empty!!! It still contains %d transactions!”, dut_q.size()))
  endfunction
endclass
