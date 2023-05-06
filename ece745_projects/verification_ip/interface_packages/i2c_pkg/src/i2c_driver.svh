class i2c_driver extends ncsu_component#(.T(i2c_transaction));

	// data members

	i2c_configuration configuration;	// handle for i2c_configuration
	virtual i2c_if bus;					// handle for i2c_if (slave bfm)



	// i2c_driver constructor

	function new(string name = "", ncsu_component_base parent = null);
		super.new(name, parent);
	endfunction : new

	// setter for i2c_configuration

	function void set_configuration(i2c_configuration cfg);
		this.configuration = cfg;
	endfunction : set_configuration

	// blocking put task to send the transaction to i2c_if driver

	virtual task bl_put(T trans);
		bit tx_complete; 		// parameter for provide_read_data

		// display
		//$display({this.get_full_name()}, " ", trans.convert2string());
		// drive the i2c_if bus with transaction
		this.bus.wait_for_i2c_transfer( .op(trans.op), .write_data(trans.data));
		if(trans.op == 1'b1) begin
			this.bus.provide_read_data( .read_data(trans.read_data), .transfer_complete(tx_complete));
		end
		//$display({this.get_full_name()}, " ", trans.convert2string());
	endtask : bl_put 


endclass : i2c_driver
	