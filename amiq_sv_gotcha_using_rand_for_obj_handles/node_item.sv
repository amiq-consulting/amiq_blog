class item;
     rand int size;
endclass

class node;
   rand item item_1;
   rand item item_2;

   function new();
      item_2= new();
   endfunction

   function void post_randomize();
      $display($psprintf("item_1 is %p.", item_1));
      $display($psprintf("item_2 is %p.", item_2));
   endfunction
endclass