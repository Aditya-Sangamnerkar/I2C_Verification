class i2cmb_test extends ncsu_component;
	`ncsu_register_object(i2cmb_test)

	i2cmb_env_configuration cfg;		// handle to env_configuration class
	i2cmb_environment 	  env;		// handle to environment class
	i2cmb_generator		  gen;		// handle to generator class
	i2cmb_random_generator gen_rand;	// handle to const. random data generator class
	i2cmb_register_generator gen_reg;
	string sequence_name;				// cmd line argument to select generator

	// i2cmb_test constructor

	function new(string name="", ncsu_component_base parent = null);

		// call to parent class constructor
		super.new(name, parent);

		// instantiate environment configuration
		this.cfg = new("cfg");

		// coverage 
		// cfg.sample_coverage();

		// instantiate the environment
		this.env = new("env", this);

		// setter for environment configuration
		this.env.set_configuration(this.cfg);

		// build the environment
		this.env.build();

		// instantiate generator
		this.gen = new("gen", this);
		this.gen_rand = new("gen_rand", this);
		this.gen_reg = new("gen_reg", this);

		// set the agents inside the generator 
		this.gen.set_wb_agent(this.env.get_wb_agent());
		this.gen.set_i2c_agent(this.env.get_i2c_agent());

		this.gen_rand.set_wb_agent(this.env.get_wb_agent());
		this.gen_rand.set_i2c_agent(this.env.get_i2c_agent());

		this.gen_reg.set_wb_agent(this.env.get_wb_agent());
		this.gen_reg.set_i2c_agent(this.env.get_i2c_agent());

		// instantiate the sequence name
		if ( !$value$plusargs("GEN_TEST_TYPE=%s", sequence_name)) begin
      		$display("FATAL: +GEN_TEST_TYPE plusarg not found on command line");
      		$fatal;
    	end
    	$display("%m found +GEN_TRANS_TYPE=%s", sequence_name);



	endfunction : new

	virtual task run();
		env.run();
		if(sequence_name == "i2cmb_random_test") begin
			$display("################### CONST. RANDOM I2C TESTS ####################");
			gen_rand.run();
		end
		else if (sequence_name == "i2cmb_test")begin
			$display("################### DIR. I2C TESTS ####################");
			gen.run();
		end
		else if(sequence_name == "i2cmb_register_test")begin
			$display("################### I2CMB REGISTER TESTS ####################");
			gen_reg.run();
		end
		else begin
			$display("############### INVALID TEST #####################");
		end
				
		
	endtask : run

endclass : i2cmb_test