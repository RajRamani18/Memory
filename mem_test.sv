
module mem_test ( mem_intf.tb busa );

timeunit      1ns;
timeprecision 1ns;

bit         debug = 1;  //1 - to display each addr and data
bit         ok;         //Check randomization is successful or not
logic [7:0] rand_data;  //randmize this var for data
logic [7:0] rdata;      //stores data read from memory for verification

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

    $display("Random Data Test");
    for(int i = 0; i < 32; i++)
    begin
        ok = randomize(rand_data) with {rand_data dist {[8'h41:8'h5a] := 4, [8'h61:8'h7a] := 1}; };
                                                          //A : Z weight 80%    a : z weight 20%
        busa.write_mem(i, rand_data, debug);
        busa.read_mem(i, rdata, debug);
        error_status = checkit(i, rdata, rand_data);
    end
    printstatus(error_status);// print results of test
    
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
