/******************************************************************************
* (C) Copyright 2019 AMIQ Consulting
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
* PROJECT:     How to Map SystemVerilog Data Types to C, Using DPI-C
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        https://www.amiq.com/consulting/2019/01/30/how-to-map-systemverilog-data-types-to-c-using-dpi-c/
*******************************************************************************/


`include "dpi_c_ex_types.svh"

class dpi_c_ex_test;

	rand byte  m_byte;
	constraint c_m_byte { m_byte != 0; }

	rand shortint m_shortint;
	constraint c_m_shortint { m_shortint != 0; }

	rand int   m_int;
	constraint c_m_int { m_int != 0; }

	rand longint  m_longint;
	constraint c_m_longint { m_longint != 0; }

	rand bit[63:0] m_bits4real;
	constraint c_m_real { m_bits4real != 0; }
	real       m_real;

	string   m_string;
	string   m_string_a[3];

	rand bit m_bit;
	rand bit[`BIT_ARRAY_SIZE - 1 : 0]     m_bit_a;

	logic m_logic;
	rand int   m_logic_int;
	constraint c_m_logic_int { m_logic_int inside {[0:3]};}

	logic[`LOGIC_ARRAY_SIZE - 1 : 0] m_logic_a;
	rand int   m_logic_a_i[`LOGIC_ARRAY_SIZE];
	constraint c_m_logic_a_i { foreach(m_logic_a_i[i]) m_logic_a_i[i] inside {[0:3]};}

	reg   m_reg;
	rand int   m_reg_int;
	constraint c_m_reg_int { m_reg_int inside {[0:3]};}

	reg[`REG_ARRAY_SIZE - 1 : 0] m_reg_a;
	rand int   m_reg_a_i[`REG_ARRAY_SIZE];
	constraint c_m_reg_a_i { foreach(m_reg_a_i[i]) m_reg_a_i[i] inside {[0:3]};}

	rand byte  m_byte_ua[];
	constraint c_m_byte_ua { m_byte_ua.size() == 3; }

	rand shortint m_shortint_ua[];
	constraint  c_m_shortint_ua { m_shortint_ua.size() inside {[2:5]}; }

	rand int      m_int_ua[];
	constraint  c_m_int_ua { m_int_ua.size() inside {[2:5]}; }

	rand longint  m_longint_ua[];
	constraint  c_m_longint_ua { m_longint_ua.size() inside {[2:5]}; }

	real     m_real_ua[];

	dpi_c_ex_s m_struct;

	// constructor
	function new();
	endfunction

	// test setup
	function void initialize();
		//`ifndef QUESTA
		m_real = 3.1415;
		//`endif
		m_string = "A_STRING";
		m_string_a[0] = "A_STRING_0";
		m_string_a[1] = "A_STRING_1";
		m_string_a[2] = "A_STRING_2";

		case (m_logic_int)
			0 : m_logic = 0;
			1 : m_logic = 1;
			2 : m_logic = 1'bz;
			3 : m_logic = 1'bx;
		endcase

		foreach(m_logic_a_i[i]) begin
			case (m_logic_a_i[i])
				0 : m_logic_a[i] = 0;
				1 : m_logic_a[i] = 1;
				2 : m_logic_a[i] = 1'bz;
				3 : m_logic_a[i] = 1'bx;
			endcase
		end

		case (m_reg_int)
			0 : m_reg = 0;
			1 : m_reg = 1;
			2 : m_reg = 1'bz;
			3 : m_reg = 1'bx;
		endcase

		foreach(m_reg_a_i[i])
			case (m_reg_a_i[i])
				0 : m_reg_a[i] = 0;
				1 : m_reg_a[i] = 1;
				2 : m_reg_a[i] = 1'bz;
				3 : m_reg_a[i] = 1'bx;
			endcase

		m_struct.aBit  = m_bit;
		m_struct.aByte = m_byte;
		m_struct.anInt = m_int;
		m_struct.aLongInt = m_longint;
		m_struct.aBitVector = m_bit_a;
	endfunction

	// test
	function void test();
		initialize();
		// --------------
		test_byte();
		test_shortint();
		test_int();
		test_longint();
		test_real();
		test_string();
		test_string_array();
		test_bit();
		test_bit_vector();
		test_logic();
		test_logic_vector();
		test_reg();
		test_reg_vector();
		test_chandle();
		test_unsized_int_array();

		`ifndef XCELIUM
		test_unsized_byte_array();
		`endif

		`ifdef XCELIUM
		test_struct();
		`endif
	endfunction

	function void test_byte();
		byte cres, ares;
		byte expected = transform_byte(m_byte);
		$display($sformatf("test.test_byte calls compute_byte with %d", m_byte));
		compute_byte(m_byte, cres);
		ares = get_byte(m_byte);
		COMPUTE_BYTE_ERR: assert(cres == expected) else begin
			$display($sformatf("compute_byte error: expected %d received %d for input %d", expected, cres, m_byte));
			$finish();
		end
		GET_BYTE_ERR: assert(ares == expected) else begin
			$display($sformatf("get_byte error: expected %d received %d for input %d", expected, ares, m_byte));
			$finish();
		end
	endfunction

	function void test_shortint();
		shortint cres, ares;
		shortint expected = transform_shortint(m_shortint);

		$display($sformatf("test.test_shortint calls compute_shortint with %d", m_shortint));
		compute_shortint(m_shortint, cres);
		ares = get_shortint(m_shortint);
		COMPUTE_SHORTINT_ERR: assert(cres == expected) else begin
			$display($sformatf("compute_shortint error: expected %d received %d for input %d", expected, cres, m_shortint));
			$finish();
		end
		GET_SHORTINT_ERR: assert(ares == expected) else begin
			$display($sformatf("get_shortint error: expected %d received %d for input %d", expected, ares, m_shortint));
			$finish();
		end
	endfunction

	function void test_int();
		int cres, ares;
		int expected = transform_int(m_int);
		$display($sformatf("test.test_int calls compute_int with %d", m_int));
		compute_int(m_int, cres);
		ares = get_int(m_int);
		COMPUTE_INT_ERR: assert(cres == expected) else begin
			$display($sformatf("compute_int error: expected %d received %d for input %d", expected, cres, m_int));
			$finish();
		end
		GET_INT_ERR: assert(ares == expected) else begin
			$display($sformatf("get_int error: expected %d received %d for input %d", expected, ares, m_int));
			$finish();
		end
	endfunction

	function void test_longint();
		longint cres, ares;
		longint expected = transform_longint(m_longint);
		$display($sformatf("test.test_longint calls compute_longint with %d", m_longint));
		compute_longint(m_longint, cres);
		ares = get_longint(m_longint);
		COMPUTE_LONGINT_ERR: assert (cres == expected) else begin
			$display($sformatf("compute_longint error: expected %d received %d for input %d", expected, cres, m_longint));
			$finish();
		end
		GET_LONGINT_ERR: assert (ares == expected) else begin
			$display($sformatf("get_longint error: expected %d received %d for input %d", expected, ares, m_longint));
			$finish();
		end
	endfunction

	function void test_real();
		real cres, ares;
		real expected = transform_real(m_real);
		$display($sformatf("test.test_real calls compute_real with %f", m_real));
		compute_real(m_real, cres);
		ares = get_real(m_real);
		COMPUTE_REAL_ERR: assert(cres == expected) else begin
			$display($sformatf("compute_real error: expected %d received %d for input %d", expected, cres, m_real));
			$finish();
		end
		GET_REAL_ERR: assert(ares == expected) else begin
			$display($sformatf("get_real error: expected %d received %d for input %d", expected, ares, m_real));
			$finish();
		end
	endfunction

	function void test_string();
		string cres, ares;
		string expected = "DEAF_BEAF_DRINKS_COFFEE";
		$display($sformatf("test.test_string calls compute_string with %s", m_string));
		compute_string(m_string, cres);
		ares = get_string(m_string);
		COMPUTE_STRING_ERR: assert(cres == expected) else begin
			$display($sformatf("compute_string error: expected %s received %s for input %s", expected, cres, m_string));
			$finish();
		end
		GET_STRING_ERR: assert(ares == expected) else begin
			$display($sformatf("compute_string error: expected %s received %s for input %s", expected, ares, m_string));
			$finish();
		end
	endfunction

	function void test_string_array();
		string cres[3], ares[3];
		string expected[3] = {"DEAF_BEAF","DRINKS", "COFFEE"};
		$display($sformatf("test.test_string_array calls compute_string_array with %s, %s, %s", m_string_a[0], m_string_a[1], m_string_a[2]));
		compute_string_array(m_string_a, cres);
		foreach(expected[i])
			COMPUTE_STRING_A_ERR: assert(cres[i] == expected[i]) else begin
				$display($sformatf("compute_string_array error: expected %s received %s for input %s", expected[i], cres[i], m_string_a[i]));
				$finish();
			end
	endfunction

	function void test_bit();
		bit cres, ares;
		bit expected = transform_bit(m_bit);
		$display($sformatf("test.test_bit calls compute_bit with %b", m_bit));
		compute_bit(m_bit, cres);
		ares = get_bit(m_bit);
		COMPUTE_BIT_ERR: assert(cres == expected) else begin
			$display($sformatf("compute_bit error: expected %b received %b for input %b", expected, cres, m_bit));
			$finish();
		end
		GET_BIT_ERR: assert(ares == expected) else begin
			$display($sformatf("get_bit error: expected %b received %b for input %b", expected, ares, m_bit));
			$finish();
		end
	endfunction

	function void test_bit_vector();
		bit_vector_t cres, ares;
		bit_vector_t expected = transform_bit_vector(m_bit_a);
		$display($sformatf("test.test_bit_array calls compute_bit_vector with %b", m_bit_a));
		compute_bit_vector(m_bit_a, cres);

		COMPUTE_BIT_ARRAY_ERR: assert(cres == expected) else begin
			$display($sformatf("compute_bit_vector error: expected %b received %b for input %b", expected, cres, m_bit_a));
			$finish();
		end
		`ifndef QUESTA
		ares = get_bit_vector(m_bit_a);
		GET_BIT_ARRAY_ERR: assert(ares == expected) else begin
			$display($sformatf("get_bit_vector error: expected %b received %b for input %b", expected, ares, m_bit_a));
			$finish();
		end
		`endif
	endfunction

	function void test_logic();
		logic cres, ares;
		logic expected;
		expected = transform_logic(m_logic);

		$display($sformatf("test.test_logic calls compute_logic with %b", m_logic));
		compute_logic(m_logic, cres);
		ares = get_logic(m_logic);
		COMPUTE_LOGIC_ERR: assert(cres === expected) else begin
			$display($sformatf("compute_logic error: expected %b received %b for input %b", expected, cres, m_logic));
			$finish();
		end
		GET_LOGIC_ERR: assert(ares === expected) else begin
			$display($sformatf("compute_logic error: expected %b received %b for input %b", expected, ares, m_logic));
			$finish();
		end

	endfunction


	function void test_logic_vector();
		logic_vector_t cres=0, ares=0;
		logic_vector_t expected=0;
		logic abit;
		int i;
		for (i = 0; i < `LOGIC_ARRAY_SIZE; i++) begin
			expected[i] = transform_logic(m_logic_a[i]);
		end

		$display($sformatf("test.test_logic_vector calls compute_logic_vector with %08b, expect %08b", m_logic_a, expected));
		compute_logic_vector(m_logic_a, cres, `LOGIC_ARRAY_SIZE);
		$display($sformatf("test.test_logic_vector %08b, expect %08b, received %08b", m_logic_a, expected, cres));
		for (i = 0; i < `LOGIC_ARRAY_SIZE; i++) begin
			TEST_LOGIC_VECTOR_ERR: assert (cres[i] === expected[i])
				$display($sformatf("----->test_logic_vector passed[%0d]: expected %b received %b for input %b!", i, expected[i], cres[i], m_logic_a[i]));
			else begin
				$display($sformatf("test_logic_vector error[%0d]: expected %b received %b for input %b", i, expected[i], cres[i], m_logic_a[i]));
				$finish();
			end
		end
	endfunction

	function void test_reg();
		reg cres, ares;
		reg expected;
		expected = transform_reg(m_reg);

		$display($sformatf("test.test_reg calls compute_reg with %x", m_reg));
		compute_reg(m_reg, cres);
		ares = get_reg(m_reg);
		COMPUTE_REG_ERR: assert(cres === expected) else begin
			$display($sformatf("compute_reg error: expected %x received %x for input %x", expected, cres, m_reg));
			$finish();
		end
		GET_REG_ERR: assert(ares === expected) else begin
			$display($sformatf("get_reg error: expected %x received %x for input %x", expected, ares, m_reg));
			$finish();
		end
	endfunction

	function void test_reg_vector();
		reg_vector_t cres=0, ares=0;
		reg_vector_t expected=0;
		int i;
		for (i = 0; i < `REG_ARRAY_SIZE; i++) begin
			expected[i] = transform_reg(m_reg_a[i]);
		end

		$display($sformatf("test.test_reg_vector calls compute_reg_vector with %08b, expect %08b", m_reg_a, expected));
		compute_logic_vector(m_reg_a, cres, `REG_ARRAY_SIZE);
		$display($sformatf("test.test_reg_vector %08b, expect %08b, received %08b", m_reg_a, expected, cres));
		for (i = 0; i < `REG_ARRAY_SIZE; i++) begin
			TEST_REG_VECTOR_ERR: assert (cres[i] === expected[i])
				$display($sformatf("----->test_reg_vector passed[%0d]: expected %b received %b for input %b!", i, expected[i], cres[i], m_reg_a[i]));
			else begin
				$display($sformatf("test_reg_vector error[%0d]: expected %b received %b for input %b", i, expected[i], cres[i], m_reg_a[i]));
				$finish();
			end
		end
	endfunction


	function void test_chandle();
		chandle ch = null, ares=null;
		int cres, expected;

		expected = get_expected_chandle_value();

		$display("test.test_chandle calls compute_chandle");
		compute_chandle(ch);
		ares=get_chandle();
		$display($sformatf("test.test_chandle calls call_chandle %p", ch));
		call_chandle(ch, cres);

		COMPUTE_CHANDLE_ERR: assert (cres == expected) else begin
			$display($sformatf("compute_chandle error: expected %0d received %0d", expected, cres));
			$finish();
		end

		call_chandle(ares, cres);
		GET_CHANDLE_ERR: assert (cres == expected) else begin
			$display($sformatf("get_chandle error: expected %0d received %0d", expected, cres));
			$finish();
		end

	endfunction

	function void test_unsized_int_array();
		int_array_t expected, cres;

		cres = new[m_int_ua.size()];

		$display($sformatf("test.test_unsized_int_array calls compute_unsized_int_array with %p", m_int_ua));

		expected = transform_int_array(m_int_ua);

		compute_unsized_int_array(m_int_ua, cres);

		foreach(expected[i])
			COMPUTE_UNSIZED_INT_ARRAY_A_ERR: assert(cres[i] == expected[i]) else begin
				$display($sformatf("compute_unsized_int_array error: expected %0d received %0d for input %0d", expected[i], cres[i], m_int_ua[i]));
				$finish();
			end
	endfunction

	function void test_unsized_byte_array();
		byte_array_t expected, cres;

		cres = new[m_byte_ua.size()];

		$display($sformatf("test.test_unsized_byte_array calls compute_unsized_byte_array with %p", m_byte_ua));

		expected = transform_byte_array(m_byte_ua);

		compute_unsized_byte_array(m_byte_ua, cres);

		foreach(expected[i])
			COMPUTE_UNSIZED_BYTE_ARRAY_A_ERR: assert(cres[i] == expected[i]) else begin
				$display($sformatf("compute_unsized_byte_array error: expected %0d received %0d for input %0d", expected[i], cres[i], m_byte_ua[i]));
				$finish();
			end
	endfunction

	function void test_struct();
		dpi_c_ex_s cres, expected;
		int cres_handle_value;

		expected = transform_struct(m_struct);

		$display($sformatf("test.test_struct calls compute_struct with %s", struct2string(m_struct)));

		compute_struct(m_struct, cres);

		$display($sformatf("test.test_struct compute_struct returned %s", struct2string(cres)));

		COMPUTE_STRUCT_ERR: assert(
				cres.aBit == expected.aBit &&
				cres.aByte == expected.aByte &&
				cres.anInt == expected.anInt &&
				cres.aLongInt == expected.aLongInt &&
				cres.aBitVector == expected.aBitVector
			) else begin
			$display($sformatf("compute_struct error (bit): expected %b received %b for input %b", expected.aBit, cres.aBit, m_struct.aBit));
			$display($sformatf("compute_struct error (byte): expected %d received %d for input %d", expected.aByte, cres.aByte, m_struct.aByte));
			$display($sformatf("compute_struct error (int): expected %d received %d for input %d", expected.anInt, cres.anInt, m_struct.anInt));
			$display($sformatf("compute_struct error (int2): expected %d received %d for input %d", expected.aLongInt, cres.aLongInt, m_struct.aLongInt));
			$display($sformatf("compute_struct error (bit vector): expected %d received %d for input %d", expected.aBitVector, cres.aBitVector, m_struct.aBitVector));
			$finish();
		end
	endfunction

	function string array2string(byte anarray[]);
		array2string="";
		foreach(anarray[i])
			array2string = $sformatf("%s %2x", array2string, anarray[i]);
	endfunction

	function string struct2string(dpi_c_ex_s astruct);
		return $sformatf("struct={aBit=%1b, aByte=%2x, anInt=%0X, aLongInt=%016x, aBitVector:%016x}",
			astruct.aBit,
			astruct.aByte,
			astruct.anInt,
			astruct.aLongInt,
			astruct.aBitVector
		);
	endfunction

	function dpi_c_ex_s transform_struct(dpi_c_ex_s in);
		transform_struct.aBit = transform_bit(m_bit);
		transform_struct.aByte = transform_byte(m_byte);
		transform_struct.anInt = transform_int(m_int);
		transform_struct.aLongInt = transform_longint(m_longint);
		transform_struct.aBitVector = transform_bit_vector(m_bit_a);
	endfunction

	function byte transform_byte(byte in);
		return 255-in;
	endfunction

	function bit transform_bit(bit in);
		return !in;
	endfunction

	function int transform_int(int in);
		return 23*in;
	endfunction

	function longint transform_longint(longint in);
		return 123*in;
	endfunction


	function shortint transform_shortint(shortint in);
		return 65535-in;
	endfunction

	function real transform_real(real in);
		return in * 3;
	endfunction

	function bit_vector_t transform_bit_vector(bit_vector_t in);
		return (in << 3) + 2;
	endfunction

	function logic transform_logic(logic in);
		case (in)
			1'b0: return 1'b1;
			1'b1: return 1'bx;
			1'bz: return 1'b0;
			1'bx: return 1'bz;
		endcase
	endfunction

	function reg transform_reg(reg in);
		case (in)
			1'b0: return 1'b1;
			1'b1: return 1'bx;
			1'bz: return 1'b0;
			1'bx: return 1'bz;
		endcase
	endfunction

	function int get_expected_chandle_value();
		return 10;
	endfunction

	function byte_array_t transform_byte_array(byte_array_t in);
		transform_byte_array=new[in.size()];

		foreach(in[i])
			transform_byte_array[i] = in[i] + 3;
	endfunction

	function int_array_t transform_int_array(int_array_t in);
		transform_int_array=new[in.size()];

		foreach(in[i])
			transform_int_array[i] = in[i] + 3;
	endfunction
endclass
