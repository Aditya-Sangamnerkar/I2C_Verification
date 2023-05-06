class i2cmb_env_configuration extends ncsu_configuration;

	// data members

	// data members for coverage **
	// declare the covergroup **
	// function void sample_coverage(); **

	i2c_configuration i2c_agent_config;	// handle to i2c_configuration class
	wb_configuration  wb_agent_config;	// handle to wb_configuration class


	// env_configuation constructor

	function new(string name="");

		// call to parent constructor
		super.new(name);

		// instantiate i2c_agent_config
		this.i2c_agent_config = new("i2c_agent_config");

		// instantiat wb_agent_config
		this.wb_agent_config = new("wb_agent_config");

		// instantiate the covergroup **
		// initialize the collect coverage **
		// call to i2c_agent sample coverage **
		// call to wb_agent sample coverage **

	endfunction : new


endclass : i2cmb_env_configuration