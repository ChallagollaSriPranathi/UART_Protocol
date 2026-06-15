`timescale 1ns/1ps

module baudrate_gen #(
    parameter CLK_FREQ  = 100_000_000,   // system clock frequency (Hz)
    parameter BAUD_RATE = 115200 
)(
    input  wire clock,
    input  wire reset,
    output reg  enb_tx,
    output reg  enb_rx
);

    // Divisors calculated from parameters
    localparam integer DIV_TX = CLK_FREQ / BAUD_RATE;
    localparam integer DIV_RX = CLK_FREQ / (16 * BAUD_RATE);

    // Dynamic counter widths to prevent bit-width warnings
    reg [$clog2(DIV_TX)-1:0] counter_tx;
    reg [$clog2(DIV_RX)-1:0] counter_rx;

    always @(posedge clock) begin
        if(reset) begin
            counter_tx <= 0;
            counter_rx <= 0;
            enb_tx     <= 1'b0;
            enb_rx     <= 1'b0;
        end else begin
            // TX counter
            if(counter_tx == (DIV_TX - 1)) begin
                counter_tx <= 0;
                enb_tx     <= 1'b1;
            end else begin
                counter_tx <= counter_tx + 1'b1;
                enb_tx     <= 1'b0;
            end

            // RX counter
            if(counter_rx == (DIV_RX - 1)) begin
                counter_rx <= 0;
                enb_rx     <= 1'b1;
            end else begin
                counter_rx <= counter_rx + 1'b1;
                enb_rx     <= 1'b0;
            end
        end
    end
endmodule
