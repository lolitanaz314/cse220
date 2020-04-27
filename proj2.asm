# Lolita Nefari Nazarov
# lnazarov
# 110722612

.text
strlen:
    # a0 has the address of the string
    li $t1, 0 # length of the string, which we're going to return
    
    loop_through_string:
    	lbu $t0, 0($a0) # offset is always zero, extract character
    	beqz $t0, done_strlen
    	addi $a0, $a0, 1
    	addi, $t1, $t1, 1
    	j loop_through_string
    	
    done_strlen:
        move $v0, $t1		
    	jr $ra
 
insert:
        # takes three args, str, ch, index
        # str = a0
        # ch = a1
        # index = a2
        # return length of modified string
        
        # if index < 0 or index >= strlen, return -1 (store -1 in v0)
        addi $sp, $sp, -16 # save space on the stack
        sw $ra, 0($sp)      # save ra to the stack
        sw $s0, 4($sp)      # save copy of str to the stack
        sw $s1, 8($sp)      # save copy of ch to the stack
        sw $s2, 12($sp)     # save copy of index to the stack
        
        move $s0, $a0   # copy to s registers
        move $s1, $a1
        move $s2, $a2
        
        bltz $s2, return_neg_one
        
        jal strlen   # call strlen, pass string (a0) as an argument to strlen
        
        # get return value of strlen of the str
        move $t0, $v0 # t0 contains the string length
        move $t4, $t0 # make a copy of the string length for the loop
        
        # if index <= strlen, branch to shifting everything
        ble $s2, $t0, shift_address
        
        # else, return -1
	return_neg_one:
	    li $t0, -1
	    move $v0, $t0
	    
	    lw $ra, 0($sp)      # restore ra from the stack
	    lw $s0, 4($sp)      # restore copy of str from the stack
            lw $s1, 8($sp)      # restore copy of ch from the stack
            lw $s2, 12($sp)     # restore copy of index from the stack
	    addi $sp, $sp, 16 # move pointer back
	    
	    jr $ra
	
	# put char at index in string, shift all the other characters right by one byte
	
	shift_address:
	    add $s0, $s0, $t0 # start from back / shift address of s0 by strlen
	
        insert_shift: 
	    lbu $t1, 0($s0)  # take the char at that index and load it into $t1
	    sb $t1, 1($s0) # store the character from register t1 into the index + 1 of the string
	    beq $s2, $t4, done_insert # branch when you get to index 
	    addi $s0, $s0, -1 # decrement address
	    addi $t4, $t4, -1 # decrement strlen copy
	    
	    j insert_shift
	    
	    # return the new length of the string, which is strlen + 1
	    # t0 has the length of the string
	    done_insert:
	       
	       sb $s1, ($s0)  # store argument char into the designated location
	       
	       addi $t1, $t0, 1 # return length of updated string, which is strlen (stored in t0) + 1
               move $v0, $t1	
               
               lw $ra, 0($sp)      # restore ra from the stack
               lw $s0, 4($sp)      # restore copy of str from the stack  
               lw $s1, 8($sp)      # restore copy of ch from the stack
               lw $s2, 12($sp)     # restore copy of index from the stack
	       addi $sp, $sp, 16 # move pointer back
	       
    	       jr $ra
	
