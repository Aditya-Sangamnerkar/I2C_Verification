`define CSR 0
`define DPR 1
`define CMDR 2
`define FSMR 3

class i2cmb_register_generator extends i2cmb_generator;
	`ncsu_register_object(i2cmb_register_generator)
	// generator class constructor
	bit[7:0] expected_register_values[4];
	bit[7:0] actual_register_values[4];
	function new(string name="", ncsu_component_base parent = null);
		super.new(name, parent);
		// GEN TRANS TYPE coverage ***
	endfunction : new

	task run();
		default_value_test();
		access_permission_test();
		system_reset_test();
		cmdr_aliasing_test();
		cmdr_access_test();
	endtask: run

	task default_value_test();

		// reset the i2cmb core
		this.wb_trans_name = "RESET_I2CMB";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CSR;
		this.wb_trans.data = 8'b0xxxxxxx;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);

		// read the values of four control registers
		this.wb_trans_name = "READ_CSR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CSR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.actual_register_values[`CSR] = this.wb_trans.data;
		this.expected_register_values[`CSR] = 8'h0;

		this.wb_trans_name = "READ_DPR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `DPR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.actual_register_values[`DPR] = this.wb_trans.data;
		this.expected_register_values[`DPR] = 8'h0;

		this.wb_trans_name = "READ_CMDR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CMDR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.actual_register_values[`CMDR] = this.wb_trans.data;
		this.expected_register_values[`CMDR] = 8'b10000000;

		this.wb_trans_name = "READ_FSMR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `FSMR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.actual_register_values[`FSMR] = this.wb_trans.data;
		this.expected_register_values[`FSMR] = 8'h0;

		if((this.actual_register_values[`CSR] == this.expected_register_values[`CSR]) &&
		   (this.actual_register_values[`DPR] == this.expected_register_values[`DPR]) &&
		   (this.actual_register_values[`CMDR] == this.expected_register_values[`CMDR]) &&
		   (this.actual_register_values[`FSMR] == this.expected_register_values[`FSMR])  ) begin
		   	$display("REGISTER DEFAULT VALUE MATCH!");
		end
		else begin
			$display("REGISTER DEFAULT VALUE MISMATCH!");
		end
		// $display("actual register values : %p" ,this.actual_register_values);
		// $display("expected register values : %p", this.expected_register_values);

	endtask: default_value_test

	task access_permission_test();

		this.wb_trans_name = "READ_BEFORE_FSMR_ACCESS";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `FSMR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.expected_register_values[`FSMR] = this.wb_trans.data;

		this.wb_trans_name = "WRITE_FSMR_ACCESS";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `FSMR;
		this.wb_trans.w_r = 1'b0;
		this.wb_trans.data = 8'hFF;
		this.wbAgent.bl_put(this.wb_trans);

		this.wb_trans_name = "READ_AFTER_FSMR_ACCESS";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `FSMR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.actual_register_values[`FSMR] = this.wb_trans.data;
		
		if((this.actual_register_values[`FSMR] == this.expected_register_values[`FSMR])  ) begin
		   	$display("FSMR REGISTER ACCESS PERMISSSION MATCH!");
		end
		else begin
			$display("FSMR REGISTER ACCESS PERMISSION MISMATCH!");
		end
	endtask: access_permission_test

	task system_reset_test();
		// reset the i2cmb core
		this.wb_trans_name = "RESET_I2CMB";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CSR;
		this.wb_trans.data = 8'b0xxxxxxx;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);

		// read the values of four control registers
		this.wb_trans_name = "READ_CSR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CSR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.expected_register_values[`CSR] = this.wb_trans.data;

		this.wb_trans_name = "READ_DPR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `DPR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.expected_register_values[`DPR] = this.wb_trans.data;

		this.wb_trans_name = "READ_CMDR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CMDR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.expected_register_values[`CMDR] = this.wb_trans.data;

		this.wb_trans_name = "READ_FSMR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `FSMR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.expected_register_values[`FSMR] = this.wb_trans.data;

		// write values to DPR, CMDR and FSMR
		this.wb_trans_name = "WRITE_DPR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `DPR;
		this.wb_trans.w_r = 1'b0;
		this.wb_trans.data = 8'hFF;
		this.wbAgent.bl_put(this.wb_trans);
		

		this.wb_trans_name = "WRITE_CMDR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CMDR;
		this.wb_trans.w_r = 1'b0;
		this.wb_trans.data = 8'hFF;
		this.wbAgent.bl_put(this.wb_trans);

		this.wb_trans_name = "WRITE_FSMR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `FSMR;
		this.wb_trans.w_r = 1'b0;
		this.wb_trans.data = 8'hFF;
		this.wbAgent.bl_put(this.wb_trans);

		// read values after invalid writes

		this.wb_trans_name = "READ_DPR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `DPR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.actual_register_values[`DPR] = this.wb_trans.data;

		this.wb_trans_name = "READ_CMDR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CMDR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.actual_register_values[`CMDR] = this.wb_trans.data;

		this.wb_trans_name = "READ_FSMR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `FSMR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.actual_register_values[`FSMR] = this.wb_trans.data;

		if((this.actual_register_values[`CSR][7] == 1'b0) &&
		   (this.actual_register_values[`DPR] == this.expected_register_values[`DPR]) &&
		   (this.actual_register_values[`CMDR] == this.expected_register_values[`CMDR]) &&
		   (this.actual_register_values[`FSMR] == this.expected_register_values[`FSMR])  ) begin
		   	$display("REGISTER SYSTEM RESET CHECK VALUE MATCH!");
		end
		else begin
			$display("REGISTER SYSTEM RESET CHECK VALUE MISMATCH!");
		end
		// $display("actual register values : %p" ,this.actual_register_values);
		// $display("expected register values : %p", this.expected_register_values);

	endtask : system_reset_test

	task cmdr_aliasing_test();

		// reset the i2cmb core
		this.wb_trans_name = "RESET_I2CMB";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CSR;
		this.wb_trans.data = 8'b1xxxxxxx;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);

		// read the values of four control registers
		this.wb_trans_name = "READ_CSR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CSR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.expected_register_values[`CSR] = this.wb_trans.data;
		

		this.wb_trans_name = "READ_DPR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `DPR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.expected_register_values[`DPR] = this.wb_trans.data;
		

		this.wb_trans_name = "READ_CMDR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CMDR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.expected_register_values[`CMDR] = this.wb_trans.data;
		

		this.wb_trans_name = "READ_FSMR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `FSMR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.expected_register_values[`FSMR] = this.wb_trans.data;
		
		// write to cmdr
		this.wb_trans_name = "WRITE_CMDR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CMDR;
		this.wb_trans.w_r = 1'b0;
		this.wb_trans.data = 8'hAF;
		this.wbAgent.bl_put(this.wb_trans);

		// read values after cmdr writes

		this.wb_trans_name = "READ_CSR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CSR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.actual_register_values[`CSR] = this.wb_trans.data;
		
		this.wb_trans_name = "READ_DPR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `DPR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.actual_register_values[`DPR] = this.wb_trans.data;

		this.wb_trans_name = "READ_CMDR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CMDR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.actual_register_values[`CMDR] = this.wb_trans.data;

		this.wb_trans_name = "READ_FSMR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `FSMR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.actual_register_values[`FSMR] = this.wb_trans.data;

		if((this.actual_register_values[`CSR] == this.expected_register_values[`CSR]) &&
		   (this.actual_register_values[`DPR] == this.expected_register_values[`DPR]) &&
		   (this.actual_register_values[`FSMR] == this.expected_register_values[`FSMR])  ) begin
		   	$display("REGISTER ALIASING CHECK VALUE MATCH!");
		end
		else begin
			$display("REGISTER ALIASING CHECK VALUE MISMATCH!");
		end

		// $display("actual register values : %p" ,this.actual_register_values);
		// $display("expected register values : %p", this.expected_register_values);

	endtask : cmdr_aliasing_test

	task cmdr_access_test();
		// reset the i2cmb core
		this.wb_trans_name = "RESET_I2CMB";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CSR;
		this.wb_trans.data = 8'b0xxxxxxx;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);

		this.wb_trans_name = "READ_CMDR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CMDR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.expected_register_values[`CMDR] = this.wb_trans.data;

		// write to cmdr
		this.wb_trans_name = "WRITE_CMDR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CMDR;
		this.wb_trans.w_r = 1'b0;
		this.wb_trans.data = 8'h78;
		this.wbAgent.bl_put(this.wb_trans);

		this.wb_trans_name = "READ_CMDR";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = `CMDR;
		this.wb_trans.w_r = 1'b1;
		this.wbAgent.bl_put(this.wb_trans);
		this.actual_register_values[`CMDR] = this.wb_trans.data;


		if((this.actual_register_values[`CMDR] == this.expected_register_values[`CMDR]) ) begin
		   	$display("CMDR ADDRESS ACCESS MATCH!");
		end
		else begin
			$display("CMDR ADDRESS ACCESS MISMATCH!");
		end

		// $display("actual register values : %p" ,this.actual_register_values);
		// $display("expected register values : %p", this.expected_register_values);
	endtask : cmdr_access_test

endclass : i2cmb_register_generator