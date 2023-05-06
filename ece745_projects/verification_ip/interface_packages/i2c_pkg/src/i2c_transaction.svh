class i2c_transaction extends ncsu_transaction;
	`ncsu_register_object(i2c_transaction)


	// data specified with an i2c  transaction

	bit [7 : 0] data [];		// i2c data
	rand bit [7 : 0] read_data[];	// i2c read data
	i2c_op_t op;				// i2c operation type
	bit [6 : 0] addr;			// i2c slave address

	// constraint
	constraint i2c_read_data_range
	{
		foreach(read_data[k]) (k < read_data.size) -> read_data[k] inside {[8'h0 : 8'hFF]};
		 	
	}

	// i2c_transaction constructor

	function new(string name="");
		super.new(name);
	endfunction : new

	// convert2string method

	virtual function string convert2string();
		return {super.convert2string(), $sformatf("addr : %h, op : %b, data : %p read_data : %p", this.addr, this.op, this.data, this.read_data)};
	endfunction : convert2string


	// i2c_transaction compare method

	function bit compare(i2c_transaction rhs);
		return ( (this.op == rhs.op) &&
				 (this.addr == rhs.addr) &&
				 (this.data == rhs.data)
				);
	endfunction : compare


	// add_to_wave method

	virtual function void add_to_wave(int transaction_viewing_stream_h);
     super.add_to_wave(transaction_viewing_stream_h);
     $add_attribute(transaction_view_h, this.addr,"addr");
     $add_attribute(transaction_view_h, this.op,"op");
     $add_attribute(transaction_view_h,	this.data,"data");
     $end_transaction(transaction_view_h,end_time);
     $free_transaction(transaction_view_h);
  endfunction : add_to_wave


endclass : i2c_transaction