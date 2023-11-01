module tt_um_Fiona_CMU (
  input  logic [7:0] ui_in,
  output logic [7:0] uo_out,
  input  logic [7:0] uio_in,
  output logic [7:0] uio_out,
  output logic [7:0] uio_oe,
  input  logic       ena,
  input  logic       clk,
  input  logic       rst_n);

  logic [7:0]       out;
  logic [2:0]       ct;
  logic             view, inc;

  logic [63:0] lsr;
  //max 8 characters (bytes) can be held at a time
  //pushing beyond this limit will lose previous characters
  //all values except for the last can still be encrypted in this case

  assign uio_out = 8'b0000_0000;
  assign uio_oe  = 8'b0000_0000;
  assign uo_out  = out;

  assign ct = ui_in[2:0];
  //when not encrypting, used to control which byte of data is being viewed

  assign view = uio_in[2];
  //if high, view encrypted message
  //if low,  view decrypted message

  assign encrypt = uio_in[1];
  //if high, message is stored and encrypted
  //if low,  message can only be viewed

  assign inc   = uio_in[0];
  //used when encryting to indicate to the system that input is valid

  always_ff@ (posedge inc, negedge rst_n) begin
    if(~rst_n) lsr <= 0;
    else if (encrypt & inc) lsr <= (ui_in ^ lsr[7:0]) + (lsr << 8);
  end

  always_comb begin
    if(~rst_n | encrypt) out <= 0;
    else begin
     if (view) begin
       //viewing encrypted message
       if      (ct == 0)  out <= lsr[7:0];
       else if (ct == 1)  out <= lsr[15:8];
       else if (ct == 2)  out <= lsr[23:16];
       else if (ct == 3)  out <= lsr[31:24];
       else if (ct == 4)  out <= lsr[39:32];
       else if (ct == 5)  out <= lsr[47:40];
       else if (ct == 6)  out <= lsr[55:48];
       else               out <= lsr[63:56];
   end
     else begin
       //viewing decrypted message
       if      (ct == 0)  out <= lsr[7:0]   ^ lsr[15:8];
       else if (ct == 1)  out <= lsr[15:8]  ^ lsr[23:16];
       else if (ct == 2)  out <= lsr[23:16] ^ lsr[31:24];
       else if (ct == 3)  out <= lsr[31:24] ^ lsr[39:32];
       else if (ct == 4)  out <= lsr[39:32] ^ lsr[47:40];
       else if (ct == 5)  out <= lsr[47:40] ^ lsr[55:48];
       else if (ct == 6)  out <= lsr[55:48] ^ lsr[63:56];
       else               out <= lsr[63:56];
      end
    end
  end
endmodule: tt_um_Fiona_CMU
