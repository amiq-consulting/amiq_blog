class on_the_fly_seq extends uvm_sequence #(packet);
   task body();
      // holds the generated delays
      int inter_packet_delay[nof_packets-1];

      // first packet is driven immediately
      `uvm_do_with (req, {req.delay == 0;});

      // for the rest, generate delay before driving the packet
      for(int i = 1; i < nof_packets; i++)begin
         // available delay
         int available_window_delay = window_delay - inter_packet_delay.sum();
         // if not enough delay is used early, 
         // we may end with too much available delay for later packets
         int min_delay = available_window_delay - max_delay*(nof_packets-i-1);

         assert(randomize(new_delay) with {
             // legal delay between 0 and max delay
             new_delay inside {[0:max_delay]};
             // at least minimum delay
             new_delay >= min_delay;
             // at most available window delay
             new_delay <= available_window_delay;             
         });

         inter_packet_delay[i-1] = new_delay;

         `uvm_do_with (req, {req.delay == inter_packet_delay[i-1];}); 
      end
   endtask
endclass