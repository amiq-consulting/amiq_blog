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
* PROJECT:     How To Export Functional Coverage from SystemC to SystemVerilog
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        https://www.amiq.com/consulting/2017/08/18/how-to-export-functional-coverage-from-systemc-to-systemverilog/
*******************************************************************************/

#include <netinet/in.h>

#include <sstream>
#include <cstdlib>
#include <ctime>

#include "uvm_ml.h"
#include "ml_tlm2.h"

using namespace uvm;
using namespace uvm_ml;

// Class to store transactions
class simple_transaction {
public:
  unsigned char m_type;
  uint32_t m_len;
  std::vector<int> m_data;
};

// Prints char array
void print_arr(unsigned char* st, uint len) {

  std::cout << "STREAM: ";
  for (uint i = 0; i < len; ++i)
    std::cout << std::hex << (unsigned int) st[i] << " ";

  std::cout << endl;
}

// Class that connects to SV
class producer: public sc_module, public tlm::tlm_bw_transport_if<tlm::tlm_base_protocol_types> {
public:

  // Target socket
  tlm::tlm_initiator_socket<32, tlm::tlm_base_protocol_types> sok;

  producer(sc_module_name nm) :
      sc_module(nm), sok("sok") {
    sok(*this);
  }

  tlm::tlm_sync_enum nb_transport_bw(tlm_generic_payload& trans, tlm::tlm_phase& phase, sc_time& delay) {
    return tlm::TLM_ACCEPTED;
  }

  void invalidate_direct_mem_ptr(sc_dt::uint64 start_range, sc_dt::uint64 end_range) {
  }
  ;

  // Generate random transactions and pack them
  void create_gp(tlm_generic_payload& gp) {

    simple_transaction t;
    int aux;
    uint len = 0;

    t.m_type = rand() % 5;
    t.m_len = rand() % 11;

    for (uint i=0; i < t.m_len; ++i)
      t.m_data.push_back(rand());

    stringstream packer(ios::in | ios::out | ios::binary);

    // Pack the class
    packer.write((char *)(&t.m_type), sizeof(t.m_type));
    len += sizeof(t.m_type);

    t.m_len = htonl(t.m_len);
    packer.write((char *)(&t.m_len), sizeof(t.m_len));
    len += sizeof(t.m_len);

    for (uint i = 0; i < t.m_data.size(); ++i) {
      aux = htonl(t.m_data[i]);
      packer.write((char *)(&aux), sizeof(aux));
      len += sizeof(aux);
    }

    unsigned char *data = new unsigned char[len];
    packer.read((char *)data, len);

    gp.set_data_ptr(data);
    gp.set_data_length(len);

    wait(5, SC_NS);
  }

};

// Top level module
class sc_top: public sc_module {
public:

  producer prod;

  SC_HAS_PROCESS(sc_top);

  sc_top(sc_module_name nm) :
      sc_module(nm), prod("prod") {

    ML_TLM2_REGISTER_INITIATOR(prod, tlm_generic_payload, sok, 32);
    SC_THREAD(run_test);

  }

  // Generates 10 transaction and sends them to SV
  void run_test() {

    tlm_generic_payload gp;
    sc_time time;

    for (int i = 0; i < 10; ++i) {
      prod.create_gp(gp);
      prod.sok->b_transport(gp, time);
    }

  }

};

int sc_main(int argc, char** argv) {

  srand(time(NULL));

  sc_top top("top");
  sc_start(-1);

  return 0;
}

