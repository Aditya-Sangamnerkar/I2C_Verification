class wb_coverage extends ncsu_component#(.T(wb_transaction));

	// data members

	wb_configuration configuration;    // handle for wb_configuration class

	bit [1:0] addr;			// wb register address
	bit [7:0] data;			// wb data
	bit w_r;				// write read bit for wb interface

	// wb transaction covergroup
	covergroup wb_transaction_cg();
		option.per_instance = 1;
    	option.name = get_full_name();

    	// coverpoint for address
    	address: coverpoint this.addr
    	{	
    		bins csr = {2'h00};
    		bins dpr = {2'h01};
    		bins cmdr = {2'h02};
    		bins fsmr = {2'h03};
    	}

    	// coverpoint for data
    	data: coverpoint this.data
    	{

    	}

    	// coverpoint for op
    	w_r: coverpoint this.w_r
    	{
    		bins writes = {1'b0}; // bin to count the wb write operations
    		bins reads = {1'b1}; // bin to count the wb read operations
    	}

    	// cross
    	address_x_w_r: cross address, w_r
    	{
    		bins csr_read_writes = binsof(address.csr) && binsof(w_r);
    		bins dpr_read_writes = binsof(address.dpr) && binsof(w_r);
    		bins cmdr_read_writes = binsof(address.cmdr) && binsof(w_r);
    		bins fsmr_reads = binsof(address.fsmr) && binsof(w_r.reads);
    	}




	endgroup : wb_transaction_cg

	// setter for wb configuration
	
	function void set_configuration(wb_configuration cfg);
      this.configuration = cfg;
   	endfunction : set_configuration

   	// wb_coverage constructor

   	function new(string name = "", ncsu_component #(T) parent  = null);
   		super.new(name, parent);
   		this.wb_transaction_cg = new; // instantiate wb transaction covergroup
   	endfunction : new

   	// nonblocking put of wb_coverage

   	virtual function void nb_put(T trans);
   		//$display("wb_coverage::nb_put() %s called",get_full_name());
   		this.addr = trans.addr;
   		this.w_r = trans.w_r;
   		this.data = trans.data;
   		wb_transaction_cg.sample();
   	endfunction : nb_put

   
endclass : wb_coverage