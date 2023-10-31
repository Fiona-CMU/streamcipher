module tt_um_Fiona_CMU (
  input  logic [7:0] ui_in,
  output logic [7:0] uo_out,
  input  logic [7:0] uio_in,
  output logic [7:0] uio_out,
  output logic [7:0] uio_oe,
  input  logic       ena,
  input  logic       clk,
  input  logic       rst_n);

  logic [7:0]       out, indrive, ct, in, index, lsr_low, lsr_high;
  logic             view, inc, enable, clock, reset_n;
  logic [31:0] lsr; //max 16 characters with a buffer byte for calculation

  assign uio_out = 8'b0000_0000;
  assign uio_oe  = 8'b0000_0000;
  assign uo_out  = out;

  assign ct = ui_in[1:0];

  assign view    = uio_in[2];
  //if high, view encrypted message
  //if low,  view decrypted message

  assign encrypt = uio_in[1];
  //encrypt if high

  assign inc   = uio_in[0];
  //increment the state (go to next symbol)

  always_ff@ (posedge inc, negedge rst_n) begin
    if(~rst_n) lsr <= 0;
    else if (encrypt & inc) lsr <= (ui_in ^ lsr[7:0]) + (lsr << 8);
  end

  always_comb begin
    if(~rst_n | encrypt) out <= 0;
    else begin
     if (view) begin
       if      (ct == 0) out <= lsr[7:0];
       else if (ct == 1) out <= lsr[15:8];
       else if (ct == 2) out <= lsr[23:16];
       else              out <= lsr[31:24];
      end
     else begin
       if      (ct == 0) out <= lsr[7:0]   ^ lsr[15:8];
       else if (ct == 1) out <= lsr[15:8]  ^ lsr[23:16];
       else if (ct == 2) out <= lsr[23:16] ^ lsr[31:24];
       else              out <= lsr[31:24];
     end
    end
  end

endmodule: tt_um_Fiona_CMU
