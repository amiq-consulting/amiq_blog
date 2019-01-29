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
* Link:		   https://www.amiq.com/consulting/2019/01/30/how-to-map-systemverilog-data-types-to-c-using-dpi-c/
*******************************************************************************/

#ifndef __dpi_c_dbg_h
#define __dpi_c_dbg_h

#include <stdio.h>
#include <errno.h>
#include <string.h>
#include "svdpi.h"

typedef struct dpi_c_ex_s {
	char aChar;
	int anInt;
	svBit aBit;
	long int aLongInt;
	svBitVecVal aBitVector;
} dpi_c_ex_s;

// print macro
#define log_info(M, ...) \
	fprintf(stderr, "[INFO](%s:%d:) " M "\n", __FILE__, __LINE__, ##__VA_ARGS__)

// convert svLogic to string
char* svLogic2String(const svLogic svl) {
	switch (svl) {
	case sv_0:
		return "0";
	case sv_1:
		return "1";
	case sv_z:
		return "Z";
	case sv_x:
		return "X";
	}
	return "0";
}

// convert svLogicVecVal (e.g. logic[4:0]) to string
char* svLogicVecVal2String(const svLogicVecVal* svlvv, int asize) {
	char* result = "'b";
	int i;
	for (i = asize - 1; i >= 0; i--)
		asprintf(&result, "%s%s", result,
				svLogic2String(svGetBitselLogic(svlvv, i)));
	return result;
}

svLogic transform_svLogic(const svLogic in) {
	switch (in%4) {
	case sv_0:
		return sv_1;
	case sv_1:
		return sv_x;
	case sv_z:
		return sv_0;
	case sv_x:
		return sv_z;
	}
	return in;
}

svBit transform_svBit(const svBit in) {
	return !in;
}

int transform_int(const int in) {
	return 23*in;
}

short int transform_short_int(const short int in) {
	return 65535 - in;
}

char transform_char(const char in) {
	log_info("transform_char in: %d", in);
	return 255 - in;
}

long int transform_long_int(const long int in) {
	return 123 * in;
}

double transform_double(const double in){
	return in * 3;
}

svBitVecVal transform_svBitVecVal(const svBitVecVal* in) {
	return ((*in) << 3) + 2;
}

int print_chandle() {
	log_info("dpi_c.print_chandle()");
	return 10;
}


dpi_c_ex_s transform_struct(const dpi_c_ex_s* in) {
	dpi_c_ex_s* output = malloc(sizeof(dpi_c_ex_s));
	memcpy((dpi_c_ex_s*) output, (dpi_c_ex_s*) in, sizeof(dpi_c_ex_s));

	log_info("dpi_c: i_value.aBit=%x", (int) in->aBit);
	log_info("dpi_c: i_value.aChar=%x", (int) in->aChar);
	log_info("dpi_c: i_value.anInt=%x", (int) in->anInt);
	log_info("dpi_c: i_value.aLongInt=%lx", in->aLongInt);
	log_info("dpi_c.i_value.ABitVector=%u", in->aBitVector);

	output->aBit = transform_svBit(output->aBit);
	output->aChar = transform_char(output->aChar);
	output->anInt = transform_int(output->anInt);
	output->aLongInt = transform_long_int(output->aLongInt);
	output->aBitVector = transform_svBitVecVal(&(output->aBitVector));

	log_info("dpi_c: output.aBit=%x", (int) output->aBit);
	log_info("dpi_c: output.aChar=%x", (int) output->aChar);
	log_info("dpi_c: output.anInt=%x", (int) output->anInt);
	log_info("dpi_c: output.aLongInt=%lx", output->aLongInt);
	log_info("dpi_c: output.ABitVector=%u", output->aBitVector);

	return *output;
}

#endif
