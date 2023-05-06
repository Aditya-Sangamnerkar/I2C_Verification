class i2cmb_environment extends ncsu_component;

	// data members

	i2cmb_env_configuration	configuration;	// handle to environment configuration class
	i2c_agent 			i2cAgent;		// handle to i2c_agent class
	wb_agent 			wbAgent;		// handle to wb_agent class
	i2cmb_scoreboard	scbd;			// handle to scoreboard class
	i2cmb_predictor		pred;			// handle to predictor class
	// coverage			coverage;		// handle to coverage class **

	// i2cmb_environment constructor

	function new(string name = "", ncsu_component_base  parent = null); 
    	super.new(name,parent);
  	endfunction : new

  	// setter for env configuration
  	function void set_configuration(i2cmb_env_configuration cfg);
    	this.configuration = cfg;
  	endfunction : set_configuration


  	// build method to instantiate various components

  	virtual function void build();

  		// intantiate, set configuration and build the i2c agent
  		this.i2cAgent = new("i2cAgent", this);
  		this.i2cAgent.set_configuration(this.configuration.i2c_agent_config);
  		this.i2cAgent.build();


  		// instantiate,  set configuration and build the wb agent
  		this.wbAgent = new("wbAgent", this);
  		this.wbAgent.set_configuration(this.configuration.wb_agent_config);
  		this.wbAgent.build();

  		//instantiate and build the scoreboard
  		this.scbd = new("scbd", this);
  		this.scbd.build();

  		//instantiate and build predictor
  		pred  = new("pred", this);
    	pred.set_configuration(configuration);
    	pred.set_scoreboard(scbd);
    	pred.build();

  		// instantiate and build coverage **


  		// connect subscribers to i2c agent
  		this.i2cAgent.connect_subscriber(this.scbd);  // connect scoreboard

  		// connect scoreboard to predictor
  		
  		// connect subscribers to wb agent
  		this.wbAgent.connect_subscriber(this.pred);	 // connect predictor

  		// subscribe to coverage **
  		// 											 // connect coverage;

  	endfunction : build

  	// getter for i2c_agent
  	function i2c_agent get_i2c_agent();
  		return this.i2cAgent;
  	endfunction : get_i2c_agent

  	// getter for wb_agent
  	function wb_agent get_wb_agent();
  		return this.wbAgent;
  	endfunction : get_wb_agent

  	// run task
  	virtual task run();
  		this.wbAgent.run();
  		this.i2cAgent.run();
  	endtask : run


endclass : i2cmb_environment