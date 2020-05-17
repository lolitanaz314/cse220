# Lolita Nefari Nazarov
# 110722612
# lnazarov

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

# Part 1
init_list:
	# a0 is the pointer to the list
	li $t0, 0
	# set size and head fields to 0
	
	sw $t0, 0($a0)  
	sw $t0, 4($a0)  
	
jr $ra

# Part 2
append:
	# a0 has list
	# a1 has num to append to the list
	
	move $t0, $a0  # move list address to t0 
	
	# increment the size of the list
	lw $t9, 0($t0)
	addi $t9, $t9, 1
	sw $t9, 0($t0)
	
	# allocating 8 bytes of memory for the new intnode
	li $a0, 8
	li $v0, 9 # v0 will have the address of the newly allocated memory buffer
	syscall
	
	sw $a1, 0($v0) # store num into the first 4 bytes of new node
	li $t1, 0
	sw $t1, 4($v0) # make the new node point to null
	
	# now, get the last node to point to new node (address at v0)
	
	# traverse through the whole list until we reach node that has 0 "next" value
	traverse_loop_append:
		lw $t2, 4($t0) 
		beqz $t2, link_node_append # this means pointer doesn't point to anything, so we've reached the tail
		move $t0, $t2 # otherwise, move the pointer to t0
		j traverse_loop_append
		
	link_node_append: # append node to the end of the list
	
		#t0 now points to the base address of the tail node
		sw $v0, 4($t0) # store address of new node to the "next" section of the previous tail node
		move $v0, $t9 # updated size becomes the new return value
		jr $ra

# Part 3
insert:
	# a0 has the list
	# a1 has the num to insert
	# a2 has the index where to insert the num
	
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	
	move $s0, $a0 # move list address
	move $s1, $a1 # move num
	move $s2, $a2 # move index
	
	li $t1, -1
	lw $t2, 0($s0) # size of the list
	
	bltz $s2, insert_done
	bgt $s2, $t2, insert_done
	beq $s2, $t2, insert_at_end
	
	# otherwise, insert somewhere in the middle of the list and increment size of the list
	
	# if index = 0, just make the head point to the first element of the list
	beqz $s2, insert_at_0
	j insert_in_middle
	
	insert_at_0:
		# allocating 8 bytes of memory for the new head
		li $a0, 8
		li $v0, 9 # v0 will have the address of the newly allocated memory buffer
		syscall
		
		lw $t1, 4($s0) # address of current head in the array
		sw $v0, 4($s0) # store pointer of new head in last 4 bytes of array
		
		sw $s1, 0($v0) # store num into new head
		sw $t1, 4($v0) # store pointer to previous head into current head
		
		lw $t9, 0($s0)
		addi $t9, $t9, 1
		sw $t9, 0($s0)
		
		lw $t1, 0($s0)
		
		j insert_done
		
	insert_in_middle:
	
	move $t0, $s0 # copy address of the list again
	li $t9, 0
	move $t8, $s2
	addi $t8, $t8, -1
	
	traverse_loop_insert:
		lw $t2, 4($t0) # address of head (INITIALLY IN LOOP)
		move $t0, $t2 # move to address of next node
		beq $t9, $t8, relink_nodes_insert # this means pointer doesn't point to anything, so we've reached the tail
		
		addi $t9, $t9, 1
		
		j traverse_loop_insert
		
	relink_nodes_insert: # relink the addresses so that previous node points to new node, and new node points to next node
		
		#t0 now points to prev
		
		lw $t4, 4($t0) # address of node at current index (prev.next)
		
		# allocating 8 bytes of memory for the new intnode
		li $a0, 8
		li $v0, 9 # v0 will have the address of the newly allocated memory buffer
		syscall
		
		sw $v0, 4($t0) # prev.next has to point to the new node
		
		sw $s1, 0($v0) # num
		sw $t4, 4($v0) # pointer to "after" node
		
		# increment the size of the list
		lw $t9, 0($s0)
		addi $t9, $t9, 1
		sw $t9, 0($s0)
		
		lw $t1, 0($s0)
		
		j insert_done
		
	insert_at_end:
		#a0 and a1 are already list and num
		jal append
		move $t1, $v0 # return value is updated size
		j insert_done
		
	insert_done:
		move $v0, $t1
		
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		addi $sp, $sp, 16
		
		jr $ra

# Part 4
get_value:
	# a0 has list, a1 has index where to insert
	li $v0, -1
	li $v1, -1
	
	lw $t2, 0($a0) # size of list
	beqz $t2, get_value_done
	bgt $a1, $t2, get_value_done
	bltz $a1, get_value_done
	
	move $t0, $a0 # address of base of list
	li $t9, 0
	
	# otherwise, traverse loop and get value at index
	traverse_loop_get_value:
		lw $t2, 4($t0) # address of head (INITIALLY IN LOOP)
		move $t0, $t2 # move to address of next node
		beq $t9, $a1, continue_get_value # this means pointer doesn't point to anything, so we've reached the tail
		
		addi $t9, $t9, 1
		
		j traverse_loop_get_value
	
	continue_get_value:
	lw $t2, 0($t0)
	
	li $v0, 0
	move $v1, $t2
	
	get_value_done:
	
	jr $ra

# Part 5
set_value:
	#a0 - list, a1 - index, a2 - num
	li $v0, -1
	li $v1, -1
	
	lw $t2, 0($a0) # size of list
	blez $t2, get_value_done
	bgt $a1, $t2, get_value_done
	bltz $a1, get_value_done
	
	move $t0, $a0 # address of base of list
	li $t9, 0
	
	# otherwise, traverse loop and get value at index
	traverse_loop_set_value:
		lw $t2, 4($t0) # address of head (INITIALLY IN LOOP)
		move $t0, $t2 # move to address of next node
		beq $t9, $a1, continue_set_value # this means pointer doesn't point to anything, so we've reached the tail
		
		addi $t9, $t9, 1
		
		j traverse_loop_set_value
	
	continue_set_value:
		lw $t2, 0($t0) # retrieve old value
		sw $a2, 0($t0) # put in new value
	
		li $v0, 0
		move $v1, $t2
	
	set_value_done:
	
		jr $ra
	
# Part 6
index_of:
	# a0 has the list, a1 has the num
	lw $t2, 0($a0) # size of list
	blez $t2, index_of_fail
	
	move $t0, $a0 # address of base of list
	li $t9, 0
	
	# otherwise, traverse loop and get value at index
	traverse_loop_index_of:
		lw $t2, 4($t0) # address of head (INITIALLY IN LOOP)
		move $t0, $t2 # move to address of next node
		beqz $t0, index_of_fail
		
		lw $t3, 0($t0) # num at index in the list
		beq $t3, $a1, index_of_success # 
		
		addi $t9, $t9, 1
		
		j traverse_loop_index_of
	
	index_of_success:
		move $v0, $t9
		jr $ra
	
	index_of_fail:
		li $v0, -1
		jr $ra

