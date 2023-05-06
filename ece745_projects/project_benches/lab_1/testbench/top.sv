`timescale 1ns / 10ps

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_BUSSES = 1;

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
  forever begin
     wb_bus.master_monitor( .addr(moniter_addr), .data(moniter_data), .we(monitor_we));
    $display("WB_ADDR : %d, WB_DATA : %d, WB_WE : %d", moniter_addr, moniter_data, monitor_we);
  end
 
end: wb_monitoring

// ****************************************************************************
// Define the flow of the simulation
initial begin: test_flow
  // example 1 : Write byte “1xxxxxxx” to the CSR register. This sets bit E to '1', enabling the core.
  wb_bus.master_write( .addr(2'h0), .data(8'b11xxxxxx));

  

  // example 3 : Write a byte 0x78 to a slave with address 0x22, residing on I2C bus #5.

  // 1. Write byte 0x05 to the DPR. This is the ID of desired I2C bus.
  wb_bus.master_write( .addr(2'h1), .data(8'h00));

  // 2. Write byte “xxxxx110” to the CMDR. This is Set Bus command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx110));
  
  // 3. Wait for interrupt or until DON bit of CMDR reads '1'.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);
  
  // 4. Write byte “xxxxx100” to the CMDR. This is Start command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx100));
  
  // 5. Wait for interrupt or until DON bit of CMDR reads '1'.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);
  
  // 6. Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left +
  // rightmost bit = '0', which means writing.
   wb_bus.master_write( .addr(2'h1), .data(8'h44));
  
  // 7. Write byte “xxxxx001” to the CMDR. This is Write command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx001));
  
  // 8. Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bit
  // is '1', then slave doesn't respond.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);
  
  // 9. Write byte 0x78 to the DPR. This is the byte to be written.
   wb_bus.master_write( .addr(2'h1), .data(8'h78));
  
  // 10.Write byte “xxxxx001” to the CMDR. This is Write command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx001));
  
  // 11.Wait for interrupt or until DON bit of CMDR reads '1'.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);
  
  // 12.Write byte “xxxxx101” to the CMDR. This is Stop command.
   wb_bus.master_write( .addr(2'h2), .data(8'bxxxxx101));
  
  // 13.Wait for interrupt or until DON bit of CMDR reads '1'.
  do begin
    wb_bus.master_read( .addr(2'h2), .data(data_read));
  end while(!data_read[7]);

end: test_flow

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
