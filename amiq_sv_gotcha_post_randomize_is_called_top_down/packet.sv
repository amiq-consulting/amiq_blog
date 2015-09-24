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
* PROJECT:     Gotcha: SystemVerilog’s post_randomize() is Called Top-Down Not Bottom-Up
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        http://www.amiq.com/consulting/2015/02/26/gotcha-systemverilogs-post_randomize-is-called-top-down-not-bottom-up/
*******************************************************************************/

class packet;
   rand header header_i;
   
   rand byte data[8];
   
   // crc calculated based on the generated header
   byte packet_crc;

   function void post_randomize();
      // At this point the header is randomized, but its CRC ia not computed yet
      packet_crc = compute_packet_crc();
      $display("packet: calling post_randomize() - header_i.CRC is: %X", header_i.header_crc);
   endfunction
endclass
