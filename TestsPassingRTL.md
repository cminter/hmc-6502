Available RTL-Passing Tests:
  * test/scripts/PowerTest.fdo (a.k.a. Suite P)
  * test/scripts/SuiteA/test00.fdo (loads & stores)
  * test/scripts/SuiteA/test01.fdo (and & or & xor)
  * test/scripts/SuiteA/test02.fdo (inc & dec)
  * test/scripts/SuiteA/test03.fdo (bit shifts)
  * test/scripts/SuiteA/test04.fdo (jumps & return)
  * test/scripts/SuiteA/test05.fdo (register instructions)
  * test/scripts/SuiteA/test06.fdo (add & subtract)
  * test/scripts/SuiteA/test07.fdo (cmp & beq & bne)
  * test/scripts/SuiteA/test08.fdo (cpx & cpy & bit)
  * test/scripts/SuiteA/test09.fdo (other branches)
  * test/scripts/SuiteA/test10.fdo (flag instructions)
  * test/scripts/SuiteA/test11.fdo (stack instructions)
  * test/scripts/SuiteA/test12.fdo (rti)
  * test/scripts/SuiteA/test13.fdo (special [unused](unused.md) flags)
  * test/scripts/AllSuiteA.fdo (a.k.a. Suite A)
(Notice that all but PowerTest make up "Suite A", and that test00 through test13 are all combined into the single AllSuiteA test for convenience, though I'd recommend running each individual test for better confidence.)

Testing Instructions:
  * First "svn update" on the repository.
  * From the src directory, run generate\_plas.bat (if you're using Windows, assumes Python is in your PATH environment variable, ask Heather if you need help with this step). YOU MUST DO THIS STEP FOR EVERY UPDATE.
  * In ModelSim, change directory to the trunk of the repository (most likely a directory named either hmc-6502 or trunk).
  * In the ModelSim command prompt, for each TEST\_NAME, type:
    * do {./TEST\_NAME}
      * ^ See all available test names in the list at the top of this page. You need to include the path to that test as well.
    * run -all
  * If you need debugging help, just ask Heather or Kyle.

Debugging:
  * ROMS (opcodes + comments on what the tests are doing) are in test/roms.
  * Verilog testbenches are test/SuiteATests/testXX.sv and test/unittests/PowerTest.sv in case you need to look at the testbench particulars (though it probably won't help too much with debugging).