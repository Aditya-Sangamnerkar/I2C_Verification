class wb_driver extends ncsu_component#(.T(wb_transaction));


	// data members

	wb_configuration configuration;		// handle for wb_configuration
	virtual wb_if bus;					// handle for wb_if 


	// wb_driver constructor

	function new(string name = "", ncsu_component_base parent = null);
		super.new(name, parent);
	endfunction : new

	// setter for wb_configuration

	function void set_configuration(wb_configuration cfg);
		this.configuration = cfg;
	endfunction : set_configuration


	// blocking put task to send the transaction to wb_if driver

	virtual task bl_put(T trans);

		// display
		
		// driver wb_if bus with transaction
		if(trans.w_r == 1'b0) begin
			this.bus.master_write( .addr(trans.addr), .data(trans.data));
		end

		else begin
			this.bus.master_read( .addr(trans.addr), .data(trans.data));
				//$display({this.get_full_name()}, " ", trans.convert2string());

		end


	endtask : bl_put

endclass : wb_driver