pacman:
        # $a0 has the address for the string
        # returns index of the '<' character & length of the final string
        
        addi $sp, $sp, -8 # save space on the stack
        sw $ra, 0($sp)   # save ra to the stack
        sw $s0, 4($sp)   # save string to the stack
        
        move $s0, $a0   # s0 starts from the beginning of the string
        
        jal strlen
        
        lw $ra, 0($sp)   # load (restore) from the stack
        # addi $sp, $sp, 4
        
        move $t4, $v0 # store the string length into $t4
           
        li $t5, 0 # this is supposed to be the position (index) of the pacman and FIRST RETURN VALUE
        li $t6, '_'
        li $t3, '<'
        
        loop_pacman:
           lbu $t0, 0($s0)   # read string[i]
           beqz $t0, done_pacman_end    # if we've reached null terminator, we need to put a < at the end
           
           is_ghost_letter:
               li $t2, 'g'
	       beq $t0, $t2, yes_ghost
	       li $t2, 'h'
	       beq $t0, $t2, yes_ghost
	       li $t2, 'o'
	       beq $t0, $t2, yes_ghost
	       li $t2, 's'
	       beq $t0, $t2, yes_ghost
	       li $t2, 't'
	       beq $t0, $t2, yes_ghost
	       li $t2, 'G'
	       beq $t0, $t2, yes_ghost
	       li $t2, 'H'
	       beq $t0, $t2, yes_ghost
	       li $t2, 'O'
	       beq $t0, $t2, yes_ghost
	       li $t2, 'S'
	       beq $t0, $t2, yes_ghost
	       li $t2, 'T'
	       beq $t0, $t2, yes_ghost
	       
	       # else just store _ into the address at string[i]
	       sb $t6, 0($s0) # store '_' char at string[i]
	       addi $s0, $s0, 1 # increment address of string
	       addi $t5, $t5, 1 # increment counter of index
	       
	   j loop_pacman  # if the character isn't any of the characters in "ghost", jump back to loop
       
       yes_ghost:
          # if t5 is 0 or t5 = strlen, INSERT < into those positions, do not replace
          beqz $t5, yes_ghost_index_0
          
          j done_pacman_inbetween
          
          yes_ghost_index_0:
              # insert has a0 - string, a1 - char, a2 - index as arguments
              
              sub $s0, $s0, $t5  # bring string pointer back to the beginning
              move $a0, $s0 # move string into a0
              li $a1, '<'    # move '<' character into arg 1 register
              li $a2, 0 # move 0 into arg 2 register
              
              beqz $t5, done_pacman_0
              
	done_pacman_0:
	   # INSERT < AT THE BEGINNING OF STRING, STRLEN = STRLEN + 1
	   
	   # stack already decremented by 8
           addi $sp, $sp, -8 # save space on the stack
           
           sw $ra, 0($sp)    # save ra to the stack
           # s0 is saved at 4($sp)
           sw $s1, 8($sp)    # save to the stack to reload for after the function
           sw $s2, 12($sp)   # save to the stack to reload for after the function
           
           addi $s1, $t4, 1      # save length of final string 
           move $s2, $t5      # save index where < is inserted to the stack
           
           jal insert
           
           move $v1, $s1  # length of updated string which is strlen + 1
	   move $v0, $s2  # index of the '<' character in final string
           
	   lw $ra, 0($sp) # restore ra from the stack
	   lw $s0, 4($sp) # restore string from stack
	   lw $s1, 8($sp) # restore length of final string
	   lw $s2, 12($sp) # restore index where < is inserted
	   addi $sp, $sp, 16 # move pointer back
	   
	   jr $ra
	
        done_pacman_end:
           # INSERT < AT THE END OF THE STRING, STRLEN = STRLEN + 1
           
           sub $s0, $s0, $t5  # bring string to point back to beginning
           move $a0, $s0
           li $a1, '<'  # move '<' character into arg 1 register
           move $a2, $t4 # move strlen into arg 2 register
           
           addi $s1, $t4, 1      # save length of final string 
           move $s2, $t5      # save index where < is inserted to the stack
           
           addi $sp, $sp, -8
           sw $ra, 0($sp)    # save ra to the stack
           # s0 is already saved to 4($sp)
           sw $s1, 8($sp)    # save to the stack to reload for after the function
           sw $s2, 12($sp)    # save to the stack to reload for after the function
           
           jal insert
           
           move $v1, $s1 # updated length of string
           move $v0, $s2 # index of '<' character in final string
           
           lw $ra, 0($sp) # restore from stack
           lw $s0, 4($sp)
           lw $s1, 8($sp) # restore length of final string
	   lw $s2, 12($sp) # restore index where < is inserted
           addi $sp, $sp, 16
           
           jr $ra
           
	done_pacman_inbetween:
	   addi $s0, $s0, -1  # else, go back to string[i]
	   sb $t3, 0($s0) # replace '<' with  string[i]
	   move $a0, $s0
	   
	   addi $t5, $t5, -1
	   
           move $v0, $t5 # index of the '<' character
           
           move $v1, $t4 # length of the final string
           
    	   jr $ra

