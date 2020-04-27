# Lolita Nefari Nazarov
# lnazarov
# 110722612

.data
# Command-line arguments
num_args: .word 0
addr_arg0: .word 0
addr_arg1: .word 0
addr_arg2: .word 0
addr_arg3: .word 0
addr_arg4: .word 0
no_args: .asciiz "You must provide at least one command-line argument.\n"

# Error messages
invalid_operation_error: .asciiz "INVALID_OPERATION\n"
invalid_args_error: .asciiz "INVALID_ARGS\n"
second_arg_wrong: .asciiz "second arg wrong\n"

# Put your additional .data declarations here

# Miscellaneous strings
nl: .asciiz "\n"
space:  .asciiz " "

# Main program starts here
.text
.globl main
main:
    # Do not modify any of the code before the label named "start_coding_here"
    # Begin: save command-line arguments to main memory
    sw $a0, num_args
    beqz $a0, zero_args
    li $t0, 1
    beq $a0, $t0, one_arg
    li $t0, 2
    beq $a0, $t0, two_args
    li $t0, 3
    beq $a0, $t0, three_args
    li $t0, 4
    beq $a0, $t0, four_args
five_args:
    lw $t0, 16($a1)
    sw $t0, addr_arg4
four_args:
    lw $t0, 12($a1)
    sw $t0, addr_arg3
three_args:
    lw $t0, 8($a1)
    sw $t0, addr_arg2
two_args:
    lw $t0, 4($a1)
    sw $t0, addr_arg1
one_arg:
    lw $t0, 0($a1)
    sw $t0, addr_arg0
    j start_coding_here

zero_args:
    la $a0, no_args
    li $v0, 4
    syscall
    j exit
    # End: save command-line arguments to main memory

start_coding_here:
    # Start the assignment by writing your code here
    
    lw $s0, addr_arg0 # Load address of the first argument into $s0 
    lbu $s1, 0($s0) # get first char of first argument
    lbu $s2, 1($s0) # get second char of first argument
    
    # make sure that first argument has length one
    bne $s2, $0, not_length_one 
    
    li $t0 , 'B'
    li $t1, 'C'
    li $t2, 'D'
    li $t3, 'E'
    
    beq $s1, $t0, arg_b # check if first arg is b; if it's B, branch to arg_b
    beq $s1, $t1, arg_c # check if first arg is c
    beq $s1, $t2, arg_d # check if first arg is d
    beq $s1, $t3, arg_e # check if first arg is e
    
arg_b:
    lw $s0, num_args
    li $t0, 2
    bne $s0, $t0, invalid_args
    
    lw $s0, addr_arg1
    
    li $s1, 0 # number of aces
    li $s2, 0 # number of kings
    li $s3, 0 # number of queens
    li $s4, 0 # number of jacks
    
    li $t2, 0 # number of hearts
    li $t3, 0 # number of diamonds
    li $t4, 0 # number of clubs
    li $t5, 0 # number of spades
    
    li $t6, 0 # the number of ranks or suits which to end on when reading in the string
    li $t7, 1 # for incrementing the number of ranks or suits
    
rank_loop_b:

    lbu $t0, 0($s0) # get first character of second argument - RANK
    
    caseAce: 
         li $s5, 'A'
         bne $t0, $s5, caseKing
         add $s1, $s1, $t7 # increment number of aces
    
    caseKing:
         li $s5, 'K'
         bne $t0, $s5, caseQueen
         add $s2, $s2, $t7 # increment number of kings
    
    caseQueen:
         li $s5, 'Q'
         bne $t0, $s5, caseJack
         add $s3, $s3, $t7 # increment number of queens
         
    
    caseJack:
         li $s5, 'J'
         bne $t0, $s5, default_rank
         add $s4, $s4, $t7 # increment number of jacks
    
    default_rank: 
    	add $t6, $t6, $t7 # increment the rank counter until it's 13 (number of ranks in the string)
    	li $s6, 13 # check if we've reached the end 
        beq $t6, $s6, reset_everything_between_loops
    	addi $s0, $s0, 2 # move pointer to next NEXT character
    	
    j rank_loop_b
    
