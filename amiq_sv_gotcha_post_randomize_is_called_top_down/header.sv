class header;
   //random info
   rand byte header_info[2];
   
   //crc calculated based on the generated data
   byte header_crc;

   function void post_randomize();
      header_crc = compute_header_crc();
      $display("header: calling post_randomize() - CRC is: %X", header_crc);
   endfunction
endclass