replace_first_pair:
        # a0 has string
        # a1 - first char
        # a2 - second char
        # a3 - replacement
        # t0 - start index
        
        lbu $t0, 0($sp) # accessing the fifth arg - index from which to start searching
        li $t4, 0 # counter for the index of first char
        
        increment_counter:
            beq $t4, $t0, replace_first_loop # branch if counter = start index
            addi $t4, $t4, 1  # increment counter
            addi $a0, $a0, 1  # increment address of string
            
            j increment_counter
        
        replace_first_loop:
            lbu $t1, 0($a0)  # take the char at that index and load into $t1
            lbu $t2, 1($a0)  # take the char at index + 1 and load into $t2
            
            addi $a0, $a0, 1
            addi $t4, $t4, 1 # increment the counter for the index of first char
            
            beqz $t1, done_not_found # if first  char reaches null terminator, return -1
            beq $a1, $t1, verify_second_char
            
            j replace_first_loop
            
        verify_second_char:
            bne $a2, $t2, replace_first_loop  # if second char in string is not equal to 3rd arg
            
            addi $a0, $a0, -1
            addi $t4, $t4, -1 # increment the counter for the index of first char
            
            sb $a3, 0($a0) # otherwise, store the replacement char into the index where the first char is
            
            shift_left_loop:
               lbu $t6, 0($a0) # grab current char
               beqz $t6, done_replace_first_pair
               lbu $t5, 2($a0) # grab two chars down
               sb $t5, 1($a0) # insert into directly next position
               addi $a0, $a0, 1
               
               j shift_left_loop
               
            j done_replace_first_pair
            
        done_not_found:
            li $v0, -1
            jr $ra
                
	done_replace_first_pair:
            move $v0, $t4		
    	    jr $ra
	
replace_all_pairs:
        # a0 - str, a1 - first char, a2 - second char, a3 - replacement char
        
        addi $sp, $sp, -32    # save space on the stack
        sw $ra, 4($sp)    # save ra to the stack
        sw $s0, 8($sp)    # save original a0 to the stack
        sw $s1, 12 ($sp)   #save first char
        sw $s2, 16 ($sp)   # save second char
        sw $s3, 20 ($sp)   # save replacement char
        sw $s4, 24 ($sp)   # save number of pairs replaced
        sw $s5, 28 ($sp)
        
        move $s0, $a0    
        move $s1, $a1 
        move $s2, $a2 
        move $s3, $a3
        move $s5, $a0  # second copy of string
        
        li $t9, 0 # number of pairs replaced // RETURN VALUE 
        li $t0, 0 # initial index where to start search 
        
        loop_replace_all_pairs: 
        
            lbu $t1, 0($s0)  # take the char at that index and load into $t1
            lbu $t2, 1($s0)  # take the char at index + 1 and load into $t2
            addi $s0, $s0, 1
            
            beqz $t1, done_found_all_pairs # if first char reaches null terminator, we're done
            bne $s1, $t1, loop_replace_all_pairs
            
            verify_second_char_all_pairs: 
                
                bne $s2, $t2, loop_replace_all_pairs  # if second char in string is not equal to 3rd arg
                
                found_pair_all_pairs:
            
                    sw $t0, 0($sp)    # fifth argument (index) for replace_first_pair 
                    move $a0, $s5     # saved string points to the beginning
                    move $a1, $s1     # first char
                    move $a2, $s2     # second char
                    move $a3, $s3     # replacement char
                    
                    jal replace_first_pair
                    
                    addi $t9, $t9, 1 # increment number of pairs we've replaced
                    
                    addi $t0, $v0, 1 # increment search index for the next time we call replace_first_pair
                    
                    # addi $s0, $s0, 1
                    
	            j loop_replace_all_pairs	
        
        done_found_all_pairs:
            move $v0, $t9
        
            lw $ra, 4($sp) # restore ra from the stack
            lw $s0, 8($sp) # restore saved a0 from the stack
            lw $s1, 12($sp) # restore saved a1 from the stack
            lw $s2, 16($sp) # restore saved a2 from the stack
            lw $s3, 20 ($sp) # restore saved a3 from the stack
            lw $s4, 24 ($sp) # restore number of pairs replaced
            lw $s5, 28 ($sp)
            
            addi $sp, $sp, 32 # move pointer back
            
            jr $ra
            
