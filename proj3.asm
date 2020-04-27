# Lolita Nefari Nazarov
# lnazarov
# 110722612

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

# Part I
load_game_file:
      # return number of non-zero game tiles

      # a0 originally contains a pointer to the GameBoard struct 
      # a1 originally contains a string containing the filename to open and read the contents of

      #addi $sp, $sp, -16 # save space on the stack
      #sw $s0, 0($sp)  # save pointer to GameBoard struct
      #sw $s1, 4($sp)  # save address of the file
      #sw $s3, 8($sp)  # number of non-zero tiles
      #sw $s5, 12($sp)  # copy of the GameBoard struct pointer to increment on so that we don't modify $s0
      
      move $s0, $a0  # move pointer to beginning of GameBoard struct / DOES!! NOT!! CHANGE!!
      move $s1, $a1  # move filename where the game board is to be saved
      li $s3, 0  # initialize number of non-zero tiles to 0
      move $s5, $s0  # pointer to beginning of GameBoard / ends up pointing to the end of GameBoard Array because it's incremented on 
      
      # open the file
      li $v0, 13
      move $a0, $s1 # address of the file to be read
      li $a1, 0  # a1 = flags = 0
      li $a2, 0  # a2 = mode = 0
      syscall
      bltz $v0, load_game_file_error
      add $s2, $v0, $0  # store fd in $s2 , use as an arg for $a2 in reading from file
      
      # read row number from file 
      # v0 14 reads bytes from file, storing in buffer
      
      li $t0, 0 # number of rows
      li $t1, 0 # number of columns
      li $t2, 10 #multiplier
      
      read_first_line:
            
            read_row_number_loop:
            
                  li $v0, 14   # read from file
      		  move $a0, $s2   # move file descriptor
      		  addi $sp, $sp, -4
      		  move $a1, $sp # use stack as the input buffer
     		  li $a2, 1	# read 1 byte / 1 char
      		  syscall
      
      		  lbu $t7, 0($sp)  # this contains the row count DIGIT
      		  addi $sp, $sp, 4
      		  li $t8, ' '
      		  beq $t7, $t8, store_row_into_board
      		  
      		  addi $t7, $t7, -48
      		  mul $t0, $t0, $t2 # multiply sum by 10 
                  add $t0, $t0, $t7 # increment the giant binary number by the character converted to binary
                  j read_row_number_loop
            
            store_row_into_board:
                  # s0 has the saved address for the board struct
                  sb $t0, 0($s5)     # store row into array[0] 
                  addi $s5, $s5, 1   # increment address of array
             
            read_col_number_loop:
                  li $v0, 14   # read from file
      		  move $a0, $s2   # move file descriptor
      		  addi $sp, $sp, -4
      		  move $a1, $sp # use stack as the input buffer
     		  li $a2, 1	# read 1 byte / 1 char
      		  syscall
      
      		  lbu $t7, 0($sp)  # this contains the row count
      		  addi $sp, $sp, 4
      		  li $t8, '\n'
      		  beq $t7, $t8, store_col_into_board
      		  
      		  addi $t7, $t7, -48
      		  mul $t1, $t1, $t2 # multiply sum by 10 
                  add $t1, $t1, $t7 # increment the giant binary number by the character converted to binary
                  j read_col_number_loop
                  
             store_col_into_board:
                  # s0 has the saved address for the board struct
                  sb $t1, 0($s5)     # store col into array[1] 
                  addi $s5, $s5, 1   # increment address of array
             
             initialize_number_first_value_of_array:
                  li $t0, 0  # this becomes each number stored into the array
                  j read_rest_of_lines_loop
                  
             initialize_number:
                  li $t0, 0
                  
             read_rest_of_lines_loop:
             # loop through text file and keep reading in 1 byte at a time and store as half-words (2 bytes) into the array 
                  li $v0, 14   # read from file
      		  move $a0, $s2   # move file descriptor
      		  addi $sp, $sp, -4
      		  move $a1, $sp # use stack as the input buffer
     		  li $a2, 1	# read 1 byte / 1 char
      		  syscall
      		  
      		  beq $v0, $0, load_game_file_correct
      
      		  lbu $t7, 0($sp)  # this contains the DIGIT of a number in array
      		  addi $sp, $sp, 4
      		  
      		  li $t8, ' '
      		  beq $t7, $t8, store_value_into_array
      		  li $t8, '\n'
      		  beq $t7, $t8, store_value_into_array
      		  
      		  addi $t7, $t7, -48
      		  mul $t0, $t0, $t2 # multiply sum by 10 
                  add $t0, $t0, $t7 # increment the giant binary number by the character converted to binary
                  
                  j read_rest_of_lines_loop
             
             store_value_into_array:
             
                  bnez $t0, increment_nonzero_and_store_into_array
             
                  sh $t0, 0($s5)     # store number into array[i] starting at i=2
                  addi $s5, $s5, 2   # increment address of array by 2 because it's half-words
                  
                  j initialize_number
             
             increment_nonzero_and_store_into_array:
                  addi $s3, $s3, 1
                  
                  sh $t0, 0($s5)     # store number into array[i] starting at i=2
                  addi $s5, $s5, 2   # increment address of array by 2 because it's half-words
                  
                  j initialize_number
                  
             # close the file     
             load_game_file_correct:
                  #lw $s0, 0($sp)  # restore pointer to GameBoard struct
                  #lw $s1, 4($sp)  # restore address of the file
                  #lw $s3, 8($sp)
                  #lw $s5, 12($sp)
                  
                  #addi $sp, $sp, 16 # put stack pointer back where it was
                  
                  li $v0, 16
                  move $a0, $s2
                  syscall
                  move $v0, $s3
                  
                  jr $ra
             
             # close the file
             load_game_file_error:
                  #lw $s0, 0($sp)  # restore pointer to GameBoard struct
                  #lw $s1, 4($sp)  # restore address of the file
                  #lw $s3, 8($sp)
                  #lw $s5, 12($sp)
                  
                  #addi $sp, $sp, 16 # put stack pointer back where it was
                  
                  li $v0, 16
                  move $a0, $s2
                  syscall
                  li $v0, -1
                  
                  jr $ra