# Part 7
remove:
	li $v0, -1
	li $v1, -1
	
	# a0 is the list, a1 is the num to remove
	lw $t2, 0($a0) # size of list
	blez $t2, remove_done
	
	move $t0, $a0 # address of base of list
	li $t9, 0
	
	# otherwise, traverse loop and get value at index
	traverse_loop_remove:
		lw $t2, 4($t0) # address of head (INITIALLY IN LOOP)
		move $t0, $t2 # move to address of next node
		beqz $t0, remove_done # we did not find the number
		
		lw $t3, 0($t0) # num at index in the list
		beq $t3, $a1, remove_options # if we've located the number
		
		addi $t9, $t9, 1
		
		j traverse_loop_remove
		
	remove_options:
		li $v0, 0
		move $v1, $t9 # index where we found the number
		
		beqz $t9, remove_at_head
		lw $t2, 0($a0) # size of list
		addi $t2, $t2, -1
		beq $t9, $t2, remove_at_tail
	
	remove_in_middle:
		move $t0, $a0  # beginning of list
		li $t1, 0
		
		remove_in_middle_loop:
			lw $t2, 4($t0) # address of head (INITIALLY IN LOOP)
			beq $t1, $t9, continue_remove_middle # this means pointer doesn't point to anything, so we've reached the tail
		
			move $t0, $t2 # move to address of next node
			addi $t1, $t1, 1
		
			j remove_in_middle_loop
	
		continue_remove_middle:
			# t0 now points to prev node
			
			lw $t2, 4($t0) # get current node i address
			lw $t3, 4($t2) # get "next" address
			
			sw $t3, 4($t0) # make prev.next -> after
			li $t9, 0
			sw $t9, 4($t2) # current deleted node not point to anything
			
			# decrement the size
			lw $t1, 0($a0) # size of the list
			addi $t1, $t1, -1 # decrement the size
			sw $t1, 0($a0) # put it back in
			
			j remove_done
		
	remove_at_head:
		# make new head point to head.next
		# make original head point to nothing
		
		move $t0, $a0  # beginning of list
		
		lw $t1, 0($t0) # size of the list
		addi $t1, $t1, -1 # decrement the size
		sw $t1, 0($t0) # put it back in
		
		lw $t1, 4($t0) # base address of head current
		lw $t2, 4($t1) # base address of head.next
		
		sw $t2, 4($t0) # make new head point to head.next
		li $t9, 0
		sw $t9, 4($t1) # zero out the "next" portion of current head . THIS IS THE THE WAY OF DELETING CORRECTLY
		
		j remove_done
		
	remove_at_tail:
		
		move $t0, $a0  # beginning of list
		
		lw $t1, 0($t0) # size of the list
		addi $t1, $t1, -1 # decrement the size
		sw $t1, 0($t0) # put it back in
		
		li $t1, 0
		
		remove_at_tail_loop:
			lw $t2, 4($t0) # address of head (INITIALLY IN LOOP)
			beq $t1, $t9, continue_remove_tail # this means pointer doesn't point to anything, so we've reached the tail
		
			move $t0, $t2 # move to address of next node
			addi $t1, $t1, 1
		
			j remove_at_tail_loop
	
		continue_remove_tail:
			# t0 now points to prev node
			
			li $t1, 0
			sw $t1, 4($t0) # nullify
			
			j remove_done
			
	remove_done:
		jr $ra


# helper function, although it might not be so "helper" because it wastes like 100 lines of code  D;
append_4_cards_of_rank:
	# accepts 2 arguments: pointer to beginning of list and number 2-9
	addi $sp, $sp, -12
        sw $ra, 0($sp)
        sw $s0, 4($sp) # pointer to BEGINNING. OF. THE LIST. NOT THE MIDDLE
        sw $s1, 8($sp) # rank (2-9)
        	
        move $s0, $a0
        move $s1, $a1
        
        # append D_C
        
        li $t8, 10
        div $s1, $t8
        mflo $t3
        mfhi $t4
        
        li $t0, 0x00000000 # hex number we will be appending
        
        li $t1, 4 # letter C in hex (clubs)	
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        li $t1, 3 # letter C in hex (clubs)	
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        move $t1, $t3 # letter '2' - '9' in hex
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        move $t1, $t4 # letter '2' - '9' in hex 
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        li $t1, 4 # letter D in hex (down)
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        li $t1, 4 # letter D in hex (down)
        add $t0, $t0, $t1
        
        move $a0, $s0 # pointer
	move $a1, $t0 # dec encoding of card representation
	jal append
	
	# append D_D
	
        li $t8, 10
        div $s1, $t8
        mflo $t3
        mfhi $t4
        
        li $t0, 0x00000000 # hex number we will be appending
        
        li $t1, 4 # letter D in hex (diamonds)	
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        li $t1, 4 # letter D in hex (diamonds)	
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        move $t1, $t3 # letter '2' - '9' in hex
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        move $t1, $t4 # letter '2' - '9' in hex 
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        li $t1, 4 # letter D in hex (down)
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        li $t1, 4 # letter D in hex (down)
        add $t0, $t0, $t1
        
        move $a0, $s0 # pointer
	move $a1, $t0 # dec encoding of card representation
	jal append
	
	
        li $t8, 10
        div $s1, $t8
        mflo $t3
        mfhi $t4
        
        li $t0, 0x00000000 # hex number we will be appending
        
        li $t1, 4 # letter H in hex (hearts)	
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        li $t1, 8 # letter H in hex (hearts)	
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        move $t1, $t3 # letter '2' - '9' in hex
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        move $t1, $t4 # letter '2' - '9' in hex 
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        li $t1, 4 # letter D in hex (down)
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        li $t1, 4 # letter D in hex (down)
        add $t0, $t0, $t1
        
        move $a0, $s0 # pointer
	move $a1, $t0 # dec encoding of card representation
	jal append
	
	
	
	li $t8, 10
        div $s1, $t8
        mflo $t3
        mfhi $t4
        
        li $t0, 0x00000000 # hex number we will be appending
        
        li $t1, 5 # letter S in hex (spades)	
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        li $t1, 3 # letter S in hex (spades)	
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        move $t1, $t3 # letter '2' - '9' in hex
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        move $t1, $t4 # letter '2' - '9' in hex 
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        li $t1, 4 # letter D in hex (down)
        add $t0, $t0, $t1
        sll $t0, $t0, 4
        
        li $t1, 4 # letter D in hex (down)
        add $t0, $t0, $t1
        
        move $a0, $s0 # pointer
	move $a1, $t0 # dec encoding of card representation
	jal append
	
        lw $ra, 0($sp)
        lw $s0, 4($sp) # pointer to BEGINNING. OF. THE LIST. NOT THE MIDDLE
        lw $s1, 8($sp) # rank ('2'-'9')
        addi $sp, $sp, 12
        	
        jr $ra
        	
        	
