# PQ Instruction Set Extension
In order to integrate the new PQ instruction in the compiler, the *files pulp-riscv-gnu-toolchain/riscv-binutils-gdb/opcodes/riscv-opc.c* and *pulp-riscv-gnu-toolchain/riscv-binutils-gdb/include/opcode/riscv-opc.h* have to be exchanged with the ones given in this repository. After that reinstall the RISC-V toolchain:

```bash
cd pulp-riscv-gnu-toolchain
sudo make clean
sudo rm -r /opt/risq-v
./configure --prefix=/opt/risqv --with-arch=rv32imfcxpulpv3 --with-abi=ilp32 --with-cmodel=medlow
sudo make
```
