class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

	// data members

	i2c_configuration configuration;	// handle for i2c_configuration
	virtual i2c_if bus;					// handle for i2c_if (slave bfm)
	T monitored_trans;					// handle for the i2c_transaction for which the class has been parametrized
	ncsu_component #(T) agent;			// handle for the i2c_agent that will call the run method of the monitor

	// i2c_monitor constructor

	function new(string  name = "", ncsu_component_base parent = null);
		super.new(name, parent);
	endfunction : new

	// setter for i2c_configuration

	function void set_configuration(i2c_configuration cfg);
		this.configuration = cfg;
	endfunction : set_configuration

	// setter for i2c_agent

	function void set_agent(ncsu_component#(T) agent);
		this.agent = agent;
	endfunction : set_agent

	// run method

	virtual task run ();
		forever begin
			
			// create a new transaction instance
			this.monitored_trans = new("i2c_monitored_trans");

			// check the enabled transaction viewing and record start time
			// if ( enable_transaction_viewing) begin
           	// 	this.monitored_trans.start_time = $time;
        	// end

			// call to i2c_if monitor task 
			this.bus.monitor( .addr(monitored_trans.addr), 
						 .op(monitored_trans.op), 
						 .data(monitored_trans.data)
						 );

			// display
			// $display("%s i2c_monitor::run() addr : %h op : %b data : %p",
			// 		 this.get_full_name(),
			// 		 this.monitored_trans.addr,
			// 		 this.monitored_trans.op,
			// 		 this.monitored_trans.data);

			// call to non blocking put method of agent
			this.agent.nb_put(this.monitored_trans);

			// check the enabled transaction viewing and record end time
			// if ( enable_transaction_viewing) begin
           	// 	this.monitored_trans.end_time = $time;
           	// 	this.monitored_trans.add_to_wave(transaction_viewing_stream);
        	// end
		end
	endtask : run


endclass : i2c_monitor