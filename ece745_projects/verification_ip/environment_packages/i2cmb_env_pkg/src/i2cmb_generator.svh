class i2cmb_generator extends ncsu_component;
	`ncsu_register_object(i2cmb_generator)
	// data memebrs 

	wb_transaction wb_trans;				
	string wb_trans_name;
	//ncsu_component #(wb_transaction) wbAgent;
	wb_agent wbAgent;

	i2c_transaction i2c_trans;
	string i2c_trans_name;
	//ncsu_component #(i2c_transaction) i2cAgent;
	i2c_agent i2cAgent;
	bit [7 : 0] read_data[];

	// generator class constructor
	
	function new(string name="", ncsu_component_base parent = null);
		super.new(name, parent);
		// GEN TRANS TYPE coverage ***
	endfunction : new

	// ******************************* DEFAULT TEST ***************************************** //
	// run task
	virtual task run();
		
		fork
			begin : i2c
					
					this.helper_i2c_only_writes();
					this.helper_i2c_only_reads();
					this.helper_i2c_write_reads();
					this.helper_i2c_only_reads();
					
			end   : i2c

			begin : wb
					this.helper_wb_setup();
					this.helper_wb_only_writes();
					this.helper_wb_only_reads();
					this.helper_wb_write_reads();
					this.helper_wb_read_nak();
				
					
			end   : wb

		join_any
		

	endtask : run

	// ******************************* RANDOM WRITES ***************************************** //


	virtual task helper_i2c_only_writes();
		/* *************** WRITE 32 VALUES	[0:31] ************* */
		
		// i2c start
		this.i2c_trans_name = "I2C_Start_WRITE";
		this.i2c_trans = new(this.i2c_trans_name);
		//this.i2c_trans.read_data = this.read_data;
		this.i2cAgent.bl_put(this.i2c_trans);
		//$display({this.get_full_name(), this.i2c_trans.convert2string()});

		// i2c write data
		this.i2c_trans_name = "I2C_WRITE_DATA";
		this.i2c_trans = new(this.i2c_trans_name);
		for(int i=0; i<32; i++) begin
			this.i2cAgent.bl_put(this.i2c_trans);
		end
		//$display({this.get_full_name(), this.i2c_trans.convert2string()});
		
		// i2c stop
		this.i2c_trans_name = "I2C_Stop_WRITE";
		this.i2c_trans = new(this.i2c_trans_name);
		//this.i2c_trans.read_data = this.read_data;
		this.i2cAgent.bl_put(this.i2c_trans);
		//$display({this.get_full_name(), this.i2c_trans.convert2string()});

	endtask : helper_i2c_only_writes


	virtual task helper_wb_only_writes();
		// **************** WRITE 32 INC. Values [0-31] *************

		
		// Write byte “xxxxx100” to the CMDR. This is Start command.
		this.wb_trans_name = "SET_CMDR_START_CMD";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h2;
		this.wb_trans.data = 8'bxxxxx100;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});
		

		// Wait for interrupt or until DON bit of CMDR reads '1'.
		this.wb_trans_name = "CMDR_DON";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.w_r = 1'b1;
		this.wb_trans.addr = 2'h2;
		do begin
			this.wbAgent.bl_put(this.wb_trans);
		end while(!this.wb_trans.data[7]);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});

			 
		// Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +
  		// rightmost bit = '0', which means writing.
  		this.wb_trans_name = "SET_DPR_I2C_SLAVE_ADDR";
  		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h1;
		this.wb_trans.data = 8'h44;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});
		

		// Write byte “xxxxx001” to the CMDR. This is Write command.
		this.wb_trans_name = "SET_CMDR_WRITE_CMD";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h2;
		this.wb_trans.data = 8'bxxxxx001;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});
		
		

		// Wait for interrupt or until DON bit of CMDR reads '1'.
		this.wb_trans_name = "CMDR_DON";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h2;
		this.wb_trans.w_r = 1'b1;
		do begin
			this.wbAgent.bl_put(this.wb_trans);
		end while(!this.wb_trans.data[7]);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});
		


		
		for(int i=0; i<32; i++) begin
			
			// write byte to the DPR
			this.wb_trans_name = "SET_DPR_DATA_BYTE";
  			this.wb_trans = new(this.wb_trans_name);
  			// this.wb_trans.randomize();
			this.wb_trans.addr = 2'h1;
			this.wb_trans.data = i;
			this.wb_trans.w_r = 1'b0;
			this.wbAgent.bl_put(this.wb_trans);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});

			// Write byte “xxxxx001” to the CMDR. This is Write command.
			this.wb_trans_name = "SET_CMDR_WRITE_CMD";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h2;
			this.wb_trans.data = 8'bxxxxx001;
			this.wb_trans.w_r = 1'b0;
			this.wbAgent.bl_put(this.wb_trans);	
			//$display({this.get_full_name(), this.wb_trans.convert2string()});	

			// Wait for interrupt or until DON bit of CMDR reads '1'.
			this.wb_trans_name = "CMDR_DON";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.w_r = 1'b1;
			this.wb_trans.addr = 2'h2;
			do begin
				this.wbAgent.bl_put(this.wb_trans);
			end while(!this.wb_trans.data[7]);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});

		end
			
		// Write byte “xxxxx101” to the CMDR. This is Stop command.
		this.wb_trans_name = "SET_CMDR_STOP_CMD";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h2;
		this.wb_trans.data = 8'bxxxxx101;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});

		// Wait for interrupt or until DON bit of CMDR reads '1'.
		this.wb_trans_name = "CMDR_DON";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.w_r = 1'b1;
		this.wb_trans.addr = 2'h2;
		do begin
			this.wbAgent.bl_put(this.wb_trans);
		end while(!this.wb_trans.data[7]);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});

	endtask : helper_wb_only_writes

	virtual task helper_i2c_only_reads();

		// i2c start 
		this.i2c_trans_name = "I2C_Start_READ";
		this.i2c_trans = new(this.i2c_trans_name);
		//this.i2c_trans.read_data = this.read_data;
		this.i2cAgent.bl_put(this.i2c_trans);
		//$display({this.get_full_name(), this.i2c_trans.convert2string()});


		// i2c stop
		this.i2c_trans_name = "I2C_Stop_READ";
		this.i2c_trans = new(this.i2c_trans_name);
		//this.i2c_trans.read_data = this.read_data;
		this.i2cAgent.bl_put(this.i2c_trans);
		//$display({this.get_full_name(), this.i2c_trans.convert2string()});

	endtask : helper_i2c_only_reads

	virtual task helper_wb_only_reads();
		// initialize the read_data
		this.read_data = new[32];
		for(int i=0; i<32; i++) begin
			this.read_data[i] = 8'h64 + i;
		end
		this.i2c_trans.read_data = read_data;

		// Write byte “xxxxx100” to the CMDR. This is Start command.
		this.wb_trans_name = "SET_CMDR_START_CMD";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h2;
		this.wb_trans.data = 8'bxxxxx100;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});
		

		// Wait for interrupt or until DON bit of CMDR reads '1'.
		this.wb_trans_name = "CMDR_DON";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.w_r = 1'b1;
		this.wb_trans.addr = 2'h2;
		do begin
			this.wbAgent.bl_put(this.wb_trans);
		end while(!this.wb_trans.data[7]);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});

			 
		// Write byte 0x45 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +
  		// rightmost bit = '1', which means reading.
  		this.wb_trans_name = "SET_DPR_I2C_SLAVE_ADDR";
  		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h1;
		this.wb_trans.data = 8'h45;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});
		

		// Write byte “xxxxx001” to the CMDR. This is Write command.
		this.wb_trans_name = "SET_CMDR_WRITE_CMD";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h2;
		this.wb_trans.data = 8'bxxxxx001;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});
		
		

		// Wait for interrupt or until DON bit of CMDR reads '1'.
		this.wb_trans_name = "CMDR_DON";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.w_r = 1'b1;
		this.wb_trans.addr = 2'h2;
		do begin
			this.wbAgent.bl_put(this.wb_trans);
		end while(!this.wb_trans.data[7]);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});


		
		for(int i=0; i<32; i++) begin
			
			// write byte to the CMDR. This is the ACK command
			this.wb_trans_name = "SET_CMDR_ACK_CMD";
  			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h2;
			this.wb_trans.data = 8'h2;
			this.wb_trans.w_r = 1'b0;	
			this.wbAgent.bl_put(this.wb_trans);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});	

			// Wait for interrupt or until DON bit of CMDR reads '1'.
			this.wb_trans_name = "CMDR_DON";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.w_r = 1'b1;
			this.wb_trans.addr = 2'h2;
			do begin
				this.wbAgent.bl_put(this.wb_trans);
			end while(!this.wb_trans.data[7]);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});

			// Read DPR to get received byte of data.
			this.wb_trans_name = "DATA_BYTE";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h1;
			this.wb_trans.w_r = 1'b1;
			this.wbAgent.bl_put(this.wb_trans);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});

		end
			
		// Write byte “xxxxx101” to the CMDR. This is Stop command.
		this.wb_trans_name = "SET_CMDR_STOP_CMD";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h2;
		this.wb_trans.data = 8'bxxxxx101;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});

		// Wait for interrupt or until DON bit of CMDR reads '1'.
		this.wb_trans_name = "CMDR_DON";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.w_r = 1'b1;
		this.wb_trans.addr = 2'h2;
		do begin
			this.wbAgent.bl_put(this.wb_trans);
		end while(!this.wb_trans.data[7]);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});
			
	endtask : helper_wb_only_reads


	virtual task helper_i2c_write_reads();
		for(int i=0; i<64; i++) begin
			// ************ WRITE **************
			// i2c start
			this.i2c_trans_name = "I2C_Start_WRITE";
			this.i2c_trans = new(this.i2c_trans_name);
			//this.i2c_trans.read_data = this.read_data;
			this.i2cAgent.bl_put(this.i2c_trans);
			//$display({this.get_full_name(), this.i2c_trans.convert2string()});

			// i2c write data
			this.i2c_trans_name = "I2C_WRITE_DATA";
			this.i2c_trans = new(this.i2c_trans_name);
			this.i2cAgent.bl_put(this.i2c_trans);
			//$display({this.get_full_name(), this.i2c_trans.convert2string()});

			// ************ READ ***************
			
			// i2c start 
			this.i2c_trans_name = "I2C_Start_READ";
			this.i2c_trans = new(this.i2c_trans_name);
			this.i2cAgent.bl_put(this.i2c_trans);
			//$display({this.get_full_name(), this.i2c_trans.convert2string()});

			
		end

		// i2c stop
		this.i2c_trans_name = "I2C_Stop_WRITE_READS";
		this.i2c_trans = new(this.i2c_trans_name);
		//this.i2c_trans.read_data = this.read_data;
		this.i2cAgent.bl_put(this.i2c_trans);
		//$display({this.get_full_name(), this.i2c_trans.convert2string()});
			
	endtask : helper_i2c_write_reads
	
	virtual task helper_wb_write_reads();
		/* ************** WRITE 64 incrementing values [64:127] READ 64 decrementing values [63:0] ******************** */
		for(int i=0; i<64; i++) begin
			
			//******************************* WRITE ******************************
			// Write byte “xxxxx100” to the CMDR. This is Start command.
			this.wb_trans_name = "SET_CMDR_START_CMD";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h2;
			this.wb_trans.data = 8'bxxxxx100;
			this.wb_trans.w_r = 1'b0;
			this.wbAgent.bl_put(this.wb_trans);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});
		

			// Wait for interrupt or until DON bit of CMDR reads '1'.
			this.wb_trans_name = "CMDR_DON";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.w_r = 1'b1;
			this.wb_trans.addr = 2'h2;
			do begin
				this.wbAgent.bl_put(this.wb_trans);
			end while(!this.wb_trans.data[7]);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});

			 
			// Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +
  			// rightmost bit = '0', which means writing.
  			this.wb_trans_name = "SET_DPR_I2C_SLAVE_ADDR";
  			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h1;
			this.wb_trans.data = 8'h44;
			this.wb_trans.w_r = 1'b0;
			this.wbAgent.bl_put(this.wb_trans);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});
		

			// Write byte “xxxxx001” to the CMDR. This is Write command.
			this.wb_trans_name = "SET_CMDR_WRITE_CMD";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h2;
			this.wb_trans.data = 8'bxxxxx001;
			this.wb_trans.w_r = 1'b0;
			this.wbAgent.bl_put(this.wb_trans);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});
		
			// Wait for interrupt or until DON bit of CMDR reads '1'.
			this.wb_trans_name = "CMDR_DON";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h2;
			this.wb_trans.w_r = 1'b1;
			do begin
				this.wbAgent.bl_put(this.wb_trans);
			end while(!this.wb_trans.data[7]);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});
		
			// write byte to the DPR
			this.wb_trans_name = "SET_DPR_DATA_BYTE";
  			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h1;
			this.wb_trans.data = 8'h40 + i;
			this.wb_trans.w_r = 1'b0;
			this.wbAgent.bl_put(this.wb_trans);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});

			// Write byte “xxxxx001” to the CMDR. This is Write command.
			this.wb_trans_name = "SET_CMDR_WRITE_CMD";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h2;
			this.wb_trans.data = 8'bxxxxx001;
			this.wb_trans.w_r = 1'b0;
			this.wbAgent.bl_put(this.wb_trans);	
			//$display({this.get_full_name(), this.wb_trans.convert2string()});	

			// Wait for interrupt or until DON bit of CMDR reads '1'.
			this.wb_trans_name = "CMDR_DON";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.w_r = 1'b1;
			this.wb_trans.addr = 2'h2;
			do begin
				this.wbAgent.bl_put(this.wb_trans);
			end while(!this.wb_trans.data[7]);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});

			// ************************* READ ******************************

			// initialize the read_data
			this.read_data = new[1];
			this.read_data[0] = 8'h3F - i;
			this.i2c_trans.read_data = this.read_data;

			// Write byte “xxxxx100” to the CMDR. This is Start command.
			this.wb_trans_name = "SET_CMDR_START_CMD";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h2;
			this.wb_trans.data = 8'bxxxxx100;
			this.wb_trans.w_r = 1'b0;
			this.wbAgent.bl_put(this.wb_trans);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});
		

			// Wait for interrupt or until DON bit of CMDR reads '1'.
			this.wb_trans_name = "CMDR_DON";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.w_r = 1'b1;
			this.wb_trans.addr = 2'h2;
			do begin
				this.wbAgent.bl_put(this.wb_trans);
			end while(!this.wb_trans.data[7]);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});

			 
			// Write byte 0x45 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +
  			// rightmost bit = '1', which means reading.
  			this.wb_trans_name = "SET_DPR_I2C_SLAVE_ADDR";
  			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h1;
			this.wb_trans.data = 8'h45;
			this.wb_trans.w_r = 1'b0;
			this.wbAgent.bl_put(this.wb_trans);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});
		

			// Write byte “xxxxx001” to the CMDR. This is Write command.
			this.wb_trans_name = "SET_CMDR_WRITE_CMD";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h2;
			this.wb_trans.data = 8'bxxxxx001;
			this.wb_trans.w_r = 1'b0;
			this.wbAgent.bl_put(this.wb_trans);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});
		
		

			// Wait for interrupt or until DON bit of CMDR reads '1'.
			this.wb_trans_name = "CMDR_DON";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.w_r = 1'b1;
			this.wb_trans.addr = 2'h2;
			do begin
				this.wbAgent.bl_put(this.wb_trans);
			end while(!this.wb_trans.data[7]);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});
			
			// write byte to the CMDR. This is the ACK command
			this.wb_trans_name = "SET_CMDR_ACK_CMD";
  			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h2;
			this.wb_trans.data = 8'h2;
			this.wb_trans.w_r = 1'b0;	
			this.wbAgent.bl_put(this.wb_trans);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});	

			// Wait for interrupt or until DON bit of CMDR reads '1'.
			this.wb_trans_name = "CMDR_DON";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.w_r = 1'b1;
			this.wb_trans.addr = 2'h2;
			do begin
				this.wbAgent.bl_put(this.wb_trans);
			end while(!this.wb_trans.data[7]);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});

			// Read DPR to get received byte of data.
			this.wb_trans_name = "DATA_BYTE";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h1;
			this.wb_trans.w_r = 1'b1;
			this.wbAgent.bl_put(this.wb_trans);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});


		end

		// Write byte “xxxxx101” to the CMDR. This is Stop command.
		this.wb_trans_name = "SET_CMDR_STOP_CMD";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h2;
		this.wb_trans.data = 8'bxxxxx101;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});

		// Wait for interrupt or until DON bit of CMDR reads '1'.
		this.wb_trans_name = "CMDR_DON";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.w_r = 1'b1;
		this.wb_trans.addr = 2'h2;
		do begin
			this.wbAgent.bl_put(this.wb_trans);
		end while(!this.wb_trans.data[7]);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});

	endtask : helper_wb_write_reads

	
	virtual task helper_wb_setup();
		// **************** I2C BUS Setup ****************

		// Write byte “11xxxxxx” to the CSR register. This sets bit E to '1', enabling the core and IE to '1' enabling interrupt.
		this.wb_trans_name = "SET_CSR_E_IE";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h0;
		this.wb_trans.data = 8'b1xxxxxxx;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});
		
		// Write byte 0x00 to the DPR. This is the ID of desired I2C bus.
		this.wb_trans_name = "SET_DPR_I2C_BUS_ID";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h1;
		this.wb_trans.data = 8'b00000000;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});

		// Write byte “xxxxx110” to the CMDR. This is Set Bus command.
		this.wb_trans_name = "SET_CMDR_SET_BUS_CMD";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h2;
		this.wb_trans.data = 8'bxxxxx110;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});
		
		// Wait for interrupt or until DON bit of CMDR reads '1'.
		this.wb_trans_name = "CMDR_DON";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.w_r = 1'b1;
		this.wb_trans.addr = 2'h2;
		do begin
			this.wbAgent.bl_put(this.wb_trans);
		end while(!this.wb_trans.data[7]);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});

	endtask : helper_wb_setup


	virtual task helper_wb_read_nak();
		// initialize the read_data
		this.read_data = new[32];
		for(int i=0; i<32; i++) begin
			this.read_data[i] = 8'h64 + i;
		end
		this.i2c_trans.read_data = read_data;

		// Write byte “xxxxx100” to the CMDR. This is Start command.
		this.wb_trans_name = "SET_CMDR_START_CMD";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h2;
		this.wb_trans.data = 8'bxxxxx100;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});
		

		// Wait for interrupt or until DON bit of CMDR reads '1'.
		this.wb_trans_name = "CMDR_DON";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.w_r = 1'b1;
		this.wb_trans.addr = 2'h2;
		do begin
			this.wbAgent.bl_put(this.wb_trans);
		end while(!this.wb_trans.data[7]);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});

			 
		// Write byte 0x45 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +
  		// rightmost bit = '1', which means reading.
  		this.wb_trans_name = "SET_DPR_I2C_SLAVE_ADDR";
  		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h1;
		this.wb_trans.data = 8'h45;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});
		

		// Write byte “xxxxx001” to the CMDR. This is Write command.
		this.wb_trans_name = "SET_CMDR_WRITE_CMD";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h2;
		this.wb_trans.data = 8'bxxxxx001;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});
		
		

		// Wait for interrupt or until DON bit of CMDR reads '1'.
		this.wb_trans_name = "CMDR_DON";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.w_r = 1'b1;
		this.wb_trans.addr = 2'h2;
		do begin
			this.wbAgent.bl_put(this.wb_trans);
		end while(!this.wb_trans.data[7]);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});


		
		for(int i=0; i<32; i++) begin
			
			// write byte to the CMDR. This is the ACK command
			this.wb_trans_name = "SET_CMDR_ACK_CMD";
  			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h2;
			this.wb_trans.data = 8'h2;
			this.wb_trans.w_r = 1'b0;	
			this.wbAgent.bl_put(this.wb_trans);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});	

			// Wait for interrupt or until DON bit of CMDR reads '1'.
			this.wb_trans_name = "CMDR_DON";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.w_r = 1'b1;
			this.wb_trans.addr = 2'h2;
			do begin
				this.wbAgent.bl_put(this.wb_trans);
			end while(!this.wb_trans.data[7]);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});

			// Read DPR to get received byte of data.
			this.wb_trans_name = "DATA_BYTE";
			this.wb_trans = new(this.wb_trans_name);
			this.wb_trans.addr = 2'h1;
			this.wb_trans.w_r = 1'b1;
			this.wbAgent.bl_put(this.wb_trans);
			//$display({this.get_full_name(), this.wb_trans.convert2string()});

		end

		// Write byte “xxxxx101” to the CMDR. This is Stop command.
		this.wb_trans_name = "SET_CMDR_NAK_CMD";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h2;
		this.wb_trans.data = 8'bxxxxx011;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
			
		// Write byte “xxxxx101” to the CMDR. This is Stop command.
		this.wb_trans_name = "SET_CMDR_STOP_CMD";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.addr = 2'h2;
		this.wb_trans.data = 8'bxxxxx101;
		this.wb_trans.w_r = 1'b0;
		this.wbAgent.bl_put(this.wb_trans);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});

		// Wait for interrupt or until DON bit of CMDR reads '1'.
		this.wb_trans_name = "CMDR_DON";
		this.wb_trans = new(this.wb_trans_name);
		this.wb_trans.w_r = 1'b1;
		this.wb_trans.addr = 2'h2;
		do begin
			this.wbAgent.bl_put(this.wb_trans);
		end while(!this.wb_trans.data[7]);
		//$display({this.get_full_name(), this.wb_trans.convert2string()});
	endtask : helper_wb_read_nak


	

	// ******************************* RANDOM READS ***************************************** //

	// ******************************* RANDOM WRITE READS ***************************************** //

	
	// setter for i2c agent

	function void set_i2c_agent(i2c_agent agent);
		this.i2cAgent = agent;
	endfunction : set_i2c_agent

	// setter for wb agent

	function void set_wb_agent(wb_agent agent);
		this.wbAgent = agent;
	endfunction : set_wb_agent

endclass : i2cmb_generator