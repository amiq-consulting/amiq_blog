/******************************************************************************
* (C) Copyright 2015 AMIQ Consulting
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
extend sys {
    data : uint;
    keep data <= 10000;
    keep soft data == select { 
        50 : normal(0,     10000*0.001);
        50 : normal(10000, 10000*0.001);
    };
    event data_cvr_e;
    cover data_cvr_e is {
        item data using ranges = {
            range ([0..9],        "", 1);
            range ([10..9990]);
            range ([9991..10000], "", 1);
        };
    };
    run() is also {
        for i from 1 to 100 {
            gen data;
            emit data_cvr_e;
        };
    };
};
'>
