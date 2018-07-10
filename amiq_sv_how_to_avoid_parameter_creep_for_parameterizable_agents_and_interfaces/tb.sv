/******************************************************************************
* (C) Copyright 2017 AMIQ Consulting
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
* PROJECT:     How to Avoid Parameter Creep for Parameterizable Agents and Interfaces
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        http://www.amiq.com/consulting/<TO BE UPDATED>
*******************************************************************************/

`include "uvm_macros.svh"
import uvm_pkg::*;

//------------------------------------------------------------------------------
// Defines
//------------------------------------------------------------------------------

typedef struct packed {
   byte unsigned addr_width;
   byte unsigned data_width;
} layer1_t;

typedef struct packed {
   int unsigned payload_length;
} layer2_t;

typedef struct packed {
   layer1_t layer1;
   layer2_t layer2;
} my_config_t;

parameter my_config_t cfg_a = '{ '{ addr_width:  8, data_width: 4 }, '{ payload_length: 2 } };
parameter my_config_t cfg_b = '{ '{ addr_width: 16, data_width: 8 }, '{ payload_length: 4 } };
parameter my_config_t cfg_c = '{ '{ addr_width:  8, data_width: 8 }, '{ payload_length: 3 } };

//------------------------------------------------------------------------------
// Interface
//------------------------------------------------------------------------------

interface my_if#(parameter my_config_t cfg = cfg_a) (
   input logic clk
);
   timeunit 1ns/1ps;

   logic                             valid;
   logic [cfg.layer1.addr_width-1:0] addr;
   logic [cfg.layer1.data_width-1:0] data;
endinterface

//------------------------------------------------------------------------------
// Data
//------------------------------------------------------------------------------

class my_packet#(parameter my_config_t cfg = cfg_a) extends uvm_sequence_item;
   `uvm_object_param_utils(my_packet#(cfg))

   rand bit [cfg.layer1.addr_width-1:0] addr;
   rand bit [cfg.layer1.data_width-1:0] payload[cfg.layer2.payload_length];

   function new(string name = "");
      super.new(name);
   endfunction
endclass

//------------------------------------------------------------------------------
// Driver
//------------------------------------------------------------------------------

class my_driver#(parameter my_config_t cfg = cfg_a) extends uvm_driver#(my_packet#(cfg));
   `uvm_component_param_utils(my_driver#(cfg))

   virtual my_if#(cfg) vif;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);

      vif.valid = '0;
      vif.addr  = '0;
      vif.data  = '0;

      @(posedge vif.clk) forever begin
         my_packet#(cfg) packet;

         seq_item_port.get_next_item(packet);

         vif.valid = 1;
         vif.addr  = packet.addr;
         for (int i = 0; i < cfg.layer2.payload_length; i++) begin
            vif.data = packet.payload[i];
            @(posedge vif.clk);
         end
         vif.valid = 0;

         seq_item_port.item_done();
      end
   endtask
endclass

//------------------------------------------------------------------------------
// Monitor
//------------------------------------------------------------------------------

class my_monitor#(parameter my_config_t cfg = cfg_a) extends uvm_monitor;
   `uvm_component_param_utils(my_monitor#(cfg))

   virtual my_if#(cfg) vif;

   uvm_analysis_port#(my_packet#(cfg)) analysis_port;

   int unsigned agent_id = '1;

   function new(string name, uvm_component parent);
      super.new(name, parent);

      this.analysis_port = new("analysis_port", this);
   endfunction

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);

      @(posedge vif.clk) forever begin
         my_packet#(cfg) packet = my_packet#(cfg)::type_id::create("packet", this);

         while (!vif.valid) @(posedge vif.clk);
         packet.addr = vif.addr;

         for (int i = 0; i < cfg.layer2.payload_length; i++) begin
            packet.payload[i] = vif.data;
            @(posedge vif.clk);

            if (i < cfg.layer2.payload_length - 1)
                while (!vif.valid) @(posedge vif.clk);
         end

         begin
            string s;
            s = { s, $sformatf("addr     = %h\n", packet.addr) };
            for (int i = 0; i < cfg.layer2.payload_length; i++)
               s = { s, $sformatf("data[%2d] = %h\n", i, packet.payload[i]) };
            $display("Detected new packet on interface #%0d:\n%s\n", agent_id, s);
         end

         analysis_port.write(packet);
      end
   endtask
endclass

//------------------------------------------------------------------------------
// Sequencer
//------------------------------------------------------------------------------

class my_sequencer#(parameter my_config_t cfg = cfg_a) extends uvm_sequencer#(my_packet#(cfg));
   `uvm_component_param_utils(my_sequencer#(cfg))

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction
endclass

//------------------------------------------------------------------------------
// Sequence library
//------------------------------------------------------------------------------

class my_sequence#(parameter my_config_t cfg = cfg_a) extends uvm_sequence#(my_packet#(cfg));
   `uvm_object_param_utils(my_sequence#(cfg))

   function new(string name = "my_sequence");
      super.new(name);
   endfunction

   virtual task body();
      my_packet#(cfg) packet = my_packet#(cfg)::type_id::create("packet");

      if (!packet.randomize())
         `uvm_error(get_name(), "Randomization error!")

      start_item (packet);
      finish_item(packet);
   endtask
endclass

//------------------------------------------------------------------------------
// Agent
//------------------------------------------------------------------------------

class my_agent#(parameter my_config_t cfg = cfg_a) extends uvm_agent;
   `uvm_component_param_utils(my_agent#(cfg))

   virtual my_if#(cfg) vif;

   my_driver     #(cfg) driver;
   my_monitor    #(cfg) monitor;
   my_sequencer  #(cfg) sequencer;

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      if (!uvm_config_db#(virtual my_if#(cfg))::get(this, "", "if", vif))
         `uvm_fatal(get_name(), "Could not get the virtual interface handle from the config database.")

      driver    = my_driver   #(cfg)::type_id::create("driver"   , this);
      monitor   = my_monitor  #(cfg)::type_id::create("monitor"  , this);
      sequencer = my_sequencer#(cfg)::type_id::create("sequencer", this);
   endfunction

   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      driver .vif = vif ;
      monitor.vif = vif;

      driver.seq_item_port.connect(sequencer.seq_item_export);
   endfunction
endclass

//------------------------------------------------------------------------------
// Test
//------------------------------------------------------------------------------

class my_test extends uvm_test;
   `uvm_component_utils(my_test)

   my_agent#(cfg_a) agent_a;
   my_agent#(cfg_b) agent_b;
   my_agent#(cfg_c) agent_cs[4];

   function new(string name = "my_test", uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      agent_a = my_agent#(cfg_a)::type_id::create("agent_a", this);
      agent_b = my_agent#(cfg_b)::type_id::create("agent_b", this);

      foreach (agent_cs[i])
         agent_cs[i] = my_agent#(cfg_c)::type_id::create($sformatf("agent_c_%0d", i), this);
   endfunction

   virtual function void end_of_elaboration_phase(uvm_phase phase);
      uvm_phase run_phase = uvm_run_phase::get();
      run_phase.phase_done.set_drain_time(this, 100us);

      agent_a.monitor.agent_id = 0;
      agent_b.monitor.agent_id = 1;
      foreach (agent_cs[i])
         agent_cs[i].monitor.agent_id = i + 2;
   endfunction

   virtual task run_phase(uvm_phase phase);
      super.run_phase(phase);

      phase.raise_objection(this);

      fork
         repeat (3) begin
            my_sequence#(cfg_a) seq_a = my_sequence#(cfg_a)::type_id::create("seq_a");
            seq_a.start(agent_a.sequencer);
         end

         repeat (3) begin
            my_sequence#(cfg_b) seq_b = my_sequence#(cfg_b)::type_id::create("seq_b");
            seq_b.start(agent_b.sequencer);
         end

         begin
            foreach (agent_cs[i])
               fork
                  automatic int unsigned agent_id = i;

                  repeat (3) begin
                     my_sequence#(cfg_c) seq_c = my_sequence#(cfg_c)::type_id::create("seq_c");
                     seq_c.start(agent_cs[agent_id].sequencer);
                  end
               join_none

            wait fork;
         end
      join

      phase.drop_objection(this);
   endtask
endclass

//------------------------------------------------------------------------------
// Top
//------------------------------------------------------------------------------

module my_tb;
   timeunit 1ns/1ps;

   bit clk = 0;
   initial forever #10 clk = ~clk;

   my_if#(cfg_a) if_a    (clk);
   my_if#(cfg_b) if_b    (clk);
   my_if#(cfg_c) if_cs[4](clk);

   initial begin
      static virtual my_if#(cfg_c) vif_cs[4] = if_cs;

      uvm_config_db#(virtual my_if#(cfg_a))::set(null, "*agent_a*", "if", if_a);
      uvm_config_db#(virtual my_if#(cfg_b))::set(null, "*agent_b*", "if", if_b);
      foreach (vif_cs[i])
         uvm_config_db#(virtual my_if#(cfg_c))::set(null, $sformatf("*agent_c_%0d*", i), "if", vif_cs[i]);

      run_test();
   end
endmodule
