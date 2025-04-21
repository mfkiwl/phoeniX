//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: Immediate Generation Unit Module
//  Copyright 2025 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.v"

module Immediate_Generator 
(
	input   wire [31 : 7] instruction,
	input   wire [ 2 : 0] instruction_type,

	output  wire [31 : 0] immediate
);

    assign  immediate   =   (instruction_type == `I_TYPE) ? { {21{instruction[31]}}, instruction[30 : 20] }                                                 :
                            (instruction_type == `S_TYPE) ? { {21{instruction[31]}}, instruction[30 : 25], instruction[11 : 7] }                            :
                            (instruction_type == `B_TYPE) ? { {20{instruction[31]}}, instruction[7], instruction[30 : 25], instruction[11 : 8], 1'b0 }      :
                            (instruction_type == `U_TYPE) ? { instruction[31 : 12], {12{1'b0}} }                                                            :
                            (instruction_type == `J_TYPE) ? { {12{instruction[31]}}, instruction[19 : 12], instruction[20], instruction[30 : 21], 1'b0 }    :
                            32'bz;
endmodule