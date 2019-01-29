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

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#include "svdpi.h"

#include "dpi_c_misc.h"

#ifndef __dpi_c_ex_c
#define __dpi_c_ex_c

void compute_byte(const char i_value, char* result) {
	log_info("dpi_c.compute_byte(): received value %d", (int) (i_value));
	*result = transform_char(i_value);
	log_info("dpi_c.compute_byte(): return value %d", (int) (*result));
}

char get_byte(const char i_value) {
	log_info("dpi_c.get_byte(): received %d", (int) (i_value));
	char result = transform_char(i_value);
	log_info("dpi_c.get_byte(): return %d", (int) (result));
	return result;
}

void compute_shortint(const short int i_value, short int* result) {
	log_info("dpi_c.compute_shortint(): received %d", (int)(i_value));
	*result = transform_short_int(i_value);
	log_info("dpi_c.compute_shortint(): return %d", (int)(*result));
}

short int get_shortint(const short int i_value) {
	log_info("dpi_c.get_shortint(): received %d", (int)(i_value));
	short int result = transform_short_int(i_value);
	log_info("dpi_c.get_shortint(): return %d", (int)(result));
	return result;
}

void compute_int(const int i_value, int* result) {
	log_info("dpi_c.compute_int(): received %d", (int)(i_value));
	*result = transform_int(i_value);
	log_info("dpi_c.compute_int(): return %d", (int)(*result));
}

int get_int(const int i_value) {
	log_info("dpi_c.get_int(): received %d", (int)(i_value));
	int result = transform_int(i_value);
	log_info("dpi_c.get_int(): return %d", (int)(result));
	return result;
}

void compute_longint(const long int i_value, long int* result) {
	log_info("dpi_c.compute_longint(): received %d", (int)(i_value));
	*result = transform_long_int(i_value);
	log_info("dpi_c.compute_longint(): return %d", (int)(*result));
}

long int get_longint(const long int i_value) {
	log_info("dpi_c.get_longint(): received %d", (int)(i_value));
	long int result = transform_long_int(i_value);
	log_info("dpi_c.get_longint(): return %d", (int)(result));
	return result;
}

void compute_real(const double i_value, double* result) {
	log_info("dpi_c.compute_real(): received %f", i_value);
	*result = transform_double(i_value);
	log_info("dpi_c.compute_real(): return %f", *result);
}

double get_real(const double i_value) {
	log_info("dpi_c.get_real(): received %f", i_value);
	double result = transform_double(i_value);
	log_info("dpi_c.get_real(): return %f", result);
	return result;
}

void compute_string(const char* i_value, char** result) {
	log_info("dpi_c.compute_string(): received %s", i_value);
	*result = "DEAF_BEAF_DRINKS_COFFEE";
	log_info("dpi_c.compute_string(): return %s", *result);
}

char* get_string(const char* i_value) {
	log_info("dpi_c.get_string(): received %s", i_value);
	char* result = "DEAF_BEAF_DRINKS_COFFEE";
	log_info("dpi_c.get_string(): return %s", result);
	return result;
}

void compute_string_array(const svOpenArrayHandle i_value,
		const svOpenArrayHandle result) {
	char** i_val = svGetArrayPtr(i_value);
	char** o_val = svGetArrayPtr(result);
	log_info("dpi_c.compute_string_array(): inputs {%s, %s, %s}", i_val[0],
			i_val[1], i_val[2]);
	o_val[0] = "DEAF_BEAF";
	o_val[1] = "DRINKS";
	o_val[2] = "COFFEE";
	log_info("dpi_c.compute_string_array(): return value {%s, %s, %s}",
			o_val[0], o_val[1], o_val[2]);
}

void compute_bit(const svBit i_value, svBit* result) {
	log_info("dpi_c.compute_bit(): input %u", i_value);
	*result = transform_svBit(i_value);
	log_info("dpi_c.compute_bit(): result %u", *result);
}

svBit get_bit(const svBit i_value) {
	svBit result;
	log_info("dpi_c.get_bit(): input %u", i_value);
	result = transform_svBit(i_value);
	log_info("dpi_c.get_bit(): result %u", result);
	return result;
}

void compute_bit_vector(const svBitVecVal* i_value, svBitVecVal* result) {
	log_info("dpi_c.compute_bit_vector(): input %u", *i_value);
	*result = transform_svBitVecVal(i_value);
	log_info("dpi_c.compute_bit_vector(): result %u", *result);
}

svBitVecVal get_bit_vector(const svBitVecVal* i_value) {
	svBitVecVal result;
	log_info("dpi_c.get_bit_vector(): input %u", *i_value);
	result = transform_svBitVecVal(i_value);
	log_info("dpi_c.get_bit_vector(): result %u", result);
	return result;
}

void compute_logic(const svLogic i_value, svLogic* result) {
	log_info("dpi_c.compute_logic(): integer value:%d, input %s", (int) i_value, svLogic2String(i_value));
	*result = transform_svLogic(i_value);
	log_info("dpi_c.compute_logic(): result %s <- %s", svLogic2String(*result),
			svLogic2String(i_value));
}