# Part II
save_game_file:
      # WRITES TO A FILE FROM GAMEBOARD STRUCT
      # a0 contains the pointer to a valid GameBoard struct
      # a1 contains name of the file where the game board is to be saved
      
      move $s0, $a0  # move pointer to the GameBoard struct
      move $s1, $a1  # move filename where the game board is to be saved
      
      li $v0, 13
      move $a0, $s1
      li $a1, 1 # open for writing (0 - read, 1 - write)
      li $a2, 0 # mode is ignored
      syscall
      bltz $v0, save_game_file_error
      
      move $s6, $v0 # save the file descriptor
      
      lbu $t7, 0($s0) # number of rows
      lbu $t8, 1($s0) # number of column
      
      li $t2, 10 # what to divide and % by
      li $t6, 48
      
      # write to first line of the file
      write_first_line:
          
          write_row_count:
                lbu $t0, 0($s0)  # load first byte of the array (ENTIRE THING, NOT JUST 1 DIGIT)
                
                move $fp, $sp # set frame pointer to point at the very top of the stack
                
                # this stores all the digits (chars) on the stack
                write_digit_loop_row:
                    div $t0, $t2  # divide number in array by 10 to get quotient & remainder
                    mfhi $t3 # remainder
                    mflo $t4 # quotient
                    
                    add $t3, $t3, $t6 # convert to ascii
                    
                    addi $sp, $sp, -4
                    sb $t3, 0($sp)  # store digit (char) on the stack (LAST DIGIT ON TOP OF STACK)
                    
                    move $t0, $t4  # move quotient upon / 10 into t0
                    
                    beqz $t4, write_digits_to_file_row_loop
                    j write_digit_loop_row
                
                # this prints out digits one by one
                write_digits_to_file_row_loop:
                    # we have all the digits in the stack, with the last digit on top of stack
                    beq $sp, $fp, print_space_after_row
                    
                    li $v0, 15 # system call for write to file
                    move $a0, $s6 # file descriptor
                    move $a1, $sp # use stack as the output buffer
                    
                    li $a2, 1 # write 1 byte / 1 char
                    syscall
                    
                    addi $sp, $sp, 4
                    
                    j write_digits_to_file_row_loop
                    
                print_space_after_row:
                    addi $sp, $sp, -4
                    
                    li $v0, 15 # system call for write to file
                    move $a0, $s6 # file descriptor
                    li $t9, ' '
                    sb $t9, 0($sp)
                    move $a1, $sp # use stack as the output buffer
                    li $a2, 1 # write 1 byte / 1 char
                    syscall
                    
                    addi $sp, $sp, 4
                    
                lbu $t0, 1($s0)  # load first byte of the array (ENTIRE THING, NOT JUST 1 DIGIT)
                
                # this stores all the digits (chars) on the stack
                write_digit_loop_column:
                    div $t0, $t2  # divide number in array by 10 to get quotient & remainder
                    mfhi $t3 # remainder
                    mflo $t4 # quotient
                    
                    add $t3, $t3, $t6 # convert to ascii
                    
                    addi $sp, $sp, -4
                    sb $t3, 0($sp)  # store digit (char) on the stack (LAST DIGIT ON TOP OF STACK)
                    
                    move $t0, $t4  # move quotient upon / 10 into t0
                    
                    beqz $t4, write_digits_to_file_column_loop
                    j write_digit_loop_column
                
                # this prints out digits one by one
                write_digits_to_file_column_loop:
                    # we have all the digits in the stack, with the last digit on top of stack
                    beq $sp, $fp, print_newline_after_column
                    
                    li $v0, 15 # system call for write to file
                    move $a0, $s6 # file descriptor
                    move $a1, $sp # use stack as the output buffer
                    
                    li $a2, 1 # write 1 byte / 1 char
                    syscall
                    
                    addi $sp, $sp, 4
                    
                    j write_digits_to_file_column_loop
                    
                print_newline_after_column:
                    addi $sp, $sp, -4
                    
                    li $v0, 15 # system call for write to file
                    move $a0, $s6 # file descriptor
                    li $t9, '\n'
                    sb $t9, 0($sp)
                    move $a1, $sp # use stack as the output buffer
                    li $a2, 1 # write 1 byte / 1 char
                    syscall
                    
                    addi $sp, $sp, 4
                
                rest_of_array:
                    li $t9, 0 # counter for elements in array to traverse
                    mul $t7, $t7, $t8 # number of elements in array, ultimately branch to end when t7 = t9
                    # remember that t8 is num columns
                    
                    # frame pointer is equal to stack pointer at this point
                    
                    li $t2, 10 # what to divide and % by
                    li $t6, 48
                    
                    addi $s0, $s0, 2 # increment to point to first half word
                    
                    load_half_word_and_giant_conditional:
                        bge $t9, $t7, save_game_file_correct
                        lhu $t0, 0($s0)  # load halfword at current address
                        
                    # this stores all the digits (chars) on the stack
                    write_digit_loop:
                        div $t0, $t2  # divide number in array by 10 to get quotient & remainder
                        mfhi $t3 # remainder
                        mflo $t4 # quotient
                    
                        add $t3, $t3, $t6 # convert to ascii
                    
                        addi $sp, $sp, -4
                        sb $t3, 0($sp)  # store digit (char) on the stack (LAST DIGIT ON TOP OF STACK)
                    
                        move $t0, $t4  # move quotient upon / 10 into t0
                    
                        beqz $t4, write_digits_to_file_loop
                        j write_digit_loop
                
                    # this prints out digits of a number one by one
                    write_digits_to_file_loop:
                        # we have all the digits in the stack, with the last digit on top of stack
                        beq $sp, $fp, done_writing_number
                    
                        li $v0, 15 # system call for write to file
                        move $a0, $s6 # file descriptor
                        move $a1, $sp # use stack as the output buffer
                    
                        li $a2, 1 # write 1 byte / 1 char
                        syscall
                    
                        addi $sp, $sp, 4
                    
                        j write_digits_to_file_loop
                        
                    done_writing_number:  # print out space or newline after?
                        addi $t9, $t9, 1
                        div $t9, $t8 # divide counter by number of cols
                        mfhi $t4 # remainder
                        beqz $t4, print_newline
                        
                    print_space:
                          addi $sp, $sp, -4
                    
                          li $v0, 15 # system call for write to file
                          move $a0, $s6 # file descriptor
                          li $t5, ' '
                          sb $t5, 0($sp)
                          move $a1, $sp # use stack as the output buffer
                          li $a2, 1 # write 1 byte / 1 char
                          syscall
                          
                          addi $s0, $s0, 2 # add 2 bytes to address counter
                    
                          addi $sp, $sp, 4
                          
                          j load_half_word_and_giant_conditional
                    
                    print_newline:
                          addi $sp, $sp, -4
                    
                          li $v0, 15 # system call for write to file
                          move $a0, $s6 # file descriptor
                          li $t5, '\n'
                          sb $t5, 0($sp)
                          move $a1, $sp # use stack as the output buffer
                          li $a2, 1 # write 1 byte / 1 char
                          syscall
                          
                          addi $s0, $s0, 2 # add 2 bytes to address counter
                    
                          addi $sp, $sp, 4
                          
                          j load_half_word_and_giant_conditional
                
      save_game_file_correct:
            # close the file
            li $v0, 16 # system call to close file
            move $a0, $s6 # file descriptor to close
            syscall
            
            li $v0, 0
            jr $ra
               
      save_game_file_error:
            # close the file
            li $v0, 16 # system call to close file
            move $a0, $s6 # file descriptor to close
            syscall
            
            li $v0, -1
            jr $ra
      
