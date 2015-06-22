class basic_test extends uvm_test;
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        set_report_id_action_hier("MY_ERROR", UVM_STOP);
    endfunction
endclass