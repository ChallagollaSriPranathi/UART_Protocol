`timescale 1ns / 1ps

module UART_top_tb;
    reg clk;
    reg rst;
    reg [7:0] data_in;
    reg wr_en;
    reg rdy_clr;
    
    wire rdy;
    wire busy;
    wire [7:0] data_out;
    
    integer i;

    uart_top dut(
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .wr_en(wr_en),
        .rdy_clr(rdy_clr),
        .rdy(rdy),
        .busy(busy),
        .data_out(data_out)
    );

    initial begin
        clk     = 0;
        rst     = 0;
        wr_en   = 0;
        rdy_clr = 0;
        data_in = 8'd0;
    end

    always #5 clk = ~clk; // 100MHz Simulation Clock Execution Ticks

    task send_byte(input [7:0] din);
    begin
        @(negedge clk);
        data_in = din;
        wr_en   = 1'b1;
        @(negedge clk);
        wr_en   = 1'b0;
    end
    endtask

    task clear_ready;
    begin
        @(negedge clk);
        rdy_clr = 1'b1;
        @(negedge clk);
        rdy_clr = 1'b0;
    end
    endtask

    initial begin
        rst = 1'b1;
        #200;
        rst = 1'b0;
        #200;
        
        for(i = 0; i <= 100; i = i + 1) begin
            send_byte(i[7:0]);
            wait(rdy); // Check structural alignment completion first
            $display("sent = %0d   received = %0d", i, data_out);
            clear_ready;
            wait(!busy); 
            #100; // Separation spacing window
        end
        
        #10000;
        $finish;
    end
endmodule