# Part III
get_tile:
      # a0 contains the board pointer
      # a1 contains the row number
      # a2 contains the column number
      
      lbu $t1, 0($a0)  # actual numrows
      lbu $t2, 1($a0)  # actual numcolumns
      
      bltz $a1, get_tile_error_done
      bltz $a2, get_tile_error_done
      
      bge $a1, $t1, get_tile_error_done
      bge $a2, $t2, get_tile_error_done
      
      # actually accessing the tile value
      
      addi $a0, $a0, 2
      mul $t5, $a1, $t2  # i * num_columns
      add $t5, $t5, $a2  # i * num_columns + j
      sll $t5, $t5, 1  # 2 * (i * num_columns + j)   mult by 2 bc we have an array of 2 byte half-words
      add $a0, $a0, $t5  # base_addr + 2 * (i * num_columns + j)
      
      lhu $t6, 0($a0) # get the byte from the address of the array
      
      get_tile_correct_done:
            move $v0, $t6 
            jr $ra
      
      get_tile_error_done:
            li $v0, -1
            jr $ra
      
# Part IV
set_tile:
      # a0 has pointer to gameboard address
      # a1 has row number
      # a2 has column number where we want to write
      # a3 has value to write at board.tiles[row][col]
      
      lbu $t1, 0($a0)  # actual numrows
      lbu $t2, 1($a0)  # actual numcolumns
      
      bltz $a1, set_tile_error_done
      bltz $a2, set_tile_error_done
      
      bge $a1, $t1, set_tile_error_done
      bge $a2, $t2, set_tile_error_done
      
      # storing value at that tile
      
      addi $a0, $a0, 2
      mul $t5, $a1, $t2  # i * num_columns
      add $t5, $t5, $a2  # i * num_columns + j
      sll $t5, $t5, 1  # 2 * (i * num_columns + j)   mult by 2 bc we have an array of 2 byte half-words
      add $a0, $a0, $t5  # base_addr + 2 * (i * num_columns + j)
      sh $a3, 0($a0)
      
      set_tile_correct_done:
            move $v0, $a3
            jr $ra
      
      set_tile_error_done:
            li $v0, -1
            jr $ra
      
jr $ra

# Part V
can_be_merged:
      # a0 has address of the board
      # a1 has row1
      # a2 has col1
      # a3 has row2
      # arg 4 has col2
      
      lbu $t0, 0($sp)  # col2
      
      # save everything to the stack
      addi $sp, $sp, -36 # save space on the stack
      sw $ra, 4($sp)    # save ra to the stack
      sw $s0, 8($sp)    # save original a0 to the stack
      sw $s1, 12 ($sp)   #save a1 to the stack
      sw $s2, 16 ($sp)   # save a2 to the stack
      sw $s3, 20 ($sp)   # save a3 on the stack
      sw $s4, 24 ($sp)   # save copy of the string to the stack
      sw $s5, 28 ($sp)   # save tiles[row1][col1]
      sw $s6, 32 ($sp)   # save tiles[row2][col2]
      
      move $s0, $a0     # save board address to s0
      move $s1, $a1     # save row1 to s1
      move $s2, $a2     # save col1 to s2
      move $s3, $a3     # save row2 to s3
      move $s4, $t0    # save col2 to s4
      
      # check that the row1, row2, col1, col2 ranges are within valid ranges
      lbu $t1, 0($s0)  # actual numrows
      lbu $t2, 1($s0)  # actual numcolumns
      
      bltz $s1, can_be_merged_error
      bltz $s2, can_be_merged_error
      bltz $s3, can_be_merged_error
      bltz $s4, can_be_merged_error
      
      bge $s1, $t1, can_be_merged_error
      bge $s2, $t2, can_be_merged_error
      bge $s3, $t1, can_be_merged_error
      bge $s4, $t2, can_be_merged_error
      
      check_if_coords_equal:
      # if coordinates are equal - error
          bne $s1, $s3, get_abs_value_row_diff
          beq $s2, $s4, can_be_merged_error
      
      get_abs_value_row_diff:
      # get abs value of row1 - row2
      sub $t1, $s1, $s3
      bgez $t1, pos_row_value
      sub $t1, $0, $t1
      # t1 holds the row_diff value
      
      pos_row_value:
      # row difference better be a 0 or 1
      
      li $t2, 1
      beq $t1, $t2, row_diff_equals_1
      bnez $t1, can_be_merged_error
      
      # get abs value of col1 - col2
      get_abs_value_col_diff:
            
            row_diff_equals_0:
                # take absolute value (column difference), where s2 is col1 and s4 is col2
                # it needs to equal 1
                sub $t2, $s2, $s4
                beqz $t2, can_be_merged_error
                bltz $t2, make_col_pos
                li $t3, 1
                bne $t2, $t3, can_be_merged_error
                j check_compatible_values # otherwise, if col difference=1, continue
                
                make_col_pos:
                      sub $t2, $0, $t2
                      li $t3, 1
                      bne $t2, $t3, can_be_merged_error
                      j check_compatible_values # otherwise, if col difference=1, continue
                
            row_diff_equals_1:
                # take column difference
                # needs to equal 0
                sub $t2, $s2, $s4
                bnez $t2, can_be_merged_error
            
      check_compatible_values:
      # we can only merge if tiles[row1][col] = 1 or 2 and tiles[row2][col2] = 2 or 1 IN THAT ORDER
      # call get_tile(board, row1, col1) and get_tile(board, row2, col2)
      
            move $a0, $s0  # move board into first arg
            move $a1, $s1  # move row1 to arg2
            move $a2, $s2  # move col1 to arg3
            
            jal get_tile
            
            move $s5, $v0 # contains the value at tiles[row1][col1]
            
            move $a0, $s0  # move board into first arg
            move $a1, $s3  # move row2 to arg2
            move $a2, $s4  # move col2 to arg3
            
            jal get_tile
            
            move $s6, $v0 # contains the value at tiles[row2][col2]
            
            li $t1, 1
            li $t2, 2
            li $t3, 3
            
            beq $s5, $t1, first_coord_1_second_coord_2
            beq $s5, $t2, first_coord_2_second_coord_1
            
            blt $s5, $t3, can_be_merged_error
            blt $s6, $t3, can_be_merged_error
            
            beq $s5, $s6, can_be_merged_correct  # if the two numbers are >= 3 and equal, they can be merged
            j can_be_merged_error # else, they can't be merged
            
            first_coord_1_second_coord_2:
                  bne $s6, $t2, can_be_merged_error
                  j can_be_merged_correct
                  
            first_coord_2_second_coord_1:
                  bne $s6, $t1, can_be_merged_error
                  j can_be_merged_correct
            
      can_be_merged_correct:
            add $t0, $s5, $s6  # function returns sum of get_tile[row1][col1] + get_tile[row2][col2]
            move $v0, $t0
            
            lw $ra, 4($sp) # restore ra from the stack
            lw $s0, 8($sp) # restore saved a0 from the stack
            lw $s1, 12($sp) # restore saved a1 from the stack
            lw $s2, 16($sp) # restore saved a2 from the stack
            lw $s3, 20 ($sp) # restore saved a3 from the stack
            lw $s4, 24 ($sp) # restore number of pairs replaced
            lw $s5, 28 ($sp) # restore tiles[row1][col1]
            lw $s6, 32 ($sp) # restore tiles[row2][col2]
            
            addi $sp, $sp, 36 # move pointer back
            
            jr $ra          
      
      can_be_merged_error:
            li $v0, -1
            
            lw $ra, 4($sp) # restore ra from the stack
            lw $s0, 8($sp) # restore saved a0 from the stack
            lw $s1, 12($sp) # restore saved a1 from the stack
            lw $s2, 16($sp) # restore saved a2 from the stack
            lw $s3, 20 ($sp) # restore saved a3 from the stack
            lw $s4, 24 ($sp) # restore number of pairs replaced
            lw $s5, 28 ($sp) # restore tiles[row1][col1]
            lw $s6, 32 ($sp) # restore tiles[row2][col2]
            
            addi $sp, $sp, 36 # move pointer back
            
            jr $ra
      
