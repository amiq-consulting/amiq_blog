module top;
   initial begin
      automatic constraint_container cc_inst = new();
      void'(cc_inst.randomize());
      $display($sformatf("a: %0d, b: %0d, c: %0d", cc_inst.a, cc_inst.b, cc_inst.c));
   end
endmodule