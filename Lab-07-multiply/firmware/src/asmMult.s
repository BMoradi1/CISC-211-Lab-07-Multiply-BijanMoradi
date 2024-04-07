/*** asmMult.s   ***/
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */
/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
    
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Bijan Moradi"  
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0  
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0  
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

    
/********************************************************************
function name: asmMult
function description:
     output = asmMult ()
     
where:
     output: 
     
     function description: The C call ..........
     
     notes:
        None
          
********************************************************************/    
.global asmMult
.type asmMult,%function
asmMult:   

    /* save the caller's registers, as required by the ARM calling convention */
    push {r4-r11,LR}
 
.if 0
    /* profs test code. */
    mov r0,r0
.endif
    
    /** note to profs: asmMult.s solution is in Canvas at:
     *    Canvas Files->
     *        Lab Files and Coding Examples->
     *            Lab 8 Multiply
     * Use it to test the C test code */
    
    /*** STUDENTS: Place your code BELOW this line!!! **************/

    /*zero everything*/
    LDR r5, = a_Multiplicand
	/*set r4 to 0, use r5 to store memory address of the variable, then set it to 0 with r4*/
    MOV r4, 0
    STR r4, [r5]
    LDR r5, = b_Multiplier
    STR r4, [r5]
    LDR r5, = rng_Error
    STR r4, [r5]
    LDR r5, = a_Sign
    STR r4, [r5]
    LDR r5, = b_Sign
    STR r4, [r5]
    LDR r5, = prod_Is_Neg
    STR r4, [r5]
    LDR r5, = a_Abs
    STR r4, [r5]
    LDR r5, = b_Abs
    STR r4, [r5]
    LDR r5, = init_Product
    STR r4, [r5]
    LDR r5, = final_Product
    STR r4, [r5]
    /*load the multiplican and multiplier*/
    LDR r2, = a_Multiplicand
    STR r0, [r2]
    LDR r2, = b_Multiplier
    STR r1, [r2]
    /*check to ensure the multiplicand and multiplier are within 16 bit as stated on lab sheet*/
    /*check r0*/
    /*use LDR psedo instruction due to the size being to large for MOV intermediate*/
    LDR r7,= -32768
    LDR r8,= 32767
    CMP r0, r7 /*check negative maximum*/
    BLT overflow
    CMP r0, r8 /*check positive maximum*/
    BGT overflow
	/*check r1*/
    CMP r1, r7 /*check negative maximum*/
    BLT overflow
    CMP r1, r8 /*check positive maximum*/
    BGT overflow
    /*get the signs*/

    /*lets use r3, r4 for our ASR to make sure we dont mess up the value in r0, r1.*/
    MOV r3, r0
    ASR r3, r3, 31 /*replace all bits with the sign bit using ASR*/
    MOV r4, r1
    ASR r4, r4, 31 /*replace all bits with the sign bit using ASR*/
    /*now lets use LSL and LSR so we end up with only one bit. now we can just transfer the states into the memory locations a_Neg, b_Neg*/
    /*same method we used in packing and unpacking last lab*/
    /*a_sign = r3, b_sign = r4*/
    LSL r3,r3,31
    LSR r3,r3,31
    LSL r4,r4,31
    LSR r4,r4,31
    /*0 positive, 1 negative*/
    LDR r5, = a_Sign /*store our signs*/
    STR r3, [r5]
    LDR r5, = b_Sign
    STR r4, [r5]
    CMP r0, 0 /*check to see if either value is 0 if so we skip using EOR*/
    BEQ oneeqzero
    CMP r1, 0
    BEQ oneeqzero
    EOR r6, r3, r4 /* use XOR to find out if product is negative*/
    
    LDR r5, = prod_Is_Neg
    STR r6, [r5] /*result is the sign assuming neither number was zero (which we checked for previously)*/
    B skip /*skip the oneeqzero label*/
    oneeqzero:/*one of the numbers being multiplied was a zero, therefore the awnser will be zero, and the sign positive*/
    MOV r6,0
    LDR r5, = prod_Is_Neg
    STR r6, [r5]
    skip:
    /*lets get our absolute vales now, we will use register shifts to remove the sign bits*/
    LDR r6, = a_Multiplicand /* load multiplicand into register*/
    LDR r3, [r6]
    STR r3, [r6]
    
    LDR r6, = b_Multiplier /* load multiplicand into regester*/
    LDR r4, [r6]
    STR r4, [r6]
    
    /*now time to negate using RSB */
    CMP r3, 0 /*check if its negative before negation*/
    RSBLT r3, r3, 0 /*r3 = 0 -r3 -> r3 = -r3, heres where we change the sign if negative*/
    
    /*now time to negate*/
    CMP r4, 0 /*check if its negative before negation*/
    RSBLT r4, r4, 0 /*r4 = 0 -r4 -> r4 = -r4, heres where we change the sign if negative*/
    
    /*store those into a_abs and b_abs*/
    LDR r6, = a_Abs
    STR r3, [r6]
    LDR r6, = b_Abs
    STR r4, [r6]
     
    /*now we implement shift add multiplication as per lecture slide*/
    /*r3 will be a_abs MULTIPLICANT, r4 b_abs MULTIPLIER, r5 temp product*/
    /*note: no need to reload a/b abs, already in correct registers*/
    
    MOV r5, 0 /*make sure r5 is cleared*/
    loop:
	CMP r4, 0 /*check if Multiplier is 0*/
	BEQ stoploop /*nothing left to add, the product has been calculated*/
	MOV r7, r4
	LSl r7, r7, 31 /*clear all bits except LSB*/
	LSR r7, r7, 31
	CMP r7, 1 /*check if LSB is 1*/
	BNE noAdd /*skip the addition as per the flow chart*/
	ADD r5, r5, r3 /*product = product + multiplicand as per slides*/
	

    noAdd: /*multiplier != 1, skip addition as per lab flowchart*/
	LSR r4, r4, 1/*register shifts as per flowchart*/
	LSL r3, r3, 1
	B loop
    	
    stoploop: /*finished multipling as per flowchart*/
	LDR r6, = init_Product
	STR r5, [r6]
	B finalcleanup

    /*heres where we negate if negative, and set the final r0 register value*/
    finalcleanup:
	LDR r6,= prod_Is_Neg
	LDR r7, [r6]
	CMP r7, 1 /*check if its a negative product*/
	BEQ addnegative /*negative detected if EQ*/
	LDR r6, = final_Product
	LDR r9, = init_Product
	LDR r10, [r9] /*load them up into the correct memory locations*/
	STR r10,[r6]
	LDR r0, [r9]
	B done
    addnegative: /*the product is negative, therefore we must negate the absolute value for the true product*/
	LDR r6, = init_Product
	LDR r7, [r6]
	RSB r7, r7, 0 /*r7 = 0 -r7 -> r7 = -r7, this gives us our negative*/
	LDR r6, = final_Product
	STR r7, [r6]
	MOV r0, r7 /*final product goes in r0*/
	B done
	
	
  
    overflow: /*set overflow state accordinng to lab*/
	LDR r2, = rng_Error
	MOV r3, 1 /*set error state 1*/
	STR r3, [r2]
	MOV r0, 0 /*final product goes in r0*/
	B done
    /*** STUDENTS: Place your code ABOVE this line!!! **************/

done:    
    /* restore the caller's registers, as required by the 
     * ARM calling convention 
     */
    mov r0,r0 /* these are do-nothing lines to deal with IDE mem display bug */
    mov r0,r0 

screen_shot:    pop {r4-r11,LR}

    mov pc, lr	 /* asmMult return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
           