reset_everything_between_loops:
    
    # need to reset everything
    li $t6, 0 # reset the suit counter (branches if it reaches 13, the number of cards in hand)
    lw $s0, addr_arg1 
    
    
    j suit_loop_b

suit_loop_b:

    lbu $t1, 1($s0) # get second character of second argument - SUIT
    
    caseHearts:
         li $s5, 'H'
         bne $t1, $s5, caseDiamonds
         add $t2, $t2, $t7 # increment number of hearts
         
    caseDiamonds:
         li $s5, 'D'
         bne $t1, $s5, caseClubs
         add $t3, $t3, $t7 # increment number of diamonds
    
    caseClubs:
         li $s5, 'C'
         bne $t1, $s5, caseSpades
         add $t4, $t4, $t7 # increment number of clubs
    
    caseSpades:
         li $s5, 'S'
         bne $t1, $s5, default_suit
         add $t5, $t5, $t7 # increment number of spades
    
    default_suit:
    	add $t6, $t6, $t7 # increment the rank counter until it's 13 (number of ranks in the string)
    	li $s6, 13 # check if we've reached the end 
    	beq $t6, $s6, tally_total_score_b
    	addi $s0, $s0, 2 # move pointer to next NEXT character
    	
    j suit_loop_b  

tally_total_score_b:
    li $t6, 0 # represents total score
    
    li $t0, 4 #points for Ace
    li $t1, 3 #points for King
    li $s5, 2 #points for Queen
    li $s6, 1 #points for Jack
    
    mul $t7, $t0, $s1 # multiply points x # Aces
    add $t6, $t6, $t7 # increment total score by Ace points
    mul $t7, $t1, $s2 # multiply points x # King
    add $t6, $t6, $t7 # increment total score by King points
    mul $t7, $s5, $s3 # multiply points x # Queen
    add $t6, $t6, $t7 # increment total score by Queen points
    mul $t7, $s6, $s4 # multiply points x # Jack
    add $t6, $t6, $t7 # increment total score by Jack points
    
    # number hearts = t2, number diamonds = t3, number clubs = t4, number spades = t5
    
    li $t0, 3 #points added if no suit
    li $t1, 2 #points added if 1 of suit
    li $s5, 1 #points added if 2 of suit

# IF A SUIT HAS 0 CARDS
hearts_equals_0_b: # if number Hearts = 0, add 3 to total tally
    beqz $t2, add_to_tally_no_suit_H_b
    j diamonds_equals_0_b
    
add_to_tally_no_suit_H_b:
    add $t6, $t6, $t0
    
diamonds_equals_0_b: # if number Diamonds = 0, add 3 to total tally
    beqz $t3, add_to_tally_no_suit_D_b
    j clubs_equals_0_b
    
add_to_tally_no_suit_D_b:
    add $t6, $t6, $t0
    
clubs_equals_0_b: # if number Clubs = 0, add 3 to total tally
    beqz $t4, add_to_tally_no_suit_C_b
    j spades_equals_0_b

add_to_tally_no_suit_C_b:
    add $t6, $t6, $t0
    
spades_equals_0_b: # if number Spades = 0, add 3 to total tally
    beqz $t5, add_to_tally_no_suit_S_b
    j hearts_equals_1_b # once we checked all of the suits for nullity, jump to checking if there's 1 in each suit

add_to_tally_no_suit_S_b:
    add $t6, $t6, $t0
    
    
    
# IF A SUIT HAS 1 CARD 
hearts_equals_1_b: # if number Hearts = 1, add 2 to total tally
    beq $t2, $s5 add_to_tally_one_of_suit_H_b
    j diamonds_equals_1_b # if number of hearts does not equal 1, check if # diamonds = 1
    