# Part VI
slide_row:
      # a0 has the board address
      # a1 has the row (int)
      # a2 has the direction (-1 for left, 1 for right)
      
      # if a2 = -1, start traversing from the left
      # if a2 = 1, start traversing from the right
      
      addi $sp, $sp, -40 # save space on the stack
      sw $ra, 0($sp)    # save ra to the stack
      sw $s0, 4($sp)    # save original a0 to the stack
      sw $s1, 8 ($sp)   #save a1 to the stack
      sw $s2, 12 ($sp)   # save a2 to the stack
      sw $s3, 16 ($sp)
      sw $s4, 20 ($sp)
      sw $s5, 24 ($sp)
      sw $s6, 28 ($sp)
      sw $s7, 32 ($sp)
      sw $t9, 36 ($sp)
      
      move $s0, $a0 
      move $s1, $a1 
      move $s2, $a2 
      
      lbu $t0, 0($s0) # board row number count
      bltz $s1, slide_row_error
      bge $s1, $t0, slide_row_error
      
      li $t0, 1
      li $t1, -1
      
      beq $t0, $a2, slide_right
      bne $t1, $a2, slide_row_error
      
      slide_left:
            lbu $t0, 1($s0) # column number, acts as end of loop
            addi $t0, $t0, -1
            
            li $t1, 0  # column index 0
            li $t2, 1  # column index 1
            
            move $s3, $t1  #first column index
            move $s4, $t2  #second column index
            move $s5, $t0  #save column loop terminator (aka total column #)
            addi $s5, $s5, -1  #increment until col1 # = total col # - 2
            
            li $t9, -1 # this is the zero checker (return -1 if none merged)
            
            slide_left_loop:
                  # traverse from left to right
                  move $a0, $s0  # board address
                  move $a1, $s1  # row
                  move $a2, $s3  # column 1
            
                  jal get_tile
                  
                  move $s6, $v0  # value at [row][col1]
                  
                  move $a0, $s0  # board address
                  move $a1, $s1  # row
                  move $a2, $s4  # column 2
                  
                  jal get_tile
                  
                  move $s7, $v0 # value at [row][col2]
                  
                  # check if first value = 0
                  bnez $s6, continue_slide_left_loop
                  # if it does, shift everything to the right of it by 1 cell to the left
                  
                  shift_left_0_case:
                        
                        move $a0, $s0
                        move $a1, $s1  # row
                        move $a2, $s3  # col1 
                        move $a3, $s7  # value
                        
                        jal set_tile
                        
                        shift_left_0_case_loop:
                        # loop until col1's value becomes equal to column number - 2
                              addi $s3, $s3, 1  #increment col1
                              addi $s4, $s4, 1  #increment col2
                              
                              move $a0, $s0  # board address
                              move $a1, $s1  # row
                              move $a2, $s4  # column 2
                              
                              jal get_tile # get tile from index $s4
                              move $s7, $v0
                              
                              move $a0, $s0  # board address
                              move $a1, $s1  # row
                              move $a2, $s3  # column 1
                              move $a3, $s7  # value 
                              
                              jal set_tile # set tile at index $s3
                              
                              beq $s3, $s5, add_0_at_end_and_jump
                              
                              j shift_left_0_case_loop
                              
                  add_0_at_end_and_jump:
                       addi $s5, $s5, 1
                       
                       move $a0, $s0  # board address
                       move $a1, $s1  # row
                       move $a2, $s5  # last column
                       move $a3, $0  # value 0
                              
                       jal set_tile # set tile at last index to 0
                       
                       bltz $t9, slide_row_not_merged
                       
                       j slide_row_merged
                        
            continue_slide_left_loop: 
                  # call can_be_merged and see if it returns a number >= 3
                  move $a0, $s0
                  move $a1, $s1  #row1
                  move $a2, $s3  #col1
                  move $a3, $s1  #row2
                  move $t0, $s4  #col2
                  addi $sp, $sp, -4
                  sw $t0, 0($sp)
                  
                  jal can_be_merged
                  
                  move $t0, $v0  # supposed to represent the merged value, like 3+3 = 6 or -1 if it can't be merged
                  addi $sp, $sp, 4
                  
                  addi $t9, $t9, 1 # increment t9 to not be negative anymore
                  
                  # if v0 is greater than 3, replace first cell with v0 and shift everything left
                  # put 0 in last cell
                  addi $s3, $s3, 1  #increment col1
                  addi $s4, $s4, 1  #increment col2
                  
                  move $t9, $t0 # this temporary register t9 is saved on stack because I ran out of s registers LOL
                  
                  beq $s3, $s5, slide_row_not_merged
                  
                  # if result from can_be_merged is -1, keep looping
                  bltz $t0, slide_left_loop
                  
                  addi $s3, $s3, -1  #decrement col1
                  addi $s4, $s4, -1  #decrement col2
                  
                  #else, two tiles can be merged and row can be shifted
                  move $a0, $s0  # board address
                  move $a1, $s1  # row
                  move $a2, $s3  # column
                  move $a3, $t0  # value of can_be_merged (has to be a number >= 3)
                              
                  jal set_tile # set tile at first index to the sum
                  
                  # shift everything
                  j shift_left_0_case_loop
                  
      slide_right:
           # traverse from right to left
           
            li $t0, 0 # column number 0, acts as end of loop (while col#1 > 0)
            
            lbu $t1, 1($s0) # column number
            addi $t1, $t1, -2  #col1   (the one closest to the left)
            addi $t2, $t1, 1   #col2
            
            move $s3, $t1  #first column index
            move $s4, $t2  #second column index
            move $s5, $t0  #save column loop terminator (aka 0)
            
            li $t9, -1
            
            slide_right_loop:
                  # traverse from right to left
                  move $a0, $s0  # board address
                  move $a1, $s1  # row
                  move $a2, $s3  # column 1
            
                  jal get_tile
                  
                  move $s6, $v0  # value at [row][col1]
                  
                  move $a0, $s0  # board address
                  move $a1, $s1  # row
                  move $a2, $s4  # column 2
                  
                  jal get_tile
                  
                  move $s7, $v0 # value at [row][col2]
                  
                  # check if second value = 0
                  bnez $s7, continue_slide_right_loop
                  # if it does, shift everything to the right of it by 1 cell to the left
                  
                  shift_right_0_case:
                        
                        move $a0, $s0
                        move $a1, $s1  # row
                        move $a2, $s4  # col2 
                        move $a3, $s6  # value at [row][col1]
                        
                        jal set_tile
                        
                        shift_right_0_case_loop:
                        # loop until col1's value becomes equal to 0
                              addi $s3, $s3, -1  #increment col1
                              addi $s4, $s4, -1  #increment col2
                              
                              move $a0, $s0  # board address
                              move $a1, $s1  # row
                              move $a2, $s3  # column 1
                              
                              jal get_tile # get tile from index $s4
                              move $s6, $v0
                              
                              move $a0, $s0  # board address
                              move $a1, $s1  # row
                              move $a2, $s4  # column 2
                              move $a3, $s6  # value 
                              
                              jal set_tile # set tile at index $s3
                              
                              beq $s3, $s5, add_0_at_end_and_jump_R
                              
                              j shift_right_0_case_loop
                              
                  add_0_at_end_and_jump_R:
                  
                       move $a0, $s0  # board address
                       move $a1, $s1  # row
                       move $a2, $s5  # first column
                       move $a3, $0  # value 0
                              
                       jal set_tile # set tile at last index to 0
                       
                       bltz $t9, slide_row_not_merged
                       
                       j slide_row_merged
                        
            continue_slide_right_loop: 
                  # call can_be_merged and see if it returns a number >= 3
                  move $a0, $s0
                  move $a1, $s1  #row1
                  move $a2, $s3  #col1
                  move $a3, $s1  #row2
                  move $t0, $s4  #col2
                  addi $sp, $sp, -4
                  sw $t0, 0($sp)
                  
                  jal can_be_merged
                  
                  move $t0, $v0  # supposed to represent the merged value, like 3+3 = 6 or -1 if it can't be merged
                  addi $sp, $sp, 4
                  addi $t9, $t9, 1
                  
                  # this is to check whether any tiles have been merged at the end
                  move $t9, $t0 # this temporary register t9 is saved on stack because I ran out of s registers LOL
                  
                  # if v0 is greater than 3, replace first cell with v0 and shift everything right
                  # put 0 in last cell
                  addi $s3, $s3, -1  #decrement col1
                  addi $s4, $s4, -1  #decrement col2
                  
                  beq $s3, $s5, slide_row_not_merged
                  
                  # if result from can_be_merged is -1, keep looping
                  bltz $t0, slide_right_loop
                  
                  addi $s3, $s3, 1  #increment col1
                  addi $s4, $s4, 1  #increment col2
                  
                  #else, two tiles can be merged and row can be shifted
                  move $a0, $s0  # board address
                  move $a1, $s1  # row
                  move $a2, $s4  # column
                  move $a3, $t0  # value of can_be_merged (has to be a number >= 3)
                              
                  jal set_tile # set tile at first index to the sum
                  
                  # shift everything
                  j shift_right_0_case_loop
           
      slide_row_merged:
            li $v0, 1
            
            lw $ra, 0($sp) # restore ra from the stack
            lw $s0, 4($sp) # restore saved a0 from the stack
            lw $s1, 8($sp) # restore saved a1 from the stack
            lw $s2, 12($sp) # restore saved a2 from the stack
            lw $s3, 16($sp)
            lw $s4, 20($sp)
            lw $s5, 24($sp)
            lw $s6, 28($sp)
            lw $s7, 32($sp)
            lw $t9, 36 ($sp)
            
            addi $sp, $sp, 40 # move pointer back
            
            jr $ra
      
      slide_row_not_merged:
            li $v0, 0
            
            lw $ra, 0($sp) # restore ra from the stack
            lw $s0, 4($sp) # restore saved a0 from the stack
            lw $s1, 8($sp) # restore saved a1 from the stack
            lw $s2, 12($sp) # restore saved a2 from the stack
            lw $s3, 16($sp)
            lw $s4, 20($sp)
            lw $s5, 24($sp)
            lw $s6, 28($sp)
            lw $s7, 32($sp)
            lw $t9, 36 ($sp)
            
            addi $sp, $sp, 40 # move pointer back
            
            jr $ra
      
      slide_row_error:
            li $v0, -1
            
            lw $ra, 0($sp) # restore ra from the stack
            lw $s0, 4($sp) # restore saved a0 from the stack
            lw $s1, 8($sp) # restore saved a1 from the stack
            lw $s2, 12($sp) # restore saved a2 from the stack
            lw $s3, 16($sp)
            lw $s4, 20($sp)
            lw $s5, 24($sp)
            lw $s6, 28($sp)
            lw $s7, 32($sp)
            lw $t9, 36 ($sp)
            
            addi $sp, $sp 40 # move pointer back
            
            jr $ra
      
