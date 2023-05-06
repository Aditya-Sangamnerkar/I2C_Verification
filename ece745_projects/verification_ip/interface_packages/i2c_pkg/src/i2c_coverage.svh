class i2c_coverage extends ncsu_component#(.T(i2c_transaction));

	// data members

	i2c_configuration configuration;    // handle for i2c_configuration class

	bit [7:0] data;					// i2c data
	//bit [7:0] read_data[];				// i2c read data
	i2c_op_t op;						// i2c operation type
	bit [6:0] addr;						// i2c slave address

	// i2c transaction covergroup
	covergroup i2c_transaction_cg();
		option.per_instance = 1;
    	option.name = get_full_name();

    	// coverpoint for address
    	address: coverpoint this.addr
    	{
    		bins slave_addr = { 8'h22 };	// slave address
    	}

    	// coverpoint for data
    	data: coverpoint this.data
    	{
    		bins test_1 = { [8'h0 : 8'h1F] }; 	// 32 cont. writes
    		bins test_2 = { [8'h64 : 8'h83] };  // 32 cont. reads
    		bins test_3 = { [8'h0 : 8'h7F] };   // 64 alt. read/writes
    		// bin for random tests
    		bins test_rnd = {[8'h0 : 8'hFF]};
    	}

    	// coverpoint for op
    	op: coverpoint this.op
    	{
    		bins writes = {1'b0}; // bin to count the i2c write operations
    		bins reads = {1'b1}; // bin to count the i2c read operations
    	}

    	// cross
    	address_x_op: cross address, op
    	{
    		bins address_reads = binsof(address.slave_addr) && binsof(op.reads);	// reads to slave address 8'h22
    		bins address_writes = binsof(address.slave_addr) && binsof(op.writes); // writes to slave address 8'h22
    	}


	endgroup : i2c_transaction_cg

	// setter for i2c configuration
	
	function void set_configuration(i2c_configuration cfg);
      this.configuration = cfg;
   	endfunction : set_configuration

   	// i2c_coverage constructor

   	function new(string name = "", ncsu_component #(T) parent  = null);
   		super.new(name, parent);
   		this.i2c_transaction_cg = new; // instantiate i2c transaction covergroup
   	endfunction : new

   	// nonblocking put of i2c_coverage

   	virtual function void nb_put(T trans);
   		// $display("i2c_coverage::nb_put() %s called",get_full_name());
   		this.addr = trans.addr;
   		this.op = trans.op;
   		for(int i=0; i<trans.data.size();i++) begin
   			this.data = trans.data[i];
   			i2c_transaction_cg.sample();
   		end
   		
   	endfunction : nb_put

   
endclass : i2c_coverage