# Part 8
create_deck:
	# a0 is the list
	# a1 is the num  for append
	addi $sp, $sp, -12
        sw $ra, 0($sp)
        sw $s0, 4($sp) # this is the pointer to the beginning of the list
        sw $s1, 8($sp) # 2-9
        
	# allocate memory
	li $a0, 8
	li $v0, 9 # v0 will have the address of the newly allocated memory buffer
	syscall
	
	move $a0, $v0
	jal init_list
	
	move $s0, $a0 # points to BEGINNING OF LIST
	li $s1, '2'
	addi $s1, $s1, -18 # starts at 32
	
	loop_2_through_9:
		
		move $a0, $s0
		move $a1, $s1
		jal append_4_cards_of_rank
		li $t9, '9' 
		addi $t9, $t9, -18
		beq $t9, $s1, continue_create_deck
		addi $s1, $s1, 1
		
		j loop_2_through_9
		
	continue_create_deck:
	
	# just brute force the rest of the way
	# append tens
	
	move $a0, $s0 # pointer
	li $a1, 4412484 # dec encoding of DTC
	jal append
	
	move $a0, $s0 # pointer
	li $a1, 4478020 # dec encoding of DTD
	jal append
	
	move $a0, $s0 # pointer
	li $a1, 4740164 # dec encoding of DTH
	jal append
	
	move $a0, $s0 # pointer
	li $a1, 5461060 # dec encoding of DTS
	jal append
	
	# append Jacks
	
	move $a0, $s0 # pointer
	li $a1, 4409924 # dec encoding of DJC
	jal append
	
	move $a0, $s0 # pointer
	li $a1, 4475460 # dec encoding of DJD
	jal append
	
	move $a0, $s0 # pointer
	li $a1, 4737604 # dec encoding of DJH
	jal append
	
	move $a0, $s0 # pointer
	li $a1, 5458500 # dec encoding of DJS
	jal append
	
	# append Queens
	
	move $a0, $s0 # pointer
	li $a1, 4411716 # dec encoding of DQC
	jal append
	
	move $a0, $s0 # pointer
	li $a1, 4477252 # dec encoding of DQD
	jal append
	
	move $a0, $s0 # pointer
	li $a1, 4739396 # dec encoding of DQH
	jal append
	
	move $a0, $s0 # pointer
	li $a1, 5460292 # dec encoding of DQS
	jal append
	
	# append Kings
	
	move $a0, $s0 # pointer
	li $a1, 4410180  # dec encoding of DKC
	jal append
	
	move $a0, $s0 # pointer
	li $a1, 4475716  # dec encoding of DKD
	jal append
	
	move $a0, $s0 # pointer
	li $a1, 4737860 # dec encoding of DKH
	jal append
	
	move $a0, $s0 # pointer
	li $a1, 5458756 # dec encoding of DKS
	jal append
	
	# append Aces
	
	move $a0, $s0 # pointer
	li $a1, 4407620 # dec encoding of DAC
	jal append
	
	move $a0, $s0 # pointer
	li $a1, 4473156 # dec encoding of DAD
	jal append
	
	move $a0, $s0 # pointer
	li $a1, 4735300 # dec encoding of DAH
	jal append
	
	move $a0, $s0 # pointer
	li $a1, 5456196 # dec encoding of DAS
	jal append
	
	move $v0, $s0 # we need to return a pointer to the beginning of the list

        lw $ra, 0($sp)
        lw $s0, 4($sp) # this is the pointer to the beginning of the list
        lw $s1, 8($sp) # 
	addi $sp, $sp, 12
	
	jr $ra

# Part 9
draw_card:
	# a0 has pointer to the card deck
	lw $t0, 0($a0) # size of list
	li $v0, -1
	li $v1, -1
	beqz $t0, done_draw_card
		
	lw $t1, 0($a0) # size of the list
	addi $t1, $t1, -1 # decrement the size
	sw $t1, 0($a0) # put it back in
		
	lw $t1, 4($a0) # base address of head current
	lw $t2, 4($t1) # base address of head.next
		
	sw $t2, 4($a0) # make new head point to head.next
	li $t9, 0
	sw $t9, 4($t1) # zero out the "next" portion of current head . THIS IS THE THE WAY OF DELETING CORRECTLY
		
	li $v0, 0
	lw $v1, 0($t1) # top card that was removed
	
	done_draw_card:
		jr $ra

# Part 10
deal_cards:
	addi $sp, $sp, -32
        sw $ra, 0($sp)
        sw $s0, 4($sp) # this is the pointer to the beginning of the list
        sw $s1, 8($sp) # 2-9
        sw $s2, 12($sp)
        sw $s3, 16($sp)
        sw $s4, 20($sp) # players offset [ keeps incrementing until it hits s5 or s6, whichever comes first ]
        sw $s5, 24($sp) # num_players x cards per player
        sw $s6, 28($sp) # size of list
        
        move $s0, $a0 # pointer to the card deck
        move $s1, $a1 # players array (double pointer) 
        move $s2, $a2 # num_players
        move $s3, $a3 # cards per player
        
        li $s4, 0 
        mul $s5, $s2, $s3 # [num_players] x [cards per player]
        lw $s6, 0($s0) # list size
        
        li $v0, -1
        
        blez $s2, deal_cards_done
        li $t0, 1
        blt $s3, $t0, deal_cards_done
        
        deal_cards_loop:
        	move $a0, $s0
        	jal draw_card
        	# v1 has the value of the card drawn
        	
        	addi $v1, $v1, 17 # make it face up
        	
        	div $s4, $s2
        	mfhi $t0
        	li $t1, 4
        	mul $t2, $t0, $t1 # offset in register t2
        	add $t3, $s1, $t2 # pointer to players[i]
        	
        	lw $t8, 0($t3) # address of players [i] 
        	
        	move $a0, $t8
        	move $a1, $v1 
        	jal append
        	
        	addi $s4, $s4, 1
        	
        	beq $s4, $s5, deal_cards_success
        	beq $s4, $s6, deal_cards_success
        	
        	j deal_cards_loop
        	
        deal_cards_success:
        move $v0, $s4  # number of cards that were dealt
        
	deal_cards_done:
	
        lw $ra, 0($sp)
        lw $s0, 4($sp) # 
        lw $s1, 8($sp) # 
        lw $s2, 12($sp)
        lw $s3, 16($sp)
        lw $s4, 20($sp)
        lw $s5, 24($sp)
        lw $s6, 28($sp)
        
        addi $sp, $sp, 32
	
	jr $ra
	
