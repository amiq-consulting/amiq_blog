-- VHDL library declarations
library ieee;
use ieee.std_logic_1164.all;

LIBRARY DUT;
USE DUT.ALL;

LIBRARY tb;
USE tb.all;

-- declaration of tb entity
ENTITY tb IS
END;

-- implementation of the testbench
architecture rtl of tb is

-- declaration of timescale_printer component
COMPONENT timescale_printer is PORT ();
END COMPONENT timescale_printer;

-- declaration of dut component
COMPONENT dut is PORT ();
END COMPONENT dut;

begin

-- instance of the DUT; I skipped signal connections for the example's simplicity sake
dut_i : dut PORT_MAP();

-- instance of the timescale_printer component
timescale_printer_i : timescale_printer PORT MAP();

end rtl;