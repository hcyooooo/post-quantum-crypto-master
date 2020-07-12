# RISQ-V: Tightly Coupled RISC-V Accelerators for Post-Quantum Cryptography
This repository provides the RISQ-V platform. RISQ-V is an enhanced RISC-V architecture that integrates a set of powerful tightly coupled accelerators to speed up lattice-based post-quantum cryptography. The RISC-V core used in this work is a 32 bit, 4 stages pipeline, in order execution processor from the PULP team. This core is also known as CV32E40P (formerly RI5CY). To illustrate the efficiency of our approach, we accelerated the post-quantum schemes NewHope, Kyber, and Saber.

## Project Structure
1. *RTL* contains the RTL-description of the RISQ-V platform:
- The subdirectory *ips* contains the original RISC-V core and other IPs (slight modifications of original source).
- The subdirectory *rtl* contains the original PULPino hardware description (slight modifications of original source).
- The subdirectory *rtl_pq* contains the post-quantum accelerators designed in this work and the files of the RISC-V core that have major modifications of the original source.
- The subdirectory *tb* contains the testbench files of the toplevel (slight modifications of original source).
3. *COMPILE* contains the environment for creating the instruction code for the RISC-V processor.
4. *TEST* contains the spi stimuli files which are used to load the program code into the instruction and data memory.
5. *MODELSIM* contains all scripts for simulating a programm running on the PULPino platform.

## Cloning the Project
```bash
git clone https://gitlab.lrz.de/tueisec/post-quantum-crypto
```

## Prerequisites and Compilers
To compile a C/C++ code for the CV32E40P (formerly RI5CY) core a RISC-V compiler is required.
RISC-V compilers can be found at: i.) [PULP compiler](https://github.com/pulp-platform/pulp-riscv-gnu-toolchain), and ii.) [Official RISC-V compiler](https://github.com/riscv/riscv-gnu-toolchain). Note that our test results and codes are based and optimized for the PULP compiler.

### Install  PULP Toolchain
The PULP toolchain can be installed with:

```bash
git clone --recursive https://github.com/pulp-platform/pulp-riscv-gnu-toolchain
sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev
./configure --prefix=/opt/risq-v --with-arch=rv32imfcxpulpv3 --with-abi=ilp32 --with-cmodel=medlow
make
```

Make sure that the Base Integer Instruction Set (I), Compressed Instructions (C), and  Integer Multiplication (M) extensions are installed. The RI5CY extensions can be enabled with XPULPV3. The project was tested with the compiler riscv32-unknown-elf-gcc (GCC) version 7.1.1 (20170509). Installation dependencies might change, please refer to the original source.

### Install Official RISC-V Toolchain
The official RISC-V compiler can be installed with:

```bash
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
sudo apt-get install autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
./configure --prefix=/opt/riscv --with-arch=rv32imc --with-abi=ilp32
make
```

Make sure that the Base Integer Instruction Set (I), Compressed Instructions (C), and  Integer Multiplication (M) extensions are installed. Installation dependencies might change, please refer to the original source.

### PQ Instruction Set Extension
For activating the PQ instruction set extension, see [here](COMPILE/isa_extension/readme.md). 

### PULPino Platform
To download the PULPino platform use:

```bash
git clone https://github.com/pulp-platform/pulpino
./update-ips.py
```

However, all files required for this project are already in the working directory. They were downloaded on 23th January 2020. It is not required to download the files again.


## RISC-V Synthesis and Simulation
### Post-Quantum Source Code
As a reference, the sources from [PQClean](https://github.com/PQClean/PQClean) are used.
All tests were performed for the PQClean version of 17th January 2020. To switch to the tested version when a new clone of PQClean is created use:
```bash
cd PQClean
git checkout 8eca85fcd2b56fab5f40a86361cbf56c313f0ee4
```

All tests were performed for the MUPQ version of 28th April 2020. To switch to the tested version when a new clone of MUPQ is created use:
```bash
cd mupq
git checkout 1f1ad36a51aa571e5e58e1f024ec7f76f8e542e0
```

The downloaded files of the tested versions are placed at *COMPILE/src*. It is not required to clone them again.

The RISC-V optimized code with PQ instructions are placed at *COMPILE/src/RISCV_optimized_code*.

### Compile a New Source Code and Create Stimuli
Change to the folder compile:

```bash
cd COMPILE/compile
make
```

Make sure that your install directory of the RISC-V compiler matches the PREFIX in the *Makefile*. Now a fresh stimuli file *spi_stim.txt* should be created and copied to the *TEST/slm_files* directory.
Several targets are defined in the *Makefile*. Choose the desired target (e.g. newhope512hw_bench, kyber512hw_bench or lightsaberhw_bench).

### Run Modelsim Simulation
Switch to the MODELSIM directory and run the following commands:

```bash
cd MODELSIM/work
module load mentor/modelsim/latest (if applicable)
vsim
```

To run the Modelsim simulation, type *do ../scripts/run_pre_syn.do* in the Modelsim command window.
This command loads and compiles all RTL files and starts the simulation process. You should after a short time see the waveform window.
When the source code is loaded from the file *TEST/slm_files/spi_stim.txt* to the instruction and data memory, the core starts the computation by setting the *fetch_enable* signal to one.
The code was tested with the Modelsim version 10.4c.


## LICENSING
### Original and modified PULPino files
The licenses for the implementations in the following directories and files are described in the original source at [PULPino_LICENSE](https://github.com/pulp-platform/pulpino/blob/master/LICENSE) (SOLDERPAD HARDWARE LICENSE version 0.51):
- *COMPILE/compile/utils*
- *COMPILE/compile/link.common.ld*
- *COMPILE/compile/link.riscv.ld*
- *COMPILE/lib*
- *RTL/ips*
- *RTL/rtl*
- All files starting with *RTL/rtl_pq/riscv_...*
- *RTL/tb*

The files that were changed in this work were marked at the top of each source file. A copy of the SOLDERPAD HARDWARE LICENSE version 0.51 can be found [HERE](LICENSE_SOLDERPAD).

### Modified RISC-V compiler files
The following files are licensed under the [GNU GENERAL PUBLIC LICENSE](https://www.gnu.org/licenses/gpl-3.0.de.html):
- *COMPILE/isa_extension/riscv-opc.c*
- *COMPILE/isa_extension/riscv-opc.h*

A copy of the GNU GENERAL PUBLIC LICENSE version 3 can be found [HERE](LICENSE_GPL).


### Original PQClean and MUPQ files
The licences for the implementations in the following directories are described in the original source at [PQM4_LICENSE](https://github.com/mupq/pqm4):
- *COMPILE/src/PQClean*
- *COMPILE/src/mupq*

Each subdirectory of *PQClean* and *mupq* containing implementations contains a LICENSE file stating under what license that specific implementation is released. The content of these two directories is identical to the original source (but might be an older commit).


### All remaining files developed in this work
All remaining code in this repository is released under the [LICENSE MIT](LICENSE_MIT) with the addition of referencing the article "RISQ-V: Tightly Coupled RISC-V Accelerators for Post-Quantum Cryptography" of https://eprint.iacr.org/2020/446.pdf whenever the code is used.