svLogic get_logic(const svLogic i_value) {
	svLogic result = sv_0;
	log_info("dpi_c.get_logic(): input %s", svLogic2String(i_value));
	result = transform_svLogic(i_value);
	log_info("dpi_c.get_logic(): result %s <- %s", svLogic2String(result),
			svLogic2String(i_value));
	return result;
}

void compute_logic_vector(const svLogicVecVal* i_value, svLogicVecVal* result,
		int asize) {
	log_info("dpi_c.compute_logic_vector(): input %s",
			svLogicVecVal2String(i_value, asize));
	int i;
	for (i = 0; i < asize; i++) {
		svLogic bit = svGetBitselLogic(i_value, i);
		bit = transform_svLogic(bit);
		svPutBitselLogic(result, i, bit);
	}
	log_info("dpi_c.compute_logic_vector(): result %s",
			svLogicVecVal2String(result, asize));
}

svLogicVecVal* get_logic_vector(const svLogicVecVal* i_value, int asize) {
	svLogicVecVal* result = malloc(sizeof(svLogicVecVal));
	log_info("dpi_c.get_logic_vector(): input %s",
			svLogicVecVal2String(i_value, asize));
	int i;
	for (i = 0; i < asize; i++) {
		svLogic bit = svGetBitselLogic(i_value, i);
		bit = transform_svLogic(bit);
		svPutBitselLogic(result, i, bit);
	}
	log_info("dpi_c.get_logic_vector(): result %s",
			svLogicVecVal2String(result, asize));
	return result;
}

void compute_reg(const svLogic i_value, svLogic* result) {
	log_info("dpi_c.compute_reg(): input %u", i_value);
	*result = transform_svLogic(i_value);
	log_info("dpi_c.compute_reg(): result %u", *result);
}

svLogic get_reg(const svLogic i_value) {
	svLogic result = sv_0;
	log_info("dpi_c.get_reg(): input %u", i_value);
	result = transform_svLogic(i_value);
	log_info("dpi_c.get_reg(): result %u", result);
	return result;
}

void compute_reg_vector(const svLogicVecVal* i_value, svLogicVecVal* result,
		int asize) {
	log_info("dpi_c.compute_reg_vector(): input %s",
			svLogicVecVal2String(i_value, asize));
	int i;
	for (i = 0; i < asize; i++) {
		svLogic bit = svGetBitselLogic(i_value, i);
		bit = transform_svLogic(bit);
		svPutBitselLogic(result, i, bit);
	}
	log_info("dpi_c.compute_reg_vector(): result %s",
			svLogicVecVal2String(result, asize));
}

svLogicVecVal* get_reg_vector(const svLogicVecVal* i_value, int asize) {
	svLogicVecVal* result = malloc(sizeof(svLogicVecVal));
	log_info("dpi_c.get_reg_vector(): input %s",
			svLogicVecVal2String(i_value, asize));
	int i;
	for (i = 0; i < asize; i++) {
		svLogic bit = svGetBitselLogic(i_value, i);
		bit = transform_svLogic(bit);
		svPutBitselLogic(result, i, bit);
	}
	log_info("dpi_c.get_reg_vector(): result %s",
			svLogicVecVal2String(result, asize));
	return result;
}

void compute_chandle(void** result) {
	int (*pcp)();
	pcp = print_chandle;
	*result = (void*) pcp;
	log_info("dpi_c.compute_chandle() %p ", result);
}

void** get_chandle() {
	int (*pcp)();
	pcp = print_chandle;
	void** result = (void*) pcp;
	log_info("dpi_c.get_chandle() %p ", result);
	return result;
}

void call_chandle(const void* i_value, int* o_value) {
	log_info("dpi_c.call_chandle() %p ", i_value);
	int (*pcp)();
	pcp = i_value;
	*o_value = pcp();
	log_info("dpi_c.call_chandle() returns %0d ", *o_value);
}

void compute_unsized_int_array(const svOpenArrayHandle i_value,	svOpenArrayHandle result) {
	int count = svSize(i_value, 1);
	memcpy((int*) svGetArrayPtr(result), (int*) svGetArrayPtr(i_value),
			svSizeOfArray(i_value));

	while (count--) {
		int* tmp = (int*) svGetArrElemPtr1(result, count);
		*tmp += 3;
	}
}

void compute_unsized_byte_array(const svOpenArrayHandle i_value, svOpenArrayHandle result) {
	int count = svSize(i_value, 1);
	memcpy((char*) svGetArrayPtr(result), (char*) svGetArrayPtr(i_value),
			svSizeOfArray(i_value));

	while (count--) {
		char* tmp = (char*) svGetArrElemPtr1(result, count);
		*tmp += 3;
	}
};

void compute_struct(const dpi_c_ex_s* i_value, dpi_c_ex_s* output) {
	*output = transform_struct(i_value);
}

#endif