bytepair_encode:
    
    # 52 * 4 = 208
    # 676 * 4 = 2704

    # a0 - string, a1 - base address of frequencies, a2 - base address of replacements
    # frequencies is 676 bytes
    # replacements is 52 bytes
    
    addi $sp, $sp, -36 # move pointer back       
    
    sw $ra, 0($sp) # save ra to the stack
    sw $s0, 4($sp) # save a0 to the stack
    sw $s1, 8($sp) # save base address of frequencies to the stack
    sw $s2, 12($sp) # save base address of replacements to the stack
    sw $s3, 16 ($sp) # last index in replacements, which keeps decreasing by 2 (STARTS AT 50)
    sw $s4, 20 ($sp) # save number of pairs replaced (STARTS AT 0)
    sw $s5, 24 ($sp) # save letter 'Z', which keeps getting decremented
    sw $s6, 28($sp)  # save index in freq array 
    sw $s7, 32($sp)  # serves as length of the string whose function is to bring to the beginning of string each time
    
    move $s0, $a0  # move string into saved register
    move $s1, $a1  # move base address freq into saved register
    move $s2, $a2  # move base address replacements into saved registers
    li $s3, 50
    li $s4, 0
    li $s5, 'Z'
    
    li $t1, 0
    
    # setting replacements all 0s
    loop_replacements_all_0s:
        li $t3, 51
        beq $t1, $t3, set_t1_register_back_0
        add $t0, $t1, $s2  # t1 = addr of array[i]
        lbu $t4, 0($t0)  # t4 = array[i]
        li $t4, 0   # t4 = 0
        sb $t4, 0($t0)  # array[i] = 0
        addi $t1, $t1, 1
        
        j loop_replacements_all_0s
    
    set_t1_register_back_0:
        li $t1, 0
        
    # setting frequency array to all 0
    loop_frequency_all_0s:
        li $t2, 675
        beq $t1, $t2, initialize_string_length_counter
        add $t0, $t1, $s1  # t0 = addr of array[i]
        lbu $t4, 0($t0)  # t4 = array[i]
        li $t4, 0   # t4 = 0
        sb $t4, 0($t0)  # array[i] = 0
        addi $t1, $t1, 1
        
        j loop_frequency_all_0s
    
    initialize_string_length_counter:
        li $t9, 0
    
    populate_frequency_array_loop:
        lbu $t1, 0($s0)  # take the char at that index and load into $t1
        lbu $t2, 1($s0)  # take the char at index + 1 and load into $t2
        
        beqz $t1, calculate_max_frequency_initializer  # done with reading the string, now can calculate max occuring frequency
        
        addi $t1, $t1, -97  # get first char in range [0-25]
        addi $t2, $t2, -97  # get second char in range [0-25]
        
        addi $s0, $s0, 1
        addi $t9, $t9, 1
        
        # only populate frequency array if the two chars are lowercase (in other words, ascii - 97 >= 0)
        bltz $t1, populate_frequency_array_loop  # that means it's uppercase
            
        check_second_char_lowercase_encode: 
            bltz $t2, populate_frequency_array_loop  # that means it's uppercase
        
        li $t0, 26
        mul $t3, $t1, $t0 # GETTING INDEX OF THE BYTECODE PAIR, which is 26 * firstchar + secondchar
        add $t4, $t3, $t2 # this is now the index i in freq[i] at which to increment frequency
        
        add $s1, $s1, $t4 # new address of freq[i]
        
        lbu $t1, 0($s1) # grab t1 = freq[i]
        addi $t1, $t1, 1  # freq[i] ++
        sb $t1, 0($s1) # store freq[i] back
        
        sub $s1, $s1, $t4 # bring frequency array index back to base address
        
        j populate_frequency_array_loop        
        
    calculate_max_frequency_initializer:
        li $t1, 0  # i, where to start
        li $t2, 676  # number of elements in array to traverse
        
        lbu $t3, 0($s1)	        # set max ($t3) to freq[0]
	addi $s1, $s1, 1	# pointer to start at freq[1]
	addi $t2, $t2, -1	# and go round count-1 times
	
	calculate_max_frequency:
	    lbu $t4,($s1)	# load next word from array
	    ble $t4,$t3, notMax
	    move $t3,$t4	# copy a[i] to max
	    
	    notMax: 
	    addi $t2,$t2,-1	# decrement counter
	    addi $s1,$s1,1	# increment pointer by 1 byte
	    bnez $t2, calculate_max_frequency	# and continue if counter>0
	    
    beqz $t3, done_encode
    
    modify_replacements:
    # if freq[i] = max, modify replacements array AND replace string with uppercase char [A-Z]
    # loop through freq array      
    # t7 holds the uppercase character, which starts at 'Z'
    # t3 contains the max in the array	     	     
    
    addi $s1, $s1, -676 # restore freq array back to the base address
    li $t1, 0 # starting i (index #) 
    move $s6, $t1  # save the index where we're at in frequencies across the function call
    move $s7, $t9  # save the length of the string
    sub $s0, $s0, $s7  # make string s0 start FROM THE BEGINNING EACH TIME
    
        # this loops through the frequency array and gets all the freq[i] that are equal to the max 
        modify_replacements_loop:
            li $t8, 26 # CONSTANT, DOES NOT CHANGE!! (this is number we divide by to get indices) 
            li $t2, 675 # number of elements in freq
            
            add $t0, $s6, $s1
            lbu $t4, 0($t0)  # t4 = freq[i]
            
            beq $s6, $t2, set_t1_register_back_0  # reached the end of frequency array, go to next round of frequency calculation
            
            beq $t4, $t3, modify_replacements_and_string   # if the number in freq array is equal to the max, modify replacements array and string
            
            addi $s6, $s6, 1  # increment the index of frequencies
            
            j modify_replacements_loop
             
            modify_replacements_and_string:
                
                div $s6, $t8  # index / 26 to get char 
                mfhi $t5 # remainder, char 2
                mflo $t6 # quotient, char 1
                addi $t5, $t5, 97 # revive the actual character
                addi $t6, $t6, 97 # revive the actual character
                
                # modfify the replacements array
                add $t4, $s2, $s3  # back of rep[i]
                sb $t6, 0($t4)  # rep[i] = char1
                sb $t5, 1($t4)  # rep[i+1] = char2
                addi $s3, $s3, -2
                beqz $s3, done_encode
                
                move $a0, $s0 # string that ALWAYS points at 0 (starting address)
                move $a1, $t6 # first char
                move $a2, $t5 # second char
                move $a3, $s5 # the uppercase letter to replace
                
                jal replace_all_pairs
                # a0 - str, a1 - first char, a2 - second char, a3 - replacement
                
                add $s4, $s4, $v0
                addi $s5, $s5, -1 # decrement upper case until it reaches 65 for A
                li $t1, 64  # the @ symbol, one ASCII character below 'A'
                addi $s6, $s6, 1  # increment the index of frequencies
                addi $s7, $s7, -1 # decrement the length of the string that we have to subtract each time
                
                beq $t1, $s5, done_encode
          
          # once done modifying replacements and string, make frequency array all 0s again and loop  
          j set_t1_register_back_0
          
    done_encode: 
    
        move $v0, $s4
        
        lw $ra, 0($sp) # restore ra from the stack
        lw $s0, 4($sp) # restore saved a0 from the stack
        lw $s1, 8($sp) # restore saved a1 from the stack
        lw $s2, 12($sp) # restore saved a2 from the stack
        lw $s3, 16($sp) # restore index in replacements
        lw $s4, 20($sp) # restore return value
        lw $s5, 24($sp) # restore number of pairs replaced
        lw $s6, 28($sp) # restore index in frequency
        lw $s7, 32($sp) # restore length of string
            
        addi $sp, $sp, 36 # move pointer back       
        jr $ra

