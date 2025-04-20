//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: Arithmetic Logic Unit (ALU) Module
//  Copyright 2025 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
/*
    phoeniX RV32IEM ALU: Designer Guidelines
    ==========================================================================================================================
    DESIGNER NOTICE:
    - Kindly adhere to the established guidelines and naming conventions outlined in the project documentation. 
    - Following these standards will ensure smooth integration of your custom-made modules into this codebase.
    - Thank you for your cooperation.
    ==========================================================================================================================
    ALU Approximation CSR
    - ALU CSR is addressed as 0x800 in control status registers.
    - One adder circuit is used for 3 integer instructions: ADD/ADDI/SUB
    - Internal signals are all generated according to phoeniX core "Self Control Logic" of the modules so designer won't 
      need to change anything inside this module (excepts parts which are considered for designers to instatiate their own 
      custom made designs).
    - Instantiate your modules (Approximate or Accurate) between the comments in the code.
    - How to work with the speical purpose CSR:
        CSR [0]       : APPROXIMATE = 1 | ACCURATE = 0
        CSR [2   : 1] : CIRCUIT_SELECT (Defined for switching between 4 accuarate or approximate circuits)
        CSR [7   : 3] : TRUNCATION_CONTROL
        CSR [11  : 8] : CUSTOM_FIELD_1
        CSR [15 : 12] : CUSTOM_FIELD_2
        CSR [31 : 16] : APPROXIMATION_ERROR_CONTROL

    - PLEASE DO NOT REMOVE ANY OF THE COMMENTS IN THIS FILE
    - Input and Output paramaters:
        Input:  control_status_register = {control_status_register[USER_ERROR_LEN:3], control_status_register[2:1] (module select), control_status_register[0]}
        Input:  adder_input_1 = First operand of your module
        Input:  adder_input_2 = Second operand of your module
        Input:  adder_C_in     = Input Carry
        Output: adder_result  = Module output
    ==========================================================================================================================
    - This unit executes R-Type and I-Type instructions
    - Inputs `rs1`, `rs2` comes from `Register_File` (DATA BUS)
    - Input `immediate` comes from `Immediate_Generator`
    - Input signals `opcode`, `funct3`, `funct7`, comes from `Instruction_Decoder`
*/

