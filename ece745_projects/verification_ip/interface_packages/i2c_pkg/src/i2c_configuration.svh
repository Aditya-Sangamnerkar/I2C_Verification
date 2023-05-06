class i2c_configuration extends ncsu_configuration;


	// constraint definition

	// covergroup definition


	// function void sample_coverage();

	// i2c_configuration constructor

	function new(string name="");
		super.new(name);
	endfunction : new

	// convert2string method

	virtual function string convert2string();
		return {super.convert2string()};
	endfunction : convert2string

endclass : i2c_configuration