replace_first_char:
        # a0 has string
        # a1 - character to replace
        # a2 - first char
        # a3 - second char
        # t0 - start index
        
        lbu $t0, 0($sp) # accessing the fifth arg - index from which to start searching
        li $t4, 0 # counter for the index of first char
        
        # stack already decremented by 4 bc of t0
        addi $sp, $sp, -20 # save space on the stack
        sw $ra, 4($sp)      # save ra to the stack
        sw $s0, 8($sp)      # save copy of str to the stack
        sw $s1, 12($sp)      # save copy of ch to the stack
        sw $s2, 16($sp)     # save copy of first char to the stack
        sw $s3, 20($sp)     # save copy of second char to the stack
        
        move $s0, $a0
        move $s1, $a1
        move $s2, $a2
        move $s3, $a3
        
        increment_counter_char:
            beq $t4, $t0, replace_char_loop # branch if counter = start index
            addi $t4, $t4, 1  # increment counter
            addi $s0, $s0, 1  # increment address of string
            
            j increment_counter_char
        
        replace_char_loop:
            lbu $t1, 0($s0)  # take the char at that index and load into $t1
            
            beqz $t1, done_not_found_char # if char reaches null terminator, return -1
            beq $s1, $t1, replace_and_insert_function_call
            
            addi $s0, $s0, 1 
            addi $t4, $t4, 1 # increment the counter for the index of char
            
            j replace_char_loop
            
            replace_and_insert_function_call:
               # a0 - str, a1 - ch, a2 - index
               
               sb $s2, 0($s0) # replace char at index with the arg char 1
               
               sub $s0, $s0, $t4  # make address of string start from the beginning before the function call
               addi $t4, $t4, 1
               
               move $a0, $s0  
               move $a1, $s3 # char that we want to insert into the index (SECOND CHAR)
               move $a2, $t4 # index where we want to insert second char
               
               jal insert
               
	       j done_replace_first_char
	       
        done_not_found_char:
        
            li $v0, -1
            
            lw $ra, 4($sp) # restore ra from the stack
            lw $s0, 8($sp) # restore saved a0 from the stack
            lw $s1, 12($sp) # restore saved a1 from the stack
            lw $s2, 16($sp) # restore saved a2 from the stack
            lw $s3, 20 ($sp) # restore saved a3 from the stack
            
            addi $sp, $sp, 20 # move pointer back
            
            jr $ra
            
	done_replace_first_char:
	    
	    addi $t4, $t4, -1
	    move $v0, $t4	
	    
	    lw $ra, 4($sp) # restore ra from the stack
            lw $s0, 8($sp) # restore saved a0 from the stack
            lw $s1, 12($sp) # restore saved a1 from the stack
            lw $s2, 16($sp) # restore saved a2 from the stack
            lw $s3, 20 ($sp) # restore saved a3 from the stack
            
            addi $sp, $sp, 20 # move pointer back
            
    	    jr $ra
    	    
