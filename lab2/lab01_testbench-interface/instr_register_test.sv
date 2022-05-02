/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/
//la crearea clasei in afara de initial begin intra totul in clasa:functii,var interne ...
//clasa mai are constructors
//declaram o var in clasa pt interfata cu virtual:virtual virtual tb_ifc.test interface
//declaram clasa class   endclass

module instr_register_test
  import instr_register_pkg::*;  // user-defined types are defined in instr_register_pkg.sv
  (
    tb_ifc.TB laborator3
  );//aici am important interfata creeand o instanta pt ea
//functia are timpu de simulare 0 iar task ul are timp de simulare mediu si nu returneaza o valoare
  //timeunit 1ns/1ns;
  class first_test;  
  virtual tb_ifc.TB laborator3;
  parameter nr_of_operations = 5;

  covergroup my_coverage; 
        OP_A_COVER:coverpoint laborator3.cb.operand_a{
            bins neg[] = {[-15:-1]}; //valorile pe care vrem sa le masuram;cu el cream un coverpoint
            bins zero = {0};
            bins pos[] = {[1:15]};//punem [] pt a luat toate val din interval,doar la cele cu mai multe valori
        }
        OP_B_COVER:coverpoint laborator3.cb.operand_b{
            bins zero = {0};
            bins pos[] = {[1:15]};
        }
        OP_COVER:coverpoint laborator3.cb.opcode{
            bins opcode_values[] = {[0:7]};
        }
        OP_RESULT_COVER:coverpoint laborator3.cb.instruction_word.op_result{
            bins result_neg[] = {[-30:-1]};//daca exista un nr neg din interval atunci result_neg e 100%
            bins result_pos[] = {[1:30]};
        }
    endgroup
  //int seed = 555;//seed ul reprezinta val initiala cu care va incepe randomizarea
  function new(virtual tb_ifc.TB laborator3);  
    this.laborator3=laborator3;
    my_coverage = new();
  endfunction

  task run();
  // initial begin
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");
    $display("\nFirst header");
    $display("\nReseting the instruction register...");
    laborator3.cb.write_pointer  <= 5'h00;         // initialize write pointer
    laborator3.cb.read_pointer   <= 5'h1F;         // initialize read pointer
    laborator3.cb.load_en        <= 1'b0;          // initialize load control line
    laborator3.cb.reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge laborator3.cb) ;     // hold in reset for 2 clock cycles;asteapta doua fronturi poz de ceas
    laborator3.cb.reset_n        <= 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge laborator3.cb) laborator3.cb.load_en <= 1'b1;  // enable writing to register
    //repeat (3) begin
    repeat (nr_of_operations) begin
      @(posedge laborator3.cb) randomize_transaction;
      @(negedge laborator3.cb) print_transaction;
      my_coverage.sample;
    end
    @(posedge laborator3.cb) laborator3.cb.load_en <= 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    repeat (2) begin
      //for (int i=2; i >= 2; i--) begin
      for (int i=0; i <= nr_of_operations; i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge laborator3.cb) laborator3.cb.read_pointer <= i;
      @(negedge laborator3.cb) print_results;
      my_coverage.sample;
    end
    end  
    // for (int i=2; i >= 2; i--) begin
    //   // later labs will replace this loop with iterating through a
    //   // scoreboard to determine which addresses were written and
    //   // the expected values to be read back
    //   @(posedge laborator3.cb) laborator3.cb.read_pointer <= i;
    //   @(negedge laborator3.cb) print_results;
    // end

    @(posedge laborator3.cb) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  // end
  endtask

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab
    //
    static int temp = 0;
    laborator3.cb.operand_a     <= $signed($urandom)%16;                 // between -15 and 15,ia val random,ata poz cat si neg
    laborator3.cb.operand_b     <= $unsigned($urandom)%16;            // between 0 and 15,val random pe 32 biti numa poz
    laborator3.cb.opcode        <= opcode_t'($unsigned($urandom)%8);
    // laborator3.cb.operand_a     <= $random(seed)%16;                 // between -15 and 15,ia val random,ata poz cat si neg
    // laborator3.cb.operand_b     <= $unsigned($random)%16;            // between 0 and 15,val random pe 32 biti numa poz
    // laborator3.cb.opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type;are loc op de cast,convertire,care trece din index in stringuri
    laborator3.cb.write_pointer <= temp++;//daca avem numa =,adica blocanta,avem temp++
    //cu <= e neblocanta si primeste intai temp dupa ++
  endfunction: randomize_transaction

  function void print_transaction;//printeaza in consola
    $display("Writing to register location %0d: ", laborator3.cb.write_pointer);
    $display("  opcode = %0d (%s)", laborator3.cb.opcode, laborator3.cb.opcode.name);
    $display("  operand_a = %0d",   laborator3.cb.operand_a);
    $display("  operand_b = %0d\n", laborator3.cb.operand_b);
    $display("  time = %d ns \n", $time);
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", laborator3.cb.read_pointer);
    $display("  opcode = %0d (%s)", laborator3.cb.instruction_word.opc, laborator3.cb.instruction_word.opc.name);
    $display("  operand_a = %0d",   laborator3.cb.instruction_word.op_a);
    $display("  operand_b = %0d\n", laborator3.cb.instruction_word.op_b);
    $display("  time   = %d ns\n", $time);//print time
    $display("  result    = %0d\n", laborator3.cb.instruction_word.op_result);//print result
  endfunction: print_results 