# Part VII
slide_col:
      # a0 has the board address
      # a1 has the col (int)
      # a2 has the direction (-1 for up, 1 for down)
      
      # if a2 = -1, start traversing from the top
      # if a2 = 1, start traversing from the bottom
      
      addi $sp, $sp, -40 # save space on the stack
      sw $ra, 0($sp)    # save ra to the stack
      sw $s0, 4($sp)    # save original a0 to the stack
      sw $s1, 8 ($sp)   #save a1 to the stack
      sw $s2, 12 ($sp)   # save a2 to the stack
      sw $s3, 16 ($sp)
      sw $s4, 20 ($sp)
      sw $s5, 24 ($sp)
      sw $s6, 28 ($sp)
      sw $s7, 32 ($sp)
      sw $t9, 36 ($sp)
      
      move $s0, $a0 #board 
      move $s1, $a1 #col to shift
      move $s2, $a2 # -1 for shift up, 1 for shift down
      
      lbu $t0, 1($s0) # board col number count
      bltz $s1, slide_row_error
      bge $s1, $t0, slide_row_error
      
      li $t0, 1
      li $t1, -1
      
      beq $t0, $a2, slide_down
      bne $t1, $a2, slide_col_error
      
      slide_up:
            # traverse from top to bottom
            lbu $t0, 0($s0) # row number, acts as end of loop
            addi $t0, $t0, -1
            
            li $t1, 0  # row index 0
            li $t2, 1  # row index 1
            
            move $s3, $t1  #first row index
            move $s4, $t2  #second row index
            move $s5, $t0  #save row loop terminator (aka total row # - 1)
            addi $s5, $s5, -1  #increment until row # = total row # - 2
            
            li $t9, -1
            
            slide_up_loop:
                  # traverse from top to bottom
                  move $a0, $s0  # board address
                  move $a1, $s3  # row1
                  move $a2, $s1  # col
            
                  jal get_tile
                  
                  move $s6, $v0  # value at [row1][col]
                  
                  move $a0, $s0  # board address
                  move $a1, $s4  # row2
                  move $a2, $s1  # col
                  
                  jal get_tile
                  
                  move $s7, $v0 # value at [row2][col]
                  
                  # check if first value = 0
                  bnez $s6, continue_slide_up_loop
                  # if it does, shift everything below it by 1 cell to the top and add 0 at end row
                  
                  shift_up_0_case:
                        
                        move $a0, $s0
                        move $a1, $s3  # row1
                        move $a2, $s1  # col 
                        move $a3, $s7  # value
                        
                        jal set_tile
                        
                        shift_up_0_case_loop:
                        # loop until row1's value becomes equal to row number - 2
                              addi $s3, $s3, 1  #increment row1
                              addi $s4, $s4, 1  #increment row2
                              
                              move $a0, $s0  # board address
                              move $a1, $s4  # row 2
                              move $a2, $s1  # column 
                              
                              jal get_tile # get tile from index $s4
                              move $s7, $v0
                              
                              move $a0, $s0  # board address
                              move $a1, $s3  # row 1
                              move $a2, $s1  # column
                              move $a3, $s7  # value 
                              
                              jal set_tile # set tile at index $s3
                              
                              beq $s3, $s5, add_0_at_end_and_jump_up
                              
                              j shift_up_0_case_loop
                              
                  add_0_at_end_and_jump_up:
                       addi $s5, $s5, 1
                       
                       move $a0, $s0  # board address
                       move $a1, $s5  # last row
                       move $a2, $s1  # column
                       move $a3, $0  # value 0
                              
                       jal set_tile # set tile at last index to 0
                       
                       bltz $t9, slide_col_not_merged
                       
                       j slide_col_merged
                        
            continue_slide_up_loop: 
                  # call can_be_merged and see if it returns a number >= 3
                  move $a0, $s0
                  move $a1, $s3  #row1
                  move $a2, $s1  #col1
                  move $a3, $s4  #row2
                  move $t0, $s1  #col2
                  addi $sp, $sp, -4
                  sw $t0, 0($sp)
                  
                  jal can_be_merged
                  
                  move $t0, $v0  # supposed to represent the merged value, like 3+3 = 6 or -1 if it can't be merged
                  addi $sp, $sp, 4
                  
                  addi $t9, $t9, 1
                  
                  move $t9, $t0
                  
                  # if v0 is greater than 3, replace first cell with v0 and shift everything up
                  # put 0 in last row cell
                  addi $s3, $s3, 1  #increment row1
                  addi $s4, $s4, 1  #increment row2
                  
                  beq $s3, $s5, slide_col_not_merged
                  
                  # if result from can_be_merged is -1, keep looping
                  bltz $t0, slide_up_loop
                  
                  addi $s3, $s3, -1  #decrement row1
                  addi $s4, $s4, -1  #decrement row2
                  
                  #else, two tiles can be merged and row can be shifted
                  # set first tile to the merged value
                  
                  move $a0, $s0  # board address
                  move $a1, $s3  # row1
                  move $a2, $s1  # column
                  move $a3, $t0  # value of can_be_merged (has to be a number >= 3)
                              
                  jal set_tile # set tile at first index to the sum
                  
                  # shift everything else
                  j shift_up_0_case_loop
                  
      slide_down:
      # traverse from bottom to top
      
            li $t0, 0 # row number, acts as end of loop
            
            lbu $t1, 0($s0) 
            addi $t1, $t1, -2 # row 1 (the one closest to the top)
            addi $t2, $t1, 1  # row 2 (starts at last row)
            
            move $s3, $t1  #first row index
            move $s4, $t2  #second row index
            move $s5, $t0  #save row loop terminator (aka 0)
            
            li $t9, -1
            
            slide_down_loop:
                  # traverse from bottom to top
                  move $a0, $s0  # board address
                  move $a1, $s3  # row1
                  move $a2, $s1  # col
            
                  jal get_tile
                  
                  move $s6, $v0  # value at [row1][col]
                  
                  move $a0, $s0  # board address
                  move $a1, $s4  # row2
                  move $a2, $s1  # col
                  
                  jal get_tile
                  
                  move $s7, $v0 # value at [row2][col]
                  
                  # check if second value = 0
                  bnez $s7, continue_slide_down_loop
                  # if it does, shift everything below it by 1 cell to the top and add 0 at end row
                  
                  shift_down_0_case:
                        
                        move $a0, $s0
                        move $a1, $s4  # row2
                        move $a2, $s1  # col 
                        move $a3, $s6  # value at [row - 2][col]
                        
                        jal set_tile
                        
                        shift_down_0_case_loop:
                        # loop until row1's value becomes equal to row number - 2
                              addi $s3, $s3, -1  #decrement row1
                              addi $s4, $s4, -1  #decrement row2
                              
                              move $a0, $s0  # board address
                              move $a1, $s3  # row 1
                              move $a2, $s1  # column 
                              
                              jal get_tile # get tile from index $s4
                              move $s6, $v0
                              
                              move $a0, $s0  # board address
                              move $a1, $s4  # row 2
                              move $a2, $s1  # column
                              move $a3, $s6  # value 
                              
                              jal set_tile # set tile at index $s3
                              
                              beq $s3, $s5, add_0_at_end_and_jump_down
                              
                              j shift_down_0_case_loop
                              
                  add_0_at_end_and_jump_down:
                       
                       move $a0, $s0  # board address
                       move $a1, $s5  # last row
                       move $a2, $s1  # column
                       move $a3, $0  # value 0
                              
                       jal set_tile # set tile at last index to 0
                       
                       bltz $t9, slide_col_not_merged
                       
                       j slide_col_merged
                        
            continue_slide_down_loop: 
                  # call can_be_merged and see if it returns a number >= 3
                  move $a0, $s0
                  move $a1, $s3  #row1
                  move $a2, $s1  #col1
                  move $a3, $s4  #row2
                  move $t0, $s1  #col2
                  addi $sp, $sp, -4
                  sw $t0, 0($sp)
                  
                  jal can_be_merged
                  
                  move $t0, $v0  # supposed to represent the merged value, like 3+3 = 6 or -1 if it can't be merged
                  addi $sp, $sp, 4
                  
                  addi $t9, $t9, 1
                  
                  move $t9, $t0
                  
                  # if v0 is greater than 3, replace first cell with v0 and shift everything up
                  # put 0 in last row cell
                  addi $s3, $s3, -1  #decrement row1
                  addi $s4, $s4, -1  #decrement row2
                  
                  beq $s3, $s5, slide_col_not_merged
                  
                  # if result from can_be_merged is -1, keep looping
                  bltz $t0, slide_down_loop
                  
                  addi $s3, $s3, 1  #increment row1
                  addi $s4, $s4, 1  #increment row2
                  
                  #else, two tiles can be merged and row can be shifted
                  # set second tile to the merged value
                  
                  move $a0, $s0  # board address
                  move $a1, $s4  # row2
                  move $a2, $s1  # column
                  move $a3, $t0  # value of can_be_merged (has to be a number >= 3)
                              
                  jal set_tile # set tile at first index to the sum
                  
                  # shift everything else
                  j shift_down_0_case_loop
           
      slide_col_merged:
            li $v0, 1
            
            lw $ra, 0($sp) # restore ra from the stack
            lw $s0, 4($sp) # restore saved a0 from the stack
            lw $s1, 8($sp) # restore saved a1 from the stack
            lw $s2, 12($sp) # restore saved a2 from the stack
            lw $s3, 16($sp)
            lw $s4, 20($sp)
            lw $s5, 24($sp)
            lw $s6, 28($sp)
            lw $s7, 32($sp)
            lw $t9, 36 ($sp)
            
            addi $sp, $sp, 40 # move pointer back
            
            jr $ra
      
      slide_col_not_merged:
            li $v0, 0
            
            lw $ra, 0($sp) # restore ra from the stack
            lw $s0, 4($sp) # restore saved a0 from the stack
            lw $s1, 8($sp) # restore saved a1 from the stack
            lw $s2, 12($sp) # restore saved a2 from the stack
            lw $s3, 16($sp)
            lw $s4, 20($sp)
            lw $s5, 24($sp)
            lw $s6, 28($sp)
            lw $s7, 32($sp)
            lw $t9, 36 ($sp)
            
            addi $sp, $sp, 40 # move pointer back
            
            jr $ra
      
      slide_col_error:
            li $v0, -1
            
            lw $ra, 0($sp) # restore ra from the stack
            lw $s0, 4($sp) # restore saved a0 from the stack
            lw $s1, 8($sp) # restore saved a1 from the stack
            lw $s2, 12($sp) # restore saved a2 from the stack
            lw $s3, 16($sp)
            lw $s4, 20($sp)
            lw $s5, 24($sp)
            lw $s6, 28($sp)
            lw $s7, 32($sp)
            lw $t9, 36 ($sp)
            
            addi $sp, $sp, 40 # move pointer back
            
            jr $ra
      
