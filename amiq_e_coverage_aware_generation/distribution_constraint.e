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