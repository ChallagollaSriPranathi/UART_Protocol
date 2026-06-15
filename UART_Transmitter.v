`timescale 1ns / 1ps

module uart_transmitter(
    input  wire       clk,
    input  wire       wr_enb,
    input  wire       rst,
    input  wire [7:0] data_in,
    input  wire       enb,       // baud enable pulse
    output reg        tx,
    output wire       busy
);

    localparam idle_state  = 2'b00;
    localparam start_state = 2'b01;
    localparam data_state  = 2'b10;
    localparam stop_state  = 2'b11;

    reg [7:0] data;
    reg [2:0] index;
    reg [1:0] state;

    always @(posedge clk) begin
        if(rst) begin
            tx    <= 1'b1;       
            state <= idle_state;
            index <= 3'b000;
            data  <= 8'b0;
        end else begin
            case(state)
                idle_state: begin
                    tx <= 1'b1;
                    if(wr_enb) begin
                        state <= start_state;
                        data  <= data_in;
                        index <= 3'b000;
                        tx    <= 1'b0; // Pull low immediately for start bit
                    end
                end
                
                start_state: begin
                    if(enb) begin
                        state <= data_state;
                        tx    <= data[0];
                    end
                end
                
                data_state: begin
                    if(enb) begin
                        if(index == 3'h7) begin
                            state <= stop_state;
                            tx    <= 1'b1; // Drive stop bit high
                        end else begin
                            index <= index + 1'b1;
                            tx    <= data[index + 1'b1];
                        end
                    end
                end
                
                stop_state: begin
                    if(enb) begin
                        state <= idle_state;
                    end
                end
                
                default: begin
                    state <= idle_state;
                end
            endcase
        end
    end

    assign busy = (state != idle_state) || wr_enb;
endmodule
