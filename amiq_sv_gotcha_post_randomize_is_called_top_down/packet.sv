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