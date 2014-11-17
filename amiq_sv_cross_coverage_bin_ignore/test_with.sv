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
