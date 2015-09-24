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
data : uint (bits : 12);
keep soft data == select {
    100 : normal(0, ipow(2, 12)*0.15);
};
'>
