REM  In Windows, run this batch script from the command prompt
REM    in the directory hmc-6502\src to produce the PLA code.

cd ucode
python ucasm.py > 6502.ucode.compiled
cd opcode_translator
python instrtable2opcodes.py ..\instrtable.txt
python opcode_label2bin.py opcodes.txt
cd ..\..