# Part VIII
slide_board_left:
      # a0 has the address of the board
      
      # call slide_row (board address, row #, -1) 
      addi $sp, $sp, -20
      
      sw $ra, 0($sp) # stack pointer
      sw $s0, 4($sp)
      sw $s1, 8($sp) # rows - 1
      sw $s2, 12($sp) # starting row index (0)
      sw $s3, 16($sp) # return value (sum of slide_row return values)
      
      move $s0, $a0
      li $s3, 0  # count how many rows were shifted, this acts as increment
      li $s2, 0 # starting row index
      
      lbu $t0, 0($s0) # number of rows
      addi $t0, $t0, -1 # loop until #rows - 1
      move $s1, $t0
      
      slide_board_left_loop:
            
            move $a0, $s0 # board address
            move $a1, $s2 # the row to shift left [ should iterate from 0 to row # - 1 ]
            li $a2, -1
            
            jal slide_row
            
            add $s3, $s3, $v0
            beq $s2, $s1, slide_board_left_done
            
            addi $s2, $s2, 1
            
            j slide_board_left_loop
            
      slide_board_left_done:
        
            move $v0, $s3
            
            lw $ra, 0($sp)
            lw $s0, 4($sp)
            lw $s1, 8($sp)
            lw $s2, 12($sp)
            lw $s3, 16($sp)
            
            
            addi $sp, $sp, 20
            
            jr $ra
      
