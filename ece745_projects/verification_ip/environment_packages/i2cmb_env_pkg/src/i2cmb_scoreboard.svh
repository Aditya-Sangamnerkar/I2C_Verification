class i2cmb_scoreboard extends ncsu_component#(.T(i2c_transaction));
	
	function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
  	endfunction

  	T trans_in;
  	T trans_out;

  	virtual function void nb_transport(input T input_trans, output T output_trans);
  		this.trans_in = input_trans;
    	output_trans = trans_out;
    	//$display({get_full_name()," nb_transport: expected transaction ",input_trans.convert2string()});
    
  	endfunction

  	virtual function void nb_put(T trans);
    	//$display({get_full_name()," nb_put: actual transaction ",trans.convert2string()});
    	//$display({get_full_name()," nb_put: expected transaction ",this.trans_in.convert2string()});
    	if ( this.trans_in.compare(trans) )
    	begin
    	 	$display({get_full_name(),": i2c_transaction MATCH!"});
    	 end 
    		
    	else                                
    		$display({get_full_name(),": i2c_transaction MISMATCH!"});
    	// $display({get_full_name()," nb_put: actual transaction ",trans.convert2string()});
    	//$display({get_full_name()," nb_put: expected transaction ",this.trans_in.convert2string()});
  	endfunction
endclass : i2cmb_scoreboard