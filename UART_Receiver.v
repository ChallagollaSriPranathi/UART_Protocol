`timescale 1ns / 1ps

module uart_receiver(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,
    input  wire       rdy_clr,
    input  wire       clk_en,      // 16x oversampling enable
    output reg        rdy,
    output reg [7:0]  data_out
);

    localparam start_state = 2'b00;
    localparam data_state  = 2'b01;
    localparam stop_state  = 2'b10;

    reg [1:0] state;
    reg [3:0] sample;
    reg [2:0] index;
    reg [7:0] temp_register;

    always @(posedge clk) begin
        if(rst) begin
            rdy           <= 1'b0;
            data_out      <= 8'b0;
            state         <= start_state;
            sample        <= 4'b0;
            index         <= 3'b0;
            temp_register <= 8'b0;
        end else begin
            if(rdy_clr) begin
                rdy <= 1'b0;
            end
            
            if(clk_en) begin
                case(state)
                    start_state: begin
                        if(rx == 1'b0 || sample != 4'b0) begin
                            if(sample == 4'h7) begin // Mid-point of start bit
                                if(rx == 1'b0) begin
                                    state  <= data_state;
                                    sample <= 4'b0;
                                    index  <= 3'b0;
                                end else begin
                                    state  <= start_state;
                                    sample <= 4'b0;
                                end
                            end else begin
                                sample <= sample + 1'b1;
                            end
                        end
                    end

                    data_state: begin
                        if(sample == 4'hF) begin // Sample next bits mid-period
                            sample               <= 4'b0;
                            temp_register[index] <= rx;
                            if(index == 3'h7) begin
                                state <= stop_state;
                            end else begin
                                index <= index + 1'b1;
                            end
                        end else begin
                            sample <= sample + 1'b1;
                        end
                    end

                    stop_state: begin
                        if(sample == 4'hF) begin
                            sample   <= 4'b0;
                            state    <= start_state;
                            if(rx == 1'b1) begin // Valid stop bit checked
                                data_out <= temp_register;
                                rdy      <= 1'b1;
                            end
                        end else begin
                            sample <= sample + 1'b1;
                        end
                    end

                    default: state <= start_state;
                endcase
            end
        end
    end
endmodule
