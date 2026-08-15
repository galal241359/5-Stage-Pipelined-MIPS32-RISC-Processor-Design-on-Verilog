`timescale 1ns/1ps

module mips_tb();

    reg clk;
    reg rst;
     mips_top uut (
        .clk(clk),
        .rst(rst)
    );
     always #5 clk = ~clk;

    initial begin
         clk = 0;
        rst = 1;
         $display("Time\tRST\tPC\t\tInstruction\tALU_Result");
        $monitor("%0t ns\t%b\t%h\t%h\t%h", $time, rst, uut.pc, uut.instr, uut.alu_result);
         #25;
        rst = 0; 
         #2000;
         $display("Simulation finished successfully.");
        $stop;
    end

endmodule