`include "Defines.v"

module Arithmetic_Logic_Unit
#(
    parameter GENERATE_CIRCUIT_1 = 1,
    parameter GENERATE_CIRCUIT_2 = 0,
    parameter GENERATE_CIRCUIT_3 = 0,
    parameter GENERATE_CIRCUIT_4 = 0
)
(
    input   wire [ 6 : 0] opcode,               
    input   wire [ 2 : 0] funct3,               
    input   wire [ 6 : 0] funct7,               

    input   wire [31 : 0] control_status_register,    

    input   wire [31 : 0] rs1,                 
    input   wire [31 : 0] rs2,                 
    input   wire [31 : 0] immediate,           

    output  wire [31 : 0] alu_output      
);

    wire  [31 : 0] operand_1; 
    wire  [31 : 0] operand_2;

    assign  operand_1   =   (   opcode == `OP   || 
                                opcode == `OP_IMM   ) ? rs1 : 
                                'bz;

    assign  operand_2   =   (   opcode == `OP       ) ? rs2 :
                            (   opcode == `OP_IMM   ) ? immediate :
                                'bz; 

    // ----------------------------------- //
    // Main R-type and I-type Instrcutions //
    // ----------------------------------- //
    
    assign  alu_output      =   (   (opcode == `OP_IMM) && (funct3 == `ADDI)    )   ?   adder_result                                                :
                                (   (opcode == `OP_IMM) && (funct3 == `SLLI)    )   ?   shift_result                                                :
                                (   (opcode == `OP_IMM) && (funct3 == `SLTI)    )   ?   ( $signed(operand_1) < $signed(operand_2) ? 32'd1 : 32'd0 ) :
                                (   (opcode == `OP_IMM) && (funct3 == `SLTIU)   )   ?   operand_1 < operand_2 ? 32'd1 : 32'd0                       :
                                (   (opcode == `OP_IMM) && (funct3 == `XORI)    )   ?   operand_1 ^ operand_2                                       :
                                (   (opcode == `OP_IMM) && (funct3 == `ORI)     )   ?   operand_1 | operand_2                                       :
                                (   (opcode == `OP_IMM) && (funct3 == `ANDI)    )   ?   operand_1 & operand_2                                       :
                                (   (opcode == `OP_IMM) && (funct3 == `SRI)     )   ?   shift_result                                                :
                                (   (opcode == `OP)     && (funct3 == `ADDSUB)  )   ?   adder_result                                                :
                                (   (opcode == `OP)     && (funct3 == `SLL)     )   ?   shift_result                                                :
                                (   (opcode == `OP)     && (funct3 == `SLT)     )   ?   ( $signed(operand_1) < $signed(operand_2) ? 32'd1 : 32'd0 ) :
                                (   (opcode == `OP)     && (funct3 == `SLTU)    )   ?   operand_1 < operand_2 ? 32'd1 : 32'd0                       :
                                (   (opcode == `OP)     && (funct3 == `XOR)     )   ?   operand_1 ^ operand_2                                       :
                                (   (opcode == `OP)     && (funct3 == `OR)      )   ?   operand_1 | operand_2                                       :
                                (   (opcode == `OP)     && (funct3 == `AND)     )   ?   operand_1 & operand_2                                       :
                                (   (opcode == `OP)     && (funct3 == `SR)      )   ?   shift_result                                                :
                                'bz;
    
    wire          shift_direction;
    wire [31 : 0] shift_input;
    wire [4  : 0] shift_amount;
    wire [31 : 0] shift_result;

    assign  shift_direction =   (   (opcode == `OP_IMM) && (funct3 == `SLLI)    )   ?   `LEFT   :
                                (   (opcode == `OP_IMM) && (funct3 == `SRI)     )   ?   `RIGHT  :
                                (   (opcode == `OP)     && (funct3 == `SLL)     )   ?   `LEFT   :
                                (   (opcode == `OP)     && (funct3 == `SR)      )   ?   `RIGHT  :
                                'bz;
    
    assign  shift_input     =   (   (opcode == `OP_IMM) && (funct3 == `SLLI)                            )   ?   operand_1           :
                                (   (opcode == `OP_IMM) && (funct3 == `SRI) && (funct7 == `LOGICAL)     )   ?   operand_1           :
                                (   (opcode == `OP_IMM) && (funct3 == `SRI) && (funct7 == `ARITHMETIC)  )   ?   $signed(operand_1)  :
                                (   (opcode == `OP)     && (funct3 == `SLL)                             )   ?   operand_1   :
                                (   (opcode == `OP)     && (funct3 == `SR) && (funct7 == `LOGICAL)      )   ?   operand_1           :
                                (   (opcode == `OP)     && (funct3 == `SR) && (funct7 == `ARITHMETIC)   )   ?   $signed(operand_1)  :
                                'bz;

    assign  shift_amount    =   (   (opcode == `OP_IMM) && (funct3 == `SLLI)    )   ?   operand_2[4 : 0]   :
                                (   (opcode == `OP_IMM) && (funct3 == `SRI)     )   ?   operand_2[4 : 0]   :
                                (   (opcode == `OP)     && (funct3 == `SLL)     )   ?   operand_2[4 : 0]   :
                                (   (opcode == `OP)     && (funct3 == `SR)      )   ?   operand_2[4 : 0]   :
                                'bz;
    // ----------------------------------------- //
    // Arithmetical Instructions: ADDI, ADD, SUB //
    // ----------------------------------------- //
    
    wire adder_enable;
    wire adder_C_in;
    wire [31 : 0] adder_input_1;
    wire [31 : 0] adder_input_2;
    wire [31 : 0] adder_result;
    
    wire  adder_0_enable;
    wire  adder_1_enable;
    wire  adder_2_enable;
    wire  adder_3_enable;

    wire [31 : 0] adder_0_result;
    wire [31 : 0] adder_1_result;
    wire [31 : 0] adder_2_result;
    wire [31 : 0] adder_3_result;

    // *** Implement the control systems required for your circuit ***
    assign  adder_enable    =   (   (opcode == `OP_IMM) && (funct3 == `ADDI)                    )   ?   `ENABLE :
                                (   (opcode == `OP) && (funct3 == `ADDSUB)                      )   ?   `ENABLE :
                                `DISABLE;
    
    assign  adder_C_in       =   (   (opcode == `OP_IMM) && (funct3 == `ADDI)                    )   ?   1'b0    :
                                (   (opcode == `OP) && (funct3 == `ADDSUB) && (funct7 == `ADD)  )   ?   1'b0    :
                                (   (opcode == `OP) && (funct3 == `ADDSUB) && (funct7 == `SUB)  )   ?   1'b1    :
                                'bz;

    assign  adder_input_1   =   (   (opcode == `OP_IMM) && (funct3 == `ADDI)                    )   ?   operand_1    :
                                (   (opcode == `OP) && (funct3 == `ADDSUB) && (funct7 == `ADD)  )   ?   operand_1    :
                                (   (opcode == `OP) && (funct3 == `ADDSUB) && (funct7 == `SUB)  )   ?   operand_1    :
                                'bz;

    assign  adder_input_2   =   (   (opcode == `OP_IMM) && (funct3 == `ADDI)                    )   ?   operand_2       :
                                (   (opcode == `OP) && (funct3 == `ADDSUB) && (funct7 == `ADD)  )   ?   operand_2       :
                                (   (opcode == `OP) && (funct3 == `ADDSUB) && (funct7 == `SUB)  )   ?   ~operand_2      :
                                'bz;

    assign adder_0_enable = (   adder_enable && (control_status_register[2 : 1] == 2'b00)   ) ? `ENABLE : `DISABLE;
    assign adder_1_enable = (   adder_enable && (control_status_register[2 : 1] == 2'b01)   ) ? `ENABLE : `DISABLE;
    assign adder_2_enable = (   adder_enable && (control_status_register[2 : 1] == 2'b10)   ) ? `ENABLE : `DISABLE;
    assign adder_3_enable = (   adder_enable && (control_status_register[2 : 1] == 2'b11)   ) ? `ENABLE : `DISABLE;

    assign adder_result =   (adder_0_enable) ? adder_0_result :
                            (adder_1_enable) ? adder_1_result :
                            (adder_2_enable) ? adder_2_result :
                            (adder_3_enable) ? adder_3_result : adder_0_result;

    // Instantiation of Barrel Shifter circuit
    // ---------------------------------------
    Barrel_Shifter alu_shifter_circuit
    (
        .input_value    (   shift_input     ),
        .shift_amount   (   shift_amount    ),
        .direction      (   shift_direction ),
        .result         (   shift_result    )
    );
    // ---------------------------------------
    // End of Barrel Shifter instantiation

    // *** Instantiate your adder circuit here ***
    // Please instantiate your adder module according to the guidelines and naming conventions of phoeniX
    // --------------------------------------------------------------------------------------------------
    generate 
        if (GENERATE_CIRCUIT_1)
        begin : Arithmetic_Logic_Unit_Adder_Circuit_Generate_Block_1
            // Circuit 1 (default) instantiation
            //----------------------------------
            Approximate_Accuracy_Controllable_Adder 
            #(
                .LEN(32),
                .APX_LEN(8)
            )
            approximate_accuracy_controllable_adder 
            (
                .Er     (   control_status_register[10 : 3] | {8{~control_status_register[0]}}  ), 
                .A      (   adder_input_1                                                       ),
                .B      (   adder_input_2                                                       ),
                .C_in   (   adder_C_in                                                          ),
                .Sum    (   adder_0_result                                                      ),
                .C_out  (                                                                       )  
            );
            //----------------------------------
            // End of Circuit 1 instantiation
        end
        if (GENERATE_CIRCUIT_2)
        begin : Arithmetic_Logic_Unit_Adder_Circuit_Generate_Block_2
            // Circuit 2 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 2 instantiation
        end
        if (GENERATE_CIRCUIT_3)
        begin : Arithmetic_Logic_Unit_Adder_Circuit_Generate_Block_3
            // Circuit 3 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 3 instantiation
        end
        if (GENERATE_CIRCUIT_4)
        begin : Arithmetic_Logic_Unit_Adder_Circuit_Generate_Block_4
            // Circuit 4 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 4 instantiation
        end
    endgenerate
    // --------------------------------------------------------------------------------------------------
    // *** End of adder module instantiation ***
endmodule

module Barrel_Shifter
(
    input   wire [31 : 0]   input_value, 
    input   wire [ 4 : 0]   shift_amount,
    input   wire            direction,  // direction = 1 : RIGHT, direction = 0 : LEFT

    output  wire [31 : 0]   result 
);

    wire [31 : 0] shift_mux_0; 
    wire [31 : 0] shift_mux_1; 
    wire [31 : 0] shift_mux_2; 
    wire [31 : 0] shift_mux_3; 
    wire [31 : 0] shift_mux_4; 
    wire [31 : 0] reversed;
     
    // reverse -> shift right -> then reverse again
    Reverser_Circuit #(.N(32)) RC1 (input_value, direction, reversed);

    // Stage 0: shift 0 or 1 bit
    assign shift_mux_0 = shift_amount[0] ? {1'b0,  reversed[31 : 1]} : reversed;
    // Stage 1: shift 0 or 2 bits 
    assign shift_mux_1 = shift_amount[1] ? {2'b0,  shift_mux_0[31 : 2]} : shift_mux_0;
    // Stage 2: shift 0 or 4 bits 
    assign shift_mux_2 = shift_amount[2] ? {4'b0,  shift_mux_1[31 : 4]} : shift_mux_1;
    // Stage 3: shift 0 or 8 bits 
    assign shift_mux_3 = shift_amount[3] ? {8'b0,  shift_mux_2[31 : 8]} : shift_mux_2;
    // Stage 4: shift 0 or 16 bits 
    assign shift_mux_4 = shift_amount[4] ? {16'b0, shift_mux_3[31 : 16]} : shift_mux_3;

    // Reverse again 
    Reverser_Circuit #(.N(32)) RC2 (shift_mux_4, direction, result);
endmodule

module Reverser_Circuit
#(
    parameter N = 32
)
(
    input   wire [N - 1 : 0]    input_value, 
    input   wire                enable, 
    output  wire [N - 1 : 0]    reversed_value
);

    wire [N - 1 : 0] temp;
    
    genvar i;
    generate    
        for (i = 0 ; i <= N - 1 ; i = i + 1)
        begin : Reverser_Circuit_Generate_Block
            assign temp[i] = input_value[N - 1 - i];
        end
    endgenerate
    // enable = 1 (RIGHT) -> reverse module does nothing 
    // enable = 0 (LEFT)  -> result = temp (reversed)
    assign reversed_value = enable ? input_value : temp;
endmodule

// Add your custom adder circuit here ***
// Please create your adder module according to the guidelines and naming conventions of phoeniX
// --------------------------------------------------------------------------------------------------
module Approximate_Accuracy_Controllable_Adder 
#(
    parameter LEN = 32,
    parameter APX_LEN = 8         // Valid Options for APX_LEN : 4, 8, 12, 16, ...
)
(
    input   wire [APX_LEN - 1 : 0]  Er,
    input   wire [LEN - 1 : 0]      A,
    input   wire [LEN - 1 : 0]      B,
    input   wire                    C_in,

    output  wire                    C_out,
    output  wire [LEN - 1 : 0]      Sum
);

    wire [LEN - 1 : 0] C;
    
    ////////////////////
    //    [3 : 0]     //
    ////////////////////

    Error_Configurable_Ripple_Carry_Adder 
    #(
        .LEN(4)
    ) 
    EC_RCA_1 
    (
        .Er     (   Er[3  : 0]  ),
        .A      (   A[3 : 0]    ), 
        .B      (   B[3 : 0]    ), 
        .C_in   (   C_in        ), 
        .C_out  (   C[3]        ),
        .Sum    (   Sum[3 : 0]  )        
    );
    
    ////////////////////
    //    [31 : 4]    //
    ////////////////////

    genvar i;
    generate
        
        // ------------------- //
        // Approximate Circuit //
        // ------------------- //

        for (i = 4; i < APX_LEN; i = i + 4)
        begin : Approximate_Accuracy_Controllable_Adder_Approximate_Part_Generate_Block
            wire HA_Carry;
            wire EC_RCA_Carry;
            wire [i + 3 : i] EC_RCA_Output;

            Half_Adder HA
            (
                .A      (   A[i]                ), 
                .B      (   B[i]                ),
                .C_out  (   HA_Carry            ),
                .Sum    (   EC_RCA_Output[i]    )
            );

            Error_Configurable_Ripple_Carry_Adder
            #(
                .LEN(3)
            )
            EC_RCA
            (
                .Er     (   Er[i + 3 : i + 1]               ),
                .A      (   A[i + 3 : i + 1]                ), 
                .B      (   B[i + 3 : i + 1]                ), 
                .C_in   (   HA_Carry                        ),
                .C_out  (   EC_RCA_Carry                    ),
                .Sum    (   EC_RCA_Output[i + 3 : i + 1]    )
            );

            wire BU_Carry;
            wire [i + 3 : i] BU_Output;

            Basic_Unit BU_1 
            (
                .A      (   EC_RCA_Output   ), 
                .B      (   BU_Output       ), 
                .C_out  (   BU_Carry        )
            );

            Mux_2to1 
            #(
                .LEN(5)
            )
            MUX
            (
                .data_in_1  (   {EC_RCA_Carry, EC_RCA_Output}           ),
                .data_in_2  (   {BU_Carry || EC_RCA_Carry, BU_Output}   ),
                .select     (   C[i - 1]                                ),
                .data_out   (   {C[i + 3], Sum[i + 3 : i]}              )
            );
        end
        
        // ------------- //
        // Exact Circuit //
        // ------------- //

        for (i = APX_LEN; i < LEN; i = i + 4)
        begin : Approximate_Accuracy_Controllable_Adder_Exact_Part_Generate_Block
            wire HA_Carry;
            wire RCA_Carry;
            wire [i + 3 : i] RCA_Output;

            Half_Adder HA
            (
                .A      (   A[i]            ), 
                .B      (   B[i]            ),
                .C_out  (   HA_Carry        ),
                .Sum    (   RCA_Output[i]   )
            );

            Ripple_Carry_Adder
            #(
                .LEN(3)
            )
            RCA
            (
                .A      (   A[i + 3 : i + 1]            ), 
                .B      (   B[i + 3 : i + 1]            ), 
                .C_in   (   HA_Carry                    ),
                .C_out  (   RCA_Carry                   ),
                .Sum    (   RCA_Output[i + 3 : i + 1]   )
            );

            wire BU_Carry;
            wire [i + 3 : i] BU_Output;

            Basic_Unit BU_1 
            (
                .A      (   RCA_Output  ), 
                .B      (   BU_Output   ), 
                .C_out  (   BU_Carry    )
            );

            Mux_2to1 
            #(
                .LEN(5)
            )
            MUX
            (
                .data_in_1  (   {RCA_Carry, RCA_Output}             ),
                .data_in_2  (   {BU_Carry || RCA_Carry, BU_Output}  ),
                .select     (   C[i - 1]                            ),
                .data_out   (   {C[i + 3], Sum[i + 3 : i]}          )
            );
        end
    endgenerate
    
    assign C_out = C[LEN - 1];
endmodule

module Basic_Unit 
(
    input   wire [3 : 0]    A,
    output  wire [4 : 1]    B,
    output  wire            C_out
);

    assign B[1] = ~A[0];
    assign B[2] = A[1] ^ A[0];
    wire   C1   = A[1] & A[0];
    wire   C2   = A[2] & A[3];
    assign C_out   = C1 & C2;
    wire   C3   = C1 & A[2];
    assign B[3] = A[2] ^ C1;
    assign B[4] = A[3] ^ C3;
endmodule

module Mux_2to1
#(
    parameter LEN = 5
) 
(
    input   wire [LEN - 1 : 0]  data_in_1,        
    input   wire [LEN - 1 : 0]  data_in_2,        
    input   wire                select,                   

    output  wire [LEN - 1: 0]   data_out            
);

    assign  data_out = (select) ? data_in_2 : data_in_1;
endmodule

module Error_Configurable_Ripple_Carry_Adder 
#(
    parameter LEN = 4
) 
(
    input   wire [LEN - 1 : 0]  Er,
    input   wire [LEN - 1 : 0]  A,
    input   wire [LEN - 1 : 0]  B,
    input   wire                C_in,

    output  wire                C_out,
    output  wire [LEN - 1 : 0]  Sum
);

    wire [LEN : 0] Carry;
    assign Carry[0] = C_in;

    genvar i;
    generate
        for (i = 0; i < LEN; i = i + 1)
        begin : Error_Configurable_Ripple_Carry_Adder_Generate_Block
            Error_Configurable_Full_Adder ECFA 
            (
                .Er     (   Er[i]           ),
                .A      (   A[i]            ), 
                .B      (   B[i]            ), 
                .C_in   (   Carry[i]        ),  
                .C_out  (   Carry[i + 1]    ),
                .Sum    (   Sum[i]          )
            );
        end
    endgenerate
    assign C_out = Carry[LEN];
endmodule

module Ripple_Carry_Adder 
#(
    parameter LEN = 4
) 
(
    input   wire    [LEN - 1 : 0]   A,
    input   wire    [LEN - 1 : 0]   B,
    input   wire                    C_in,

    output  wire                    C_out,
    output  wire    [LEN - 1 : 0]   Sum    
);

    wire [LEN : 0] Carry;
    assign Carry[0] = C_in;

    genvar i;
    generate
        for (i = 0; i < LEN; i = i + 1)
        begin : Ripple_Carry_Adder_Generate_Block
            Full_Adder FA 
            (
                .A      (   A[i]            ), 
                .B      (   B[i]            ), 
                .C_in   (   Carry[i]        ), 
                .C_out  (   Carry[i + 1]    ),
                .Sum    (   Sum[i]          )                
            );
        end
    endgenerate
    assign C_out = Carry[LEN];
endmodule

module Error_Configurable_Full_Adder
(
    input   wire Er,
    input   wire A,
    input   wire B, 
    input   wire C_in,

    output  wire C_out,
    output  wire Sum
);

    assign C_out = (Er && B && C_in) || ((B || C_in) && A);
    assign Sum = ~(Er && (A ^ B) && C_in) && ((A ^ B) || C_in);
endmodule

module Full_Adder 
(
    input   wire A,
    input   wire B,
    input   wire C_in,

    output  wire C_out,
    output  wire Sum
);

    assign C_out = (A && B) || (A && C_in) || (B && C_in);
    assign Sum = A ^ B ^ C_in;
endmodule

module Half_Adder 
(
    input   wire A,
    input   wire B,

    output  wire C_out,
    output  wire Sum
);

    assign C_out = A & B;
    assign Sum = A ^ B;
endmodule

// --------------------------------------------------------------------------------------------------
// *** End of adder module definition ***