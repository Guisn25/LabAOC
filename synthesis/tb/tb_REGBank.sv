`timescale 1ns/1ps

module tb_REGBank;

    logic        clock;
    logic        reset;
    logic        REGwrite;

    logic [4:0]  rs1;
    logic [4:0]  rs2;
    logic [4:0]  rd;

    logic [31:0] DATAwrite;

    logic [31:0] Data_A;
    logic [31:0] Data_B;

    REGBank dut(
        .clock(clock),
        .reset(reset),
        .REGwrite(REGwrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .DATAwrite(DATAwrite),
        .Data_A(Data_A),
        .Data_B(Data_B)
    );

    //--------------------------------------------------
    // clock generation
    //--------------------------------------------------

    always #5 clock = ~clock;
    //--------------------------------------------------
    // helper task
    //--------------------------------------------------

    task check(
        input [31:0] actual,
        input [31:0] expected,
        input [255:0] message,
        input REGWrite,
        input [31:0] Data_A,
        input [31:0] Data_B
    );
    begin
        if(actual !== expected) begin
            $display("FAIL: %s", message);
            $display("  expected = %h", expected);
            $display("  actual   = %h", actual);
            $display("Data_A: %h, Data_B: %h, REGWrite: %h", Data_A, Data_B, REGWrite);
        end
        else begin
            $display("PASS: %s", message);
        end
    end
    endtask

    //--------------------------------------------------
    // test sequence
    //--------------------------------------------------

    initial begin

        $dumpfile("tests/regbank.vcd");
        $dumpvars(0,tb_REGBank);

        clock     = 0;
        reset     = 0;
        REGwrite  = 0;
        rs1       = 0;
        rs2       = 0;
        rd        = 0;
        DATAwrite = 0;

        //--------------------------------------------------
        // RESET
        //--------------------------------------------------

        @(negedge clock);
        reset = 1;
    
        @(posedge clock);
        @(negedge clock);

        reset = 0;

        rs1 = 5;
        rs2 = 10;

        #5;

        check(Data_A, 0, "reset clears register 5", REGwrite, Data_A, Data_B);
        check(Data_B, 0, "reset clears register 10", REGwrite, Data_A, Data_B);

        //--------------------------------------------------
        // WRITE x5
        //--------------------------------------------------
        @(negedge clock);

        rd        = 5;
        DATAwrite = 32'h12345678;
        REGwrite  = 1;

        @(posedge clock);
        @(negedge clock);

        REGwrite = 0;

        rs1 = 5;

        #5;

        check(Data_A,
              32'h12345678,
              "write/read register x5", REGwrite, Data_A, Data_B);

        //--------------------------------------------------
        // WRITE x10
        //--------------------------------------------------
        @(negedge clock);

        rd        = 10;
        DATAwrite = 32'hCAFEBABE;
        REGwrite  = 1;

        @(posedge clock);
        @(negedge clock);

        REGwrite = 0;

        rs2 = 10;

        #5;

        check(Data_B,
              32'hCAFEBABE,
              "write/read register x10", REGwrite, Data_A, Data_B);

        //--------------------------------------------------
        // VERIFY x5 STILL OK
        //--------------------------------------------------
        @(negedge clock);

        rs1 = 5;

        #5;

        check(Data_A,
              32'h12345678,
              "x5 preserved", REGwrite, Data_A, Data_B);

        //--------------------------------------------------
        // x0 MUST STAY ZERO
        //--------------------------------------------------
        @(negedge clock);

        rd        = 0;
        DATAwrite = 32'hFFFFFFFF;
        REGwrite  = 1;

        @(posedge clock);
        @(negedge clock);

        REGwrite = 0;

        rs1 = 0;

        #5;

        check(Data_A,
              32'h00000000,
              "x0 remains zero", REGwrite, Data_A, Data_B);

        //--------------------------------------------------
        // OVERWRITE x5
        //--------------------------------------------------
        @(negedge clock);

        rd        = 5;
        DATAwrite = 32'hDEADBEEF;
        REGwrite  = 1;

        @(posedge clock);
        @(negedge clock);

        REGwrite = 0;

        rs1 = 5;

        #5;

        check(Data_A,
              32'hDEADBEEF,
              "overwrite x5", REGwrite, Data_A, Data_B);

        //--------------------------------------------------
        // RESET AGAIN
        //--------------------------------------------------
        @(negedge clock);

        reset = 1;

        @(posedge clock);
        @(negedge clock);

        reset = 0;

        rs1 = 5;
        rs2 = 10;

        #5;

        check(Data_A,
              32'h00000000,
              "reset clears x5", REGwrite, Data_A, Data_B);

        check(Data_B,
              32'h00000000,
              "reset clears x10", REGwrite, Data_A, Data_B);

        //--------------------------------------------------

        $display("REGBank tests completed.");

        #10;
        $finish;

    end

endmodule
