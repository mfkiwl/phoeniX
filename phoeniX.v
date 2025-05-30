//  The phoeniX RISC-V Processor
//  A Reconfigurable Embedded Platform for Approximate Computing and Fault-Tolerant Applications

//  Description: The phoeniX Processor Top Module
//  Copyright 2024 Iran University of Science and Technology. <phoenix.digital.electronics@gmail.com>

//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.

`include "Defines.v"
`include "Fetch_Unit.v"
`include "Instruction_Decoder.v"
`include "Immediate_Generator.v"
`include "Register_File.v"
`include "Register_Loading_Table.v"
`include "Arithmetic_Logic_Unit.v"
`include "Jump_Branch_Unit.v"
`include "Address_Generator.v"
`include "Load_Store_Unit.v"
`include "Hazard_Forward_Unit.v"
`include "Control_Status_Unit.v"
`include "Control_Status_Register_File.v"
`include "Divider_Unit.v"
`include "Multiplier_Unit.v"

module phoeniX 
#(
    parameter   RESET_ADDRESS               = 32'h0000_0000,
    parameter   M_EXTENSION                 = 1'b0,
    parameter   E_EXTENSION                 = 1'b0
) 
(
    input   wire    clk,
    input   wire    reset,

    //////////////////////////////////////////
    // Instruction Memory Interface Signals //
    //////////////////////////////////////////
    output  wire                instruction_memory_interface_enable,
    output  wire                instruction_memory_interface_state,
    output  wire    [31 : 0]    instruction_memory_interface_address,
    output  wire    [ 3 : 0]    instruction_memory_interface_frame_mask,
    input   wire    [31 : 0]    instruction_memory_interface_data, 

    ///////////////////////////////////
    // Data Memory Interface Signals //
    ///////////////////////////////////
    output  wire                data_memory_interface_enable,
    output  wire                data_memory_interface_state,
    output  wire    [31 : 0]    data_memory_interface_address,
    output  wire    [ 3 : 0]    data_memory_interface_frame_mask,
    inout   wire    [31 : 0]    data_memory_interface_data
);

    wire [2 : 1] stall_condition;
    // 1 -> Stall Condition 1 corresponds to instructions with multi-cycle execution
    // 2 -> Stall Condition 2 corresponds to instructions with dependencies on previous instructions whose values are not available in the pipeline

    // --------------------------------------
    // Wire Declarations for Fetch Stage (FE)
    // --------------------------------------
    wire [31 : 0] next_pc_FE_wire;

    // -------------------------------------
    // Reg Declarations for Fetch Stage (FE)
    // -------------------------------------
    reg [31 : 0] pc_FE_reg;

    // ------------------------
    // Fetch Unit Instantiation
    // ------------------------
    Fetch_Unit fetch_unit
    (
        .enable                         (   !reset && !(|stall_condition[2 : 1])        ),              
        
        .pc                             (   pc_FE_reg                                   ),
        .next_pc                        (   next_pc_FE_wire                             ),

        .memory_interface_enable        (   instruction_memory_interface_enable         ),
        .memory_interface_state         (   instruction_memory_interface_state          ),
        .memory_interface_address       (   instruction_memory_interface_address        ),
        .memory_interface_frame_mask    (   instruction_memory_interface_frame_mask     )    
    );

    wire [31 : 0] address_EX_wire;
    wire jump_branch_enable_EX_wire;

    wire [31 : 0] pc_write_value;
    assign pc_write_value = (jump_branch_enable_EX_wire) ? address_EX_wire : next_pc_FE_wire;

    wire [31 : 0] instruction;
    assign instruction = (jump_branch_enable_EX_wire) ? `NOP : instruction_memory_interface_data;

    // ------------------------
    // Program Counter Register 
    // ------------------------
    always @(posedge clk or posedge reset)
    begin
        if (reset)
            pc_FE_reg <= RESET_ADDRESS;

        else if (!(|stall_condition[2 : 1]))
            pc_FE_reg <= pc_write_value; 
    end
    
    // ------------------------------------------
    // Register Declarations for Decode Stage (DE)
    // ------------------------------------------
    reg [31 : 0] pc_DE_reg;
    reg [31 : 0] next_pc_DE_reg;
    reg [31 : 0] instruction_DE_reg;

    // --------------------
    // Instruction Register 
    // --------------------
    always @(posedge clk or posedge reset) 
    begin
        if (reset)
            instruction_DE_reg <= `NOP;

        else if (!(|stall_condition[2 : 1]))
            instruction_DE_reg <= instruction;
    end

    //////////////////////////////////////
    //    FETCH TO DECODE TRANSITION    //
    //////////////////////////////////////
    always @(posedge clk) 
    begin
        if (!(|stall_condition[2 : 1]))    
        begin
            pc_DE_reg <=  pc_FE_reg;
            next_pc_DE_reg <= next_pc_FE_wire;
        end
    end
    // --------------------------------------
    // Wire Declarations for Decode Procedure
    // --------------------------------------
    wire [ 2 : 0] instruction_type_DE_wire;
    wire [ 6 : 0] opcode_DE_wire;
    wire [ 2 : 0] funct3_DE_wire;
    wire [ 6 : 0] funct7_DE_wire;
    wire [11 : 0] funct12_DE_wire;

    wire [ 4 : 0] read_index_1_DE_wire;
    wire [ 4 : 0] read_index_2_DE_wire;
    wire [ 4 : 0] write_index_DE_wire;
    wire [11 : 0] csr_index_DE_wire;

    wire read_enable_1_DE_wire;
    wire read_enable_2_DE_wire;
    wire write_enable_DE_wire;

    wire csr_read_enable_DE_wire;
    wire csr_write_enable_DE_wire;

    wire [31 : 0] immediate_DE_wire;

    // ---------------------------------
    // Instruction Decoder Instantiation
    // ---------------------------------
    Instruction_Decoder instruction_decoder
    (
        .instruction        (   instruction_DE_reg          ),

        .instruction_type   (   instruction_type_DE_wire    ),
        .opcode             (   opcode_DE_wire              ),
        .funct3             (   funct3_DE_wire              ),
        .funct7             (   funct7_DE_wire              ),
        .funct12            (   funct12_DE_wire             ),

        .read_index_1       (   read_index_1_DE_wire        ),
        .read_index_2       (   read_index_2_DE_wire        ),
        .write_index        (   write_index_DE_wire         ),
        .csr_index          (   csr_index_DE_wire           ),

        .read_enable_1      (   read_enable_1_DE_wire       ),
        .read_enable_2      (   read_enable_2_DE_wire       ),
        .write_enable       (   write_enable_DE_wire        ),

        .csr_read_enable    (   csr_read_enable_DE_wire     ),
        .csr_write_enable   (   csr_write_enable_DE_wire    )
    );

    // ---------------------------------
    // Immediate Generator Instantiation
    // --------------------------------- 
    Immediate_Generator immediate_generator
    (
        .instruction        (   instruction_DE_reg[31 : 7]  ),
        .instruction_type   (   instruction_type_DE_wire    ),
        .immediate          (   immediate_DE_wire           )
    );

    // ----------------------------------------------------------------------
    // Wire Declaration for Reading From Register File and Forwarding Sources
    // ---------------------------------------------------------------------- 
    wire [31 : 0] RF_source_1;
    wire [31 : 0] RF_source_2;

    wire [31 : 0] FW_source_1;
    wire [31 : 0] FW_source_2;
    
    wire FW_enable_1;
    wire FW_enable_2;

    // -----------------------------------------------
    // Wire Declaration for inputs to source bus 1 & 2
    // ----------------------------------------------- 
    wire [31 : 0] rs1_DE_wire;
    wire [31 : 0] rs2_DE_wire;

    // -----------------------------------------------------------------------------------
    // assign inputs to source bus 1 & 2  --> to be selected between RF source and FW data
    // -----------------------------------------------------------------------------------
    assign rs1_DE_wire = FW_enable_1 ? FW_source_1 : RF_source_1;
    assign rs2_DE_wire = FW_enable_2 ? FW_source_2 : RF_source_2;
    
    // ---------------------------------------------------
    // Wire Declaration for Reading From CSR Register File
    // ---------------------------------------------------
    wire [31 : 0] csr_data_DE_wire;

    // ---------------------------------------
    // Reg Declarations for Execute Stage (EX)
    // ---------------------------------------
    reg [31 : 0] pc_EX_reg;
    reg [31 : 0] next_pc_EX_reg;

    reg [ 2 : 0] instruction_type_EX_reg;
    reg [ 6 : 0] opcode_EX_reg;
    reg [ 2 : 0] funct3_EX_reg;
    reg [ 6 : 0] funct7_EX_reg;
    reg [11 : 0] funct12_EX_reg;

    reg [ 4 : 0] write_index_EX_reg;
    reg [ 4 : 0] read_index_1_EX_reg;
    reg [11 : 0] csr_index_EX_reg;

    reg write_enable_EX_reg;
    reg csr_write_enable_EX_reg;
    
    reg [31 : 0] immediate_EX_reg;

    reg [31 : 0] rs1_EX_reg;
    reg [31 : 0] rs2_EX_reg;
    reg [31 : 0] csr_data_EX_reg;

    ////////////////////////////////////////
    //    DECODE TO EXECUTE TRANSITION    //
    ////////////////////////////////////////
    always @(posedge clk) 
    begin
        if (jump_branch_enable_EX_wire || (!(stall_condition[1]) & stall_condition[2]))
        begin
            write_enable_EX_reg <= `DISABLE;  
            rs1_EX_reg <= 32'd0;
            rs2_EX_reg <= 32'd0;

            opcode_EX_reg <= `NOP_opcode;
            funct3_EX_reg <= `NOP_funct3;
            funct7_EX_reg <= `NOP_funct7;
            funct12_EX_reg <= `NOP_funct12;

            immediate_EX_reg <= `NOP_immediate;
            instruction_type_EX_reg <= `NOP_instruction_type;
            write_index_EX_reg <= `NOP_write_index;
        end

        else if (!(|stall_condition[2 : 1]))
        begin
            pc_EX_reg <= pc_DE_reg;
            next_pc_EX_reg <= next_pc_DE_reg;
            
            
            instruction_type_EX_reg <= instruction_type_DE_wire;
            opcode_EX_reg <= opcode_DE_wire;
            funct3_EX_reg <= funct3_DE_wire;
            funct7_EX_reg <= funct7_DE_wire;
            funct12_EX_reg <= funct12_DE_wire;

            immediate_EX_reg <= immediate_DE_wire; 
            
            rs1_EX_reg <= rs1_DE_wire;
            rs2_EX_reg <= rs2_DE_wire;

            write_index_EX_reg <= write_index_DE_wire;
            write_enable_EX_reg <= write_enable_DE_wire;

            csr_write_enable_EX_reg <= csr_write_enable_DE_wire;
            csr_index_EX_reg <= csr_index_DE_wire;
            csr_data_EX_reg <= csr_data_DE_wire;
            read_index_1_EX_reg <= read_index_1_DE_wire;
        end
    end

    // ------------------------------------
    // Wire Declaration for Execution Units
    // ------------------------------------
    wire [31 : 0] alucsr_wire;
    wire [31 : 0] mulcsr_wire;
    wire [31 : 0] divcsr_wire;

    wire [31 : 0] alu_output_EX_wire;
    wire [31 : 0] mul_output_EX_wire;
    wire [31 : 0] div_output_EX_wire;

    wire mul_busy_EX_wire;
    wire div_busy_EX_wire;

    wire [31 : 0] csr_rd_EX_wire;
    wire [31 : 0] csr_data_out_EX_wire;

    // -----------------------------------
    // Arithmetic Logic Unit Instantiation
    // -----------------------------------
    Arithmetic_Logic_Unit
    #(
        .GENERATE_CIRCUIT_1(1),
        .GENERATE_CIRCUIT_2(0),
        .GENERATE_CIRCUIT_3(0),
        .GENERATE_CIRCUIT_4(0)
    )  
    arithmetic_logic_unit
    (
        .opcode                     (   opcode_EX_reg       ),
        .funct3                     (   funct3_EX_reg       ),
        .funct7                     (   funct7_EX_reg       ),
        .control_status_register    (   alucsr_wire         ),    
        .rs1                        (   rs1_EX_reg          ),
        .rs2                        (   rs2_EX_reg          ),
        .immediate                  (   immediate_EX_reg    ),
        .alu_output                 (   alu_output_EX_wire  )
    );

    // -------------------------------------
    // Multiplier/Divider Unit Instantiation
    // -------------------------------------
    generate if (M_EXTENSION)
    begin : M_EXTENSION_Generate_Block
        Multiplier_Unit
        #(
            .GENERATE_CIRCUIT_1(0),
            .GENERATE_CIRCUIT_2(1),
            .GENERATE_CIRCUIT_3(0),
            .GENERATE_CIRCUIT_4(0)
        ) 
        multiplier_unit
        (
            .clk                        (   clk                 ),
            .opcode                     (   opcode_EX_reg       ),
            .funct3                     (   funct3_EX_reg       ),
            .funct7                     (   funct7_EX_reg       ),
            .control_status_register    (   mulcsr_wire         ),    
            .rs1                        (   rs1_EX_reg          ),
            .rs2                        (   rs2_EX_reg          ),
            .multiplier_unit_busy       (   mul_busy_EX_wire    ),
            .multiplier_unit_output     (   mul_output_EX_wire  )
        );

        Divider_Unit
        #(
            .GENERATE_CIRCUIT_1(1),
            .GENERATE_CIRCUIT_2(0),
            .GENERATE_CIRCUIT_3(0),
            .GENERATE_CIRCUIT_4(0)
        ) 
        divider_unit
        (
            .clk                        (   clk                 ),
            .opcode                     (   opcode_EX_reg       ),
            .funct3                     (   funct3_EX_reg       ),
            .funct7                     (   funct7_EX_reg       ),
            .control_status_register    (   divcsr_wire         ),    
            .rs1                        (   rs1_EX_reg          ),
            .rs2                        (   rs2_EX_reg          ),
            .divider_unit_busy          (   div_busy_EX_wire    ),
            .divider_unit_output        (   div_output_EX_wire  )
        );
    end
    endgenerate

    // ------------------------------------
    // Address Generator Unit Instantiation
    // ------------------------------------
    Address_Generator address_generator
    (
        .opcode             (   opcode_EX_reg       ),
        .rs1                (   rs1_EX_reg          ),
        .pc                 (   pc_EX_reg           ),
        .immediate          (   immediate_EX_reg    ),
        .address            (   address_EX_wire     )
    );

    // ------------------------------
    // Jump Branch Unit Instantiation
    // ------------------------------
    Jump_Branch_Unit jump_branch_unit
    (
        .opcode             (   opcode_EX_reg               ),
        .funct3             (   funct3_EX_reg               ),
        .instruction_type   (   instruction_type_EX_reg     ),
        .rs1                (   rs1_EX_reg                  ),
        .rs2                (   rs2_EX_reg                  ),
        .jump_branch_enable (   jump_branch_enable_EX_wire  )
    );

    // ---------------------------------
    // Control Status Unit Instantiation
    // ---------------------------------
    Control_Status_Unit control_status_unit
    (
        .opcode                 (   opcode_EX_reg           ),
        .funct3                 (   funct3_EX_reg           ),

        .CSR_in                 (   csr_data_EX_reg         ),
        .rs1                    (   rs1_EX_reg              ),
        .unsigned_immediate     (   read_index_1_EX_reg     ),

        .rd                     (   csr_rd_EX_wire          ),
        .CSR_out                (   csr_data_out_EX_wire    )
    );

    // ----------------------------------------
    // Wire declaration for result of execution
    // ----------------------------------------
    wire [31 : 0] execution_result_EX_wire;

    // ----------------------------------------------------------
    //  Assigning result to alu output / mul output / div output
    // ----------------------------------------------------------
    assign  execution_result_EX_wire    =   (   {funct7_EX_reg, funct3_EX_reg, opcode_EX_reg} == {`MULDIV, `MUL,    `OP}    )   ?   mul_output_EX_wire  :
                                            (   {funct7_EX_reg, funct3_EX_reg, opcode_EX_reg} == {`MULDIV, `MULH,   `OP}    )   ?   mul_output_EX_wire  :
                                            (   {funct7_EX_reg, funct3_EX_reg, opcode_EX_reg} == {`MULDIV, `MULHSU, `OP}    )   ?   mul_output_EX_wire  :
                                            (   {funct7_EX_reg, funct3_EX_reg, opcode_EX_reg} == {`MULDIV, `MULHU,  `OP}    )   ?   mul_output_EX_wire  :
                                            (   {funct7_EX_reg, funct3_EX_reg, opcode_EX_reg} == {`MULDIV, `DIV,    `OP}    )   ?   div_output_EX_wire  :
                                            (   {funct7_EX_reg, funct3_EX_reg, opcode_EX_reg} == {`MULDIV, `DIVU,   `OP}    )   ?   div_output_EX_wire  :
                                            (   {funct7_EX_reg, funct3_EX_reg, opcode_EX_reg} == {`MULDIV, `REM,    `OP}    )   ?   div_output_EX_wire  :
                                            (   {funct7_EX_reg, funct3_EX_reg, opcode_EX_reg} == {`MULDIV, `REMU,   `OP}    )   ?   div_output_EX_wire  :
                                            alu_output_EX_wire;

    // ------------------------------------------------
    // Reg Declarations for Memory/Writeback Stage (MW)
    // ------------------------------------------------
    reg [31 : 0] pc_MW_reg;
    reg [31 : 0] next_pc_MW_reg;

    reg [ 2 : 0] instruction_type_MW_reg;
    reg [ 6 : 0] opcode_MW_reg;
    reg [ 2 : 0] funct3_MW_reg;
    reg [ 6 : 0] funct7_MW_reg;
    reg [11 : 0] funct12_MW_reg;

    reg [31 : 0] immediate_MW_reg;
    
    reg [ 4 : 0] write_index_MW_reg;
    reg write_enable_MW_reg;

    reg [31 : 0] address_MW_reg;
    reg [31 : 0] rs2_MW_reg;
    reg [31 : 0] execution_result_MW_reg;
    reg [31 : 0] csr_rd_MW_reg;

    //////////////////////////////////////////////////
    //    EXECUTE TO MEMORY/WRITEBACK TRANSITION    //
    //////////////////////////////////////////////////
    always @(posedge clk) 
    begin
        if (stall_condition[1])
        begin
            write_enable_MW_reg <= `DISABLE;  

            opcode_MW_reg <= `NOP_opcode;
            funct3_MW_reg <= `NOP_funct3;
            funct7_MW_reg <= `NOP_funct7;
            funct12_MW_reg <= `NOP_funct12;

            immediate_MW_reg <= `NOP_immediate;
            instruction_type_MW_reg <= `NOP_instruction_type;
            write_index_MW_reg <= `NOP_write_index;            
        end

        else if (!(stall_condition[1]))
        begin
            pc_MW_reg <= pc_EX_reg;
            next_pc_MW_reg <= next_pc_EX_reg;

            instruction_type_MW_reg <= instruction_type_EX_reg;
            opcode_MW_reg <= opcode_EX_reg;
            funct3_MW_reg <= funct3_EX_reg;
            funct7_MW_reg <= funct7_EX_reg;
            funct12_MW_reg <= funct12_EX_reg;

            immediate_MW_reg <= immediate_EX_reg;
            
            write_index_MW_reg <= write_index_EX_reg;
            write_enable_MW_reg <= write_enable_EX_reg;    

            address_MW_reg <= address_EX_wire;
            rs2_MW_reg <= rs2_EX_reg;
            execution_result_MW_reg <= execution_result_EX_wire;
            csr_rd_MW_reg <= csr_rd_EX_wire;
        end
    end

    // -----------------------------------
    // Wire Declarations for Memory Access
    // -----------------------------------
    wire [31 : 0] load_data_MW_wire;

    // -----------------------------
    // Load Store Unit Instantiation
    // -----------------------------
    Load_Store_Unit load_store_unit
    (
        .opcode                         (   opcode_MW_reg                       ),
        .funct3                         (   funct3_MW_reg                       ),
        .address                        (   address_MW_reg                      ),
        .store_data                     (   rs2_MW_reg                          ),
        .load_data                      (   load_data_MW_wire                   ),

        .memory_interface_enable        (   data_memory_interface_enable        ),
        .memory_interface_state         (   data_memory_interface_state         ),
        .memory_interface_address       (   data_memory_interface_address       ),
        .memory_interface_frame_mask    (   data_memory_interface_frame_mask    ),
        .memory_interface_data          (   data_memory_interface_data          )
    );
    
    // ---------------------------------------------------------------
    // assigning write back data from immediate or load data or result
    // ---------------------------------------------------------------
    wire [31 : 0] write_data_MW_wire;
        
    assign write_data_MW_wire   =   (   opcode_MW_reg == `OP_IMM    )   ?   execution_result_MW_reg :
                                    (   opcode_MW_reg == `OP        )   ?   execution_result_MW_reg :
                                    (   opcode_MW_reg == `JAL       )   ?   next_pc_MW_reg          :
                                    (   opcode_MW_reg == `JALR      )   ?   next_pc_MW_reg          :
                                    (   opcode_MW_reg == `AUIPC     )   ?   address_MW_reg          :
                                    (   opcode_MW_reg == `LOAD      )   ?   load_data_MW_wire       :
                                    (   opcode_MW_reg == `LUI       )   ?   immediate_MW_reg        :
                                    (   opcode_MW_reg == `SYSTEM    )   ?   csr_rd_MW_reg           :
                                    32'bz;

    //////////////////////////////////////
    //     Hazard Detection Units       //
    //////////////////////////////////////
    Hazard_Forward_Unit hazard_forward_unit_source_1
    (
        .source_index           (   read_index_1_DE_wire                                ),
        
        .destination_index_1    (   write_index_EX_reg                                  ),
        .destination_index_2    (   write_index_MW_reg                                  ),

        .data_1                 (   opcode_EX_reg == `LUI      ? immediate_EX_reg : 
                                    opcode_EX_reg == `AUIPC    ? address_EX_wire  : 
                                    opcode_EX_reg == `SYSTEM   ? csr_rd_EX_wire   : 
                                    execution_result_EX_wire                            ),
        .data_2                 (   write_data_MW_wire                                  ),

        .enable_1               (   write_enable_EX_reg                                 ),
        .enable_2               (   write_enable_MW_reg                                 ),

        .forward_enable         (   FW_enable_1                                         ),
        .forward_data           (   FW_source_1                                         )
    );

    Hazard_Forward_Unit hazard_forward_unit_source_2
    (
        .source_index           (   read_index_2_DE_wire                                ),
        
        .destination_index_1    (   write_index_EX_reg                                  ),
        .destination_index_2    (   write_index_MW_reg                                  ),

        .data_1                 (   opcode_EX_reg == `LUI      ? immediate_EX_reg : 
                                    opcode_EX_reg == `AUIPC    ? address_EX_wire  : 
                                    opcode_EX_reg == `SYSTEM   ? csr_rd_EX_wire   : 
                                    execution_result_EX_wire                            ),
        .data_2                 (   write_data_MW_wire                                  ),

        .enable_1               (   write_enable_EX_reg                                 ),
        .enable_2               (   write_enable_MW_reg                                 ),

        .forward_enable         (   FW_enable_2                                         ),
        .forward_data           (   FW_source_2                                         )
    );

    ////////////////////////////////////
    //          Bubble Unit           //
    ////////////////////////////////////    
    assign stall_condition[1] = (mul_busy_EX_wire || div_busy_EX_wire) ? `ENABLE : `DISABLE;
    assign stall_condition[2] = (opcode_EX_reg == `LOAD & write_enable_EX_reg &
                                (((write_index_EX_reg == read_index_1_DE_wire) & read_enable_1_DE_wire)  || 
                                ((write_index_EX_reg == read_index_2_DE_wire) & read_enable_2_DE_wire))) ? `ENABLE : `DISABLE;

    ////////////////////////////////////////
    //    Register File Instantiation     //
    ////////////////////////////////////////
    Register_File 
    #(
        .WIDTH(32),
        .DEPTH(E_EXTENSION ? 4 : 5)
    )
    register_file
    (
        .clk            (   clk                     ),
        .reset          (   reset                   ),

        .read_enable_1  (   read_enable_1_DE_wire   ),
        .read_enable_2  (   read_enable_2_DE_wire   ),
        .write_enable   (   write_enable_MW_reg     ),

        .read_index_1   (   read_index_1_DE_wire    ),
        .read_index_2   (   read_index_2_DE_wire    ),
        .write_index    (   write_index_MW_reg      ),

        .write_data     (   write_data_MW_wire      ),
        .read_data_1    (   RF_source_1             ),
        .read_data_2    (   RF_source_2             )
    );

    ///////////////////////////////////
    //    Register Loading Table     //
    ///////////////////////////////////
    Register_Loading_Table
    #(
        .WIDTH(32),
        .DEPTH(5)
    )
    register_loading_table
    (
        .clk            (   clk                     ),
        .reset          (   reset                   ),
        
        .read_enable    (                           ),
        .write_enable   (   write_enable_MW_reg &&
                            opcode_MW_reg == `LOAD  ),

        .read_index     (                           ),
        .write_index    (   write_index_MW_reg      ),
        
        .write_data     (   address_MW_reg          ),
        .read_data      (                           )
    );
    
    ///////////////////////////////////////////////////////
    //    Control Status Register File Instantiation     //
    ///////////////////////////////////////////////////////
    Control_Status_Register_File control_status_register_file
    (
        .clk                (   clk                         ),
        .reset              (   reset                       ),

        .opcode             (   opcode_MW_reg               ),
        .funct3             (   funct3_MW_reg               ),
        .funct7             (   funct7_MW_reg               ),
        .funct12            (   funct12_MW_reg              ),
        .write_index        (   write_index_MW_reg          ),

        .csr_read_enable    (   csr_read_enable_DE_wire     ),
        .csr_write_enable   (   csr_write_enable_EX_reg     ),

        .csr_read_index     (   csr_index_DE_wire           ),
        .csr_write_index    (   csr_index_EX_reg            ),

        .csr_write_data     (   csr_data_out_EX_wire        ),
        .csr_read_data      (   csr_data_DE_wire            ),

        .alucsr_wire        (   alucsr_wire                 ),
        .mulcsr_wire        (   mulcsr_wire                 ),
        .divcsr_wire        (   divcsr_wire                 )
    );
endmodule