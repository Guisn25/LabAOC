module DiplayBCD(
    input  [7:0] value,
    output [6:0] hex_ones,
    output [6:0] hex_tens,
    output [6:0] hex_hundreds
);
  logic [11:0] bcd;

  logic [3:0] ones, tens, hundreds;
  assign ones = bcd[11:8];
  assign tens = bcd[7:4];
  assign hundreds = bcd[3:0];
  reg [3:0] i;

  always @(value) begin
    bcd = 0;
    for(i = 0; i < 8; i = i + 1)begin
      bcd = {bcd[10:0], value[7-i]};

      if (i < 7 && bcd[3:0] > 4) bcd[3:0] = bcd[3:0] + 3;
      if (i < 7 && bcd[7:4] > 4) bcd[7:4] = bcd[7:4] + 3;
      if (i < 7 && bcd[11:8] > 4) bcd[11:8] = bcd[11:8] + 3;
    end
  end

  DecoderBCD ones_decoder (
      .value(ones),
      .bcd  (hex_ones)
  );

  DecoderBCD tens_decoder (
      .value(tens),
      .bcd  (hex_tens)
  );

  DecoderBCD hundreds_decoder (
      .value(hundreds),
      .bcd  (hex_hundreds)
  );
endmodule