is_valid_card:
	# a0 is the card (U or D) in decimal form
	# SELF-CONTAINING FUNCTION
	# returns 0 if valid, -1 if invalid
	
	# just brute force the whole thing because it's a helper function and assembly is super fast
	
	# check for twos
	li $t0, 4403780 # dec encoding of D2C
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4469316 # dec encoding of D2D
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4731460 # dec encoding of D2H
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 5452356 # dec encoding of D2S
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	# check for threes
	
	li $t0, 4404036 # dec encoding of D3C
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4469572 # dec encoding of D3D
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4731716 # dec encoding of D3H
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 5452612 # dec encoding of D3S
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	# check for fours
	
	li $t0, 4404292 # dec encoding of D4C
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4469828 # dec encoding of D4D
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4731972 # dec encoding of D4H
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 5452868 # dec encoding of D4S
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	# check for fives
	
	li $t0, 4404548 # dec encoding of D5C
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4470084 # dec encoding of D5D
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4732228 # dec encoding of D5H
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 5453124 # dec encoding of D5S
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	# check for sixes
	
	li $t0, 4404804 # dec encoding of D6C
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4470340 # dec encoding of D6D
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4732484 # dec encoding of D6H
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 5453380 # dec encoding of D6S
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	# check for sevens
	
	li $t0, 4405060 # dec encoding of D7C
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4470596 # dec encoding of D7D
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4732740 # dec encoding of D7H
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 5453636 # dec encoding of D7S
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	# eights
	
	li $t0, 4405316 # dec encoding of D8C
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4470852 # dec encoding of D8D
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4732996 # dec encoding of D8H
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 5453892 # dec encoding of D8S
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	# nines
	
	li $t0, 4405572 # dec encoding of D9C
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4471108 # dec encoding of D9D
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4733252 # dec encoding of D9H
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 5454148 # dec encoding of D9S
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	# check for tens
	
	li $t0, 4412484 # dec encoding of DTC
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4478020 # dec encoding of DTD
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4740164 # dec encoding of DTH
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 5461060 # dec encoding of DTS
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	#  check for jacks
	
	li $t0, 4409924 # dec encoding of DJC
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4475460 # dec encoding of DJD
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4737604 # dec encoding of DJH
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 5458500 # dec encoding of DJS
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	#  Queens
	
	li $t0, 4411716 # dec encoding of DQC
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4477252 # dec encoding of DQD
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4739396 # dec encoding of DQH
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 5460292 # dec encoding of DQS
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	#  Kings
	
	li $t0, 4410180  # dec encoding of DKC
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4475716  # dec encoding of DKD
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4737860 # dec encoding of DKH
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 5458756 # dec encoding of DKS
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	# append Aces
	
	li $t0, 4407620 # dec encoding of DAC
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4473156 # dec encoding of DAD
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 4735300 # dec encoding of DAH
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	li $t0, 5456196 # dec encoding of DAS
	beq $a0, $t0, is_valid
	addi $t0, $t0, 17
	beq $a0, $t0, is_valid
	
	is_valid:
	li $v0, 0
	j done_is_valid_card
	
	is_not_valid:
	li $v0, -1
	j done_is_valid_card
	
	done_is_valid_card:
        	
		jr $ra
	
# Part 11
card_points:
	# a0 has the point value of the card - 5458500 or something like that
	
	addi $sp, $sp, -4
        sw $ra, 0($sp)
	
	jal is_valid_card
	bltz $v0, done_card_points
	
	# Check for up and down queen of spades
	li $t0, 0x00000000 # hex number we will be appending to
	
        li $t1, 'S'    # Queen of Spades Face Down
        sll $t1, $t1, 16
        add $t0, $t0, $t1
        
        li $t1, 'Q'   
        sll $t1, $t1, 8
        add $t0, $t0, $t1
        
        li $t1, 'D'    
        sll $t1, $t1, 0
        add $t0, $t0, $t1
        
        beq $a0, $t0, is_queen_of_spades
        addi $t0, $t0, 17 # Queen of Spades Face Up
        beq $a0, $t0, is_queen_of_spades
        
        # otherwise, check for hearts
        
        li $t1, '2'
        li $t2, '9'
	
	hearts_loop:	
		li $t0, 0x00000000
					
		li $t5, 'H'    # hearts
        	sll $t5, $t5, 16
        	add $t0, $t0, $t5
        
       		move $t5, $t1 # '2' - '9'
        	sll $t5, $t5, 8
        	add $t0, $t0, $t5
        
       		li $t5, 'D'    # DOWN NOT DIAMONDS
       	 	sll $t5, $t5, 0
        	add $t0, $t0, $t5   # t0 now has the number encoding in decimal form
        		
        	beq $a0, $t0, is_heart
        	addi $t0, $t0, 17 # check for UP
        	beq $a0, $t0, is_heart
        	
        	addi $t1, $t1, 1
        	bgt $t1, $t2, continue_check_hearts
        	
        	j hearts_loop
        
        continue_check_hearts:
        # DTH
        li $t0, 4740164
        beq $a0, $t0, is_heart
        addi $t0, $t0, 17 # check for UP
        beq $a0, $t0, is_heart
        
        # DJH
        li $t0, 4737604
        beq $a0, $t0, is_heart
        addi $t0, $t0, 17 # check for UP
        beq $a0, $t0, is_heart
        
        # DQH
        li $t0, 4739396
        beq $a0, $t0, is_heart
        addi $t0, $t0, 17 # check for UP
        beq $a0, $t0, is_heart
        
        # DKH
        li $t0, 4737860
        beq $a0, $t0, is_heart
        addi $t0, $t0, 17 # check for UP
        beq $a0, $t0, is_heart
        
        # DAH
        li $t0, 4735300
        beq $a0, $t0, is_heart
        addi $t0, $t0, 17 # check for UP
        beq $a0, $t0, is_heart
        
        j done_card_points
        
        is_heart:
        li $v0, 1
        j done_card_points
        
        is_queen_of_spades:
        li $v0, 13
        j done_card_points
	
	done_card_points:
	
        lw $ra, 0($sp)
        addi $sp, $sp, 4
        
	jr $ra