replace_all_chars:

        # a0 - str, a1 - char, a2 - first, a3 - second
        addi $sp, $sp, -28 # save space on the stack
        sw $ra, 4($sp)    # save ra to the stack
        sw $s0, 8($sp)    # save original a0 to the stack
        sw $s1, 12 ($sp)   #save a1 to the stack
        sw $s2, 16 ($sp)   # save a2 to the stack
        sw $s3, 20 ($sp)   # save a3 on the stack
        sw $s5, 24 ($sp)   # save copy of the string to the stack
        
        move $s0, $a0     # save string to s0
        move $s1, $a1     # save char to s1
        move $s2, $a2     # save first char to s2
        move $s3, $a3     # save second char to s3
        move $s5, $a0     # second copy of string that always points to beginning
        
        li $t9, 0 # number of pairs replaced // RETURN VALUE 
        li $t0, 0 # initial index where to start search 
        
        loop_replace_all_chars: 
        
            lbu $t1, 0($s0)  # take the char at that index and load into $t1
            
            beqz $t1, done_found_all_chars # if first char reaches null terminator, we're done
            addi $s0, $s0, 1
            
            bne $s1, $t1, loop_replace_all_chars
            
                found_char_all_chars:
            
                    sw $t0, 0($sp) # fifth argument (index) for replace_first_char 
                    move $a0, $s5  # copy of string that always points to the beginning
                    move $a1, $s1  # char
                    move $a2, $s2  # first replacement char
                    move $a3, $s3  # second replacement char
                    
                    jal replace_first_char
                    
                    addi $t0, $v0, 1 # increment search index for the next time we call replace_first_pair
                    addi $t9, $t9, 1 # increment number of pairs we've replaced
                    
	            j loop_replace_all_chars	
        
        done_found_all_chars:
            move $v0, $t9
        
            lw $ra, 4($sp) # restore ra from the stack
            lw $s0, 8($sp) # restore saved a0 from the stack
            lw $s1, 12($sp) # restore saved a1 from the stack
            lw $s2, 16($sp) # restore saved a2 from the stack
            lw $s3, 20 ($sp) # restore saved a3 from the stack
            lw $s5, 24 ($sp) # restore number of pairs replaced
            
            addi $sp, $sp, 28 # move pointer back
            
            jr $ra
        

