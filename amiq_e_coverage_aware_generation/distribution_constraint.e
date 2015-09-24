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
* PROJECT:     Coverage Aware Generation using e Language Normal Distribution Constraints
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        http://www.amiq.com/consulting/2014/06/10/coverage-aware-generation/
*******************************************************************************/

<'
// Adjust FACTOR to get the slope you are looking for.
// For power-of-2 coverage intervals FACTOR should decrease as (MAX_VAL - MIN_VAL + 1) increases.

import cover_data_macro;

define MAX_POWER_OF_TWO 12;

define MIN_VAL 0;
define MAX_VAL ipow(2, MAX_POWER_OF_TWO) - 1;

// FACTOR determines the shape of the Bell Curve.
define FACTOR  0.15;
// SIGMA is computed by multiplying the data interval size with FACTOR. 
define SIGMA   (MAX_VAL-MIN_VAL+1) * FACTOR;

define MEAN     MIN_VAL;

extend sys  {
   data : uint;
   keep data in [MIN_VAL..MAX_VAL];
   keep soft data == select { 
      //Inside the select brackets you define the weight (100), 
      //the type of distribution (normal), the peak of Bell Curve (MEAN), 
      //and the standard deviation (SIGMA). 
      //Within the standard deviation interval 66% of the values will be generated. 
      100: normal(MEAN, SIGMA);
   };

   event data_cvr_e;
   cover data_cvr_e is {
      cover_data MAX_POWER_OF_TWO
   };
   run() is also {
      for i from 0 to 1000 {
         gen data;
         emit data_cvr_e;
      };
   };
};
'>
