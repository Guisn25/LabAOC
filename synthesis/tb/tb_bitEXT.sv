`timescale 1ns/1ps

module tb_bitEXT;

    logic [31:0] Inst;
    logic [1:0]  Immtype;

    logic [31:0] Out;

    bitEXT dut (
        .Inst(Inst),
        .Immtype(Immtype),
        .Out(Out)
    );

    //----------------------------------------------------------
    // Check Task
    //----------------------------------------------------------

    task check(
        input [31:0] expected,
        input [255:0] msg
    );
    begin
        #1;
        if (Out !== expected) begin
            $display("FAIL: %s", msg);
            $display(" Expected: %h", expected);
            $display(" Got:      %h", Out);
        end
        else begin
            $display("PASS: %s", msg);
        end
    end
    endtask

    //----------------------------------------------------------
    // Test Sequence
    //----------------------------------------------------------

    initial begin

        $dumpfile("tests/bitEXT.vcd");
        $dumpvars(0, tb_bitEXT);

        //------------------------------------------------------
        // I-Type Positive Immediate
        //------------------------------------------------------

        Immtype = 2'b00;
        Inst = 32'h12345000;
        check(32'h00000123, "I-Type Positive");

        //------------------------------------------------------
        // I-Type Negative Immediate
        //------------------------------------------------------

        Immtype = 2'b00;
        Inst[31:20] = 12'hFFF;
        check(32'hFFFFFFFF, "I-Type Negative");

        //------------------------------------------------------
        // S-Type Positive Immediate
        //------------------------------------------------------

        Immtype = 2'b01;

        Inst = 32'b0;
        Inst[31:25] = 7'b0000001;
        Inst[11:7]  = 5'b00010;

        // Immediate = 000000100010 = 0x22

        check(32'h00000022, "S-Type Positive");

        //------------------------------------------------------
        // S-Type Negative Immediate
        //------------------------------------------------------

        Immtype = 2'b01;

        Inst = 32'b0;
        Inst[31] = 1'b1;
        Inst[30:25] = 6'b111111;
        Inst[11:7] = 5'b11111;

        check(32'hFFFFFFFF, "S-Type Negative (-1)");

        //------------------------------------------------------
        // B-Type Positive Immediate
        //------------------------------------------------------

        Immtype = 2'b10;

        Inst = 32'b0;

        // Immediate = 16

        Inst[11:8]  = 4'b1000;

        check(32'h00000010, "B-Type Positive");

        //------------------------------------------------------
        // B-Type Negative Immediate
        //------------------------------------------------------

        Immtype = 2'b10;

        Inst = 32'b0;

        Inst[31]    = 1;
        Inst[7]     = 1;
        Inst[30:25] = 6'b111111;
        Inst[11:8]  = 4'b1111;

        check(32'hFFFFFFFE, "B-Type Negative (-2)");

        //------------------------------------------------------
        // U-Type Positive Immediate
        //------------------------------------------------------

        Immtype = 2'b11;

        Inst = 32'h12345000;

        check(32'h00012345, "U-Type Positive");

        //------------------------------------------------------
        // U-Type Negative Immediate
        //------------------------------------------------------

        Immtype = 2'b11;

        Inst = 32'hF2345000;

        check(32'h000F2345, "U-Type Negative");

        //------------------------------------------------------

        $display("------------------------------------");
        $display("Bit Extender tests completed.");
        $display("------------------------------------");

        #10;
        $finish;

    end

endmodule
