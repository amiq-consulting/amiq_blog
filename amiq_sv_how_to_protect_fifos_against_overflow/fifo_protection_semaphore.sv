/******************************************************************************
* (C) Copyright 2018 AMIQ Consulting
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
* PROJECT:     How To Protect FIFOs Against Overflow – Part 1
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        https://www.amiq.com/consulting/2018/07/25/how-to-protect-fifos-against-overflow-part-1/
*******************************************************************************/

import uvm_pkg::*;
`include "uvm_macros.svh"

// this enumeration identifies a FIFO
typedef enum {FIFO_MSGS, FIFO_RESP} fifo_t;

// the singleton class that contains semaphores
class fifo_protection;
   // singleton instance
   static local fifo_protection m_inst;

   // list of semaphores: one for each FIFO
   semaphore semaphores[fifo_t];
   
   // enable flag that allows us to enable/disable fifo protections
   bit       sm_en[fifo_t];
   
   // list of fifo limits
   int       sm_limit[fifo_t];

   // Constructor
   protected function new();
   endfunction

   /**
    * Creates the singleton instance
    * @return Returns the fifo_protection instance 
    */
   static function fifo_protection get();
      if(m_inst == null)
         m_inst = new();
      return m_inst;
   endfunction

   /* ------ semaphore-related API ------ */

   /**
    * Initialize the protection for a given FIFO
    * @param kind - the FIFO kind
    * @param limit - the count of available resources/keys
    * @param en - enable flag value
    * @see IEEE Std 1800-2012, 15.3 Semaphores
    */
   function void init_protection(fifo_t kind, int limit, bit en);
      semaphores[kind] = new(limit);
      sm_limit[kind] = limit;
      sm_en[kind] = en;
   endfunction

   /**
    * Enables/disables the given FIFO semaphore
    * @param kind - the FIFO kind
    * @param en - enable flag value
    */
   function void set_enable(fifo_t kind, bit en);
      sm_en[kind] = en;
   endfunction

   /**
    * Returns the enabled flag for a given FIFO protection
    * @param kind - the FIFO kind
    * @return the value of enable flag
    */
   function bit is_enabled(fifo_t kind);
      return sm_en[kind];
   endfunction

   /**
    * Wrapper method over semaphore.put()
    * @param kind - the FIFO kind
    * @param nof_keys - the number of keys to returned
    * @see IEEE Std 1800-2012, 15.3 Semaphores 
    */
   function void free(fifo_t kind, int nof_keys);
      if (!sm_en[kind])
         `uvm_warning("FIFO_PROTECTION_FREE_WRN", $sformatf("The semaphore %s is not enabled.", kind.name()))
      semaphores[kind].put(nof_keys);
   endfunction

   /**
    * Wrapper task over semaphore.get(). 
    * User should call this function only if the semaphore for the kind is enabled. Otherwise use try_get()
    * @param kind - the FIFO kind
    * @param nof_keys - number of keys to be locked
    * @see IEEE Std 1800-2012, 15.3 Semaphores
    */
   task lock(fifo_t kind, int nof_keys);
      if (!sm_en[kind])
         `uvm_warning("FIFO_PROTECTION_LOCK_WRN", $sformatf("The semaphore %s is not enabled.", kind.name()))
      semaphores[kind].get(nof_keys);
   endtask

   /**
    * Wrapper method over semaphore.try_get()
    * @param kind - the FIFO kind
    * @param nof_keys -number of keys to be locked
    * @return 0 - if there are not enough keys to be locked, nof_keys - otherwise 
    * @see IEEE Std 1800-2012, 15.3 Semaphores
    */
   function int try_lock(fifo_t kind, int nof_keys);
      if (!sm_en[kind])
         `uvm_warning("FIFO_PROTECTION_TRY_LOCK_WRN", $sformatf("The semaphore %s is not enabled.", kind.name()))
      return semaphores[kind].try_get(nof_keys);
   endfunction


   /**
    * Computes the number of available slots by successive tries, since the standard does not provide a query method for the available keys).
    * @param kind - the FIFO kind
    * @return the number of available keys in a semaphore
    */
   function int get_resource_count(fifo_t kind);
      get_resource_count = 0;
      for (int i=1; i<=sm_limit[kind]; i++) begin
         if (semaphores[kind].try_get(i) == 0)
            break;
         get_resource_count = i;
         semaphores[kind].put(i);
      end
   endfunction
   
   /**
    * Checks if all semaphores have been released.
    * @return 1-if all semaphores keys were released, 0 - otherwise
    */
   function bit are_all_free();
      int is_free[$];
      fifo_t ft = ft.first();
      are_all_free = 1;
      forever begin
         are_all_free &= (get_resource_count(ft) == sm_limit[ft]);
         if( ft == ft.last )
            break;
         ft = ft.next;
      end
   endfunction

   /**
    * Dumps the status of all semaphores in fifo_protection. It is useful for debug purposes.
    * @return a string that presents the number of available keys for each semaphore 
    */
   function string dump();
      fifo_t ft = ft.first();
      dump = "";
      forever begin
         dump=$sformatf("%s%s=%d/%d, ", dump, ft.name(), get_resource_count(ft), sm_limit[ft]);
         if( ft == ft.last )
            break;
         ft = ft.next;
      end
      dump=$sformatf("fifo_protection available resources: %s", dump);
   endfunction  

endclass

/**
 * Create the fifo_protection global variable instance
 * FIFO protection initialization is done in the build_phase() of the verification environment
 */
fifo_protection fifo_prot_ston = fifo_protection::get();