has_suite:
	# this traverses the player list and checks if a player has a certain card of suite
	# returns in v0: 0 if card of suite is not found, or value of card if it's 
	# a0 has the address of the player list to check 
	# a1 has the number 1-4 (1 - Clubs, 2 -  Diamonds, 3 - Hearts, 4 - Spades)
	
	addi $sp, $sp, -20
	sw $ra, 0($sp) 
	sw $s0, 4($sp)
	sw $s1, 8($sp) # number 1-4 as described above
	sw $s2, 12($sp) # size of list
	sw $s3, 16($sp) # next node location
	
	move $s0, $a0 # this is address of player list
	move $s1, $a1 # this is the number 1-4
	lw $s2, 0($a0) # size of list
	move $s3, $s0 # address of base of list
	
	blez $s2, does_not_have_suite
	
	# otherwise, traverse loop and get value at index
	traverse_loop_has_suite:
		lw $t2, 4($s3) # address of head (INITIALLY IN LOOP)
		move $s3, $t2 # move to address of next node
		beqz $s3, does_not_have_suite # we did not find the number
		
		lw $t3, 0($s3) # num at index in the list
		
		li $t0, 1
		beq $t0, $s1, list_has_clubs # if we're searching for a card of clubs
		
		li $t0, 2
		beq $t0, $s1, list_has_diamonds # if we're searching for a card of diamonds
		
		li $t0, 3
		beq $t0, $s1, list_has_hearts # if we're searching for a card of hearts
		
		li $t0, 4
		beq $t0, $s1, list_has_spades # if we're searching for a card of spades
		
		list_has_clubs:
			move $a0, $t3 # number at node
			li $a1, 1 # clubs
			jal is_card_of_suite
			
			li $t0, 1 
			beq $t0, $v0, has_suite_done # this means card of clubs was found
			
			j traverse_loop_has_suite
		
		list_has_diamonds:
			move $a0, $t3 # number at node
			li $a1, 2 # diamonds
			jal is_card_of_suite
			
			li $t0, 1 
			beq $t0, $v0, has_suite_done # this means card of diamonds was found
			
			j traverse_loop_has_suite
		
		list_has_hearts:
			move $a0, $t3 # number at node
			li $a1, 3 # diamonds
			jal is_card_of_suite
			
			li $t0, 1 
			beq $t0, $v0, has_suite_done # this means card of hearts was found
			
			j traverse_loop_has_suite
		
		list_has_spades:
			move $a0, $t3 # number at node
			li $a1, 4 # diamonds
			jal is_card_of_suite
			
			li $t0, 1 
			beq $t0, $v0, has_suite_done # this means card of spades was found
			
			j traverse_loop_has_suite
		
	has_suite_done:
	# get the number at the node and return
	
		lw $v0, 0($s3) # return the number that we found at the node
		
		lw $ra, 0($sp) 
		lw $s0, 4($sp)
		lw $s1, 8($sp) 
		lw $s2, 12($sp) # size of list
		lw $s3, 16($sp)
		
		addi $sp, $sp, 20
		
		jr $ra
		
	does_not_have_suite:
		li $v0, -1
		
		lw $ra, 0($sp) 
		lw $s0, 4($sp)
		lw $s1, 8($sp) 
		lw $s2, 12($sp) # size of list
		lw $s3, 16($sp)
		
		addi $sp, $sp, 20
		
		jr $ra

is_card_of_suite:

	# boolean function, returns in v0: 1 - yes, 0 - no
	# a0 has the number (value of card in dec)
	# a1 has the number 1-4 (1 - Clubs, 2 -  Diamonds, 3 - Hearts, 4 - Spades)
	
	move $t3, $a0
	
	li $t0, 1
	beq $t0, $a1, is_card_of_suite_clubs
	
	li $t0, 2
	beq $t0, $a1, is_card_of_suite_diamonds
	
	li $t0, 3
	beq $t0, $a1, is_card_of_suite_hearts
	
	li $t0, 4
	beq $t0, $a1, is_card_of_suite_spades
	
	is_card_of_suite_clubs:
	li $t1, 'C'    # U_D   leftmost number in hex number (suite - hearts)
        sll $t1, $t1, 16
        sub $t3, $t3, $t1
        j is_card_of_suite_load_up
	
	is_card_of_suite_diamonds:
	li $t1, 'D'    # U_D   leftmost number in hex number (suite - hearts)
        sll $t1, $t1, 16
        sub $t3, $t3, $t1
        j is_card_of_suite_load_up
        
        is_card_of_suite_hearts:
	li $t1, 'H'    # U_D   leftmost number in hex number (suite - hearts)
        sll $t1, $t1, 16
        sub $t3, $t3, $t1
        j is_card_of_suite_load_up
        
        is_card_of_suite_spades:
	li $t1, 'S'    # U_D   leftmost number in hex number (suite - hearts)
        sll $t1, $t1, 16
        sub $t3, $t3, $t1
        j is_card_of_suite_load_up
        
        
        is_card_of_suite_load_up:
        li $t1, 'U'    # rightmost number in hex number (down or up)
        sll $t1, $t1, 0
        sub $t3, $t3, $t1
        
        srl $t3, $t3, 8 # this is the middle character '2-A' in dec format 
        
        # if the residue number is one of these ranks, then it has to be a clubs
        li $t0, 84 #T
        beq $t3, $t0, yes_suite
        li $t0, 74 #J
        beq $t3, $t0, yes_suite
        li $t0, 81 #Q
        beq $t3, $t0, yes_suite
        li $t0, 75 #K
        beq $t3, $t0, yes_suite
        li $t0, 65 #A
        beq $t3, $t0, yes_suite
        
        li $t0, 50
        li $t1, 57
        
        blt $t3, $t0, no_suite
        bgt $t3, $t1, no_suite
        
        yes_suite:
		li $v0, 1
		jr $ra
        		
	no_suite:
		li $v0, 0
		jr $ra

get_rank:

	# a0 is the number
	# a1 is the number 1-4 (1 - Clubs, 2 -  Diamonds, 3 - Hearts, 4 - Spades)
	
	li $t0, 1
	beq $a1, $t0, get_rank_clubs
	
	li $t0, 2
	beq $a1, $t0, get_rank_diamonds
	
	li $t0, 3
	beq $a1, $t0, get_rank_hearts
	
	li $t0, 4
	beq $a1, $t0, get_rank_spades
	
	get_rank_clubs:
	li $t1, 'C'    #  leftmost number in hex number (suite - clubs)
        sll $t1, $t1, 16
        sub $a0, $a0, $t1
        j get_rank_load_up
        
        get_rank_diamonds:
	li $t1, 'D'    #  leftmost number in hex number (suite - clubs)
        sll $t1, $t1, 16
        sub $a0, $a0, $t1
        j get_rank_load_up
        
        get_rank_hearts:
	li $t1, 'H'    #  leftmost number in hex number (suite - clubs)
        sll $t1, $t1, 16
        sub $a0, $a0, $t1
        j get_rank_load_up
        
        get_rank_spades:
	li $t1, 'S'    #  leftmost number in hex number (suite - clubs)
        sll $t1, $t1, 16
        sub $a0, $a0, $t1
        j get_rank_load_up
        
        get_rank_load_up:
        li $t1, 'U'    # rightmost number in hex number (down or up)
        sll $t1, $t1, 0
        sub $a0, $a0, $t1
        
        srl $a0, $a0, 8 # this is the middle character '2-A' in dec format 
        
        li $t0, 84 # if 84 (T) - return 10
        beq $a0, $t0, is_ten_rank
        li $t0, 74 # if 74 (J) - return 11
        beq $a0, $t0, is_jack_rank
        li $t0, 81 # if 81 (Q) - return 12
        beq $a0, $t0, is_queen_rank
        li $t0, 75 # if 75 (K) - return 13
        beq $a0, $t0, is_king_rank
        li $t0, 65 # if 65 (A) - return 14
        beq $a0, $t0, is_ace_rank
        
        j continue_rank
        
        is_ten_rank:
        	li $v0, 10
        	jr $ra
        
        is_jack_rank:
        	li $v0, 11
        	jr $ra
        
        is_queen_rank:
        	li $v0, 12
        	jr $ra
        
        is_king_rank:
        	li $v0, 13
        	jr $ra
        
        is_ace_rank:
        	li $v0, 14
        	jr $ra
        
        continue_rank:
        # else, it's between 50-57 (dec), do addi -48 and return (should be between 2-9)
        addi $t3, $a0, -48
        move $v0, $t3
        
        jr $ra

