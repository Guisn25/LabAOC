`timescale 1ns/1ps

module PC(
    input  logic        clock,
    input  logic        reset,
    input  logic        write,
    input  logic [31:0] PCin,
    
    output logic [31:0] PCout
);
    reg [31:0] PC_current;

    assign PCout = PC_current;
    always_ff @(posedge clock) begin
        if (reset) begin
            PC_current <= 32'b0; 
        end else if (write) begin
            PC_current <= PCin;
        end else begin
            PC_current <= PC_current;
        end
    end

endmodule
