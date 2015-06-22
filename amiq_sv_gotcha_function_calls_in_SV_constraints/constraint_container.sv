class constraint_container;
   rand int unsigned a, b, c;

   function int unsigned get_a();
      return a;
   endfunction

   function int unsigned value_of(int unsigned value);
      return value;
   endfunction

   constraint a_constraint {
      a == 5;
      // I expect "b" to be equal to "a", but, surprise, surprise...
      b == get_a();
      // I expect "c" will be equal to "a"
      c == value_of(a);
   }
endclass
