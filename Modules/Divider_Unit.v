//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: Divider Unit Module
//  Copyright 2024 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

/*
    phoeniX RV32IMX Divider: Designer Guidelines
    ==========================================================================================================================
    DESIGNER NOTICE:
    - Kindly adhere to the established guidelines and naming conventions outlined in the project documentation. 
    - Following these standards will ensure smooth integration of your custom-made modules into this codebase.
    - Thank you for your cooperation.
    ==========================================================================================================================
    Divider Approximation CSR:
    - DIV CSR is addressed as 0x802 in control status registers.
    - Divider circuit is used for the following M-Extension instructions: DIV/DIVU/REM/REMU
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
        Input:  clk           = Source clock signal
        Input:  control_status_register = {accuracy_control[USER_ERROR_LEN:3], accuracy_control[2:1] (module select), accuracy_control[0]}
        Input:  input_1       = First operand of your module
        Input:  input_2       = Second operand of your module
        Output: result        = Module division output
        Output: busy          = Module busy signal
    ==========================================================================================================================
*/

`include "Defines.v"

module Divider_Unit
#(
    parameter GENERATE_CIRCUIT_1 = 1,
    parameter GENERATE_CIRCUIT_2 = 0,
    parameter GENERATE_CIRCUIT_3 = 0,
    parameter GENERATE_CIRCUIT_4 = 0
)
(
    input wire clk, 

    input wire [ 6 : 0] opcode, 
    input wire [ 6 : 0] funct7, 
    input wire [ 2 : 0] funct3, 

    input wire [31 : 0] control_status_register, 

    input wire [31 : 0] rs1, 
    input wire [31 : 0] rs2, 

    output              divider_unit_busy,  
    output reg [31 : 0] divider_unit_output 
);

    reg  enable;

    reg  [31 : 0] operand_1; 
    reg  [31 : 0] operand_2;
    
    reg  [31 : 0] input_1;
    reg  [31 : 0] input_2;

    wire [ 7 : 0] divider_accuracy;
    wire [31 : 0] divider_input_1;   // Latched Module input 1
    wire [31 : 0] divider_input_2;   // Latched Module input 2
    
    wire [31 : 0] result;
    wire [31 : 0] remainder;

    wire divider_0_enable_wire;
    wire divider_1_enable_wire;
    wire divider_2_enable_wire;
    wire divider_3_enable_wire;
    
    reg  divider_0_enable;
    reg  divider_1_enable;
    reg  divider_2_enable;
    reg  divider_3_enable;

    wire [31 : 0] divider_0_result;
    wire [31 : 0] divider_1_result;
    wire [31 : 0] divider_2_result;
    wire [31 : 0] divider_3_result;

    wire [31 : 0] divider_0_remainder;
    wire [31 : 0] divider_1_remainder;
    wire [31 : 0] divider_2_remainder;
    wire [31 : 0] divider_3_remainder;

    wire divider_0_busy;
    wire divider_1_busy;
    wire divider_2_busy;
    wire divider_3_busy;

    reg reset_enable_signals = 0;
    reg [1 : 0] signal_state;
    reg [1 : 0] next_state;

    localparam signal_zero = 2'b00;
    localparam signal_high = 2'b01;
    localparam signal_low  = 2'b10;

    reg reset_controller_enable;
    reg state_machine_enable;

    always @(*) 
    begin
        operand_1 = rs1;
        operand_2 = rs2;
        if (!reset_enable_signals)
        begin
            case ({funct7, funct3, opcode})
                {`MULDIV, `DIV, `OP} : begin
                    input_1 = operand_1;
                    input_2 = $signed(operand_2);
                    divider_unit_output = result;
                    case (control_status_register[2 : 1])
                        2'b00:   begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b01:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b1; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b10:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b1; divider_3_enable = 1'b0; end
                        2'b11:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b1; end 
                        default: begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                    endcase
                end
                {`MULDIV, `DIVU, `OP} : begin
                    input_1 = operand_1;
                    input_2 = operand_2;
                    divider_unit_output = result;
                    case (control_status_register[2 : 1])
                        2'b00:   begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b01:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b1; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b10:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b1; divider_3_enable = 1'b0; end
                        2'b11:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b1; end 
                        default: begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                    endcase
                end
                {`MULDIV, `REM, `OP} : begin 
                    input_1 = operand_1;
                    input_2 = $signed(operand_2);
                    divider_unit_output = remainder;
                    case (control_status_register[2 : 1])
                        2'b00:   begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b01:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b1; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b10:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b1; divider_3_enable = 1'b0; end
                        2'b11:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b1; end 
                        default: begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                    endcase
                end
                {`MULDIV, `REMU, `OP} : begin
                    input_1 = operand_1;
                    input_2 = operand_2;
                    divider_unit_output = $signed(remainder);
                    case (control_status_register[2 : 1])
                        2'b00:   begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b01:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b1; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                        2'b10:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b1; divider_3_enable = 1'b0; end
                        2'b11:   begin divider_0_enable = 1'b0; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b1; end 
                        default: begin divider_0_enable = 1'b1; divider_1_enable = 1'b0; divider_2_enable = 1'b0; divider_3_enable = 1'b0; end
                    endcase
                end
                default: 
                begin 
                    divider_unit_output = 32'bz; 
                    divider_0_enable = 1'b0; divider_1_enable = 1'b0;
                    divider_2_enable = 1'b0; divider_3_enable = 1'b0;
                end              
            endcase
        end else if (reset_enable_signals) 
        begin
            divider_0_enable = 1'b0; divider_1_enable = 1'b0;
            divider_2_enable = 1'b0; divider_3_enable = 1'b0;
        end
    end

    assign divider_unit_busy = (divider_0_enable | divider_1_enable | divider_2_enable | divider_3_enable);

    always @(divider_0_busy or divider_1_busy or divider_2_busy or divider_3_busy or reset_controller_enable) 
    begin 
        if (!divider_0_busy) begin state_machine_enable <= 1; end 
        else if (!divider_1_busy) begin state_machine_enable <= 1; end 
        else if (!divider_2_busy) begin state_machine_enable <= 1; end
        else if (!divider_3_busy) begin state_machine_enable <= 1; end
        else if (reset_controller_enable) begin state_machine_enable <= 0; end
    end

    always @(posedge clk or negedge state_machine_enable) 
    begin
        if (!state_machine_enable) signal_state <= signal_zero;
        else signal_state <= next_state;
    end

    always @(*) 
    begin
        case (signal_state)
            signal_zero:   
                begin 
                    if (state_machine_enable) 
                    begin reset_enable_signals = 0; next_state = signal_high; reset_controller_enable = 0; end
                    else if (!state_machine_enable)
                    begin reset_enable_signals = 0; next_state = signal_low;  reset_controller_enable = 0; end
                end
            signal_high:   
                begin 
                    if (state_machine_enable) 
                    begin reset_enable_signals = 1; next_state = signal_low; reset_controller_enable = 0; end
                    else if (!state_machine_enable)
                    begin reset_enable_signals = 0; next_state = signal_low; reset_controller_enable = 0; end 
                end
            signal_low:    
                begin 
                    if (state_machine_enable) 
                    begin reset_enable_signals = 0; next_state = signal_low; reset_controller_enable = 1; end
                    else if (!state_machine_enable)
                    begin reset_enable_signals = 0; next_state = signal_low; reset_controller_enable = 0; end
                end
            default:       
                begin 
                    if (state_machine_enable) 
                    begin reset_enable_signals = 0; next_state = signal_low; reset_controller_enable = 1; end
                    else if (!state_machine_enable)
                    begin reset_enable_signals = 0; next_state = signal_low; reset_controller_enable = 0; end
                end
        endcase
    end

    assign divider_0_enable_wire = (!reset_enable_signals) ? divider_0_enable : 0;
    assign divider_1_enable_wire = (!reset_enable_signals) ? divider_1_enable : 0; 
    assign divider_2_enable_wire = (!reset_enable_signals) ? divider_2_enable : 0; 
    assign divider_3_enable_wire = (!reset_enable_signals) ? divider_3_enable : 0;  

    // Assigning divider circuits' inputs
    reg circuits_input_enable = 0;
    wire enables_combine = (divider_0_enable | divider_1_enable | divider_2_enable | divider_3_enable);
    always @(posedge enables_combine) 
    begin circuits_input_enable <= 1; end
    assign divider_input_1  = (circuits_input_enable) ? input_1 : 32'bz;
    assign divider_input_2  = (circuits_input_enable) ? input_2 : 32'bz;
    assign divider_accuracy = (circuits_input_enable) ? (control_status_register[10 : 3] | {8{~control_status_register[0]}}) : 8'bz;

    // Assigning divider circuits' results to top unit result
    assign result = (divider_0_enable) ? divider_0_result :
                    (divider_1_enable) ? divider_1_result :
                    (divider_2_enable) ? divider_2_result :
                    (divider_3_enable) ? divider_3_result : divider_0_result;
    
    // Assigning divider circuits' remainder results to top unit result
    assign remainder =  (divider_0_enable) ? divider_0_remainder :
                        (divider_1_enable) ? divider_1_remainder :
                        (divider_2_enable) ? divider_2_remainder :
                        (divider_3_enable) ? divider_3_remainder : divider_0_remainder;

    // *** Instantiate your divider here ***
    // Please instantiate your divider module according to the guidelines and naming conventions of phoeniX
    // ----------------------------------------------------------------------------------------------------
    generate 
        if (GENERATE_CIRCUIT_1)
        begin : Divider_1_Generate_Block
            // Circuit 1 (default) instantiation
            //----------------------------------
            sample_divider div
            (
                .clk(clk),
                .enable(divider_0_enable),
                .divider_input_1(divider_input_1),
                .divider_input_2(divider_input_2),
                .divider_result(divider_0_result),
                .divider_remainder(divider_0_remainder),
                .divider_busy(divider_0_busy)
            );
            //----------------------------------
            // End of Circuit 1 instantiation
        end
        if (GENERATE_CIRCUIT_2)
        begin : Divider_2_Generate_Block
            // Circuit 2 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 2 instantiation
        end
        if (GENERATE_CIRCUIT_3)
        begin : Divider_3_Generate_Block
            // Circuit 3 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 3 instantiation
        end
        if (GENERATE_CIRCUIT_4)
        begin : Divider_4_Generate_Block
            // Circuit 4 instantiation
            //-------------------------------

            //-------------------------------
            // End of Circuit 4 instantiation
        end
    endgenerate
    // ----------------------------------------------------------------------------------------------------
    // *** End of divider instantiation ***
endmodule

// Add your custom divider circuit here ***
// Please create your divider module according to the guidelines and naming conventions of phoeniX
// ----------------------------------------------------------------------------------------------------
module Approximate_Accuracy_Controlable_Divider
(  
    input  clk,                 // Clock signal

    input enable,

    input  [7  : 0] Er,         // Error rate

    input  [31 : 0] operand_1,  // Operand 1
    input  [31 : 0] operand_2,  // Operand 2

    output reg [31 : 0] div,    // Division result
    output reg [31 : 0] rem,    // Remainder
    output busy                 // = 1 while calculation
);

    reg active;                 // True if the divider is running  
    reg [4  : 0] cycle;         // Number of cycles to go  
    reg [31 : 0] result;        // Begin with operand_1, end with division result  
    reg [31 : 0] denom;         // Second operand (operand_2)  
    reg [31 : 0] work;          // remunning remainder

    wire c_out;
    wire [31 : 0] sub_module;
    wire [32 : 0] sub;

    // Calculate the current digit
    Approximate_Accuracy_Controlable_Adder_Div 
    #(
        .LEN(32),
        .APX_LEN(8)
    )
    approximate_subtract
    (
        .Er(Er),
        .A({work[30 : 0], result[31]}),
        .B(~denom),
        .Cin(1'b1),
        .Sum(sub_module),
        .Cout(c_out)
    );
    assign sub = {sub_module[31], sub_module}; // sign-extend

    wire [31 : 0] div_result;
    wire [31 : 0] rem_result;
    reg  [31 : 0] latched_div_result;
    reg  [31 : 0] latched_rem_result;
    
    always @(*) 
    begin
        if ((output_ready == 1))
        begin
            assign latched_div_result = div_result;  
            assign latched_rem_result = rem_result;
        end else begin
            assign latched_div_result = 32'bz;
            assign latched_rem_result = 32'bz;
        end
    end
    always @(*) 
    begin
        if ((output_ready == 1))
        begin
            div = latched_div_result;
            rem = latched_rem_result;
        end else begin
            div = 32'bz;
            rem = 32'bz;
        end
    end

    assign div_result = result;
    assign rem_result = work;

    assign output_ready = ~active;
    assign busy = ~output_ready;

    reg [4 : 0] enable_counter = 0;

    always @(posedge enable) 
    begin 
        cycle = 32'd0; //active = 1;
        enable_counter = enable_counter + 1'b1;
    end

    // The state machine  
    always @(posedge clk) 
    begin  
        if (active)
        begin  
            if (sub[32] == 0) 
            begin  
                work   <= sub[31 : 0];
                result <= {result[30 : 0], 1'b1};
            end  
            else 
            begin  
                work   <= {work[30 : 0], result[31]};
                result <= {result[30 : 0], 1'b0};
            end  
            if (cycle == 0) begin active <= 0; end  
            cycle <= cycle - 5'd1;
        end
        else
        begin  
            // Set up for an unsigned divide.  
            cycle  <= 5'd31;  
            result <= operand_1;  
            denom  <= operand_2;  
            work   <= 32'b0;  
            active <= 1;
        end  
    end  
endmodule

module Approximate_Accuracy_Controlable_Adder_Div 
#(
    parameter LEN = 32,
    parameter APX_LEN = 8         // Valid Options for APX_LEN : 4, 8, 12, 16, ...
)
(
    input [APX_LEN - 1 : 0] Er,
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input Cin,

    output [LEN - 1 : 0] Sum,
    output Cout
);

    wire [LEN - 1 : 0] C;
    
    ////////////////////
    //    [3 : 0]     //
    ////////////////////

    Error_Configurable_Ripple_Carry_Adder_Div #(.LEN(4)) EC_RCA_1 
    (
        .Er(Er[3  : 0]),
        .A(A[3 : 0]), 
        .B(B[3 : 0]), 
        .Cin(Cin), 
        .Sum(Sum[3 : 0]), 
        .Cout(C[3])
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
        begin
            wire HA_Carry;
            wire EC_RCA_Carry;
            wire [i + 3 : i] EC_RCA_Output;

            Half_Adder_Div HA
            (
                .A(A[i]), 
                .B(B[i]),
                .Sum(EC_RCA_Output[i]),
                .Cout(HA_Carry)
            );

            Error_Configurable_Ripple_Carry_Adder_Div
            #(
                .LEN(3)
            )
            EC_RCA
            (
                .Er(Er[i + 3 : i + 1]),
                .A(A[i + 3 : i + 1]), 
                .B(B[i + 3 : i + 1]), 
                .Cin(HA_Carry),
                .Sum(EC_RCA_Output[i + 3 : i + 1]),
                .Cout(EC_RCA_Carry)
            );

            wire BU_Carry;
            wire [i + 3 : i] BU_Output;

            Basic_Unit_Div BU_1 (.A(EC_RCA_Output), .B(BU_Output), .C0(BU_Carry));

            Mux_2to1_Div 
            #(
                .LEN(5)
            )
            MUX
            (
                .data_in_1({EC_RCA_Carry, EC_RCA_Output}),
                .data_in_2({BU_Carry || EC_RCA_Carry, BU_Output}),
                .select(C[i - 1]),
                .data_out({C[i + 3], Sum[i + 3 : i]})
            );
        end
        
        // ------------- //
        // Exact Circuit //
        // ------------- //

        for (i = APX_LEN; i < LEN; i = i + 4)
        begin
            wire HA_Carry;
            wire RCA_Carry;
            wire [i + 3 : i] RCA_Output;

            Half_Adder_Div HA
            (
                .A(A[i]), 
                .B(B[i]),
                .Sum(RCA_Output[i]),
                .Cout(HA_Carry)
            );

            Ripple_Carry_Adder_Div
            #(
                .LEN(3)
            )
            RCA
            (
                .A(A[i + 3 : i + 1]), 
                .B(B[i + 3 : i + 1]), 
                .Cin(HA_Carry),
                .Sum(RCA_Output[i + 3 : i + 1]),
                .Cout(RCA_Carry)
            );

            wire BU_Carry;
            wire [i + 3 : i] BU_Output;

            Basic_Unit_Div BU_1 (.A(RCA_Output), .B(BU_Output), .C0(BU_Carry));

            Mux_2to1_Div 
            #(
                .LEN(5)
            )
            MUX
            (
                .data_in_1({RCA_Carry, RCA_Output}),
                .data_in_2({BU_Carry || RCA_Carry, BU_Output}),
                .select(C[i - 1]),
                .data_out({C[i + 3], Sum[i + 3 : i]})
            );
        end

    endgenerate
    
    assign Cout = C[LEN - 1];
endmodule

module Basic_Unit_Div 
(
    input  [3 : 0] A,
    output [4 : 1] B,
    output C0
);

    assign B[1] =  ~A[0];
    assign B[2] = A[1] ^ A[0];
    wire   C1 = A[1] & A[0];
    wire   C2 = A[2] & A[3];
    assign C0 = C1 & C2;
    wire   C3 = C1 & A[2];
    assign B[3] = A[2] ^ C1;
    assign B[4] = A[3] ^ C3;
endmodule

module Mux_2to1_Div
#(
    parameter LEN = 5
) 
(
    input [LEN - 1 : 0] data_in_1,        
    input [LEN - 1 : 0] data_in_2,        
    input select,                   

    output reg [LEN - 1: 0] data_out            
);

    always @(*) 
    begin
        case (select)
            1'b0: begin data_out = data_in_1; end
            1'b1: begin data_out = data_in_2; end
            default: begin data_out = {LEN{1'bz}}; end
        endcase
    end
endmodule

module Error_Configurable_Ripple_Carry_Adder_Div 
#(
    parameter LEN = 4
) 
(
    input [LEN - 1 : 0] Er,
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input Cin,

    output [LEN - 1 : 0] Sum,
    output Cout
);
    wire [LEN : 0] Carry;
    assign Carry[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < LEN; i = i + 1)
        begin
            Error_Configurable_Full_Adder_Div ECFA 
            (
                .Er(Er[i]),
                .A(A[i]), 
                .B(B[i]), 
                .Cin(Carry[i]), 
                .Sum(Sum[i]), 
                .Cout(Carry[i + 1])
            );
        end
    assign Cout = Carry[LEN];
    endgenerate
endmodule

module Ripple_Carry_Adder_Div 
#(
    parameter LEN = 4
) 
(
    input [LEN - 1 : 0] A,
    input [LEN - 1 : 0] B,
    input Cin,

    output [LEN - 1 : 0] Sum,
    output Cout
);
    wire [LEN : 0] Carry;
    assign Carry[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < LEN; i = i + 1)
        begin
            Full_Adder_Div FA 
            (
                .A(A[i]), 
                .B(B[i]), 
                .Cin(Carry[i]), 
                .Sum(Sum[i]), 
                .Cout(Carry[i + 1])
            );
        end
    assign Cout = Carry[LEN];
    endgenerate
endmodule

module Error_Configurable_Full_Adder_Div
(
    input Er,
    input A,
    input B, 
    input Cin,

    output Sum, 
    output Cout
);
    assign Sum = ~(Er && (A ^ B) && Cin) && ((A ^ B) || Cin);
    assign Cout = (Er && B && Cin) || ((B || Cin) && A);
endmodule

module Full_Adder_Div 
(
    input A,
    input B,
    input Cin,

    output Sum,
    output Cout
);
    assign Sum = A ^ B ^ Cin;
    assign Cout = (A && B) || (A && Cin) || (B && Cin); 
endmodule

module Half_Adder_Div 
(
    input A,
    input B, 
    output Sum, 
    output Cout
);
    assign Sum = A ^ B;
    assign Cout = A & B;
endmodule

// ----------------------------------------------------------------------------------------------------
// *** End of divider module definition ***

module sample_divider
(
    input wire clk,
    input wire enable,
    input wire [31 : 0] divider_input_1,
    input wire [31 : 0] divider_input_2,
    output reg [31 : 0] divider_result,
    output reg [31 : 0] divider_remainder,
    output reg divider_busy
);
    reg [2 : 0] count;
    
    always @(posedge clk) 
    begin
        if (~enable)	
        begin
            count <= 3'd0;
            divider_busy <= 1'b0;
        end
        
        else if (count == 3'd7)
        begin
            count <= 3'd0;
            divider_result <= divider_input_1 / divider_input_2;
            divider_remainder <= divider_input_1 % divider_input_2;
            divider_busy <= 1'b0;
        end
        
        else
        begin 
            divider_busy <= 1;
            count <= count + 3'd1;
        end 
    end
endmodule