add_to_tally_one_of_suit_H_b:  
    add $t6, $t6, $t1 # increment total tally by 2
    
diamonds_equals_1_b: # if number Diamonds = 1, add 2 to total tally
    beq $t3, $s5 add_to_tally_one_of_suit_D_b
    j clubs_equals_1_b # if number of diamonds does not equal 1, check if # clubs = 1
    
add_to_tally_one_of_suit_D_b:
    add $t6, $t6, $t1 # increment total tally by 2
    
clubs_equals_1_b: # if number Clubs = 1, add 2 to total tally
    beq $t4, $s5 add_to_tally_one_of_suit_C_b
    j spades_equals_1_b
    
add_to_tally_one_of_suit_C_b:
    add $t6, $t6, $t1 # increment total tally by 2
   
spades_equals_1_b: # if number Spades = 1, add 2 to total tally
    beq $t5, $s5 add_to_tally_one_of_suit_S_b
    j hearts_equals_2_b
    
add_to_tally_one_of_suit_S_b:
    add $t6, $t6, $t1


# IF A SUIT HAS 2 CARDS   
hearts_equals_2_b: # if number Hearts = 2, add 1 to total tally
    beq $t2, $t1 add_to_tally_two_of_suit_H_b
    j diamonds_equals_2_b # if number of hearts does not equal 2, check if # diamonds = 2
    
add_to_tally_two_of_suit_H_b:  
    add $t6, $t6, $s5 # increment total tally by 1
    
diamonds_equals_2_b: # if number Diamonds = 2, add 1 to total tally
    beq $t3, $t1 add_to_tally_two_of_suit_D_b
    j clubs_equals_2_b # if number of diamonds does not equal 2, check if # clubs = 2
    
add_to_tally_two_of_suit_D_b:
    add $t6, $t6, $s5 # increment total tally by 1
    
clubs_equals_2_b: 
    beq $t4, $t1 add_to_tally_two_of_suit_C_b # if number Clubs = 2, add 1 to total tally
    j spades_equals_2_b # if number of clubs does not equal 2, check if # spades = 2
    
add_to_tally_two_of_suit_C_b:
    add $t6, $t6, $s5 # increment total tally by 1
    
spades_equals_2_b:
    beq $t5, $t1 add_to_tally_two_of_suit_S_b  # if number Spades = 2, add 1 to total tally
    j display_part_b
    
add_to_tally_two_of_suit_S_b:
    add $t6, $t6, $s5   
    
display_part_b:
    move $a0, $t6
    li $v0, 1
    syscall
    
    j exit
    
arg_c:
    lw $s0, num_args
    li $t0, 4
    bne $s0, $t0, invalid_args
    
    lw $t7, addr_arg3 # this is the hexadecimal argument
    li $s6, 0 # this is supposed to be the giant hex string in binary form that is incremented on
    
read_hex_string_loop_c:
  
    lbu $t1, 2($t7) # load current character into $t1
    addi $t7, $t7, 1 # move pointer to next character
    
    li $t3, '9'
    
    beqz $t1, check_for_second_and_third_args_c # all arguments are terminated by null character ASCII 0. If the byte loaded is 0, branch to _____ function
    ble $t1, $t3, convert_decimal_char_c # if character <= 9, convert decimal character to binary
    bgt $t1, $t3, convert_alphabet_char_c # if character > 9, convert alphabet character to binary
    
convert_decimal_char_c: 
    addi $t1, $t1, -48 
    j increment_string_c
    
convert_alphabet_char_c:
    addi $t1, $t1, -55
    j increment_string_c

increment_string_c:
    sll $s6, $s6, 4 # make room for 4 new bits by shifting all bits to the left
    add $s6, $s6, $t1 # increment the giant binary number by the character converted to binary
    j read_hex_string_loop_c
  
