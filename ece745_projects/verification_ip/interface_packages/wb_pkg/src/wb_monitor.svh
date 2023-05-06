class wb_monitor extends ncsu_component#(.T(wb_transaction));

	// data members

	wb_configuration configuration; 	// handle for wb_configuration
	virtual wb_if bus;					// handle for wb_if 
	T monitored_trans;					// handle for the wb_transaction for which the class has been parametrized
	ncsu_component #(T) agent;			// handle for the wb_agent that will call the run method of the monitor

	// wb_monitor constructor

	function new(string  name = "", ncsu_component_base parent = null);
		super.new(name, parent);
	endfunction : new

	// setter for wb_configuration

	function void set_configuration(wb_configuration cfg);
		this.configuration = cfg;
	endfunction : set_configuration

	// setter for i2c_agent

	function void set_agent(ncsu_component#(T) agent);
		this.agent = agent;
	endfunction : set_agent

	// run method

	virtual task run();
		this.bus.wait_for_reset();
		forever begin
			
			// create a new transaction instance
			this.monitored_trans = new("wb_monitored_trans");


			// // check the enabled transaction viewing and record start time
			// if ( enable_transaction_viewing) begin
           	// 	this.monitored_trans.start_time = $time;
        	// end

        	// call to wb_if monitor task
        	this.bus.master_monitor( .addr(this.monitored_trans.addr),
        					  .data(this.monitored_trans.data),
        					  .we(this.monitored_trans.w_r));

        	// Aditya : w_r is !we
        	this.monitored_trans.w_r = ~this.monitored_trans.w_r;


			// display
			// $display("%s wb_monitor::run() addr : %h  w_r : %b data : %p",
			// 		 this.get_full_name(),
			// 		 this.monitored_trans.addr,
			// 		 this.monitored_trans.w_r,
			// 		 this.monitored_trans.data);

        	// call to non blocking put method of agent
        	this.agent.nb_put(this.monitored_trans);

        	// // check the enabled transaction viewing and record end time
			// if ( enable_transaction_viewing) begin
           	// 	this.monitored_trans.end_time = $time;
           	// 	this.monitored_trans.add_to_wave(transaction_viewing_stream);
        	// end

		end
	endtask : run

endclass : wb_monitor