`timescale 1ns/1ps

module REG(
    input  logic        clock,
    input  logic        reset,
    input  logic        write,
    input  logic [31:0] In,
    
    output logic [31:0] Out
);
    
    reg [31:0] data;

    assign Out = data;
    always_ff @(posedge clock) begin
        if (reset) begin
            data <= 32'b0;
        end else if (write) begin
            data <= In;
        end else begin
            data <= data;
        end
    end    
    
endmodule