endclass
  //int seed = 555;//seed ul reprezinta val initiala cu care va incepe randomizarea
  initial begin 
    first_test ft;
    ft=new(laborator3);
    //ft.laborator3 = laborator3;
    ft.run();
  end

endmodule: instr_register_test
//   task run();
//   // initial begin
//     $display("\n\n***********************************************************");
//     $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
//     $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
//     $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
//     $display(    "***********************************************************");
//     $display("\nFirst header");
//     $display("\nReseting the instruction register...");
//     laborator3.cb.write_pointer  <= 5'h00;         // initialize write pointer
//     laborator3.cb.read_pointer   <= 5'h1F;         // initialize read pointer
//     laborator3.cb.load_en        <= 1'b0;          // initialize load control line
//     laborator3.cb.reset_n       <= 1'b0;          // assert reset_n (active low)
//     repeat (2) @(posedge laborator3.cb) ;     // hold in reset for 2 clock cycles;asteapta doua fronturi poz de ceas
//     laborator3.cb.reset_n        <= 1'b1;          // deassert reset_n (active low)
// //task ul se pot pune valori termporale(asteapta ...ns) in timp ce n functie nu
//     $display("\nWriting values to register stack...");
//     @(posedge laborator3.cb) laborator3.cb.load_en <= 1'b1;  // enable writing to register
//     repeat (3) begin
//       @(posedge laborator3.cb) randomize_transaction;
//       @(negedge laborator3.cb) print_transaction;
//     end
//     @(posedge laborator3.cb) laborator3.cb.load_en <= 1'b0;  // turn-off writing to register

//     // read back and display same three register locations
//     $display("\nReading back the same register locations written...");
//     repeat (2) begin
//       for (int i=2; i >= 2; i--) begin
//       // later labs will replace this loop with iterating through a
//       // scoreboard to determine which addresses were written and
//       // the expected values to be read back
//       @(posedge laborator3.cb) laborator3.cb.read_pointer <= i;
//       @(negedge laborator3.cb) print_results;
//     end
//     end  
//     // for (int i=2; i >= 2; i--) begin
//     //   // later labs will replace this loop with iterating through a
//     //   // scoreboard to determine which addresses were written and
//     //   // the expected values to be read back
//     //   @(posedge laborator3.cb) laborator3.cb.read_pointer <= i;
//     //   @(negedge laborator3.cb) print_results;
//     // end

//     @(posedge laborator3.cb) ;
//     $display("\n***********************************************************");
//     $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
//     $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
//     $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
//     $display(  "***********************************************************\n");
//     $finish;
//   // end
//   endtask

//   function void randomize_transaction;
//     // A later lab will replace this function with SystemVerilog
//     // constrained random values
//     //
//     // The stactic temp variable is required in order to write to fixed
//     // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
//     // write_pointer values in a later lab
//     //
//     static int temp = 0;
//     laborator3.cb.operand_a     <= $random(seed)%16;                 // between -15 and 15,ia val random,ata poz cat si neg
//     laborator3.cb.operand_b     <= $unsigned($random)%16;            // between 0 and 15,val random pe 32 biti numa poz
//     laborator3.cb.opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type;are loc op de cast,convertire,care trece din index in stringuri
//     laborator3.cb.write_pointer <= temp++;//daca avem numa =,adica blocanta,avem temp++
//     //cu <= e neblocanta si primeste intai temp dupa ++
//   endfunction: randomize_transaction

//   function void print_transaction;//printeaza in consola
//     $display("Writing to register location %0d: ", laborator3.cb.write_pointer);
//     $display("  opcode = %0d (%s)", laborator3.cb.opcode, laborator3.cb.opcode.name);
//     $display("  operand_a = %0d",   laborator3.cb.operand_a);
//     $display("  operand_b = %0d\n", laborator3.cb.operand_b);
//     $display("  time = %d ns \n", $time);
//   endfunction: print_transaction

//   function void print_results;
//     $display("Read from register location %0d: ", laborator3.cb.read_pointer);
//     $display("  opcode = %0d (%s)", laborator3.cb.instruction_word.opc, laborator3.cb.instruction_word.opc.name);
//     $display("  operand_a = %0d",   laborator3.cb.instruction_word.op_a);
//     $display("  operand_b = %0d\n", laborator3.cb.instruction_word.op_b);
//     $display("  time   = %d ns\n", $time);//print time
//     $display("  result    = %0d\n", laborator3.cb.instruction_word.op_result);//print result
//   endfunction: print_results