check_for_second_and_third_args_c: 

    # load second argument and get first and second char
    lw $s0, addr_arg1
    lbu $t3, 0($s0) # get first character of second argument
    lbu $t4, 1($s0) # get second character of second argument - need to make sure it's null
    
    # load third argument and get first and second char 
    lw $s1, addr_arg2
    lbu $t5, 0($s1) # get first character of third argument
    lbu $t6, 1($s1) # get second character of third argument - need to make sure it's null
    
    bne $t4, $0, invalid_args # if the second character of either second or third arguments isn't null -> invalid args
    bne $t6, $0, invalid_args

    li $t0, '1'
    li $t1, '2'
    li $t2, 'S'
    
    # we check the very first bit of $s6 to see if it's a 1 (neg) or a 0 (pos)
    li $t4, 0x80000000
    and $s7, $s6, $t4
    srl $s7, $s7, 31 # this is supposed to be either 1 or 0 (most sig bit of binary number)
    
    beq $t3, $t0, first_arg_1_c # check if first character of second arg is 1
    beq $t3, $t1, first_arg_2_c # check if first character of second arg is 2
    beq $t3, $t2, first_arg_S_c # check if first character of second arg is S
    
first_arg_1_c:
    bne $t0, $t3, invalid_args
    beq $t0, $t5, first_arg_1_second_arg_1_c # check if first char of third argument is equal to 1
    beq $t1, $t5, first_arg_1_second_arg_2_c # check if first char of third argument is equal to 2
    beq $t2, $t5, first_arg_1_second_arg_S_c # check if first char of third argument is equal to S
    
first_arg_2_c:
    bne $t1, $t3, invalid_args
    beq $t0, $t5, first_arg_2_second_arg_1_c # check if first char of third argument is equal to 1
    beq $t1, $t5, first_arg_2_second_arg_2_c # check if first char of third argument is equal to 2
    beq $t2, $t5, first_arg_2_second_arg_S_c # check if first char of third argument is equal to S

first_arg_S_c:
    bne $t2, $t3, invalid_args
    beq $t0, $t5, first_arg_S_second_arg_1_c # check if first char of third argument is equal to 1
    beq $t1, $t5, first_arg_S_second_arg_2_c # check if first char of third argument is equal to 2
    beq $t2, $t5, first_arg_S_second_arg_S_c # check if first char of third argument is equal to S

# $s6 is the giant binary number which we're converting the representation
# $s7 is the most significant bit of the binary number
# t0 = 1, t1 = 2, t2 = S

first_arg_1_second_arg_1_c:
    
    bne $t0, $t5, invalid_args
    j display_part_c
    
first_arg_1_second_arg_2_c:
    
    bne $t1, $t5, invalid_args
    li $t7, 1
    beq $s7, $t7, first_arg_1_second_arg_2_negative_c
    j display_part_c
    
first_arg_1_second_arg_2_negative_c:
    
    li $t3, 1
    add $s6, $s6, $t3 # just add one??? I think??? 
    
    j display_part_c

first_arg_1_second_arg_S_c:
    bne $t2, $t5, invalid_args
    li $t7, 1
    beq $s7, $t7, first_arg_1_second_arg_S_negative_c

    j display_part_c
    
first_arg_1_second_arg_S_negative_c:

    li $t3, 0xFFFFFFFF
    li $t4, 0x80000000
    beq $t4, $s6, special_case_800_1_S
    
    # if the most significant bit is 1 (negative)
    
    xor $s6, $s6, $t3 # flip all the bits
    or $s6, $s6, $t4 # make most significant bit 1 again
    
    j display_part_c
    
special_case_800_1_S:
    li $s6, 0
    j display_part_c
    
first_arg_2_second_arg_1_c:
    bne $t0, $t5, invalid_args
    li $t7, 1
    beq $s7, $t7, first_arg_2_second_arg_1_negative_c
    
    j display_part_c
    
