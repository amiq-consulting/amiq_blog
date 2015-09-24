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
* PROJECT:     A Coverage Closure Study: “on-the-fly” or “top-down” Generation?
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        http://www.amiq.com/consulting/2015/02/02/a-coverage-closure-study-on-the-fly-or-top-down-generation/
*******************************************************************************/

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
