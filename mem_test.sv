
module mem_test ( mem_intf.tb busa );

timeunit      1ns;
timeprecision 1ns;

bit         debug = 1;  //1 - to display each addr and data
bit         ok;         //Check randomization is successful or not
logic [7:0] rand_data;  //randmize this var for data
logic [7:0] rdata;      //stores data read from memory for verification

typedef enum bit[1:0] {ascii, uc, lc, uclc} control_t;  
  
  class memcls;
        randc bit [4:0] addr; //cyclic randomization 
        rand  bit [7:0] data; 
        
        control_t ctrl;
        
        constraint data_dist { ctrl == ascii -> data inside {[8'h20:8'h7F]};
                               ctrl == uc    -> data inside {[8'h41:8'h5A]};
                               ctrl == lc    -> data inside {[8'h61:8'h7A]};
                               ctrl == uclc  -> data dist   {[8'h41:8'h5A] := 4, [8'h61:8'h7A] := 1}; }
        
        function new(input int init_addr = 0, input int init_data = 0);
            addr = init_addr;
            data = init_data;
        endfunction
  endclass

  memcls mem_rnd;  
  
  initial begin
      $timeformat ( -9, 0, " ns", 9 );  //units_number=ns , precision_number=decimal point , suffix_string , minimum_field_width
      #40000ns $display ( "MEMORY TEST TIMEOUT" );
      $finish;
    end

initial
  begin: memtest
  int error_status;

    $display("Clear Memory Test");

    for (int i = 0; i < 32; i++)
       busa.write_mem(i, 0, debug);  //Write zero data to every address location
        
    for (int i = 0; i < 32; i++)
      begin 
       busa.read_mem(i, rdata, debug);   //Read every address location
       error_status = checkit (i, rdata, 8'h00);    //Check each memory location for data = 'h00
      end
    
    printstatus(error_status);  // print results of test

    $display("Data = Address Test");

    for (int i = 0; i < 32; i++)
       busa.write_mem(i, i, debug);  // Write data = address to every address location    
       
    for (int i = 0; i < 32; i++)
      begin
        busa.read_mem(i, rdata, debug);  // Read every address location
        error_status = checkit (i, rdata, i);   // check each memory location for data = address
      end

    printstatus(error_status);// print results of test

    mem_rnd = new(0,0);
    
    $display("Random Data Test - ASCII");
    mem_rnd.ctrl = ascii;
    for (int i = 0; i < 32; i++)
    begin
       ok = mem_rnd.randomize();
       busa.write_mem (mem_rnd.addr, mem_rnd.data, 1);
       busa.read_mem  (mem_rnd.addr, rdata, 1);
       error_status = checkit (mem_rnd.addr, rdata, mem_rnd.data);
    end
    printstatus(error_status);

    $display("Random Data Test - Upper case");
    mem_rnd.ctrl = uc;
    for (int i = 0; i < 32; i++)
    begin
       ok = mem_rnd.randomize();
       busa.write_mem (mem_rnd.addr, mem_rnd.data, 1);
       busa.read_mem  (mem_rnd.addr, rdata, 1);
       error_status = checkit (mem_rnd.addr, rdata, mem_rnd.data);
    end
    printstatus(error_status);

    $display("Random Data Test Lower Case");
    mem_rnd.ctrl = lc;
    for (int i = 0; i < 32; i++)
    begin
       ok = mem_rnd.randomize();
       busa.write_mem (mem_rnd.addr, mem_rnd.data, 1);
       busa.read_mem  (mem_rnd.addr, rdata, 1);
       error_status = checkit (mem_rnd.addr, rdata, mem_rnd.data);
    end
    printstatus(error_status);

    $display("Random Data Test - Upper/Lower case distribution");
    mem_rnd.ctrl = uclc;
    for (int i = 0; i < 32; i++)
    begin
       ok = mem_rnd.randomize();
       busa.write_mem (mem_rnd.addr, mem_rnd.data, 1);
       busa.read_mem  (mem_rnd.addr, rdata, 1);
       error_status = checkit (mem_rnd.addr, rdata, mem_rnd.data);
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
