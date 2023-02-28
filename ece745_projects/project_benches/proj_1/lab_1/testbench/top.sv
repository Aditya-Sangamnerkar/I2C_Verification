`timescale 1ns / 10ps

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_BUSSES = 1;
parameter int I2C_ADDR_WIDTH = 7;
parameter int I2C_DATA_WIDTH = 8;

bit  clk;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_BUSSES-1:0] scl;
tri  [NUM_I2C_BUSSES-1:0] sda;


bit [WB_DATA_WIDTH-1:0] data_read;



typedef bit i2c_op_t;
i2c_op_t op;
bit [I2C_DATA_WIDTH-1:0] write_data[];
bit [I2C_DATA_WIDTH-1:0] read_data[];
bit tx_complete;

// ****************************************************************************
// Clock generator
initial begin: clk_gen
  clk = 1'b0;
  forever #10 clk = ~clk;
end: clk_gen


// ****************************************************************************
// Reset generator
initial begin: rst_gen
  #113 rst = 1'b0;
end: rst_gen

// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript
bit [WB_ADDR_WIDTH-1 : 0] moniter_addr;
bit [WB_DATA_WIDTH-1 : 0] moniter_data;
bit monitor_we;

initial begin: wb_monitoring
    wb_bus.master_monitor( .addr(moniter_addr), .data(moniter_data), .we(monitor_we));
    $display("WB_ADDR : %d, WB_DATA : %d, WB_WE : %d", moniter_addr, moniter_data, monitor_we);
  
end: wb_monitoring


// ***************************************************************************
initial begin: slave
  forever begin
    i2c_bus.wait_for_i2c_transfer(.op(op), .write_data(write_data));
    if(op == 1'b1) begin
        i2c_bus.provide_read_data(.read_data(read_data), .transfer_complete(tx_complete));
    end
  end
end: slave


initial begin: slave_monitor
  bit [I2C_ADDR_WIDTH-1: 0] addr_i2c;
  bit [I2C_DATA_WIDTH-1:0] data_i2c[];
  i2c_op_t op_i2c;
  forever begin
    i2c_bus.monitor(.addr(addr_i2c), .data(data_i2c), .op(op_i2c));
    $display("addr: %h op: %b data: %p", addr_i2c, op_i2c, data_i2c);
  end
end: slave_monitor



// ****************************************************************************
// Define the flow of the simulation
initial begin: test_flow

  /* ******************* I2C Bus setup ******************************** */

  // Write byte “1xxxxxxx” to the CSR register. This sets bit E to '1', enabling the core.
  wb_bus.master_write( .addr(2'h0), .data(8'b11xxxxxx));

  // Write byte 0x00 to the DPR. This is the ID of desired I2C bus.
  wb_bus.master_write( .addr(2'h1), .data(8'h00));

  // Write byte “xxxxx110” to the CMDR. This is Set Bus command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx110));
  
  // Wait for interrupt or until DON bit of CMDR reads '1'.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);
  
  /* ********************* WRITE 32 Incrementing values [0-31] *************************** */
  // Write byte “xxxxx100” to the CMDR. This is Start command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx100));
  
  // Wait for interrupt or until DON bit of CMDR reads '1'.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);
  
  // Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +
  // rightmost bit = '0', which means writing.
   wb_bus.master_write( .addr(2'h1), .data(8'h44));
  
  // Write byte “xxxxx001” to the CMDR. This is Write command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx001));
  
  // Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
  // is '1', then slave doesn't respond.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);

  for(int i=0; i<10; i++) begin
   
      // Write byte 0x78 to the DPR. This is the byte to be written.
      wb_bus.master_write( .addr(2'h1), .data(i));
  
      // Write byte “xxxxx001” to the CMDR. This is Write command.
      wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx001));
  
      // Wait for interrupt or until DON bit of CMDR reads '1'.
      do begin
        wb_bus.master_read( .addr(2'h2), .data(data_read));
      end while(!data_read[7]);

  end

  // Write byte “xxxxx101” to the CMDR. This is Stop command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx101));
  
  // Wait for interrupt or until DON bit of CMDR reads '1'.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);


  

  // /* *********************** READ 32 values [100-131]*************************** */
  //initialize read_data
  read_data = new[4];
  for(int i=0; i<4; i++) begin
    read_data[i] = 8'h64 + i;
  end

  // Write byte “xxxxx100” to the CMDR. This is Start command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx100));
  
  // Wait for interrupt or until DON bit of CMDR reads '1'.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);
  
  // Write byte 0x45 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +
  // rightmost bit = '1', which means reading.
   wb_bus.master_write( .addr(2'h1), .data(8'h45));
  
  // Write byte “xxxxx001” to the CMDR. This is Write command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx001));
  
  // Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
  // is '1', then slave doesn't respond.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);

  for(int i=0; i<4; i++) begin
    // Write byte "xxxxx010" to the CMDR. This is the ACK command.
    wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx010));

    // Wait for interrupt or until DON bit of CMDR reads '1'.
    do begin
      wb_bus.master_read( .addr(2'h2), .data(data_read));
    end while(!data_read[7]);

    // Read DPR to get received byte of data.  
    wb_bus.master_read( .addr(2'h1), .data(data_read));
  end

  // // Write byte “xxxxx101” to the CMDR. This is Stop command.
  //  wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx101));
  
  // // Wait for interrupt or until DON bit of CMDR reads '1'.
  // do begin
  //   wb_bus.master_read( .addr(2'h2), .data(data_read));
  // end while(!data_read[7]);

  // /* ************** WRITE 64 incrementing values [64:127] READ 64 decrementing values [63:0] ******************** */

  // initialize read_data
  read_data = new[64];
  for(int i=63; i>=0; i--) begin
    read_data[63-i] = i;
  end

  // Write byte “xxxxx100” to the CMDR. This is Start command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx100));
  
  // Wait for interrupt or until DON bit of CMDR reads '1'.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);
  
  // Write byte 0x45 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +
  // rightmost bit = '1', which means reading.
   wb_bus.master_write( .addr(2'h1), .data(8'h45));
  
  // Write byte “xxxxx001” to the CMDR. This is Write command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx001));
  
  // Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
  // is '1', then slave doesn't respond.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);

  for(int i=0; i<64; i++) begin
    // Write byte "xxxxx010" to the CMDR. This is the ACK command.
    wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx010));

    // Wait for interrupt or until DON bit of CMDR reads '1'.
    do begin
      wb_bus.master_read( .addr(2'h2), .data(data_read));
    end while(!data_read[7]);

    // Read DPR to get received byte of data.  
    wb_bus.master_read( .addr(2'h1), .data(data_read));
  end

  // // Write byte “xxxxx101” to the CMDR. This is Stop command.
  //  wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx101));
  
  // // Wait for interrupt or until DON bit of CMDR reads '1'.
  // do begin
  //   wb_bus.master_read( .addr(2'h2), .data(data_read));
  // end while(!data_read[7]);
  
  // Write byte “xxxxx100” to the CMDR. This is Start command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx100));
  
  // Wait for interrupt or until DON bit of CMDR reads '1'.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);
  
  // Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +
  // rightmost bit = '0', which means writing.
   wb_bus.master_write( .addr(2'h1), .data(8'h44));
  
  // Write byte “xxxxx001” to the CMDR. This is Write command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx001));
  
  // Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
  // is '1', then slave doesn't respond.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);

  for(int i=64; i<128; i++) begin
   
      // Write byte 0x78 to the DPR. This is the byte to be written.
      wb_bus.master_write( .addr(2'h1), .data(i));
  
      // Write byte “xxxxx001” to the CMDR. This is Write command.
      wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx001));
  
      // Wait for interrupt or until DON bit of CMDR reads '1'.
      do begin
        wb_bus.master_read( .addr(2'h2), .data(data_read));
      end while(!data_read[7]);

  end
  
  // Write byte “xxxxx101” to the CMDR. This is Stop command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx101));
  
  // Wait for interrupt or until DON bit of CMDR reads '1'.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);


  

end: test_flow



// ****************************************************************************
// Instantiate the I2C slave Bus Functional Model
i2c_if      #(
      .I2C_ADDR_WIDTH(I2C_ADDR_WIDTH),
      .I2C_DATA_WIDTH(I2C_DATA_WIDTH)

    )
i2c_bus (

  .sda(sda),
  .scl(scl)


  );

// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSSES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );


endmodule