# Part IX
slide_board_right:
# a0 has the address of the board
      addi $sp, $sp, -20
      
      # call slide_row (board address, row #, -1) 
      sw $ra, 0($sp) # stack pointer
      sw $s0, 4($sp)
      sw $s1, 8($sp) # rows - 1
      sw $s2, 12($sp) # starting row index (0)
      sw $s3, 16($sp) # return value (sum of slide_row return values)
      
      move $s0, $a0
      li $s3, 0  # count how many rows were shifted, this acts as increment
      li $s2, 0 # starting row index
      
      lbu $t0, 0($s0) # number of rows
      addi $t0, $t0, -1 # loop until #rows - 1
      move $s1, $t0
      
      slide_board_right_loop:
            
            move $a0, $s0 # board address
            move $a1, $s2 # row #
            li $a2, 1  # 1 to shift board RIGHT
            
            jal slide_row
            
            add $s3, $s3, $v0
            beq $s2, $s1, slide_board_right_done
            
            addi $s2, $s2, 1
            
            j slide_board_right_loop
            
      slide_board_right_done:
        
            move $v0, $s3
            
            lw $ra, 0($sp)
            lw $s0, 4($sp)
            lw $s1, 8($sp)
            lw $s2, 12($sp)
            lw $s3, 16($sp)
            
            addi $sp, $sp, 20
            
            jr $ra

# Part X
slide_board_up:
# call slide_column (board address, col #, -1) 
      addi $sp, $sp, -20
      
      sw $ra, 0($sp) # stack pointer
      sw $s0, 4($sp)
      sw $s1, 8($sp) # columns - 1
      sw $s2, 12($sp) # starting column index (0)
      sw $s3, 16($sp) # return value (sum of slide_column return values)
      
      move $s0, $a0
      li $s3, 0  # count how many columns were shifted, this acts as increment
      li $s2, 0 # starting column index
      
      lbu $t0, 1($s0) # number of columns
      addi $t0, $t0, -1 # loop until #columns - 1
      move $s1, $t0
      
      slide_board_up_loop:
            
            move $a0, $s0 # board address
            move $a1, $s2 # row #
            li $a2, -1  # -1 to shift board up
            
            jal slide_col
            
            add $s3, $s3, $v0
            beq $s2, $s1, slide_board_up_done
            
            addi $s2, $s2, 1
            
            j slide_board_up_loop
            
      slide_board_up_done:
        
            move $v0, $s3
            
            lw $ra, 0($sp)
            lw $s0, 4($sp)
            lw $s1, 8($sp)
            lw $s2, 12($sp)
            lw $s3, 16($sp)
            
            addi $sp, $sp, 20
            
            jr $ra

# Part XI
slide_board_down:
# call slide_column (board address, col #, -1) 
      addi $sp, $sp, -20
      
      sw $ra, 0($sp) # stack pointer
      sw $s0, 4($sp)
      sw $s1, 8($sp) # column - 1
      sw $s2, 12($sp) # starting column index (0)
      sw $s3, 16($sp) # return value (sum of slide_column return values)
      
      move $s0, $a0
      li $s3, 0  # count how many columns were shifted, this acts as increment
      li $s2, 0 # starting column index
      
      lbu $t0, 1($s0) # number of columns
      addi $t0, $t0, -1 # loop until #columns - 1
      move $s1, $t0
      
      slide_board_down_loop:
            
            move $a0, $s0 # board address
            move $a1, $s2 # column #
            li $a2, 1  # 1 to shift board down
            
            jal slide_col
            
            add $s3, $s3, $v0
            beq $s2, $s1, slide_board_down_done
            
            addi $s2, $s2, 1
            
            j slide_board_down_loop
            
      slide_board_down_done:
        
            move $v0, $s3
            
            lw $ra, 0($sp)
            lw $s0, 4($sp)
            lw $s1, 8($sp)
            lw $s2, 12($sp)
            lw $s3, 16($sp)
            
            addi $sp, $sp, 20
            
            jr $ra

