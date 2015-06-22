module top;
   initial begin
      automatic node a_node = new();
      void'(a_node.randomize());
   end
endmodule