first_arg_2_second_arg_1_negative_c:
    
    li $t3, -1
    add $s6, $s6, $t3
    
    j display_part_c
    
first_arg_2_second_arg_2_c:

    bne $t1, $t5, invalid_args
    j display_part_c

first_arg_2_second_arg_S_c:
    bne $t2, $t5, invalid_args
    li $t7, 1
    beq $s7, $t7, first_arg_2_second_arg_S_negative_c

    j display_part_c
    
first_arg_2_second_arg_S_negative_c:
    li $t3, 0xFFFFFFFF
    xor $s6, $s6, $t3 # flip all the bits
    li $t7, 1
    add $s6, $s6, $t7 # add one to binary number
    li $t4, 0x80000000
    or $s6, $s6, $t4 # make most significant bit 1 again
    
    j display_part_c
    
first_arg_S_second_arg_1_c:
    bne $t0, $t5, invalid_args
    li $t7, 1
    beq $s7, $t7, first_arg_S_second_arg_1_negative_c
    
    j display_part_c

first_arg_S_second_arg_1_negative_c:
    
    li $t3, 0xFFFFFFFF
    li $t4, 0x80000000
    
    # special case: 0x80000000
    beq $t4, $s6 special_case_800_S_1
    
    xor $s6, $s6, $t3 # flip all the bits
    
    or $s6, $s6, $t4 # make most significant bit 1 again
    
    j display_part_c

special_case_800_S_1:
    li $s6, 0
    j display_part_c

first_arg_S_second_arg_2_c:
    bne $t1, $t5, invalid_args
    li $t7, 1
    beq $s7, $t7, first_arg_S_second_arg_2_negative_c

    j display_part_c

first_arg_S_second_arg_2_negative_c:
     
    li $t3, 0xFFFFFFFF
    li $t4, 0x80000000
    
    beq $t4, $s6, special_case_800_S_2
    
    xor $s6, $s6, $t3 # flip all the bits
    li $t7, 1
    add $s6, $s6, $t7 # add one to binary number
    
    or $s6, $s6, $t4 # make most significant bit 1 again

    j display_part_c
    
special_case_800_S_2:
    li $s6, 0
    j display_part_c

first_arg_S_second_arg_S_c:
    bne $t2, $t5, invalid_args
    j display_part_c

display_part_c:
    move $a0, $s6
    li $v0, 35
    syscall
    
    j exit
    
arg_d:
    lw $s0, num_args
    li $t0, 2
    bne $s0, $t0, invalid_args #if number of arguments != 2, print invalid args error
    
    # load address of 0xHEXADECIMAL, aka second argument
    lw $t0, addr_arg1
    lbu $t1, 0($t0) # get first character of second argument
    lbu $t2, 1($t0) # get second character of second argument
    
    li $t3, '0'
    li $t4, 'x'
    bne $t1, $t3, invalid_args # print out invalid args error if first character of second arg isn't 0
    bne $t2, $t4, invalid_args # print out invalid args error if second character of second arg isn't x
    
    li $s0, 0 # binary string that we are trying to convert to
    # li $s1, 0 # the counter i , starting at 2 for the character position in argument
    
    j read_hex_string_loop_d
    
read_hex_string_loop_d:
  
    lbu $t1, 2($t0) # load current character into $t1
    addi $t0, $t0, 1 # move pointer to next character
    
    li $t2, '0'
    li $t3, '9'
    li $t4, 'A'
    li $t5, 'F'
    
    beqz $t1, bitwise_function_d # all arguments are terminated by null character ASCII 0. If the byte loaded is 0, branch to bitwise function
    blt $t1, $t2, invalid_char_d # if character < 0, invalid
    bgt $t1, $t5, invalid_char_d # if character > F, invalid
    ble $t1, $t3, convert_decimal_char_d # if character <= 9, convert character to binary
    bge $t1, $t4, convert_alphabet_char_d # if character >= A, convert character to binary
    