increment_totalscore:
# a0 should be big hexadec return value
# a1 should be the points awarded to the player
# a2 should be player who we're awarding points to (0-3)

	li $t0, 0
	beq $t0, $a2, increment_player0
	li $t0, 1
	beq $t0, $a2, increment_player1
	li $t0, 2 
	beq $t0, $a2, increment_player2
	li $t0, 3
	beq $t0, $a2, increment_player3
	
	increment_player0:
	sll $a1, $a1, 0
	add $a0, $a0, $a1
	j done_incrementing_total_score
	
	increment_player1:
	sll $a1, $a1, 8
	add $a0, $a0, $a1
	j done_incrementing_total_score
	
	increment_player2:
	sll $a1, $a1, 16
	add $a0, $a0, $a1
	j done_incrementing_total_score
	
	increment_player3:
	sll $a1, $a1, 24
	add $a0, $a0, $a1
	j done_incrementing_total_score
	
	done_incrementing_total_score:
	move $v0, $a0 # return the updated score so we can keep updating the value
	jr $ra
	
# Part 12
simulate_game:
	#a0 has the deck 
	# a1 has the players array
	# a2 has the number of rounds
	
	addi $sp, $sp, -44
        sw $ra, 0($sp)
        sw $s0, 4($sp) # 
        sw $s1, 8($sp) # 
        sw $s2, 12($sp)
        sw $s3, 16($sp) # i < num_rounds (starts at 0)
        sw $s4, 20($sp) 
        sw $s5, 24($sp) 
        sw $s6, 28($sp) 
        sw $s7, 32($sp) 
        sw $t7, 36($sp) # the suite of the round (1 - Clubs, 2 -  Diamonds, 3 - Hearts, 4 - Spades)
        sw $t8, 40($sp) # number drawn or removed in a round from 1 player 
        
        move $s0, $a0 # deck of cards, 52 & shuffled
        move $s1, $a1 # players array, each player 1 word
        move $s2, $a2 # numrounds (1-13)
        li $s3, 0 
        li $s4, 0 # hex encoding of the players tally
        li $s5, 0 # player index with max rank in the suite in the round [0-3]
        li $s6, 0 # max rank in the round (2-14 (Ace) )
        li $s7, 0 # total tally of the points per round
        
        # initialize the lists for the players
        
	lw $a0, 0($s1) # players[0]
	jal init_list
	lw $a0, 4($s1) # players[1]
	jal init_list
	lw $a0, 8($s1) # players[2]
	jal init_list
	lw $a0, 12($s1) # players[3]
	jal init_list
	
	# deal all of the cards to the players
	move $a0, $s0 # entire card deck 
	move $a1, $s1 # players[]
	li $a2, 4 # num_players
	li $a3, 13 # cards per player
	jal deal_cards
	
	first_round:
		li $s7, 0 # total tally per round
		
		player_0_first_round:
		
		lw $a0, 0($s1) #players[0]
		li $t0, 4403797 # 2 of C face up
		move $a1, $t0
		jal remove # returns -1 if we can't find the 2C
		bltz $v0, player_1_first_round
		
		li $t0, 0 # players[] offset for the loop
		j first_round_go_around
		
		player_1_first_round:
		
		lw $a0, 4($s1) #players[1]
		li $t0, 4403797 # 2 of C face up
		move $a1, $t0
		jal remove # returns -1 if we can't find the 2C
		bltz $v0, player_2_first_round
		
		li $t0, 1
		
		j first_round_go_around
		
		player_2_first_round:
		
		lw $a0, 8($s1) #players[2]
		li $t0, 4403797 # 2 of C face up
		move $a1, $t0
		jal remove # returns -1 if we can't find the 2C
		bltz $v0, player_3_first_round
		
		li $t0, 2
		
		j first_round_go_around
		
		player_3_first_round:
		
		lw $a0, 12($s1) #players[3]
		li $t0, 4403797 # 2 of C face up
		move $a1, $t0
		jal remove # it has to return an index >= 0
		
		li $t0, 3
		
		first_round_go_around:
			# check the rest of the players (if they have a club in their deck)
			
			move $s5, $t0  # this is the player to ignore when we go around [0-3]
			move $t6, $s5 # COPY the index so it gets saved
			
			li $s6, 2 # max rank in the round is currently 2 (because of first player)
			
			player_0_check_clubs:
				
				li $t0, 0
				beq $t0, $t6, player_1_check_clubs 
			
				lw $a0, 0($s1)
				li $a1, 1 # clubs 
				jal has_suite
				
				bltz $v0, first_player_draw_round1 # if has_suite = -1, draw card from top of deck
			
				move $t8, $v0 # otherwise, keep number (card value) returned to use in other functions
				# and otherwise, remove(list, num)
				lw $a0, 0($s1) # player 1 address
				move $a1, $v0 # num to remove
				jal remove  # remove the return value of has_clubs
				
				move $a0, $t8 # number to get points of
				jal card_points
				add $s7, $s7, $v0 # increment total tally of the round
				
				# compare to the current max rank  
				
				move $a0, $t8 # number
				li $a1, 1 # check for clubs
				jal get_rank
					
				blt $v0, $s6, player_1_check_clubs
					
				change_maxrank_to_player0:
					
				li $s5, 0 # set max player of round to player 0
				move $s6, $v0 # set max rank of future round to rank of player 0 play
				
				j player_1_check_clubs
				
				first_player_draw_round1:
					# if we're drawing, that means there's no clubs
					
					lw $a0, 0($s1) # address of player0
					jal draw_card
					bltz $v0, done_first_round
					
					move $a0, $v1 # this contains the value of the drawn card
					jal card_points
					add $s7, $s7, $v0 # increment the total tally of the round
					
        		player_1_check_clubs:
        			li $t0, 1
				beq $t0, $t6, player_2_check_clubs 
			
				lw $a0, 4($s1)
				li $a1, 1 # clubs 
				jal has_suite
				
				bltz $v0, second_player_draw_round1 # if has_suite = -1, draw card from top of deck
			
				move $t8, $v0 # otherwise, keep number (card value) returned to use in other functions
				# and otherwise, remove(list, num)
				lw $a0, 4($s1) # player 2 address
				move $a1, $v0 # num to remove
				jal remove  # remove the return value of has_clubs
				
				move $a0, $t8 # number to get points of
				jal card_points
				add $s7, $s7, $v0 # increment total tally of the round
				
				# compare to the current max rank  
				move $a0, $t8 # number
				li $a1, 1 # check for clubs
				jal get_rank
					
				blt $v0, $s6, player_2_check_clubs
					
				change_maxrank_to_player1:
					
				li $s5, 1 # set max player of round to player 0
				move $s6, $v0 # set max rank to rank of player 0 play
				
				j player_2_check_clubs
				
				second_player_draw_round1:
					# if we're drawing, that means there's no clubs
					
					lw $a0, 4($s1) # address of player1
					jal draw_card
					bltz $v0, done_first_round
					
					move $a0, $v1 # this contains the value of the drawn card
					jal card_points
					add $s7, $s7, $v0 # increment the total tally of the round
					
        		player_2_check_clubs:
        			li $t0, 2
				beq $t0, $t6, player_3_check_clubs 
			
				lw $a0, 8($s1) # address of player 2
				li $a1, 1 # clubs 
				jal has_suite
				
				bltz $v0, third_player_draw_round1 # if has_suite = -1, draw card from top of deck
			
				move $t8, $v0 # otherwise, keep number (card value) returned to use in other functions
				# and otherwise, remove(list, num)
				lw $a0, 8($s1) # player 3 address
				move $a1, $v0 # num to remove
				jal remove  # remove the return value of has_clubs
				
				move $a0, $t8 # number to get points of
				jal card_points
				add $s7, $s7, $v0 # increment total tally of the round
				
				# compare to the current max rank  
				
				move $a0, $t8 # number
				li $a1, 1 # check for clubs
				jal get_rank
					
				blt $v0, $s6, player_3_check_clubs
					
				change_maxrank_to_player2:
					
				li $s5, 2 # set max player of round to player 2
				move $s6, $v0 # set max rank to rank of player 2 play
				
				j player_3_check_clubs
				
				third_player_draw_round1:
					# if we're drawing, that means there's no clubs
					
					lw $a0, 8($s1) # address of player2
					jal draw_card
					bltz $v0, done_first_round
					
					move $a0, $v1 # this contains the value of the drawn card
					jal card_points
					add $s7, $s7, $v0 # increment the total tally of the round
					
        		player_3_check_clubs:
        			li $t0, 3
				beq $t0, $t6, done_first_round 
			
				lw $a0, 12($s1)
				li $a1, 1 # clubs 
				jal has_suite
				
				bltz $v0, fourth_player_draw_round1 # if has_suite = -1, draw card from top of deck
			
				move $t8, $v0 # otherwise, keep number (card value) returned to use in other functions
				# and otherwise, remove(list, num)
				lw $a0, 12($s1) # player 4 address
				move $a1, $v0 # num to remove
				jal remove  # remove the return value of has_clubs
				
				move $a0, $t8 # number to get points of
				jal card_points
				add $s7, $s7, $v0 # increment total tally of the round
				
				# compare to the current max rank  
				
				move $a0, $t8 # number
				li $a1, 1 # check for clubs
				jal get_rank
					
				blt $v0, $s6, done_first_round
					
				change_maxrank_to_player3:
					
				li $s5, 3 # set max player of round to player 0
				move $s6, $v0 # set max rank to rank of player 0 play
				
				j done_first_round
				
				fourth_player_draw_round1:
					# if we're drawing, that means there's no clubs
					
					lw $a0, 12($s1) # address of player3
					jal draw_card
					bltz $v0, done_first_round
					
					move $a0, $v1 # this contains the value of the drawn card
					jal card_points
					add $s7, $s7, $v0 # increment the total tally of the round
					
	done_first_round:
	
	# s5 (player index with max rank) and s6 (max rank in the round have already been modified) 
	
	move $a0, $s4 # a0 should be big hexadec return value
	move $a1, $s7 # a1 should be the points of the round awarded to the player
	move $a2, $s5 # a2 should be player who we're awarding points to (0-3)
	
	jal increment_totalscore
	
	move $s4, $v0 # keep updating the incremented return value

	addi $s3, $s3, 1
	beq $s3, $s2, done_simulate_game # numrounds exhausted
		
	giant_simulate_game_loop:
		li $s7, 0 # total tally per round
		
		move $t6, $s5 # copy the index so that THIS is the index we're comparing to when we're looping through players
		# s5 has the player with the max score from last round [0-3]
		li $t0, 4
		mul $t1, $t0, $s5 # 4 x max player # to get the address
		add $t2, $s1, $t1 # get max player address for the round
		lw $t0, 0($t2) 
		
		move $a0, $t0 # address of player[i]
		jal draw_card
		
		move $t8, $v1 # this is the card
		
		move $a0, $v1
		jal card_points
		add $s7, $s7, $v0 # increment total tally of the round
		
		move $a0, $t8
		li $a1, 1 # check if card drawn is a clubs
		jal is_card_of_suite
		li $t0, 1
		
		beq $t0, $v0, set_rank_clubs
		
		move $a0, $t8
		li $a1, 2 # check if card drawn is a diamond
		jal is_card_of_suite
		li $t0, 1
		
		beq $t0, $v0, set_rank_diamonds
		
		move $a0, $t8
		li $a1, 3 # check if card drawn is a heart
		jal is_card_of_suite
		li $t0, 1
		
		beq $t0, $v0, set_rank_hearts
		
		move $a0, $t8
		li $a1, 4 # check if card drawn is a spade
		jal is_card_of_suite
		li $t0, 1
		
		beq $t0, $v0, set_rank_spades
		
		# get the rank and set
		# if it's clubs, set t7 = 1, diamonds: t7 = 2, etc
		set_rank_clubs:
		# set the rank for the round
		
		move $a0, $t8
		li $a1, 1
		jal get_rank
		
		move $s6, $v0 # this is the max rank we start off with
		li $t7, 1 # this is the suite of the round (clubs)
		
		j go_through_players
		
		set_rank_diamonds:
		# set the rank for the round
		
		move $a0, $t8
		li $a1, 2
		jal get_rank
		
		move $s6, $v0 # this is the max rank we start off with
		li $t7, 2 # this is the suite of the round (diamonds)
		
		j go_through_players
		
		set_rank_hearts:
		# set the rank for the round
		
		move $a0, $t8
		li $a1, 3
		jal get_rank
		
		move $s6, $v0 # this is the max rank we start off with
		li $t7, 3 # this is the suite of the round (hearts)
		
		j go_through_players
		
		set_rank_spades:
		# set the rank for the round
		
		move $a0, $t8
		li $a1, 4
		jal get_rank
		
		move $s6, $v0 # this is the max rank we start off with
		li $t7, 4 # this is the suite of the round (clubs)
		
		j go_through_players
		
		go_through_players:
			
			player_0:
			# ignore $s5 ( player with max rank of previous round )
			
				li $t0, 0
				beq $t0, $t6, player_1 # SKIP IF THIS IS ALREADY MAX PLAYER
			
				lw $a0, 0($s1)
				move $a1, $t7 # suite of current round to consider only
				jal has_suite
				
				bltz $v0, player0_draw # if has_suite = -1, draw card from top of deck
			
				move $t8, $v0 # otherwise, keep number (card value) returned to use in other functions
				# and otherwise, remove(list, num)
				lw $a0, 0($s1) # player 1 address
				move $a1, $v0 # num to remove
				jal remove  # remove the return value of has_clubs
				
				move $a0, $t8 # number to get points of
				jal card_points
				add $s7, $s7, $v0 # increment total tally of the round
				
				# compare to the current max rank  
				
				move $a0, $t8 # number
				move $a1, $t7 # check for suite
				jal get_rank
					
				blt $v0, $s6, player_1
					
				change_maxrank_player0:
					
				li $s5, 0 # set max player of round to player 0
				move $s6, $v0 # set max rank to rank of player 0 play
				
				j player_1
				
				player0_draw:
					# if we're drawing, that means there's no suite
					
					lw $a0, 0($s1) # address of player0
					jal draw_card
					bltz $v0, done_simulate_game
					
					move $a0, $v1 # this contains the value of the drawn card
					jal card_points
					add $s7, $s7, $v0 # increment the total tally of the round
					
			player_1:
				li $t0, 1
				beq $t0, $t6, player_2 # SKIP IF THIS IS ALREADY MAX PLAYER
			
				lw $a0, 4($s1) # address of playerlist
				move $a1, $t7 # suite
				jal has_suite
				
				bltz $v0, player1_draw # if has_suite = -1, draw card from top of deck
			
				move $t8, $v0 # otherwise, keep number (card value) returned to use in other functions
				# and otherwise, remove(list, num)
				lw $a0, 4($s1) # player 2 address
				move $a1, $v0 # num to remove
				jal remove  # remove the return value of has_clubs
				
				move $a0, $t8 # number to get points of
				jal card_points
				add $s7, $s7, $v0 # increment total tally of the round
				
				# compare to the current max rank  
				move $a0, $t8 # number
				move $a1, $t7 # check for suite
				jal get_rank
					
				blt $v0, $s6, player_2
					
				change_maxrank_player1:
					
				li $s5, 1 # set max player of round to player 1
				move $s6, $v0 # set max rank to rank of player 1 
				
				j player_2
				
				player1_draw:
					# if we're drawing, that means there's no clubs
					
					lw $a0, 4($s1) # address of player1
					jal draw_card
					bltz $v0, done_first_round
					
					move $a0, $v1 # this contains the value of the drawn card
					jal card_points
					add $s7, $s7, $v0 # increment the total tally of the round
					
			player_2:
			
				li $t0, 2
				beq $t0, $t6, player_3 # SKIP IF THIS IS ALREADY MAX PLAYER
			
				lw $a0, 8($s1) # address of player 2
				move $a1, $t7 # suite 
				jal has_suite
				
				bltz $v0, player2_draw # if has_suite = -1, draw card from top of deck
			
				move $t8, $v0 # otherwise, keep number (card value) returned to use in other functions
				# and otherwise, remove(list, num)
				lw $a0, 8($s1) # player 3 address
				move $a1, $v0 # num to remove
				jal remove  # remove the return value of has_clubs
				
				move $a0, $t8 # number to get points of
				jal card_points
				add $s7, $s7, $v0 # increment total tally of the round
				
				# compare to the current max rank  
				
				move $a0, $t8 # number
				move $a1, $t7 # check for suite
				jal get_rank
					
				blt $v0, $s6, player_3
					
				change_maxrank_player2:
					
				li $s5, 2 # set max player of round to player 2
				move $s6, $v0 # set max rank to rank of player 2 play
				
				j player_3
				
				player2_draw:
					# if we're drawing, that means there's no clubs
					
					lw $a0, 8($s1) # address of player2
					jal draw_card
					bltz $v0, done_first_round
					
					move $a0, $v1 # this contains the value of the drawn card
					jal card_points
					add $s7, $s7, $v0 # increment the total tally of the round
					
			
			player_3:
				li $t0, 3
				beq $t0, $t6, update_state_of_game
			
				lw $a0, 12($s1)
				move $a1, $t7 # suite
				jal has_suite
				
				bltz $v0, player3_draw # if has_suite = -1, draw card from top of deck
			
				move $t8, $v0 # otherwise, keep number (card value) returned to use in other functions
				# and otherwise, remove(list, num)
				lw $a0, 12($s1) # player 4 address
				move $a1, $v0 # num to remove
				jal remove  # remove the return value of has_suite
				
				move $a0, $t8 # number to get points of
				jal card_points
				add $s7, $s7, $v0 # increment total tally of the round
				
				# compare to the current max rank  
				
				move $a0, $t8 # number
				move $a1, $t7 # suite
				jal get_rank
					
				blt $v0, $s6, update_state_of_game
					
				change_maxrank_player3:
					
				li $s5, 3 # set max player of round to player 0
				move $s6, $v0 # set max rank to rank of player 0 play
				
				j update_state_of_game
				
				player3_draw:
					# if we're drawing, that means there's no clubs
					
					lw $a0, 12($s1) # address of player3
					jal draw_card
					bltz $v0, done_first_round
					
					move $a0, $v1 # this contains the value of the drawn card
					jal card_points
					add $s7, $s7, $v0 # increment the total tally of the round
			
			update_state_of_game:
			
			# get player with highest rank in suite
			# make next player = highest rank player of this round
			
			move $a0, $s4 # a0 should be big hexadec return value
			move $a1, $s7 # a1 should be the points of the round awarded to the player
			move $a2, $s5 # a2 should be player who we're awarding points to (0-3)
	
			jal increment_totalscore
	
			move $s4, $v0 # keep updating the incremented return value
			
			addi $s3, $s3, 1
			beq $s3, $s2, done_simulate_game # numrounds exhausted
			
			j giant_simulate_game_loop
	
	done_simulate_game:
	# encode all of the player points into one nice hexadecimal and pray that it's right :)
	move $v0, $s4
	
        lw $ra, 0($sp)
        lw $s0, 4($sp) # this is the pointer to the beginning of the list
        lw $s1, 8($sp) # 2-9
        lw $s2, 12($sp)
        lw $s3, 16($sp)
        lw $s4, 20($sp)
        lw $s5, 24($sp)
        lw $s6, 28($sp)
        lw $s7, 32($sp)
        lw $t7, 36($sp) # the suite of the round (1 - Clubs, 2 -  Diamonds, 3 - Hearts, 4 - Spades)
        lw $t8, 40($sp)
        
        addi $sp, $sp, 44
	jr $ra

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
