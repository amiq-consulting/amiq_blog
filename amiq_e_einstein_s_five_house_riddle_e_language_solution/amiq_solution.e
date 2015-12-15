
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
* PROJECT:     Einsten’s Five House Riddle – e-language Solution
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        http://www.amiq.com/consulting/2015/11/27/einstens-five-house-riddle-e-language-solution/
*******************************************************************************/

<'
type nationality_t : [englishman, swede, dane, norwegian, german];
type house_color_t : [red, green, yellow, blue, white];
type cigarette_t : [dunhill, blend, blue_masters, prince, pall_mall];
type pet_t : [dog, bird, cat, horse, fish];
type drink_t : [tea, coffee, milk, bier, water];

define NUM_OF_MEN 5;

struct riddle_s {
  nationality[NUM_OF_MEN] : list of nationality_t;
  house_color[NUM_OF_MEN] : list of house_color_t;
  cigar[NUM_OF_MEN] : list of cigarette_t;
  pet[NUM_OF_MEN] : list of pet_t;
  drink[NUM_OF_MEN] : list of drink_t;

  keep nationality.is_a_permutation(all_values(nationality_t));
  keep house_color.is_a_permutation(all_values(house_color_t));
  keep pet.is_a_permutation(all_values(pet_t));
  keep cigar.is_a_permutation(all_values(cigarette_t));
  keep drink.is_a_permutation(all_values(drink_t));
};

extend riddle_s {
  keep for each using index (id) in nationality{
    it == englishman => house_color[id] == red; //#1
    it == swede => pet[id] == dog;//#2
    it == dane => drink[id] == tea;//#3
    it == norwegian => id == 0;//#9
    it == german => cigar[id] == prince;//#13
    id in [1..NUM_OF_MEN-2] and it == norwegian => house_color[id+1] == blue or house_color[id-1] == blue;//#14
    id == 0 and it == norwegian => house_color[id+1] == blue;//#14
    id == NUM_OF_MEN-1 and it == norwegian => house_color[id-1] == blue;//#14
  };

  keep for each using index (id) in house_color {
    it == green => id != NUM_OF_MEN-1;//#4
    it == green => house_color[id+1]== white;//#4
    it == green => drink[id] == coffee;//#5
    it == yellow => cigar[id] == dunhill;//#7
  };

  keep for each using index (id) in cigar {
    it == pall_mall => pet[id] == bird;//#6
    id in [1..NUM_OF_MEN-2] and it == blend => pet[id+1] == cat or pet[id-1] == cat;//#10
    id == 0 and it == blend => pet[id+1] == cat;//#10
    id == NUM_OF_MEN-1 and it == blend => pet[id-1] == cat;//#10
    it == blue_masters => drink[id] == bier;//#11
    id in [1..NUM_OF_MEN-2] and it == dunhill => pet[id+1] == horse or pet[id-1] == horse;//#12
    id == 0 and it == dunhill => pet[id+1] == horse;//#12
    id == NUM_OF_MEN-1 and it == dunhill => pet[id-1] == horse;//#12
    id in [1..NUM_OF_MEN-2] and it == blend => drink[id+1] == water or drink[id-1] == water;//#15
    id == 0 and it == blend => drink[id+1] == water;//#15
    id == NUM_OF_MEN-1 and it == blend => drink[id-1] == water;//#15
  };

  keep for each using index (id) in drink {
    it == milk => id == NUM_OF_MEN/2;//#8
  };
};

extend sys {
  run() is also {
    var solution : riddle_s;
    var position : int;
    gen solution;
    position = solution.pet.first_index(it == fish);
    messagef(LOW, "Solution is: %s lives in the %s house #%0d, keeps a %s, drinks %s and smokes %s\n",
      solution.nationality[position], solution.house_color[position], position, solution.pet[position], solution.drink[position], solution.cigar[position]);
  };
};
'>
