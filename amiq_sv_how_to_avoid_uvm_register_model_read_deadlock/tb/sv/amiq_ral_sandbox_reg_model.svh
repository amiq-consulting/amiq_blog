
class amiq_simple_reg_a extends uvm_reg;
	`uvm_object_utils( amiq_simple_reg_a )

	rand uvm_reg_field reg_a_field_0;
	rand uvm_reg_field reg_a_field_1;

	function new( string name = "amiq_simple_reg_a" );
		super.new( .name( name ), .n_bits( 8 ), .has_coverage( UVM_NO_COVERAGE ) );
	endfunction: new

	virtual function void build();
		reg_a_field_0 = uvm_reg_field::type_id::create( "reg_a_field_0" );
		reg_a_field_0.configure( .parent                 ( this ),
			.size                   ( 3    ),
			.lsb_pos                ( 0    ),
			.access                 ( "RW" ),
			.volatile               ( 0    ),
			.reset                  ( 0    ),
			.has_reset              ( 1    ),
			.is_rand                ( 1    ),
			.individually_accessible( 0    ) );

		reg_a_field_1 = uvm_reg_field::type_id::create( "reg_a_field_1" );
		reg_a_field_1.configure( .parent                 ( this ),
			.size                   ( 2    ),
			.lsb_pos                ( 3    ),
			.access                 ( "RW" ),
			.volatile               ( 0    ),
			.reset                  ( 0    ),
			.has_reset              ( 1    ),
			.is_rand                ( 1    ),
			.individually_accessible( 0    ) );

	endfunction: build
endclass: amiq_simple_reg_a

class amiq_simple_reg_b extends uvm_reg;
	`uvm_object_utils( amiq_simple_reg_b )

	rand uvm_reg_field reg_b_field_0;
	rand uvm_reg_field reg_b_field_1;

	function new( string name = "amiq_simple_reg_b" );
		super.new( .name( name ), .n_bits( 8 ), .has_coverage( UVM_NO_COVERAGE ) );
	endfunction: new

	virtual function void build();
		reg_b_field_0 = uvm_reg_field::type_id::create( "reg_b_field_0" );
		reg_b_field_0.configure( .parent                 ( this ),
			.size                   ( 3    ),
			.lsb_pos                ( 0    ),
			.access                 ( "RW" ),
			.volatile               ( 0    ),
			.reset                  ( 0    ),
			.has_reset              ( 1    ),
			.is_rand                ( 1    ),
			.individually_accessible( 0    ) );

		reg_b_field_1 = uvm_reg_field::type_id::create( "reg_b_field_1" );
		reg_b_field_1.configure( .parent                 ( this ),
			.size                   ( 2    ),
			.lsb_pos                ( 3    ),
			.access                 ( "RW" ),
			.volatile               ( 0    ),
			.reset                  ( 0    ),
			.has_reset              ( 1    ),
			.is_rand                ( 1    ),
			.individually_accessible( 0    ) );

	endfunction: build
endclass: amiq_simple_reg_b

class amiq_simple_reg_c extends uvm_reg;
	`uvm_object_utils( amiq_simple_reg_c )

	rand uvm_reg_field reg_c_field_0;
	rand uvm_reg_field reg_c_field_1;

	function new( string name = "amiq_simple_reg_c" );
		super.new( .name( name ), .n_bits( 8 ), .has_coverage( UVM_NO_COVERAGE ) );
	endfunction: new

	virtual function void build();
		reg_c_field_0 = uvm_reg_field::type_id::create( "reg_c_field_0" );
		reg_c_field_0.configure( .parent                 ( this ),
			.size                   ( 3    ),
			.lsb_pos                ( 0    ),
			.access                 ( "RW" ),
			.volatile               ( 0    ),
			.reset                  ( 0    ),
			.has_reset              ( 1    ),
			.is_rand                ( 1    ),
			.individually_accessible( 0    ) );

		reg_c_field_1 = uvm_reg_field::type_id::create( "reg_c_field_1" );
		reg_c_field_1.configure( .parent                 ( this ),
			.size                   ( 2    ),
			.lsb_pos                ( 3    ),
			.access                 ( "RW" ),
			.volatile               ( 0    ),
			.reset                  ( 0    ),
			.has_reset              ( 1    ),
			.is_rand                ( 1    ),
			.individually_accessible( 0    ) );

	endfunction: build
endclass: amiq_simple_reg_c

class amiq_simple_reg_d extends uvm_reg;
	`uvm_object_utils( amiq_simple_reg_d )

	rand uvm_reg_field reg_d_field_0;
	rand uvm_reg_field reg_d_field_1;

	function new( string name = "amiq_simple_reg_d" );
		super.new( .name( name ), .n_bits( 8 ), .has_coverage( UVM_NO_COVERAGE ) );
	endfunction: new

	virtual function void build();
		reg_d_field_0 = uvm_reg_field::type_id::create( "reg_d_field_0" );
		reg_d_field_0.configure( .parent                 ( this ),
			.size                   ( 3    ),
			.lsb_pos                ( 0    ),
			.access                 ( "RW" ),
			.volatile               ( 0    ),
			.reset                  ( 0    ),
			.has_reset              ( 1    ),
			.is_rand                ( 1    ),
			.individually_accessible( 0    ) );

		reg_d_field_1 = uvm_reg_field::type_id::create( "reg_d_field_1" );
		reg_d_field_1.configure( .parent                 ( this ),
			.size                   ( 2    ),
			.lsb_pos                ( 3    ),
			.access                 ( "RW" ),
			.volatile               ( 0    ),
			.reset                  ( 0    ),
			.has_reset              ( 1    ),
			.is_rand                ( 1    ),
			.individually_accessible( 0    ) );

	endfunction: build
endclass: amiq_simple_reg_d

class amiq_ral_sandbox_reg_model extends uvm_reg_block;
	`uvm_object_utils( amiq_ral_sandbox_reg_model )

	rand amiq_simple_reg_a reg_a;
	rand amiq_simple_reg_b reg_b;
	rand amiq_simple_reg_c reg_c;
	rand amiq_simple_reg_d reg_d;

	uvm_reg_map                default_map;

	function new( string name = "amiq_simple_reg_model" );
		super.new( .name( name ), .has_coverage( UVM_NO_COVERAGE ) );
	endfunction: new

	virtual function void build();
		reg_a = amiq_simple_reg_a::type_id::create( "reg_a" );
		reg_a.configure( .blk_parent( this ) );
		reg_a.build();

		reg_b = amiq_simple_reg_b::type_id::create( "reg_b" );
		reg_b.configure( .blk_parent( this ) );
		reg_b.build();


		reg_c = amiq_simple_reg_c::type_id::create( "reg_c" );
		reg_c.configure( .blk_parent( this ) );
		reg_c.build();


		reg_d = amiq_simple_reg_d::type_id::create( "reg_d" );
		reg_d.configure( .blk_parent( this ) );
		reg_d.build();


		default_map = create_map(
			.name( "default_map" ),
			.base_addr( 8'h00 ),
			.n_bytes( 1 ),
			.endian( UVM_LITTLE_ENDIAN ) );

		default_map.add_reg( .rg( reg_a ), .offset( 0 ), .rights( "RW" ) );
		default_map.add_reg( .rg( reg_b ), .offset( 20 ), .rights( "RW" ) );
		default_map.add_reg( .rg( reg_c ), .offset( 32 ), .rights( "RW" ) );
		default_map.add_reg( .rg( reg_d ), .offset( 60 ), .rights( "RW" ) );

		lock_model(); // finalize the address mapping
	endfunction: build

endclass: amiq_ral_sandbox_reg_model