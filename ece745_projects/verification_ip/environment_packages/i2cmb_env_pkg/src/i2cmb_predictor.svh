class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));

	ncsu_component#(.T(i2c_transaction)) scoreboard;
  i2c_transaction transport_trans;
  i2cmb_env_configuration configuration;
  

  parameter [1:0]
      wait_start = 2'b00,
      wait_slave_addr_op = 2'b01,
      wait_data = 2'b10;

  reg [1:0] current_state, next_state;

	function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    // this.transport_trans = new("PREDICTED_I2C_TRANS");
  	endfunction

  function void set_configuration(i2cmb_env_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void set_scoreboard(ncsu_component #(.T(i2c_transaction)) scoreboard);
      this.scoreboard = scoreboard;
  endfunction

  virtual function void nb_put(T trans);
     void'(predictor_fsm(trans));
    //scoreboard.nb_transport(trans, transport_trans);
  endfunction

  function void predictor_fsm(T trans);
    /* convert wb transactions into i2c transaction */
    case(current_state)
      wait_start: begin
                    if( trans.addr == 2'h2 && trans.data[2:0] == 3'b100 && trans.w_r == 1'b0)
                    begin
                       this.next_state = wait_slave_addr_op;
                     end
                    else
                    begin
                      this.next_state = wait_start;
                    end
                  end
      wait_slave_addr_op: begin
                            if(trans.addr == 2'h1 && trans.w_r == 1'b0)
                            begin
                              this.transport_trans = new("PREDICTED_I2C_TRANS");
                              this.transport_trans.addr = trans.data[7:1];
                              this.transport_trans.op = trans.data[0];
                              this.next_state = wait_data;
                            end
                            else
                            begin
                              this.next_state = wait_slave_addr_op;
                            end
                          end
      wait_data: begin
                  if(trans.addr == 2'h1) 
                  begin
                    this.transport_trans.data = new [this.transport_trans.data.size() + 1] (this.transport_trans.data);
                    this.transport_trans.data[this.transport_trans.data.size() - 1] = trans.data;
                  end

                  if(trans.addr == 2'h2 && trans.data[2:0] == 3'b100 && trans.w_r == 1'b0)
                  begin
                    // $display({get_full_name()," ",this.transport_trans.convert2string()});
                    this.next_state = wait_slave_addr_op;
                    this.scoreboard.nb_transport(transport_trans, null);
                  end
                  else if(trans.addr == 2'h2 && trans.data[2:0] == 3'b101 && trans.w_r == 1'b0)
                  begin
                    // $display({get_full_name()," ",this.transport_trans.convert2string()});
                    this.next_state = wait_start;
                    this.scoreboard.nb_transport(transport_trans, null);
                  end
                  else
                  begin
                    this.next_state = wait_data;
                  end
                 end 
      default : next_state = wait_start;
    endcase // current_state
    this.current_state = this.next_state;

  endfunction: predictor_fsm
endclass : i2cmb_predictor