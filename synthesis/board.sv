module board(
    input         CLOCK_50,
    input  [17:0] SW,

    output [ 0:6] HEX0,
    output [ 0:6] HEX1,
    output [ 0:6] HEX2,
    output [ 0:6] HEX3,
    output [ 0:6] HEX4,
    output [ 0:6] HEX5,
    output [ 0:6] HEX6,
    output [ 0:6] HEX7,

    output [17:0] LEDR,
    output [ 8:0] LEDG,

    output        LCD_BLON,
    output [ 7:0] LCD_DATA,
    output        LCD_EN,
    output        LCD_ON,
    output        LCD_RS,
    output        LCD_RW,

    output [19:0] SRAM_ADDR,
    output        SRAM_CE_N,
    inout  [15:0] SRAM_DQ,
    output        SRAM_LB_N,
    output        SRAM_OE_N,
    output        SRAM_UB_N,
    output        SRAM_WE_N
);
    assign reset   = SW[17];
    assign LEDG[0] = reset;
    assign LEDG[1] = clock;
    
    logic clock, clk2, reset, read_write, stall;

    FREQDIV FREQDIV(
        .clock(CLOCK_50),
        .clock2(clk2)
    );
    assign clock = SW[16] ? clk2 : CLOCK_50;
    assign clock = clock & ~stall;
    
    logic [31:0] InputProc;
    proc RISCV(
        .clock(clock),
        .reset(reset),
        .In(InputProc),
        
        .ReadWrite(ReadWrite),
        .DataType(DataType),
        .DataOut(DataProc),
        .AddressOut(AddressProc)
    );
    logic ReadWrite;
    CTRL::data_size_t DataType;
    logic [31:0] DataProc, AddressProc;

    logic [15:0] RamOut, RamIn;
    logic RamAccess;
    assign RamAccess = AddressProc < 16'h800;

    assign RamOut = ReadWrite ? 8'bz : SRAM_DQ[15:0];
    
    assign SRAM_DQ = stall ? DataProc[31:16] : DataProc[15:0];
    assign SRAM_ADDR = {8'b0, AddressProc[11:0]} + stall;
    assign SRAM_CE_N = ~RamAccess;
    assign SRAM_LB_N = 0;
    assign SRAM_UB_N = (DataType == CTRL::Byte) ? 1 : 0;
    assign SRAM_WE_N = ~ReadWrite;
    assign SRAM_OE_N = ReadWrite;

    always_ff @(posedge clock) begin
        stall <= ~stall & (DataType == CTRL::Word);
    end

    logic [31:0] RomOut;
    logic RomAccess;
    assign RomAccess = AddressProc >= 16'h8000;
    ROM #(
        .INIT_FILE("synthesis/ROM_FIBO.mif"),
        .depth(15)
    )ProgROM(
        .clock(~clock),
        .Address (AddressProc[14:0]),
        .DataOut(RomOut)
    );

    assign PeripheralAccess = AddressProc >= 32'h800 && AddressProc < 32'h810; 
    logic [31:0] PeripheralOut;
    
    always_comb begin
        InputProc = 8'bz;
        if (PeripheralAccess) begin
            unique case (AddressProc) begin
                32'h800: begin
                    InputProc = ReadWrite ? 32'bz : {{16{1'b0}},SW[15:0]};
                end
                32'h801: begin
                    BCDInput = ReadWrite ? DataProc[7:0] : 32'bz;
                end
            end
        end else if (RomAccess) begin
            InputProc = RomOut;
        end else if (ram_cs) begin
            InputProc = RamOut;
        end
    end

    logic [7:0] BCDInput;
    bcd_display bcd_display (
      .value       (BCDInput),
      .hex_ones    (HEX2),
      .hex_tens    (HEX1),
      .hex_hundreds(HEX0)
    );
    
endmodule