# Part XII
game_status:

      addi $sp, $sp, -40
      sw $ra, 0($sp)
      sw $s0, 4($sp)
      sw $s1, 8($sp)
      sw $s2, 12($sp)
      sw $s3, 16($sp)
      sw $s4, 20($sp)
      sw $s5, 24($sp)
      sw $s6, 28($sp) # num rows that could be shifted left or right
      sw $s7, 32($sp) # num columns that could be shifted left or right
      sw $t9, 36($sp) # serves as row+1 or col+1 in can_be_merged
      
      li $s6, 0 # return value sum1
      li $s7, 0 # return value sum2
      
      move $s0, $a0
      
      # check if 49152 is in the board, return -2 -2
      
      # check if 0 is in the board, return -1 -1 if not a single 0 found
      
      # else return sum1, sum2, where sum1 = sum of number of rows that can be shifted
      # sum2 = sum of number of columns that can be shifted
      
      li $s5, 0 # counter for the number of 0s
      
      lbu $s1, 0($s0)  # row number
      lbu $s2, 1($s0)  # column number
      
      li $s3, 0  # row counter
      
      row_loop:
            li $s4, 0  # column counter
      
      col_loop:
            # keep calling get_tile
            # a0 contains the board pointer
            # a1 contains the row number
            # a2 contains the column number
            
            move $a0, $s0
            move $a1, $s3  # row
            move $a2, $s4  # counter
            
            jal get_tile
            
            move $t0, $v0
            li $t1, 49152
            
            bnez $t0, continue_with_col_loop
            addi $s5, $s5, 1
            
            continue_with_col_loop:
                  beq $t0, $t1, return_neg_2
            
                  addi $s4, $s4, 1  # j++
                  blt $s4, $s2, col_loop
            
      col_loop_done:
            addi $s3, $s3, 1  # i++
            blt $s3, $s1, row_loop
            
      # check if the number of 0's counted is 0 - if it is, board can't be shifted and we return -1, -1      
      beqz $s5, return_neg_1
      
      # traverse in row major order to check for the number of rows that can be shifted
      # row can be shifted if there's a 0 or if two tiles can be merged
      
      li $s3, 0  # row counter
      
      row_loop_count_rowsums:
            li $s4, 0  # column counter
      
      col_loop_count_rowsums:
            # keep calling get_tile
            # a0 contains the board pointer
            # a1 contains the row number
            # a2 contains the column number
            
            move $a0, $s0
            move $a1, $s3  # row
            move $a2, $s4  # counter
            
            jal get_tile
            
            move $t0, $v0
            
            beqz $t0, break_and_increment_row_count_rowsums
            
            move $a0, $s0
            move $a1, $s3  #row
            move $a2, $s4  #col
            move $a3, $s3  #row
            addi $t9, $s4, 1
            move $t0, $t9  #col + 1
            addi $sp, $sp, -4
            sw $t0, 0($sp)
                  
            jal can_be_merged
                  
            move $t0, $v0  # supposed to represent the merged value, like 3+3 = 6 or -1 if it can't be merged
            addi $sp, $sp, 4
            
            bgtz $v0, break_and_increment_row_count_rowsums  # v0 > 0 from can_be_merged means that two values can be merged, so break
            
            continue_with_col_loop_count_rowsums:
            
                  addi $s4, $s4, 1  # col++
                  blt $s4, $s2, col_loop_count_rowsums
                  
                  col_loop_done_count_rowsums:
                        addi $s3, $s3, 1  # row++
                        blt $s3, $s1, row_loop_count_rowsums
            
            break_and_increment_row_count_rowsums:
                  addi $s3, $s3, 1  # row++
                  addi $s6, $s6, 1 # increment the number of rows that can be shifted
                  blt $s3, $s1, row_loop_count_rowsums
      
      # traverse in col major order to check for the number of cols that can be shifted
      # col can be shifted if there's a 0 or if two tiles can be merged
      
      li $s3, 0  # row counter
      
      row_loop_count_colsums:
            li $s4, 0  # column counter
      
      col_loop_count_colsums:
            # keep calling get_tile
            # a0 contains the board pointer
            # a1 contains the row number
            # a2 contains the column number
            
            move $a0, $s0
            move $a1, $s3  # row
            move $a2, $s4  # counter
            
            jal get_tile
            
            move $t0, $v0
            
            beqz $t0, break_and_increment_col_count_colsums
            
            move $a0, $s0
            move $a1, $s3  #row
            move $a2, $s4  #col
            move $a3, $s3  #row
            addi $t9, $s4, 1
            move $t0, $t9  #col + 1
            addi $sp, $sp, -4
            sw $t0, 0($sp)
                  
            jal can_be_merged
                  
            move $t0, $v0  # supposed to represent the merged value, like 3+3 = 6 or -1 if it can't be merged
            addi $sp, $sp, 4
            
            bgtz $v0, break_and_increment_col_count_colsums  # v0 > 0 from can_be_merged means that two values can be merged, so break
            
            continue_with_col_loop_count_colsums:
            
                  addi $s3, $s3, 1  # row++
                  blt $s3, $s1, col_loop_count_colsums
                  
                  col_loop_done_count_colsums:
                        addi $s4, $s4, 1  # col++
                        blt $s4, $s2, col_loop_count_colsums
            
            break_and_increment_col_count_colsums:
                  addi $s4, $s4, 1  # col++
                  addi $s7, $s7, 1 # increment the number of cols that can be shifted
                  blt $s4, $s2, col_loop_count_colsums
            
      j return_sums
      
      return_neg_2:
            
            li $v0, -2
            li $v1, -2
            
            lw $ra, 0($sp)
            lw $s0, 4($sp)
            lw $s1, 8($sp)
            lw $s2, 12($sp)
            lw $s3, 16($sp)
            lw $s4, 20($sp)
            lw $s5, 24($sp)
            lw $s6, 28($sp) # num rows that could be shifted left or right
            lw $s7, 32($sp) # num columns that could be shifted left or rights
            lw $t9, 36($sp)
            
            addi $sp, $sp, 40
            
            jr $ra
      
      return_neg_1:
      
            li $v0, -1
            li $v1, -1
            
            lw $ra, 0($sp)
            lw $s0, 4($sp)
            lw $s1, 8($sp)
            lw $s2, 12($sp)
            lw $s3, 16($sp)
            lw $s4, 20($sp)
            lw $s5, 24($sp)
            lw $s6, 28($sp) # num rows that could be shifted left or right
            lw $s7, 32($sp) # num columns that could be shifted left or right
            lw $t9, 36($sp)
            
            addi $sp, $sp, 40
            
            jr $ra
      
      return_sums:
            
            move $v0, $s6
            move $v1, $s7
      
            lw $ra, 0($sp)
            lw $s0, 4($sp)
            lw $s1, 8($sp)
            lw $s2, 12($sp)
            lw $s3, 16($sp)
            lw $s4, 20($sp)
            lw $s5, 24($sp)
            lw $s6, 28($sp) # num rows that could be shifted left or right
            lw $s7, 32($sp) # num columns that could be shifted left or right
            lw $t9, 36($sp)
            
            addi $sp, $sp, 40
            
            jr $ra


#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