invalid_char_d:
    la $a0, invalid_args_error
    li $v0, 4
    syscall
    j exit

convert_decimal_char_d: 
    addi $t1, $t1, -48 
    j increment_string_d
    
convert_alphabet_char_d:
    addi $t1, $t1, -55
    j increment_string_d

increment_string_d:
    sll $s0, $s0, 4 # make room for 4 new bits by shifting all bits to the left
    add $s0, $s0, $t1 # increment the giant binary string by the character converted to binary
    j read_hex_string_loop_d

bitwise_function_d:
    andi $t2, $s0, 0xFFFF # isolate rightmost 16 bits for immediate field
    sll $t2,$s0,16 # shift left to fill least significant bits with zeroes
    sra $t2,$t2,16 # shift to rightmost to get the actual value
    andi $t3, $s0, 0x1F0000 # isolate 3rd batch of 5 bits
    sll $t3,$s0,11 # same thing
    srl $t3,$t3,27 # shift right LOGICAL - want to fill most sig bits with zeros so that it's positive
    andi $t4, $s0, 0x3E00000 # isolate 2nd batch of 5 bits
    sll $t4,$s0,6 # shift left to fill LSB with zeros
    srl $t4,$t4,27 # shift right LOGICAL - want to fill most sig bits with zeros so that it's positive
    andi $t5, $s0, 0xFC000000 # isolate 1st batch of 6 bits
    srl $t5,$t5,26
    
    j display_part_d
  
display_part_d:
    move $a0, $t5    # print 1st number
    li $v0, 1 
    syscall    
    la $a0, space  # print space            
    li $v0, 4      
    syscall  
    
    move $a0, $t4    # print 2nd number
    li $v0, 1 
    syscall  
    la $a0, space  # print space            
    li $v0, 4      
    syscall  
    
    move $a0, $t3    # print 3rd number
    li $v0, 1 
    syscall  
    la $a0, space  # print space            
    li $v0, 4      
    syscall  
    
    move $a0, $t2    # print 4th number
    li $v0, 1 
    syscall  
    
    j exit
      
arg_e:
    lw $s0, num_args
    li $t0, 5
    bne $s0, $t0, invalid_args
    
    # if first arg is just E, proceed with reading in the rest of the arguments
    
    li $s0, 0 # decimal number for second arg (arg1)
    li $s1, 0 # decimal number for third arg (arg2)
    li $s2, 0 # decimal number for fourth arg (arg3)
    li $s3, 0 # decimal number for fifth arg (arg4)
    
    # load all the arguments into registers
    lw $t0, addr_arg1
    lw $t1, addr_arg2
    lw $t2, addr_arg3
    lw $t3, addr_arg4
    
    li $s4, 10 # this is the multiplier
    
for_loop_read_arg1_e:
    lbu $t4, 0($t0) # load current character of string argument into $t4
    beqz $t4, for_loop_read_arg2_e
    addi $t4, $t4, -48
    mul $s0, $t4, $s4 # multiply sum by 10 
    
    addi $t0, $t0, 1 # move pointer to next character
    lbu $t5, 0($t0)
    addi $t5, $t5, -48
    
    add $s0, $s0, $t5 # sum += digit
    

for_loop_read_arg2_e:
    lbu $t4, 0($t1) # load current character of string argument into $t4
    beqz $t4, for_loop_read_arg3_e
    addi $t4, $t4, -48
    mul $s1, $t4, $s4 # multiply sum by 10 
    
    addi $t1, $t1, 1 # move pointer to next character
    lbu $t5, 0($t1)
    addi $t5, $t5, -48
    
    add $s1, $s1, $t5 # sum += digit
    
for_loop_read_arg3_e:
    lbu $t4, 0($t2) # load current character of string argument into $t4
    beqz $t4, for_loop_read_arg4_positive_e
    addi $t4, $t4, -48
    mul $s2, $t4, $s4 # multiply sum by 10 
    
    addi $t2, $t2, 1 # move pointer to next character
    lbu $t5, 0($t2)
    addi $t5, $t5, -48
    
    add $s2, $s2, $t5 # sum += digit
    
