
module top;

timeunit 1ns;
timeprecision 1ns;

logic clk = 0;
always #5 clk = ~clk;

mem_intf busa(clk);

mem_test test (.busa(busa.tb));

mem memory_1 (.busa(busa.mem));

endmodule
