class wb_transaction extends ncsu_transaction;
	`ncsu_register_object(wb_transaction)

	// data specified with a wb transaction

	bit [1:0] addr;			// wb register address
	rand bit [7:0] data;			// wb data
	bit w_r;				// write read bit for wb interface

	// constraint for i2c write data	
	constraint i2c_write_data_range
	{
		data inside { [8'h4F : 8'hFF] };
	}

	// wb_transaction constructor

	function new(string name="");
		super.new(name);
	endfunction : new

	// convert2string method

	virtual function string convert2string();
		return {super.convert2string(), $sformatf("addr : %h,  data : %h  w_r : %b", this.addr, this.data, this.w_r)};
	endfunction : convert2string

	// wb_transaction compare method

	function bit compare(wb_transaction rhs);
		return ( (this.addr == rhs.addr) &&
				 (this.data == rhs.data) &&
				 (this.w_r == rhs.w_r)
				);
	endfunction : compare



	// add_to_wave method

	virtual function void add_to_wave(int transaction_viewing_stream_h);
     super.add_to_wave(transaction_viewing_stream_h);
     $add_attribute(transaction_view_h, this.addr,"addr");
     $add_attribute(transaction_view_h,	this.data,"data");
     $add_attribute(transaction_view_h,	this.w_r,"w_r");
     $end_transaction(transaction_view_h,end_time);
     $free_transaction(transaction_view_h);
  endfunction : add_to_wave


endclass : wb_transaction
