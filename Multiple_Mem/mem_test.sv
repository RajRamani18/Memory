module mem_test ( mem_intf.tb busa,
                  mem_intf.tb busb );

timeunit      1ns;
timeprecision 1ns;

bit         debug = 1;  //1 - to display each addr and data
bit         ok;         //Check randomization is successful or not
logic [7:0] rand_data;  //randmize this var for data
  
  class memcls;
        randc bit [4:0] addr; //cyclic randomization 
        rand  bit [7:0] data;
              bit [7:0] rdata; 

        virtual interface mem_intf vif;
                
        constraint data_dist { data dist   {[8'h41:8'h5A] := 4, [8'h61:8'h7A] := 1}; }
        
        function new(input int init_addr = 0, input int init_data = 0);
            addr = init_addr;
            data = init_data;
        endfunction
        
        function void cnfg(virtual interface mem_intf aif);
            vif = aif;
            if(vif == null) 
                $display ("vif config error");
        endfunction
        
        task write_mem (input debug = 0);
        @(negedge vif.clk); 
            vif.write   <= 1; 
            vif.read    <= 0; 
            vif.addr    <= addr; 
            vif.data_in <= data;
        
        @(negedge vif.clk); 
            vif.write <= 0;
        
        if(debug == 1)
            $display("Write Data = %h %c @ Address = %d ", data, data, addr);        
    endtask : write_mem

    task read_mem(input debug = 0);
        @(negedge vif.clk); 
            vif.write <= 0; 
            vif.read  <= 1; 
            vif.addr  <=addr;
        
        @(negedge vif.clk); 
            vif.read <= 0; 
            rdata = vif.data_out;
        
        if(debug == 1)
            $display("Read Data = %h %c @ Address = %d", rdata, rdata, addr);           
    endtask
        
  endclass

  memcls mem_rnd_1, mem_rnd_2;  
  
  initial begin
      $timeformat ( -9, 0, " ns", 9 );  //units_number=ns , precision_number=decimal point , suffix_string , minimum_field_width
      #40000ns $display ( "MEMORY TEST TIMEOUT" );
      $finish;
    end

initial
  begin: memtest
  int error_status;

    mem_rnd_1 = new(0,0);
    mem_rnd_1.cnfg(busa);
    
    mem_rnd_2 = new(0,0);
    mem_rnd_2.cnfg(busb);
    
    $display("Random Data Test to Memory 1");
    for (int i = 0; i < 32; i++)
    begin
       ok = mem_rnd_1.randomize();
       mem_rnd_1.write_mem (1);
       mem_rnd_1.read_mem  (1);
       error_status = checkit (mem_rnd_1.addr, mem_rnd_1.rdata, mem_rnd_1.data);
    end
    printstatus(error_status);

    $display("Random Data Test to Memory 2");
    for (int i = 0; i < 32; i++)
    begin
       ok = mem_rnd_2.randomize();
       mem_rnd_2.write_mem (1);
       mem_rnd_2.read_mem  (1);
       error_status = checkit (mem_rnd_2.addr, mem_rnd_2.rdata, mem_rnd_2.data);
    end
    printstatus(error_status);

    $finish;
  end

//Function to read written data and determine no of error
function int checkit (input [4:0] address,
                      input [7:0] actual,
                      input [7:0] expected );
    static int error_status;
    if(actual !== expected) begin
        $display("ERROR @ Data = %h Expected = %h @ Address = %h",
                          actual,   expected,       address);
        error_status++;                          
    end                  
endfunction : checkit

//Show either test passes or failed with x no of errors
function void printstatus(input integer status);
    if(status == 0)
        $display("Test Passed!");
    else
        $display("Test Failed with %d Errors", status);
endfunction : printstatus

endmodule
