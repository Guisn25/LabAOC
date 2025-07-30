module FREQDIV(
    input clock,
    output reg clock2
);
  reg [27:0] counter = 28'd0;
  parameter DIVISOR = 28'd200000;
  always @(posedge clock) begin
    counter <= counter + 28'd1;
    if (counter >= (DIVISOR - 1)) counter <= 28'd0;
    clock2 <= (counter < DIVISOR / 2) ? 1'b1 : 1'b0;
  end
endmodule