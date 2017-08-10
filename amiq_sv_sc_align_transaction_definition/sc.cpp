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
* PROJECT:     How to Align SystemVerilog-to-SystemC TLM Transactions Definitions
* Description: This is a code snippet from the Blog article mentioned on PROJECT
* Link:        https://www.amiq.com/consulting/2017/09/29/how-to-align-systemverilog-to-systemc-tlm-transactions-definitions/
*******************************************************************************/

#include <netinet/in.h>

#include <sstream>

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

simple_transaction array2transaction(unsigned char *data, unsigned int len) {

  stringstream unpacker(ios::in | ios::out | ios::binary);
  simple_transaction t;

  // Add len bytes to stream
  unpacker.write((char *) data, len);

  unpacker.read((char *) (&t.m_type), sizeof(t.m_type));

  unpacker.read((char *) (&t.m_len), sizeof(t.m_len));
  t.m_len = ntohl(t.m_len);

  int aux;
  for (uint i = 0; i < t.m_len; ++i) {
    unpacker.read((char*) (&aux), sizeof(aux));
    t.m_data.push_back(ntohl(aux));
  }

  return t;
}

void transaction2array(simple_transaction &t, unsigned char *data, unsigned int len) {

  stringstream packer(ios::in | ios::out | ios::binary);
  int aux;

  // Pack back the class
  packer.write((char *) (&t.m_type), sizeof(t.m_type));

  t.m_len = htonl(t.m_len);
  packer.write((char *) (&t.m_len), sizeof(t.m_len));


  for (uint i = 0; i < t.m_data.size(); ++i) {
    aux = htonl(t.m_data[i]);
    packer.write((char *) (&aux), sizeof(aux));
  }

  packer.read((char *) data, len);
}

// Class that connects to SV
class consumer: public sc_module, tlm::tlm_fw_transport_if<tlm::tlm_base_protocol_types> {
public:

  // Target socket
  tlm::tlm_target_socket<32, tlm::tlm_base_protocol_types> sok;

  consumer(sc_module_name nm) :
      sc_module(nm), sok("sok") {
    sok(*this);
  }

  // Handler for new blocking transport
  void b_transport(tlm_generic_payload& gp, sc_time& dt) {

    // Unpack gp into transaction class
    simple_transaction t = array2transaction(gp.get_data_ptr(), gp.get_data_length());

    // Overwrite previous data
    uint len = gp.get_data_length();
    unsigned char *data = gp.get_data_ptr();
    transaction2array(t, data, len);

    wait(5, SC_NS);
  }

  tlm::tlm_sync_enum nb_transport_fw(tlm_generic_payload& trans, tlm::tlm_phase& phase,
      sc_time& delay) {
    return tlm::TLM_COMPLETED;
  }

  virtual bool get_direct_mem_ptr(tlm_generic_payload& trans, tlm::tlm_dmi& dmi_data) {
    return false;
  }

  virtual unsigned int transport_dbg(tlm_generic_payload& trans) {
    return 0;
  }

};

// Top level module
class sc_top: public sc_module {
public:

  consumer cons;

  sc_top(sc_module_name nm) :
      sc_module(nm), cons("cons") {

    std::string full_b_target_socket_name = ML_TLM2_REGISTER_TARGET(cons, tlm_generic_payload, sok,
        32);
  }
};

int sc_main(int argc, char** argv) {

  sc_top top("top");
  sc_start(-1);
  return 0;
}

