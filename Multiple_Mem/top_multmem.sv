
module top;

timeunit      1ns;
timeprecision 1ns;

logic     clk = 0;
always #5 clk = ~clk;
  
//Instantiate two bus to communicate with two memory   
mem_intf busa(clk);
mem_intf busb(clk);

mem_test test (.busa(busa.tb), .busb(busb.tb));

mem memory_1 (.bus(busa.mem));  
mem memory_2 (.bus(busb.mem));

endmodule
