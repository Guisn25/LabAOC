`timescale 1ns/1ps

module ROM #(
  parameter INIT_FILE = "ROM_FIBO.mif",
  depth = 15
) (
  input clock,
  input logic [31:0] Address,
  input logic [31:0] DataIn,
  input CTRL::data_size_t MEMType,
  input logic        MEMWrite,
  output logic [31:0] DataOut
);

    logic [15:0] Rom[2**depth];
    initial begin
      $readmemh(INIT_FILE, Rom);
    end
    logic [15:0] DataHalf;
    logic [31:0] DataWord;
    always_comb begin
		DataHalf = 16'bz;
		DataWord  = 32'bz;
      case (MEMType)
        CTRL::HalfWord: begin
          DataHalf <= MEMWrite ? DataIn[15:0] : Rom[Address+32'b1]; 
        end

        CTRL::Word: begin
          DataWord <= MEMWrite ? DataIn : {Rom[Address], Rom[Address+32'b1]};
        end
      endcase
    end

    always_ff @(posedge clock) begin
      if(MEMWrite) begin
        case(MEMType)
          CTRL::HalfWord: begin
            Rom[Address] <= DataHalf;
          end
          
          CTRL::Word: begin
            {Rom[Address], Rom[Address+32'b1]} <= DataWord;
          end
        endcase
      end
      case (MEMType)
        CTRL::HalfWord: begin
          DataOut <= {{16{1'b0}}, DataHalf};
        end
        CTRL::Word: begin
          DataOut <= DataWord;
        end
      endcase
    end
endmodule
