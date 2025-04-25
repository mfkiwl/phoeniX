![License](https://img.shields.io/github/license/phoeniX-Digital-Design/AssembleX?color=dark-green)
![GCC Test](https://img.shields.io/badge/GCC_tests-passed-dark_green)
![Version](https://img.shields.io/badge/Version-0.5-blue)
![ISA](https://img.shields.io/badge/RV32-I/EM_extension-blue)

<picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Documents/Images/phoenix_full_logotype_bb.png" width="530" height="150" style="vertical-align:middle">
    <img alt="logo in light mode and dark mode" src="https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Documents/Images/phoenix_full_logotype.png" width="530" height="150" style="vertical-align:middle"> 
</picture> 

<div align="justify">
 
The **phoeniX** RISC-V platform includes a partially-reconfigurable `RV32I/EM` core designed based on the 32-bit Base Instrcution Set of [RISC-V Instruction Set Architecture](http://riscv.org/) V2.2, with specialized features supporting approximate arithmetic hardware implementations.

This platform enables simplified adaption of faulty arithmetic circuits within the core, with different structures, accuracies, timings and etc., without fragmentizing the datapath. This allows configurable trade-offs between latency, accuracy and power consumption based on application requirements.

</div>

<div align="justify">

This repository contains an open source RISC-V embedded core, including RTL, synthesis scripts, and assistant software, under the [GNU V3.0 license](https://en.wikipedia.org/wiki/GNU_General_Public_License) and is free to use. If you use these works in your research, please cite the following papers:

<details>
<summary><b>Evaluation of Run-Time Energy Efficiency using Controlled Approximation in a RISC-V Core [2024]</b></summary>
<p>

```
@INPROCEEDINGS{10824628,
  author={Delavari, Arvin and Ghoreishy, Faraz and Shahhoseini, Hadi Shahriar and Mirzakuchaki, Sattar},
  booktitle={2024 6th Iranian International Conference on Microelectronics (IICM)}, 
  title={Evaluation of Run-Time Energy Efficiency Using Controlled Approximation in a RISC-V Core}, 
  year={2024},
  volume={},
  number={},
  pages={1-7},
  keywords={Program processors;Power demand;Accuracy;Embedded systems;Approximate computing;Process control;Energy efficiency;Hardware;Software;Real-time systems;Embedded systems;RISC-V;approximate computing;low-power design;energy efficient embedded systems;very large scale integration},
  doi={10.1109/IICM65053.2024.10824628}}

```

</p>
</details>

<details>
<summary><b>A Reconfigurable Approximate Computing RISC-V Platform for Fault-Tolerant Applications [2024]</b></summary>
<p>
    
```
@INPROCEEDINGS{10741850,
  author={Delavari, A. and Ghoreishy, F. and Shahhoseini, H. S. and Mirzakuchaki, S.},
  booktitle={2024 27th Euromicro Conference on Digital System Design (DSD)}, 
  title={A Reconfigurable Approximate Computing RISC-V Platform for Fault-Tolerant Applications}, 
  year={2024},
  volume={},
  number={},
  pages={81-89},
  keywords={Fault tolerance;Accuracy;Embedded systems;Power demand;Image processing;Fault tolerant systems;Approximate computing;Process control;Energy efficiency;Timing;Approximate Computing;Low Power Design;RISC-V;Embedded Processor;Energy-Efficient Computation;Very Large Scale Integration},
  doi={10.1109/DSD64264.2024.00020}}
```

</p>
</details>

<details>
<summary><b>PhoeniX: A RISC-V Platform for Approximate Computing Technical Specifications [2023]</b></summary>
<p>

```
@ONLINE{delavari2023phoenix,
  author={Delavari, A. and Ghoreishy, F. and Shahhoseini, H. S. and Mirzakuchaki, S.},
  title={PhoeniX: A RISC-V Platform for Approximate Computing Technical Specifications},
  year={2023},
  url={http://www.iust.ac.ir/content/76158/phoeniX-POINTS--A-RISC-V-Platform-for-Approximate-Computing}
}
```

</p>
</details>

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

</div>

<a href="https://next.ossinsight.io/widgets/official/analyze-repo-stars-map?activity=stars&repo_id=677643796" target="_blank" style="display: block" align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://next.ossinsight.io/widgets/official/analyze-repo-stars-map/thumbnail.png?activity=stars&repo_id=677643796&image_size=auto&color_scheme=dark" width="721" height="auto">
    <img alt="Star Geographical Distribution of phoeniX project" src="https://next.ossinsight.io/widgets/official/analyze-repo-stars-map/thumbnail.png?activity=stars&repo_id=677643796&image_size=auto&color_scheme=light" width="721" height="auto">
  </picture>
</a>

## Table of Contents

- [Features](#Features)
- [Directory Map](#Directory-Map)
- [Core's Structure](#Core-Structure)
- [Memory Interface](#Memory-Interface)
- [Building RISC-V Toolchain](#Building-RISC-V-Toolchain)
- [Execution Flow](#Execution-Flow)
- [Synthesis Result](#Synthesis-Result)


## Features
<div align="justify">

  - Architecture
    - RV32I/EM, 4-stage, in-order, and single issue pipeline
    - Partially-reconfigurable execution engine (ALU, MUL, DIV) 
    - A novel control mechanism over trade-offs between *accuracy* and *computational efficiency*
    - Compatible with dynamic error-adjustable arithmetic hardware
    - Automated dynamic power management ( ONGOING )
  
  - Software
    - Compliant with RISC-V GCC 8.3.0 compiler 
    - AssembleX: phoeniX's RISC-V assembly software assistant
    - Dedicated approximate computing library for fault-tolerant applications ( ONGOING )
    
  - RTL Simulation
    - Icarus Verilog
    - Verilator
    - ModelSim
    - Compatible with FPGA proprietary (commercial) and open-source toolchains

  - Synthesis
    - Compliant with proprietary (commercial) and open-source tools
    - Sample RTL-to-GDS scripts provided

</div>

## Directory Map

The tree below provides a map to all directories and sub-directories of the repository. Detailed descriptions on contents of these directories are provided in the following sections and each specific `README.md`.
<pre style="font-size:16px">
repository/
    ├── Setup/
    │   └── setup.sh
    ├── Documents/
    │   ├── Images/
    │   ├── phoeniX_Documentation/   
    │   └── RISCV_Original_Documents/
    ├── Dhrystone/
    │   ├── dhrytone.log 
    │   ├── dhrytone_rv32i_firmware.hex 
    │   └── dhrytone_rv32im_firmware.hex
    │   └── ...
    ├── Features/
    │   ├── AXI4-Lite/
    │   ├── Branch_Prediction/
    │   ├── Clock_Generator/
    │   └── ...
    ├── Synthesis/
    │   ├── Yosys_TSMC180/
    │   │   ├── layout/
    │   │   ├── synthesis/
    │   │   ├── log/
    │   │   └── ...
    │   └── DesignCompiler_NanGate45
    ├── Modules/
    │   ├── Address_Generator.v
    │   ├── Arithmetic_Logic_Unit.v
    │   └── ...
    ├── Firmware/
    │   ├── hex_converter -> hex_converter.py
    │   ├── start_procedure -> start.s
    │   ├── start_linker -> start.ld
    │   ├── riscv_linker -> riscv.ld
    │   ├── standard_library -> stdlib.c
    │   └── syscalls -> syscalls.c
    ├── Software/
    │   ├── Sample_Assembly_Codes/
    │   │   └── Program_directory/
    │   │       ├── Program.S
    │   │       ├── Program.txt
    │   │       └── Program_firmware.hex
    │   ├── Sample_C_Codes/
    │   │   └── Program_directory/
    │   │       ├── Program.c
    │   │       ├── Program.o
    │   │       └── Program_firmware.hex        
    │   └── User_Codes/
    │       └── Program_directory/
    │           ├── Program.c
    │           ├── Program.o
    │           └── Program_firmware.hex 
    ├── phoeniX.v
    ├── phoeniX_Testbench.v
    ├── phoeniX.vvp
    ├── phoeniX.vcd
    ├── phoeniX.gtkw
    ├── AssembleX.py
    └── Makefile
</pre>

## Core Structure
<div align="justify">

The repository contains a collection of building blocks of the phoeniX, included in `\Modules` directory. Modules are designed based on distributed-control logic. This deliberate approach allows designers to replace and configure individual building blocks especially arithmetic and execution units within the processor. 

<!-- TO DO -->
This repository includes detailed documentation, user manual, and developer guidelines for future works and updates. These resources make it easy for users to execute `C/C++` and `ASM` code using the standard `RISC-V GCC toolchain` on the processor, and helps developers to understand its structure and architecture, in order to update and validate new designs using the base processor, or adding and testing approximate arithmetic circuits on the core, without any need of changes in other parts of the processor such as control logics and etc.

</div>

![Alt text](https://github.com/phoeniX-Digital-Design/phoeniX/blob/phoeniX-V0.3/Documents/Images/phoeniX_Block_Diagram_V03.PNG "phoeniX V0.3 Block Diagram")

| Module                        | Description                                                                                   |
| ----------------------------- | --------------------------------------------------------------------------------------------- |
| `Address_Generator`           | Generating address for BRANCH, JUMP and LOAD/STORE instructions                               |
| `Arithmetic_Logic_Unit`       | ALU with support for `I_TYPE` and `R_TYPE` instructions                                       |
| `Control_Status_Unit`         | CSR instructions and custom CSRs for the partially-reconfigurable execution engine            |
| `Divider_unit`                | Divider unit with a modular design (Default module: Error configurable non-restoring divider) |
| `Fetch_Unit`                  | Instruction Fetch logic and program counter addressing                                        | 
| `Hazard_Forward_Unit`         | Hazard detection and data forwarding logic                                                    |
| `Immediate_Generator`         | Generating immediate values according to instructions type                                    |
| `Instruction_Decoder`         | Decoding instructions and extracting control fields (i.e., `opcode`, `funct`)                 |
| `Jump_Branch_Unit`            | Decision-making on all branch instructions                                                    |
| `Load_Store_Unit`             | Load and Store operations for aligned addresses and wordsize management                       |
| `Multiplier_Unit`             | Multiplier unit with a modular design (Default module: Fast, low-power approximate multiplier)|
| `Register_File`               | Parametrized register file suitable for GP registers and CSRs (2 read & 1 write ports)        |
| `Register_Loading_Table`      | Contains memory source addresses for values loaded in GP registers                            |

The `phoeniX.v` contains the main phoeniX RISC-V core and is included in the top directory of this repo:
| Module                        | Description                                                                  |
| ----------------------------- | ---------------------------------------------------------------------------- |
| `phoeniX`                     | phoeniX core (RV32I/EM) top module                                           |
| `phoeniX_Testbench`           | Testbench module including main core, memory and interface logic             |


## Memory Interface
<div align="justify">

The processor currently supports 32-bit word memories with synchronized access time. The core always addresses memory by a word aligned address and access a four byte frame from memory which is then operated on based on a `frame_mask` for half-word and byte operations. 

![Alt text](https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Documents/Images/frame_mask_table.png "Frame Mask Values on different aligned memory accesses")

</div>

> [!WARNING]\
> Unaligned Memory Accesses: phoeniX Load Store Unit does not support misaligned accesses. At the moment we are working to add support accesses that are not aligned on word boundaries by implementing the procedure with multiple separate aligned accesses requiring additional clock cycles.

## Building RISC-V Toolchain
<div align="justify">
 
In order to be able to compile your source files and run on the core, you need to install `RISC-V GNU Compiler Toolchain`. You can follow the installation process from the [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) repository or use the scripts provided in the original RISC-V repositories and [riscv-tools](https://github.com/riscv/riscv-tools). The default settings in the original repos build scripts will build a compiler, assembler and linker that can target any RISC-V ISA.

You can also use the provided shell script in `/Setup` directory. All shell scripts and Makefiles provided in this repository target `Ubuntu 20.04` unless otherwise specified. Simply run the `setup.sh` from your terminal, and it will automatically install all required prerequisites.

</div>

```console
user@Ubuntu:~$ git clone https://github.com/phoeniX-Digital-Design/phoeniX.git
user@Ubuntu:~$ cd phoeniX
user@Ubuntu:~$ cd Setup
user@Ubuntu:~$ chmod +x setup.sh
user@Ubuntu:~$ ./setup.sh
```
<div align="justify">

Using your favorite editor open `.bashrc` file from the `home` directory of your ubuntu. Replace `{user}` with your own user name and add the following lines to the end of file. This will change your path environment variable and is required to run `RISC-V GNU Compiler` automatically without exporting `PATH` variable each time.

</div>

> [!NOTE]\
> The script provided `setup.sh` and the following lines are set configure the toolchain based on `8.3.0` version of the compiler and toolchain for a `x86_64` machine. If you wish to install a different version please beware and change the required lines in `setup.sh` and the following lines.

```sh
export PATH=/home/{user}/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/bin:$PATH
export PATH=/home/{user}/riscv_toolchain/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/riscv64-unknown-elf/bin:$PATH
```

## Execution Flow

### Linux

#### Running Sample Codes
<div align="justify">

The directory `/Software` contains sample codes for some conventional programs and algorithms in both Assembly and C which can be found in `/Sample_Assembly_Codes` and `/Sample_C_Codes` sub-directories respectively. 

phoeniX convention for naming projects is as follows; The main source file of the project is named as `{project.c}` or `{project.s}`. This file along other required source files are kept in one directory which has the same name as the project itself, i.e. `/project`.

Sample projects provided at this time are `bubble_sort`, `fibonacci`, `find_max_array`, `sum1ton`.
To run any of these sample projects simply run `make sample` followed by the name of the project passed as a variable named project to the Makefile.

```shell
make sample project={project}
```
For example:
```shell
make sample project=fibonacci
```

Provided that the RISC-V toolchain is set up correctly, the Makefile will compile the source codes separately, then using the linker script `riscv.ld` provided in `/Firmware` it links all the object files necessary together and creates `firmware.elf`. It then creates `start.elf` which is built from `start.s` and `start.ld` and concatenate these together and finally forms the `{project}_firmware.hex`. This final file can be directly fed to our verilog testbench. Makefile automatically runs the testbench and calls upon `gtkwave` to display the selected signals in the waveform viewer.

</div>

#### Running Your Own Code
<div align="justify">

In order to run your own code on phoeniX, create a directory named to your project such as `/my_project` in `/Software/User_Codes/`. Put all your `.c` and `.s` files in `/my_project` and run the following `make` command from the main directory:
```shell
make code project=my_project
```
Provided that you name your project sub-directory correctly and the RISC-V toolchain is configured without any troubles on your machine, the Makefile will compile all your source files separately, then using the linker script `riscv.ld` provided in `/Firmware` it links all the object files necessary together and creates `firmware.elf`. It then creates `start.elf` which is built from `start.s` and `start.ld` and concatenate these together and finally forms the `my_project_firmware.hex`. After that, `iverilog` and `gtkwave` are used to compile the design and view the selected waveforms.

> Further Configurations: The default testbench provided as `phoeniX_Testbench.v` is currently set to support up to 4MBytes of memory and the stack pointer register `sp` is configured accordingly. If you wish to change this, you need configure both the testbench and the initial value the `sp` is set to in `/Firmware/start.s`. If you wish to use other specific libraries and header files not provided in `/Firmware` please beware you may need to change linker scripts `riscv.ld` and `start.ld`.

</div>

### Windows

#### Running Sample Codes
<div align="justify">

We have meticulously developed a lightweight and user-friendly software solution with the help of Python. Our execution assistant software, `AssembleX`, has been crafted to cater to the specific needs of Windows systems, enabling seamless execution of assembly code on the phoeniX processor. 

This tool enhances the efficiency of the code execution process, offering a streamlined experience for users seeking to enter the realm of assembly programming on phoeniX processor in a very simple and user-friendly way.

To run any of these sample projects simply run python `AssembleX.py sample` followed by the name of the project passed as a variable named project to the Python script.
The input command format for the terminal follows the structure illustrated below:
```shell
python AssembleX.py sample {project_name}
```
For example:
```shell
python AssembleX.py sample fibonacci
```
After execution of this script, firmware file will be generated and this final file can be directly fed to our Verilog testbench. AssembleX automatically runs the testbench and calls upon Gtkwave to display the selected signals in the waveform viewer application.

</div>

#### Running Your Own Code
<div align="justify">

In order to run your own code on phoeniX, create a directory named to your project such as `/my_project` in `/Software/User_Codes`. Put all your `user_code.s` files in my_project and run the following command from the main directory:

```shell
python AssembleX.py code my_project
```

Provided that you name your project sub-directory correctly the AssembleX software will create `my_project_firmware.hex` and fed it directly to the testbench of phoeniX processor. After that, iverilog and GTKWave are used to compile the design and view the selected waveforms.

</div>

## Implementation
<div align="justify">

The RTL has been crafted to enable the utilization of the processor as an implementable soft-core on Xilinx FPGA devices. The ASIC synthesis and implementation of the phoeniX processor was done using proprietary (commercial) and open-source tool, utilizing the `FreePDK45`. By adhering the timing requirements, the processor can achieve max frequency of up to **500 - 620MHz**, enabling efficient execution of instructions and supporting the desired operational specifications in embedded solutions.

![phoeniX_45nm_Layout](https://github.com/phoeniX-Digital-Design/phoeniX/blob/main/Synthesis/DesignCompiler_NanGate45/layout_image/phoeniX_RV32IEM_layout_45nm.png)

</div>

| Dhyrstone Parameters         | phoeniX (RV32I) V0.4 | phoeniX (RV32IM) V0.4 | phoeniX (RV32I) V0.5 |
| ---------------------------- | -------------------- | --------------------- | -------------------- |
| CPI                          | 1.119                | 1.137                 | 1.211                |
| Dhrystones per Second per MHz| 3044                 | 3324                  | 2813                 |
| DMIPS/MHz                    | 1.732                | 1.891                 | 1.601                |


> [!NOTE]\
> The following results of phoeniX core is extracted from the platform using its default (demo) execution engine, including both accurate and approximate arithmetic hardware.


| Processor                    | Max Frequency (MHz) | Technology Node (nm) | Architecture | Pipeline         |
| ---------------------------- | ------------------- | -------------------- | ------------ | ---------------- |
| phoeniX V0.5                 | 500                 | 45                   | RV32I/EM     | 4-stage in order |
| phoeniX V0.4                 | 620                 | 45                   | RV32I/EM     | 3-stage in order |
| phoeniX V0.3                 | 500                 | 45                   | RV32I/EM     | 3-stage in order |
| phoeniX V0.2                 | 500                 | 45                   | RV32I        | 3-stage in order |
| phoeniX V0.1                 | 220                 | 180                  | RV32I        | 5-stage in order |
| phoeniXS6                    | < 100 (on FPGA)     | XC6SLX9              | RV32I        | 3-stage in order |
