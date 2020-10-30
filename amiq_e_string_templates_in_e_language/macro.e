/******************************************************************************
* (C) Copyright 2020 AMIQ Consulting
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
* PROJECT:     String Templates in E-Language
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        https://www.amiq.com/consulting/2020/12/04/string-templates-in-e-language/
*******************************************************************************/
<'
define <fieldDefinition'statement> "declare <unitName'name> fields \[<item'name>,...\] as <t'name>"  as computed {
  var code : list of string;
  var unitName : string = <unitName'name>;
  var tName : string = <t'name>;
  var fields : list of string = <item'names>;
  for each(field) in fields {
    code.add(<<#:
      extend <(unitName)> {
        <(field)> : <(tName)>;
      };
    end #);
  };
  return str_join(code, "");
};
'>