bytepair_decode:
    
    # a0 holds the address for string
    # a1 holds the base address for replacements
    
    addi $sp, $sp, -28 # save space on the stack
    sw $ra, 4($sp)    # save ra to the stack
    sw $s0, 8($sp)    # save original string to the stack
    sw $s1, 12 ($sp)   # replacements base address
    sw $s4, 16 ($sp)   # uppercase value
    sw $s5, 20 ($sp)   # index i
    sw $s6, 24 ($sp)   # return value at the end (total # of replacements)
    
    li $s5, 50    # index i
    li $s4, 'Z'   # uppercase value, which keeps decrementing every time
    li $s6, 0     # return value
    
    move $s1, $a1  
    move $s0, $a0
    
    loop_replacements_decode:
        li $t0, 'A'
        blt $s4, $t0, done_decode  # done if we reach A
        beqz $s5, done_decode
        
        add $t1, $s1, $s5  # back of rep[i]
        lbu $t4, 0($t1)  # t4 = array[i]  (first char)
        beqz $t4, done_decode  # reached null terminator in replacementss
        lbu $t5, 1($t1)  # t5 = array[i-1]   (second char)
        
        move $a0, $s0    # string
        move $a1, $s4    # replacement uppercase character 
        move $a2, $t4    # first char
        move $a3, $t5    # second char
        
        jal replace_all_chars
        
        add $s6, $s6, $v0  # increment result of final answers by number of replacements
        addi $s5, $s5, -2
        addi $s4, $s4, -1
        
        j loop_replacements_decode
        
    done_decode:
    
        move $v0, $s6
    
        lw $ra, 4($sp)    # save ra to the stack
        lw $s0, 8($sp)    # save original string to the stack
        lw $s1, 12($sp)   # replacements base address
        lw $s4, 16($sp)   # uppercase value
        lw $s5, 20($sp)   # index i
        lw $s6, 24($sp)   # return value at the end (total # of replacements)
        addi $sp, $sp, 28 # save space on the stack
        
        jr $ra
    
    
        
    
