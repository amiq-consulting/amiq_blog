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

// It inherits uvm_object in order to simplify the API (objection's context will always be the fifo_protection)
class fifo_protection extends uvm_object;
   // singleton instance
   protected static fifo_protection m_inst;
   typedef uvm_object_registry#(fifo_protection, "fifo_protection") type_id;

   // list of objections: one for each FIFO
   local uvm_objection objs[fifo_t];

   // list of fifo limits
   local int objs_limit[fifo_t];

   // enable flag that allows us to enable/disable fifo protections
   local bit objs_en[fifo_t];

   // constructor
   function new(string name="fifo_protection");
      super.new(name);
   endfunction

   /**
    * Creates the singleton instance
    * @return Returns the singleton instance
    */
   static function fifo_protection get();
      if(m_inst == null)
         m_inst = fifo_protection::type_id::create("fifo_protection");
      return m_inst;
   endfunction

   // implementation of the get_type_name
   virtual function string get_type_name ();
      return "fifo_protection";
   endfunction

   // override of the create function to create the fifo_table instance
   function uvm_object create (string name="");
      fifo_protection tmp = new(name);
      return tmp;
   endfunction

   /* ------ objection-related API ------ */

   /**
    * Initialize the protection for a given FIFO
    * @param kind - the FIFO kind
    * @param limit - the count of available resources/keys
    * @param en - enable flag value
    */
   function void init_protection(fifo_t kind, int limit, bit en);
      objs[kind] = new($sformatf("obj_%s", kind.name()));
      objs_limit[kind] = limit;
      objs_en[kind] = en;
   endfunction

   /**
    * Enables/disables the given FIFO protection
    * @param kind - the FIFO kind
    * @param en - enable flag value
    */
   function void set_enable(fifo_t kind, bit en);
      objs_en[kind] = en;
   endfunction

   /**
    * Returns the enabled flag for a given FIFO protection
    * @param kind - the FIFO kind
    * @return the value of enable flag
    */
   function bit is_enabled(fifo_t kind);
      return objs_en[kind];
   endfunction

   /**
    * It raises the objection associated with kind
    * This is a blocking task.
    * @param kind - identifies the FIFO for which one wants to raise the objection
    * @param count - the count to be "raised"
    */
   task lock(fifo_t kind, int count=1);
      if(!objs_en[kind])
         `uvm_warning("FIFO_PROTECTION_LOCK_WRN", $sformatf("The objection %s is not enabled.", kind.name()))
      wait_for_resources(kind, count);
      objs[kind].raise_objection(this, "", count);
   endtask

   /**
    * It drops the objection associated with kind
    * @param kind - identifies the FIFO for which one wants to drop the objection
    * @param count - the count to be "dropped"
    */
   function void free(fifo_t kind, int count=1);
      if(!objs_en[kind])
         `uvm_warning("FIFO_PROTECTION_FREE_WRN", $sformatf("The objection %s is not enabled.", kind.name()))
      objs[kind].drop_objection(this, "", count);
   endfunction

   /**
    * It returns the objection count for a given objection
    * @param kind -
    * @return the objection count of fifo kind
    */
   function int get_resource_count(fifo_t kind);
      if (!objs_en[kind])
         `uvm_warning("FIFO_PROTECTION_GET_RESOURCE_COUNT_WRN", $sformatf("The objection %s is not enabled.", kind.name()))
      return objs[kind].get_objection_count(this);
   endfunction

   /**
    * It waits for an event on a given objection if the protection is enabled for the given FIFO
    * This is a blocking task.
    * @param kind - identifies the FIFO for which one wants to wait for the given event
    * @param objt_event - @see uvm_objection_event
    */
   task wait_for_event(fifo_t kind, uvm_objection_event objt_event);
      if (!objs_en[kind])
         `uvm_warning("FIFO_PROTECTION_WAIT_FOR_EVENT_WRN", $sformatf("The objection %s is not enabled.", kind.name()))
      objs[kind].wait_for(objt_event, this);
   endtask

   /**
    * It waits for an objection to allow the count resources that are required
    * This is a blocking task.
    * @param kind - the FIFO kind
    * @param count - the number of resources that should be available
    */
   task wait_for_resources(fifo_t kind, int count=0);
      if (!objs_en[kind])
         `uvm_warning("FIFO_PROTECTION_WAIT_FOR_RESOURCES_WRN", $sformatf("The objection %s is not enabled.", kind.name()))
      while ((objs_limit[kind] - get_resource_count(kind)) < count)
         objs[kind].wait_for(UVM_DROPPED, this);
   endtask

   /**
    * Checks if all objections have been dropped to 0.
    * @return 1-if all objections were dropped, 0 - otherwise
    */
   function bit are_all_free();
      fifo_t ft = ft.first();
      are_all_free = 1;
      forever begin
         are_all_free &= (get_resource_count(ft) == 0);
         if( ft == ft.last )
            break;
         ft = ft.next;
      end
   endfunction

   /**
    * Dumps the status of all objections in fifo_protection. It is useful for debug purposes.
    * @return a string that presents the number of available resources for each objection
    */
   function string dump();
      fifo_t ft = ft.first();
      dump = "";
      forever begin
         dump=$sformatf("%s%s=%d/%d, ", dump, ft.name(), (objs_limit[ft]-get_resource_count(ft)), objs_limit[ft]);
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

