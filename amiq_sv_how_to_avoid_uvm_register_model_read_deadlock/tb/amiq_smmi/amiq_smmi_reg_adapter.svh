// TODO add comment
class amiq_smmi_reg_adapter extends uvm_reg_adapter;
	`uvm_object_utils( amiq_smmi_reg_adapter )

	function new( string name = "amiq_smmi_reg_adapter" );
		super.new( name );
		provides_responses = 1;
	endfunction: new

	virtual function uvm_sequence_item reg2bus( const ref uvm_reg_bus_op rw );
		amiq_smmi_item smmi_item;
		smmi_item = amiq_smmi_item::type_id::create("smmi_item");

		smmi_item.addr = rw.addr[31:0];
		smmi_item.rnw = rw.kind == UVM_READ;

		if(rw.kind == UVM_WRITE)
			smmi_item.wdata = rw.data[31:0];

		return smmi_item;

	endfunction
	virtual function void bus2reg( uvm_sequence_item bus_item, ref uvm_reg_bus_op rw );
		amiq_smmi_item smmi_item;

		if(!$cast(smmi_item, bus_item))
			`uvm_error("REG_ADAPTER_ERR",$sformatf("Cannot cast item type %0s to amiq_smmi_item", bus_item.get_type_name()))

		rw.addr = smmi_item.addr;
		rw.kind = smmi_item.rnw == 1 ? UVM_READ : UVM_WRITE;
		rw.data = smmi_item.rnw == 1 ? smmi_item.rdata : smmi_item.wdata;
		rw.status = smmi_item.rsp_status == 0 ? UVM_IS_OK : UVM_NOT_OK;

	endfunction
endclass: amiq_smmi_reg_adapter