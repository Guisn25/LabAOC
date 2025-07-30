module ROM #(
    parameter INIT_FILE = "synthesis/ROM_FIBO.mif",
    depth = 15
) (
    input clock,
    input logic [31:0] Address,
    output logic [31:0] DataOUT
);

  logic [15:0] Rom[2**depth];
  initial begin
    $readmemh(INIT_FILE, Rom);
  end
  always_ff @(posedge clock) begin
    DataOut <= {Rom[Address], Rom[Address+32'b1]};
  end
endmodule