for_loop_read_arg4_positive_e:
    
    li $t6, '-'
    lbu $t4, 0($t3) # load current character of string argument into $t4
    beq $t4, $t6, for_loop_read_arg4_negative_e
    
    beqz $t4, check_if_args_are_valid_e
    
    addi $t4, $t4, -48
    mul $s3, $s3, $s4 # multiply sum by 10 
    add $s3, $s3, $t4
    addi $t3, $t3, 1 # move pointer to next character
    
    j for_loop_read_arg4_positive_e
    
    # if first char is '-', process the rest of the rest of the number and multiply by -1

for_loop_read_arg4_negative_e:
    lbu $t4, 1($t3) # load current character of string argument into $t4
    beqz $t4, negate_arg4_e
    
    addi $t4, $t4, -48
    mul $s3, $s3, $s4 # multiply sum by 10 
    add $s3, $s3, $t4 # sum += digit
    addi $t3, $t3, 1 # move pointer to next character
   
    j for_loop_read_arg4_negative_e
    
negate_arg4_e:
    li $s5, -1
    mul $s3, $s3, $s5
    j check_if_args_are_valid_e
    
check_if_args_are_valid_e:
    # check that $s0 [6 bits], $s1 [5 bits], $s2 [5 bits], & $s3 [16 bits] are 
    # within the opcode, rs, rt, and immediate ranges
    
    # ranges for the opcode, rs, rt, and immediate
    li $t0, 0 
    li $t1, 63 # opcode is [0, 63]
    li $t2, 31 # rs and rt are [0, 31]
    li $t3, -32768 # -2^15  : rt is [-2^15 to 2^15 - 1]
    li $t4, 32767 #  2^15 - 1 : rt is [-2^15 to 2^15 - 1]
    
    blt $s0, $t0, invalid_args # if opcode < 0, invalid
    blt $s1, $t0, invalid_args # if rs < 0, invalid
    blt $s2, $t0, invalid_args # if rt < 0, invalid
    blt $s3, $t3, invalid_args # if immediate < -2^15, invalid
    
    bgt $s0, $t1, invalid_args # if opcode > 63, invalid
    bgt $s1, $t2, invalid_args # if rs > 31, invalid
    bgt $s2, $t2, invalid_args # if rt > 31, invalid
    bgt $s3, $t4, invalid_args # if immediate > 2^15 - 1, invalid
    
# need to combine the opcode, rs, rt and immediate into one long binary string by masking    
    # $s0 = opcode, $s1 = rs, $s2 = rt, $s3 = immediate

    andi $s0, $s0, 0x3F # isolate rightmost 6 bits for opcode field
    andi $s1, $s1, 0x1F # isolate rightmost 5 bits for rs field
    andi $s2, $s2, 0x1F # isolate rightmost 5 bits for rt field
    andi $s3, $s3, 0xFFFF # isolate rightmost 16 bits for immediate field
     
combine_the_fields_e:
    li $s4, 0 # for masking
    sll $s0, $s0, 26 # shift
    add $s4, $s4, $s0 
    sll $s1, $s1, 21
    add $s4, $s4, $s1
    sll $s2, $s2, 16
    add $s4, $s4, $s2
    
    add $s4, $s4, $s3
    
    j display_part_e
    
display_part_e:
    move $a0, $s4
    li $v0, 34
    syscall
    
    j exit
    
not_length_one:
    la $a0, invalid_operation_error
    li $v0, 4
    syscall 
    j exit
    
invalid_args:
    la $a0, invalid_args_error
    li $v0, 4
    syscall
    j exit

exit:
    li $a0, '\n'
    li $v0, 11
    syscall
    li $v0, 10
    syscall
