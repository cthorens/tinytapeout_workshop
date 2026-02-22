/*
* Copyright (c) 2024 Renaldas Zioma
* based on the VGA examples by Uri Shaked
* SPDX-License-Identifier: Apache-2.0
*/

`default_nettype none

module tt_um_cthorens_cpu(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

parameter MEM_SIZE = 256;

localparam r0 = 0;
// localparam r1 = 1;
// localparam r2 = 2;
localparam r3 = 3;

reg [7:0] MEM [0:MEM_SIZE-1];
reg [7:0] RegisterBank [0:3];
reg [7:0] PC;

wire [7:0] instr;
wire [3:0] low_pc_rel;

integer i;

initial begin
  for (i=0;i<MEM_SIZE;i++) begin
    MEM[i] = 8'b00000000;
  end

  MEM[0] = 8'b00000000;
  MEM[1] = 8'b00000000;
  MEM[2] = 8'b00000000;
  MEM[3] = 8'b00000000;
  MEM[4] = 8'b00100001; // jrel +2
  MEM[5] = 8'b00000000;
  MEM[6] = 8'b00000000;
  MEM[7] = 8'b00010011; // movlow 1
  MEM[8] = 8'b00110100; // movhigh 3
  MEM[9] = 8'b01000101; // mov r0 in r1
  MEM[10] = 8'b01110011; // movlow 7
  MEM[11] = 8'b00000100; // movhigh 0
  MEM[12] = 8'b10000101; // mov r0 into r2
  MEM[13] = 8'b01100110; // add r1 = r1 + r2
  MEM[14] = 8'b10000011; // movlow 8
  MEM[15] = 8'b00000100; // movhigh 0
  MEM[16] = 8'b11000101; // mov r0 into r3
  MEM[17] = 8'b01110111; // sub r1 = r1 - r3
  MEM[18] = 8'b11010101; // mov r1 into r3
  MEM[19] = 8'b10111000; // shift left r3 by 2
  MEM[20] = 8'b11111001; // shift right r3 by 3
  MEM[21] = 8'b10111001; // shift right r3 by 2
  MEM[22] = 8'b00000000;
  MEM[23] = 8'b00000000;
  MEM[24] = 8'b11100001; // jrel -2

  PC = 8'b00000000;
end

assign low_pc_rel = PC[3:0] + instr[7:4];

always @(posedge clk)
begin
  if(instr[3:0] == 4'b0001) begin
    PC <= { PC[7:4], low_pc_rel };
  end
  else begin
    PC <= PC+1;
  end

  case (instr[3:0])
    4'b0011: RegisterBank[r0][3:0] <= instr[7:4]; // movlow
    4'b0100: RegisterBank[r0][7:4] <= instr[7:4]; // movhigh
    4'b0101: RegisterBank[instr[7:6]] <= RegisterBank[instr[5:4]]; // movreg
    4'b0110: RegisterBank[instr[7:6]] <= RegisterBank[instr[7:6]] + RegisterBank[instr[5:4]]; // add
    4'b0111: RegisterBank[instr[7:6]] <= RegisterBank[instr[7:6]] - RegisterBank[instr[5:4]]; // sub
    4'b1000: RegisterBank[instr[5:4]] <= RegisterBank[instr[5:4]] << instr[7:6]; // shift left
    4'b1001: RegisterBank[instr[5:4]] <= RegisterBank[instr[5:4]] >> instr[7:6]; // shift right
    default: ;
  endcase
end

assign instr = MEM[PC];
assign uo_out = RegisterBank[r3];

endmodule
