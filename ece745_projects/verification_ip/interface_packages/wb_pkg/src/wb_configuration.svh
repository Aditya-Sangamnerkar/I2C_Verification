class wb_configuration extends ncsu_configuration;

	// constraint definitions

	// covergroup  definitions

	// function void sample_coverage();

	// wb_configuration constructor

	function new(string name="");
		super.new(name);
	endfunction : new

	// convert2string method

	virtual function string convert2string();
		return {super.convert2string()};
	endfunction : convert2string

endclass : wb_configuration