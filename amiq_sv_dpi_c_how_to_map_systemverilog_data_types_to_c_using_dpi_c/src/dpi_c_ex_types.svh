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

`ifndef __dpi_c_ex_svh
`define __dpi_c_ex_svh

`define BIT_ARRAY_SIZE 16
`define LOGIC_ARRAY_SIZE 8
`define REG_ARRAY_SIZE 8

typedef bit[`BIT_ARRAY_SIZE - 1 : 0] bit_vector_t;
typedef logic[`LOGIC_ARRAY_SIZE-1:0] logic_vector_t;
typedef reg[`REG_ARRAY_SIZE-1:0] reg_vector_t;

typedef byte byte_array_t[];
typedef int int_array_t[];

typedef struct {
	byte aByte;
	int anInt;
	bit aBit;
	longint aLongInt;
	bit[`BIT_ARRAY_SIZE-1:0] aBitVector;
} dpi_c_ex_s;


import "DPI-C" function void compute_byte(input byte i_value, output byte result);
import "DPI-C" function byte get_byte(input byte i_value);

import "DPI-C" function void compute_shortint(input shortint i_value, output shortint result);
import "DPI-C" function shortint get_shortint(input shortint i_value);

import "DPI-C" function void compute_int(input int i_value, output int result);
import "DPI-C" function int get_int(input int i_value);

import "DPI-C" function void compute_longint(input longint i_value, output longint result);
import "DPI-C" function longint get_longint(input longint i_value);

//`ifndef QUESTA
import "DPI-C" function void compute_real(input real i_value, output real result);
import "DPI-C" function real get_real(input real i_value);
//`endif

import "DPI-C" function void compute_string(input string i_value, output string result);
import "DPI-C" function string get_string(input string i_value);

import "DPI-C" function void compute_string_array(input string i_value[], output string result[]);

import "DPI-C" function void compute_bit(input bit i_value, output bit result);
import "DPI-C" function bit get_bit(input bit i_value);

import "DPI-C" function void compute_bit_vector(input bit[`BIT_ARRAY_SIZE - 1 : 0] i_val, output bit[`BIT_ARRAY_SIZE - 1 : 0] result);

`ifndef QUESTA
   import "DPI-C" function bit[`BIT_ARRAY_SIZE - 1 : 0] get_bit_vector(input bit[`BIT_ARRAY_SIZE - 1 : 0] i_val);
`endif

import "DPI-C" function void compute_logic(input logic i_value, output logic result);
import "DPI-C" function logic get_logic(input logic i_value);

import "DPI-C" function void compute_logic_vector(input logic[`LOGIC_ARRAY_SIZE - 1 : 0] i_val, output logic[`LOGIC_ARRAY_SIZE - 1 : 0] result, input int asize);
//import "DPI-C" function logic[`LOGIC_ARRAY_SIZE - 1 : 0] get_logic_vector(input logic[`LOGIC_ARRAY_SIZE - 1 : 0] i_val, input int asize);

import "DPI-C" function void compute_reg(input reg i_value, output reg result);
import "DPI-C" function reg  get_reg(input reg i_value);

import "DPI-C" function void compute_reg_vector(input reg[`REG_ARRAY_SIZE - 1 : 0] i_val, output reg[`REG_ARRAY_SIZE - 1 : 0] result, input int asize);
//import "DPI-C" function reg[`REG_ARRAY_SIZE - 1 : 0] get_reg_vector(input reg[`REG_ARRAY_SIZE - 1 : 0] i_val, input int asize);

import "DPI-C" function void compute_chandle(output chandle result);
import "DPI-C" function chandle get_chandle();
import "DPI-C" function void call_chandle(input chandle i_value, output int result);

import "DPI-C" function void compute_unsized_int_array(input int i_value[], output int result[]);
import "DPI-C" function void compute_unsized_byte_array(input byte i_value[], output byte result[]);

import "DPI-C" function void compute_struct(input dpi_c_ex_s i_value, output dpi_c_ex_s result);
//import "DPI-C" function dpi_c_ex_s get_struct(input dpi_c_ex_s i_value); //unsupported return type

`endif
