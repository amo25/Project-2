////////////////////////////////////////////////////////////////
//  Filename     : mips.v
//  Module       : MIPS
//  Author       : L. Nazhand-Ali
//  Description  : single cycle MIPS 
//   
//     The top module of the single cycle MIPS is presented in this
//  file. You need to edit this module to complete the data path for
//  some of the instructions in your project.


module MIPS(clk, reset);

   input clk;
   input reset;

   // instruction and PC related wires
   wire [31:0] instruction;
   wire [31:0] PCplus4;
   wire [31:0] PC;
   
   // decoder related wires
   wire [5:0]  op, func;
   wire [4:0]  rs, rt, rd, shft;
   wire [15:0] imm16;
   wire [25:0] target;
   
   // control related wires
   wire        regWrite, regDst;
   wire        memRead, memWrite, memToReg;
   wire        extCntrl, ALUSrc;
   wire [3:0]  ALUCntrl;
   wire        branch, jump;
   wire			bne; //added bne control wire

   // ALU related wires
   wire [31:0] A, B, ALUout;
   wire        zero;

   // register file related wires
   wire [31:0] regData2;
   wire [4:0]  regDstAddr;

   // immediate related wires
   wire [31:0] immExtended;

   ///////////////////////////////////////////////
   // Put your new wires below this line
   //lw stuff
	wire [31:0] ReadData_DMEMout; //data memory output
	wire [31:0] writeData_muxOut;	//dmem mux output
	
	//beq stuff
   wire [31:0] shiftedExtendedImm_branchALUin; //branch ADD ALU input 2
   wire [31:0] computedBranchTargetAddress;		//branch target address, computed with the branchAdder
   wire branchAnd_out;
   wire [31:0] branchMuxOne_out; //output from the first branch mux, which is selecting between the branch ADDER computed target address and PC+4
   
   //bne stuff
   wire not_zero; //inverted zero output. 1 if operands are not equal
   wire bneAnd_out; //output from the notEqual & bne
   wire beq_or_bne_out;	//or beq and bne and gates
   //////////////////////////////////////////////
   
   //shift the sign extended immediate by 2
   SHIFT2 shiftExtendedImm
	(
		.word_out(shiftedExtendedImm_branchALUin),
		.word_in(immExtended)
	);
	
	//ADD ALU - for branch instructions
	//Takes shiftedExtendedImm_branchALUin and PC+4
	ADDER32 branchAdder
		(
			.result_out(computedBranchTargetAddress),
			.a_in(PC),								//TODO, datapath given in book uses PCplus4, but this gives me one further memory location than I want. So I'll use PC
			.b_in(shiftedExtendedImm_branchALUin)
			
		);
		
	//branch AND gate
	and branchAnd (branchAnd_out, branch, zero);
	
	//bne
	//not gate
	not bne_not(not_zero, zero);
	
	//AND gate
	and bneAnd(bneAnd_out, bne, not_zero);
	
	//or gate
	or beq_or_bne(beq_or_bne_out, bneAnd_out, branchAnd_out);
		
	//spit the ADDERs results out to a mux, which selects between it
	//and PCplus4. The selection is done via an and gate, which takes the branch input signal and the zero output of the main ALU
	MUX32_2X1 branchMuxOne
     (
      .value_out(branchMuxOne_out),
      .value0_in(PCplus4), 			
      .value1_in(computedBranchTargetAddress), 
      .select_in(beq_or_bne_out)
      );
	
	
   //TODO we can leave this as is right now, and put the branchMuxOne_out directly to the input of PC. Later, we will need to sever this connection and put it another mux, to implement jump.
   
   
   //ADD DATA MEMORY
   DMEM dmem
	(
		.data_out(ReadData_DMEMout),
		
		.clk(clk),
		.writeCntrl_in(memWrite),
		.readCntrl_in(memRead),
		.address_in(ALUout),
		.writeData_in(regData2)
	);
   
   // instantiation of a 32-bit MUX used for selecting between ALUResult (0) and data memory out (1) via MemtoReg
   MUX32_2X1 writeDataMux
     (
      .value_out(writeData_muxOut),
      .value0_in(ALUout), 
      .value1_in(ReadData_DMEMout), 
      .select_in(memToReg)
      );

   // instantiation of instruction memory
   IMEM	imem
     (
      .instruction_out(instruction),
      .address_in(PC)
      );


   // instantiation of register file
   REG_FILE reg_file
     (
      .clk(clk),
      .data1_out(A),
      .data2_out(regData2),
      .readAddr1_in(rs),
      .readAddr2_in(rt),
      .writeAddr_in(regDstAddr),
      .writeData_in(writeData_muxOut),	//Break original connection, give it the output of a mux which chooses between ALUout and DMEMout based on MemtoReg.
      .writeCntrl_in(regWrite)
      );

   // instantiation of PC register
   PC_REG pc_reg
     (
      .clk(clk),
      .reset(reset),
      .PC_out(PC),
      .PC_in(branchMuxOne_out)	//TODO break this connection, give it jump mux output
      );

   // instantiation of the decoder
   MIPS_DECODE	mips_decode
     (
      .instruction_in(instruction), 
      .op_out(op), 
      .func_out(func), 
      .rs_out(rs), 
      .rt_out(rt), 
      .rd_out(rd), 
      .shft_out(shft), 
      .imm16_out(imm16), 
      .target_out(target)
      );

   // instantiation of the control unit
   MIPS_CONTROL mips_control
     (
      .op_in(op),
      .func_in(func),
      .branch_out(branch), 
      .regWrite_out(regWrite), 
      .regDst_out(regDst), 
      .extCntrl_out(extCntrl), 
      .ALUSrc_out(ALUSrc), 
      .ALUCntrl_out(ALUCntrl), 
      .memWrite_out(memWrite),
      .memRead_out(memRead),
      .memToReg_out(memToReg), 
      .jump_out(jump),
	  .bne_out(bne)
      );

   // instantiation of the ALU
   MIPS_ALU mips_alu
     (
      .ALUCntrl_in(ALUCntrl), 
      .A_in(A), 
      .B_in(B), 
      .ALU_out(ALUout), 
      .zero_out(zero)
      );

   // instantiation of the sign/zero extender
   EXTEND extend
     (
      .word_out(immExtended),
      .halfWord_in(imm16),
      .extendCntrl_in(extCntrl)
      );

   // instantiation of a 32-bit adder used for computing PC+4
   ADDER32 plus4Adder
     (
      .result_out(PCplus4),
      .a_in(32'd4), 
      .b_in(PC)
      );

   // instantiation of a 32-bit MUX used for selecting between immediate and register as the second source of ALU
   MUX32_2X1 aluMux
     (
      .value_out(B),
      .value0_in(regData2), 
      .value1_in(immExtended), 
      .select_in(ALUSrc)
      );

   // instantiation of a 5-bit MUX used for selecting between RT or RD as the destination address of the operation
   MUX5_2X1 regMUX 
     (
      .value_out(regDstAddr),
      .value0_in(rt),
      .value1_in(rd),
      .select_in(regDst)
      );

endmodule