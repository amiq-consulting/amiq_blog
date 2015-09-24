/******************************************************************************
* (C) Copyright 2014 AMIQ Consulting
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
* PROJECT:     How to print `timescale in Verilog, SystemVerilog and VHDL
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        http://www.amiq.com/consulting/2014/10/31/how-to-print-timescale-in-verilog-systemverilog-and-vhdl/
*******************************************************************************/

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
