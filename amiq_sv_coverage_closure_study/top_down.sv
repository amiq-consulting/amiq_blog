class top_down_seq extends uvm_sequence #(packet);
   task body();
      // holds the generated delays
      int inter_packet_delay[nof_packets-1];
      
      // first packet is driven immediately
      `uvm_do_with ( req,{req.delay == 0;});

      // generate delays up-front
      assert(randomize(inter_packet_delay) with {
         // sum of all inter-packet delays equal to window delay
         inter_packet_delay.sum() == window_delay;

         // legal delay between 0 and max delay
         foreach(inter_packet_delay[i])
            inter_packet_delay[i] inside {[0:max_delay]};
      });

      // drive the rest of the packets
      for(int i = 1; i < nof_packets; i++)begin
         `uvm_do_with ( req,{req.delay == inter_packet_delay[i-1];});
      end
   endtask
endclass