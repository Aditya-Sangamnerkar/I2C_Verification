class wb_agent extends ncsu_component#(.T(wb_transaction));

	// data members

	wb_configuration configuration;		// handle for wb_configuration
	wb_driver 		  driver;			// handle for wb_driver
	wb_monitor		  monitor;			// hndle for wb_monitor
	virtual wb_if 	  bus;				// handle to wb_if 
	ncsu_component #(T) subscribers[$];	// handle to queue of subscribers


	wb_coverage coverage_wb_trans_cg;			// handle for wb_coverage

	// wb_agent constructor

	function new(string name = "", ncsu_component_base  parent = null); 
    	super.new(name,parent);
    	if ( !(ncsu_config_db#(virtual wb_if)::get(this.get_full_name(), this.bus))) begin;
     	$display("wb_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",this.get_full_name());
      	$finish;
    	end
  	endfunction : new


  	// setter for wb_configuration

	function void set_configuration(wb_configuration cfg);
		this.configuration = cfg;
	endfunction : set_configuration



  	// build method to instantiate all the handles

	virtual function void build();

		// instantiate the driver
		this.driver = new("driver", this);
		this.driver.set_configuration(this.configuration);
		this.driver.build();
		this.driver.bus = this.bus;

		// instantiate the coverage 
		this.coverage_wb_trans_cg = new("wb_coverage", this);
		this.coverage_wb_trans_cg.set_configuration(this.configuration);
		this.coverage_wb_trans_cg.build();
		connect_subscriber(coverage_wb_trans_cg);

		// instantiate the monitor
		this.monitor = new("monitor", this);
		this.monitor.set_configuration(this.configuration);
		this.monitor.set_agent(this);
		this.monitor.enable_transaction_viewing = 1;
		this.monitor.bus = this.bus;

	endfunction : build


	// non blocking put method to send the transaction to subscribers

	virtual function void nb_put(T trans);
		foreach(this.subscribers[i]) begin
			subscribers[i].nb_put(trans);
		end
	endfunction : nb_put


	// blocking put method to send the transaction to driver

	virtual task bl_put(T trans);
		//$display({this.get_full_name()}, " ", trans.convert2string());
		
		this.driver.bl_put(trans);
	endtask : bl_put


	// connect_subscribers method to push subscribers to the agent in the subscribers queue

	virtual function void connect_subscriber(ncsu_component#(T) subscriber);
    this.subscribers.push_back(subscriber);
  	endfunction : connect_subscriber

  	// run task to call the run task of monitor

  	virtual task run();
  		fork this.monitor.run(); join_none
  	endtask : run

endclass : wb_agent