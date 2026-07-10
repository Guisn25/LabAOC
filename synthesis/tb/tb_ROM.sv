`timescale 1ns/1ps

module tb_ROM;

    logic clock;
    logic [31:0] Address;
    logic [31:0] DataIn;
    logic        MEMWrite;
    logic [31:0] DataOut;

    ROM #(
        .INIT_FILE("test.mem"),
        .depth(4)
    ) dut (
        .clock(clock),
        .Address(Address),
        .DataIn(DataIn),
        .MEMWrite(MEMWrite),
        .DataOut(DataOut)
    );

    always #5 clock = ~clock;

    task check(
        input [31:0] expected,
        input [255:0] msg
    );
    begin
        if(DataOut !== expected) begin
            $display("FAIL: %s  @ t=%0t", msg, $time);
            $display(" expected=%h", expected);
            $display(" actual=%h", DataOut);
        end
        else begin
            $display("PASS: %s  @ t=%0t", msg, $time);
        end
    end
    endtask

    initial begin

        $dumpfile("tests/rom.vcd");
        $dumpvars(0,tb_ROM);

        clock   = 0;
        MEMWrite = 0;

        //--------------------------------------------------
        // Address 0
        //--------------------------------------------------

        @(negedge clock);
        Address = 0;

        @(posedge clock);

        @(negedge clock);
        check(
            32'h11112222,
            "Address 0"
        );

        //--------------------------------------------------
        // Address 2
        //--------------------------------------------------
        @(negedge clock);
        Address = 2;

        @(posedge clock);

        @(negedge clock);
        check(
            32'h33334444,
            "Address 2"
        );

        //--------------------------------------------------
        // Address 4
        //--------------------------------------------------
        @(negedge clock);
        Address = 4;
        DataIn = 32'h9999999;

        @(posedge clock);

        @(negedge clock);
        check(
            32'h55556666,
            "Address 4"
        );

        //--------------------------------------------------
        

        //--------------------------------------------------
        // Write/Read Address 0
        //--------------------------------------------------
       

        @(negedge clock);
        Address = 0;
        MEMWrite = 1;
        DataIn = 32'h12345678;

        @(posedge clock);
        
        @(negedge clock);
        MEMWrite = 0;
        check(
          32'h11112222,
          "Old Address 0"
          );
        @(posedge clock);

        @(negedge clock);
        check(
          32'h12345678,
          "New Address 0"
        );

        //--------------------------------------------------
        

        //--------------------------------------------------
        // Write/Read Address 0, 2 and last
        //--------------------------------------------------
        @(negedge clock);
        Address = 0;
        DataIn = 32'hCAFEBEBE;
        MEMWrite = 1;

        @(posedge clock);
        
        @(negedge clock);
        Address = 2;
        DataIn = 32'hDEADBEEF;
        MEMWrite = 1;

        @(posedge clock);

        @(negedge clock);
        Address = 14;
        DataIn = 32'h98765432;
        MEMWrite = 1;

        @(posedge clock);

        @(negedge clock);
        MEMWrite = 0;
        Address = 0;

        @(posedge clock);

        @(negedge clock);
        check(
          32'hCAFEBEBE,
          "W/R Address 0"
        );
        Address = 2;

        @(posedge clock);

        @(negedge clock);
        check(
          32'hDEADBEEF,
          "W/R Address 2"
          );
        Address = 14;

        @(posedge clock);

        @(negedge clock);
        check(
          32'h98765432,
          "W/R Address last"
        );

        //--------------------------------------------------
        //--------------------------------------------------
        // Overwrite Address 10
        //--------------------------------------------------
        
        @(negedge clock);
        Address = 10;
        DataIn = 32'hFFFFFFFF;
        MEMWrite = 1;

        @(posedge clock);

        @(negedge clock);
        Address = 10;
        DataIn = 32'h12341234;
        MEMWrite = 1;

        @(posedge clock);

        @(negedge clock);
        MEMWrite = 0;
        Address = 10;

        @(posedge clock);
        
        @(negedge clock)
        check(
          32'h12341234,
          "Overwrite Address 10"
        );


        //--------------------------------------------------

        $display("ROM tests completed");

        #10;
        $finish;

    end

endmodule
