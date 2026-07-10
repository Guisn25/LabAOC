`timescale 1ns/1ps

module board(
    input         CLOCK_50,
    //input         reset    //remover  
    input  [17:0] SW,

    //output [ 0:6] HEX0,
    //output [ 0:6] HEX1,
    //output [ 0:6] HEX2,
    //output [ 0:6] HEX3,
    //output [ 0:6] HEX4,
    //output [ 0:6] HEX5,
    //output [ 0:6] HEX6,
    //output [ 0:6] HEX7,

    //output [17:0] LEDR,
    output [ 8:0] LEDG

    //output        LCD_BLON,
    //output [ 7:0] LCD_DATA,
    //output        LCD_EN,
    //output        LCD_ON,
    //output        LCD_RS,
    //output        LCD_RW,

);
    
    logic clock, clk; 
    logic reset; 
    logic read_write, stall;
    logic ReadWrite;
    CTRL::data_size_t DataType;
    logic [31:0] DataProc; 
    logic [7:0]  AddressProc; //talvez mudar
    logic [15:0] RamOut, RamIn;
    FREQDIV FREQDIV(
        .clock_in(CLOCK_50),
        .clock_out(clk)
    );
    assign clock = SW[16] ? clk : CLOCK_50;
    //assign clock = clock & ~stall;
    //assign clock = CLOCK_50; //trocar 
    assign LEDG[1] = clock;
    assign reset   = SW[17];
    assign LEDG[0] = reset;
    logic [31:0] InputProc;
    proc RISCV(
        .clock(clock),  //mudar depois
        .reset(reset),
        .In(InputProc),
        
        .ReadWrite(ReadWrite),
        .DataType(DataType),
        .DataOut(DataProc),
        .AddressOut(AddressProc)
    );

    logic RamAccess;
    assign RamAccess = AddressProc > 8'hA0;

    //always_ff @(posedge clock) begin
      //  stall <= ~stall & (DataType == CTRL::Word);
    //end

    logic [31:0] RomOut;
    logic RomAccess;
    assign RomAccess = AddressProc <= 8'h80;
    ROM #(
        .INIT_FILE("test.mem"),
        .depth(9)
    )ProgROM(
        .clock(~clock),
        .Address(AddressProc),
        .DataIn(DataProc),
        .MEMType(DataType),
        .MEMWrite(ReadWrite),
        .DataOut(RomOut)
    );

    assign PeripheralAccess = AddressProc > 8'h80 && AddressProc <= 8'hA0; 
    logic [31:0] PeripheralOut;
    logic [7:0] BCDInput;
    always_comb begin
        InputProc = 8'bz;
		  BCDInput = 8'bz;
        if (PeripheralAccess) begin
            unique case (AddressProc)
                32'h82: begin
                    InputProc = ReadWrite ? 32'bz : {{16{1'b0}},SW[15:0]};
                end
                32'h84: begin
                    BCDInput = ReadWrite ? DataProc[7:0] : 32'bz;
                end
              endcase
        end else 
          if (RomAccess) begin
            InputProc = RomOut;
        end else if (RamAccess) begin
            InputProc = RamOut;
        end
    end

    //DisplayBCD bcd_display (
      //.value       (BCDInput),
      //.hex_ones    (HEX2),
      //.hex_tens    (HEX1),
      //.hex_hundreds(HEX0)
    //);
endmodule
