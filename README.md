Note:

The language parse tree is navigated by the semantic analyser,
which also checks that the language’s semantic rules are being
followed and prints the relevant error messages in the event of a
violation.

Semantic Rules are: 
1.  In C, you cannot use the reserved keyword or identifier. 
2.  Arithmetic operations require numbers/integers.  
3.  New declarations don't conflict with earlier ones 
4.  Break and Continue statements only appear in loops 
5.  The actual parameter’s type in a call must be compatible with the formal parameter’s 
type.  
 
Assumptions:

Assignment statements of the form "a=b" and "a=b+c". 
If-statement and if-else-statement - no loops and switch.

Programs are made in FLEX, Bison & C++

Instructions: 

1. Click on run.bat
2. If any errors, they are displayed in console
3. Check symbol table in symboltable.txt
4. For more options/errors check the comments in input.c 

Build By:

Pulkit Batra, Gopal Pandey and Shubham Sagar
