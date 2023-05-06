class i2c_agent extends ncsu_component#(.T(i2c_transaction));

	// data members

	i2c_configuration configuration;	// handle for i2c_configuration
	i2c_driver 		  driver;			// handle for i2c_driver
	i2c_monitor		  monitor;			// hndle for i2c_monitor
	virtual i2c_if 	  bus;				// handle to i2c_if (slave bfm)
	ncsu_component #(T) subscribers[$];	// handle to queue of subscribers

	i2c_coverage	  coverage_i2c_trans_cg;			// handle for i2c_coverage

	// i2c_agent constructor

	function new(string name = "", ncsu_component_base  parent = null); 
    	super.new(name,parent);
    	if ( !(ncsu_config_db#(virtual i2c_if)::get(this.get_full_name(), this.bus))) begin;
     	$display("i2c_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",this.get_full_name());
      	$finish;
    	end
  	endfunction : new

  	// setter for i2c_configuration

	function void set_configuration(i2c_configuration cfg);
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
		this.coverage_i2c_trans_cg = new("i2c_coverage", this);
		this.coverage_i2c_trans_cg.set_configuration(this.configuration);
		this.coverage_i2c_trans_cg.build();
		connect_subscriber(coverage_i2c_trans_cg);


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
		this.driver.bl_put(trans);
	endtask : bl_put

	// connect_subscribers method to push subscribers to the agent in the subscribers queue
	
	virtual function void connect_subscriber(ncsu_component#(T) subscriber);
    	this.subscribers.push_back(subscriber);
  	endfunction : connect_subscriber

  	// run task to call the run task of monitor
  	virtual task run();
  		fork this.monitor.run(); join_none
  	endtask:run





endclass : i2c_agent