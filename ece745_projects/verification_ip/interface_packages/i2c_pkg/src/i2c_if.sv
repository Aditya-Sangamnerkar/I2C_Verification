interface i2c_if	#(
		int I2C_ADDR_WIDTH = 7,
		int I2C_DATA_WIDTH = 8
	)

(
	inout triand scl,
	inout triand sda

);

// system signals

typedef  bit   i2c_op_t;
typedef enum bit[1:0] {ERROR=2'b00, START=2'b01, STOP=2'b10, DATA=2'b11} condition_type_t;

bit release_sda = 1'b1;
logic sda_s;

// wait_for_i2c_transfer
condition_type_t condition;
bit data;
i2c_op_t operation;
bit[I2C_ADDR_WIDTH-1: 0] slave_address;
bit[I2C_DATA_WIDTH-1: 0] data_byte;
bit [I2C_DATA_WIDTH-1:0] write_data_buffer [];

bit [I2C_DATA_WIDTH-1:0] monitor_write_data_buffer[];
i2c_op_t monitor_operation_buffer;
bit [I2C_ADDR_WIDTH-1:0] monitor_slave_address;

// provide_read_data
bit [I2C_DATA_WIDTH-1:0] monitor_read_data_buffer [];

// monitor 
event start_done, stop_done;
bit first_start;



// ****************************************************************
assign sda = (release_sda) ? 1'bz : sda_s;


// ************************************************************************************************
	task wait_for_i2c_transfer( 
								 output i2c_op_t op
							   , output bit [I2C_DATA_WIDTH-1:0] write_data []
							  );

	
	
	//$display("******* wait for i2c pass *********");	
	// check for condition
	read_condition(.cond_type(condition), .data_bit(data));
	if(condition == START) begin
		// clear write data buffer
		monitor_write_data_buffer = new[write_data_buffer.size()] (write_data_buffer);
		monitor_operation_buffer = operation;
		monitor_slave_address = slave_address;
		write_data_buffer.delete();
		// read slave address
		repeat(I2C_ADDR_WIDTH) begin: read_slave_address
			read_data(.data_bit(data));
			slave_address = slave_address << 1;
			slave_address = {slave_address[I2C_ADDR_WIDTH-1:1], data};
		end: read_slave_address
		//$display("slave address : %h",slave_address);
		// read the operation type
		read_data(.data_bit(data));
		operation = i2c_op_t'(data);
		op = operation;
		//$display("operation : %b",operation);
		// acknowledge signal from slave
		slave_acknowledge();
		//$display("slave ack");

		// release the sda bus from slave
		slave_sda_release();
		//$display("slave sda release");

		// trigger start_done event
		-> start_done;
	end
	else if(condition == DATA) begin
			// write operation
			if(op == 1'b0) begin
				// read data byte
				// reset data byte

				// repeat(I2C_DATA_WIDTH-1) begin 
				// 	data_byte = {data_byte[I2C_DATA_WIDTH-1:1], data};
				// 	data_byte = data_byte << 1;
				// 	read_data(.data_bit(data));
				// end

				data_byte[7] = data;
				for(int i=I2C_DATA_WIDTH-2; i>=0; i--) begin
					read_data(.data_bit(data));
					data_byte[i] = data;
				end

				// reset the write data buffer
				write_data_buffer = new[write_data_buffer.size()+1](write_data_buffer);
				// push data to the write data buffer
				write_data_buffer[write_data_buffer.size()-1] = data_byte;
				// copy data to write data
				write_data = new[write_data_buffer.size()](write_data_buffer);
				//$display("data byte %d", data_byte);
				//$display("write_data %p",write_data);
			
				// acknowledge signal from slave
				slave_acknowledge();
				//$display("slave ack");

				// release sda bus from slave
				slave_sda_release();
				//$display("slave sda release");
			end
			// read operation
			else begin

				
			end

	end
	else if(condition == STOP) begin
		
		op = 1'b0;
		-> stop_done;
		//$display("stop received");
		
	end
	 
	
	endtask


// *************************************************************************************************
	task provide_read_data( 
							  input bit [I2C_DATA_WIDTH-1:0] read_data [], 
							  output bit transfer_complete
						  );

	// provide 8 bits of data on sda
	// wait for ack from master
	// assumption : master koi bakchodi nahi karega
	//$display("provide_read_data read_data %p", read_data);
	transfer_complete = 1'b0;
	monitor_read_data_buffer = new[read_data.size()](read_data);
	for(int i=0; i<read_data.size(); i++) begin
		//$display("byte %d tx begin data byte : %d",i, read_data[i]);
		// write data byte to sda bus	
		for(int j=I2C_DATA_WIDTH-1; j>=0; j--) begin
			// write data bit to sda bus
			@(negedge scl);
			sda_s = read_data[i][j];
			release_sda = 1'b0;
			//$display("provide_read_data bit %b", read_data[i][j]);
		end
		// release sda bus
		// negedge already hai toh ek aur ko wait nako karo
		release_sda = 1'b1;
		//$display("slave sda release");
		// wait for ack from the master 
		wait(scl==1'b1 && sda == 1'b0);
		//$display("master ack received");

	end
	transfer_complete = 1'b1;
	
	endtask

// ****************************************************************************************************
	task monitor( 
				   output bit [I2C_ADDR_WIDTH-1:0] addr, 
				   output i2c_op_t op, 
				   output bit [I2C_DATA_WIDTH-1:0] data []
				);

		if(first_start == 1'b0) begin
			wait(start_done.triggered);
			first_start = 1'b1;
		end
		
		
		@(negedge scl);
		fork:check
			begin
				wait(stop_done.triggered);
				first_start = 1'b0;
			end
			begin
				wait(start_done.triggered);
			end
		join_any:check
		disable fork;

		
		if(first_start == 1'b1) begin
			addr = monitor_slave_address;
			op = monitor_operation_buffer;
		end
		else begin
			addr = slave_address;
			op = operation;
		end
		
		if(op == 1'b0) begin
			if(first_start == 1'b1)  data = new[monitor_write_data_buffer.size()](monitor_write_data_buffer);
			else data = new[write_data_buffer.size()](write_data_buffer);
			//$display("operation write data : %p", write_data_buffer);
		end
		else begin
			data = new[monitor_read_data_buffer.size()](monitor_read_data_buffer);
			//$display("operation read data : %p", monitor_read_data_buffer);
		end


	endtask


// *****************************************************************************************************

task read_condition(output condition_type_t cond_type, output bit data_bit);
	
	fork: read_cond
		begin: start
				//$display("start fork start");
				wait(scl);
				@(negedge sda);
				 cond_type = START;
				//$display("start fork end");
		end: start
			
		begin: stop
				//$display("stop fork start");
				wait(scl);
				@(posedge sda);
				cond_type = STOP;
				//$display("stop fork end");
		end: stop

		begin: data
				//$display("data fork start");
				// read data at posedge
				@(posedge scl);
				data_bit = sda;
				// if no other thread completes till scl negedge 
				// it implies that the value on sda is data 
				@(negedge scl);
				cond_type = DATA;
				//$display("data : %b",data_bit);
				//$display("data fork end");

		end: data

	join_any: read_cond
	disable fork;
	
endtask



task read_data(output bit data_bit);
		@(posedge scl);
		data_bit = sda;

endtask

task slave_acknowledge();
		@(negedge scl);
		sda_s = 1'b0;
		release_sda = 1'b0;
endtask

task slave_sda_release();
	
		@(negedge scl)
		release_sda = 1'b1;

endtask

endinterface : i2c_if




