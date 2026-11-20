module Encrypt(
    input [63:0]  plaintext  ,
    input [63:0]  secretKey  ,
    output [63:0] ciphertext 
);
    wire [63:0] state [0:10];
    wire [63:0] roundKey [0:10];

    assign state[0] = plaintext ^ secretKey;
    assign roundKey[0] = secretKey;

    genvar i;
    generate
        for (i=0; i<10; i = i+1) begin
            wire [63:0] nk;
            NextKey nk_inst (.currentKey(roundKey[i]), .nextKey(nk));
            assign roundKey[i+1] = nk;
            Round round_inst (.currentState(state[i]), .roundKey(roundKey[i+1]), .nextState(state[i+1]));
        end
    endgenerate

    assign ciphertext = state[10];

endmodule

module Round(
    input  [63:0] currentState ,
    input  [63:0] roundKey     ,
    output [63:0] nextState    
);
    wire [63:0] sub_out;
    wire [63:0] shift_out;

    SBox s0  (.in(currentState[63:60]), .out(sub_out[63:60]));
    SBox s1  (.in(currentState[59:56]), .out(sub_out[59:56]));
    SBox s2  (.in(currentState[55:52]), .out(sub_out[55:52]));
    SBox s3  (.in(currentState[51:48]), .out(sub_out[51:48]));
    SBox s4  (.in(currentState[47:44]), .out(sub_out[47:44]));
    SBox s5  (.in(currentState[43:40]), .out(sub_out[43:40]));
    SBox s6  (.in(currentState[39:36]), .out(sub_out[39:36]));
    SBox s7  (.in(currentState[35:32]), .out(sub_out[35:32]));
    SBox s8  (.in(currentState[31:28]), .out(sub_out[31:28]));
    SBox s9  (.in(currentState[27:24]), .out(sub_out[27:24]));
    SBox s10 (.in(currentState[23:20]), .out(sub_out[23:20]));
    SBox s11 (.in(currentState[19:16]), .out(sub_out[19:16]));
    SBox s12 (.in(currentState[15:12]), .out(sub_out[15:12]));
    SBox s13 (.in(currentState[11:8]),  .out(sub_out[11:8]));
    SBox s14 (.in(currentState[7:4]),   .out(sub_out[7:4]));
    SBox s15 (.in(currentState[3:0]),   .out(sub_out[3:0]));

    ShiftRows sr (.currentState(sub_out), .nextState(shift_out));

    AddRoundKey ark (.currentState(shift_out), .roundKey(roundKey), .nextState(nextState));
endmodule

module SBox(
    input [3:0]in ,
    output [3:0]out
);
assign out[0]=(in[2] & ~in[0]) | (~in[3] & ~in[1] & in[0]) | (in[3] & in[2] & in[1]) | (in[3] & in[1] & ~in[0]);
assign out[1]=(~in[2] & ~in[1]) | (in[0] & ~in[1]) | (~in[3] & in[2] & in[1] & ~in[0]) | (in[3] & ~in[2] & ~in[0]);
assign out[2]=(~in[3] & ~in[1] & ~in[0]) | (~in[3] & in[2] & ~in[0]) | (~in[2] & in[1] & in[0]) | (in[3] & ~in[2] & in[1]) | (in[3] & in[2] & ~in[1]);
assign out[3]=(~in[3] & in[2] & ~in[0]) | (in[2] & in[1] & in[0]) | (in[3] & in[2] & in[0]) | (in[3] & in[1] & in[0]) | (in[3] & ~in[2] & ~in[1] & ~in[0]) | (~in[3] & ~in[2] & ~in[1] & in[0]);
endmodule

module NextKey(
    input  [63:0] currentKey,
    output [63:0] nextKey
);
assign nextKey = {currentKey[59:0], currentKey[63:60]};
endmodule

module ShiftRows(
    input  [63:0] currentState ,
    output [63:0] nextState    
);
wire [3:0] x0 = currentState[63:60];
wire [3:0] x1 = currentState[59:56];
wire [3:0] x2 = currentState[55:52];
wire [3:0] x3 = currentState[51:48];
wire [3:0] x4 = currentState[47:44];
wire [3:0] x5 = currentState[43:40];
wire [3:0] x6 = currentState[39:36];
wire [3:0] x7 = currentState[35:32];
wire [3:0] x8 = currentState[31:28];
wire [3:0] x9 = currentState[27:24];
wire [3:0] a = currentState[23:20];
wire [3:0] b = currentState[19:16];
wire [3:0] c = currentState[15:12];
wire [3:0] d = currentState[11:8];
wire [3:0] e = currentState[7:4];
wire [3:0] f = currentState[3:0];

assign nextState[15:0] = currentState[15:0];
assign nextState[31:16] = {b, x8, x9, a};
assign nextState[47:32] = {x6, x7, x4, x5};
assign nextState[63:48] = {x1, x2, x3, x0}; 
endmodule

module AddRoundKey(
    input  [63:0] currentState ,
    input  [63:0] roundKey     ,
    output [63:0] nextState    
);
assign nextState = currentState ^ roundKey;
endmodule
