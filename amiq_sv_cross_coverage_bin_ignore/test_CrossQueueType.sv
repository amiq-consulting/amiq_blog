class my_s;
     rand bit[3:0] x, y;

     covergroup cover_me;
          x_cp : coverpoint x;
          y_cp : coverpoint y;

          x_y_cross : cross x_cp, y_cp {
               function CrossQueueType createIgnoreBins();
                    // Iterate over all bins
                    for (int xx=0; xx<=15; xx++) begin
                         for (int yy=0; yy<=15; yy++) begin
                              if (xx > yy)
                                   // Ignore this bin
                                   createIgnoreBins.push_back('{xx,yy});
                              else
                                   // This is a valid bin
                                   continue;
                         end
                    end
               endfunction

               ignore_bins ignore_x_values_higher_than_y = createIgnoreBins();
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
