# Lolita Nefari Nazarov
# lnazarov
# 110722612

#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################

.text

# Part I
compare_to:
      # a0 has the pointer to customer1
      # a1 has pointer to customer2 
      # both have id (int - 4 bytes), fame (short - 2 bytes), wait_time (short - 2 bytes)
      
      lw $t0, 0($a0)  # id        C1
      lh $t1, 4($a0)  # fame
      lh $t2, 6($a0)  # wait_time
      
      #priority = fame + 10 x wait_time
      li $t3, 10
      mul $t4, $t3, $t2 # 10 x wait_time
      add $t5, $t4, $t1  # priority of c1
      
      lw $t0, 0($a1)  # id        C2
      lh $t8, 4($a1)  # fame
      lh $t9, 6($a1)  # wait_time
      
      li $t3, 10
      mul $t4, $t3, $t9 # 10 x wait_time
      add $t6, $t4, $t8  # priority of c2
      
      blt $t5, $t6, c1_less_than_c2
      bgt $t5, $t6, c1_greater_than_c2
      
      j c1_equal_to_c2
      
      c1_less_than_c2:
            li $v0, -1
            jr $ra
            
      c1_greater_than_c2:
            li $v0, 1
            jr $ra

      c1_equal_to_c2:
            
            blt $t1, $t8, c1_fame_less_than_c2_fame
            bgt $t1, $t8, c1_fame_greater_than_c2_fame
            
            c1_fame_equal_to_c2_fame:
                  li $v0, 0
                  jr $ra
      
            c1_fame_less_than_c2_fame:
                  li $v0, -1
                  jr $ra
            
            c1_fame_greater_than_c2_fame:
                  li $v0, 1
                  jr $ra
            
# Part II
init_queue:
      # a0 contains the queue, which has size (short), max_size (short), and Customer [] customers (byte per cell)
      # a1 is the max size of the array 
      bltz $a1, initialize_queue_error
      
      sh $0, 0($a0)
      sh $a1, 2($a0)
      
      li $t0, 0 # counter for max # of cells to initialize to 0
      
      addi $t1, $a0, 4 # beginning of array
      
      initialize_array_loop:
            sb $0, 0($t1)
            addi $t0, $t0, 1
            addi $t1, $t1, 1 # increment the place in the array
            beq $t0, $a1, initialize_queue_correct
            j initialize_array_loop
            
      initialize_queue_error:
            li $v0, -1
            jr $ra
            
      initialize_queue_correct:
            addi $a1, $a1, 1
            move $v0, $a1
            jr $ra
      
# Part III
memcpy:
      # a0 holds src char array
      # a1 holds dest char array
      # a2 holds n, number of bytes to copy
      blez $a2, memcpy_error
      #addi $a2, $a2, -1  # loop until n-1 bc it starts at 0
      
      li $t2, 0 # counter for looping through the char array until n
      
      copy_loop:
            add $t0, $t2, $a0 # address where to extract from src
            add $t1, $t2, $a1 # address where to insert into dest
            
            lbu $t3, 0($t0) # load byte from address at src
            sb $t3, 0($t1) # store byte into address at src
            
            addi $t2, $t2, 1
            beq $t2, $a2, memcpy_correct
            
            j copy_loop
            
      memcpy_correct:
            
            move $v0, $a2
            jr $ra
            
      memcpy_error:
            li $v0, -1
            jr $ra

# Part IV
contains:
      #a0 contains queue
      #a1 has customer_id as int

      # get index of the element (root index starts at 0)
      
      li $t1, 0 # index counter
      
      lhu $t0, 0($a0) # get size
      addi $t0, $t0, -1 # loop until size - 1 to get the index
      
      addi $a0, $a0, 4  #start at queue address + 4 bytes to search for index
      
      find_index_loop:
            lw $t2, 0($a0) #load index from queue
            
            beq $a1, $t2, get_level_in_heap
            addi $a0, $a0, 8 #next index
            addi $t1, $t1, 1 # increment index counter
            bgt $t1, $t0, contains_notfound
            j find_index_loop
            
      get_level_in_heap:
      # t1 has the index of the element
      
      # get level in the heap
      # root level starts at 1, root index is 0
      # formula for level --->   level = floor(log3(index+1))
      # just keep dividing by 3, branch when mflo = 0
      
      li $t4, 3
      addi $t1, $t1, 1
      li $t8, 1 # counter for the level number (starting at 1)
      
            get_level_in_heap_loop:
                  div $t1, $t4  # divide index+1 by 3
                  mflo $t9  # store quotient
                  beqz $t9, contains_found
                  move $t1, $t9 # move quotient to the new dividend
                  addi $t8, $t8, 1
                  
                  j get_level_in_heap_loop
      
      contains_found:
            move $v0, $t8
            jr $ra
      
      contains_notfound:
            li $v0, -1
            jr $ra

# Part V
enqueue:
      # a0 has pointer to CustomerQueue struct (queue)
      # a1 has pointer to a valid customer struct
      
      # if contains(queue, customer_id) returns >= 0, error because element is already exists in queue
      # contains returns level that node is at
      # if size = max_size, return -1
      
      addi $sp, $sp, -36
      sw $ra, 0($sp)
      sw $s0, 4($sp) # queue struct
      sw $s1, 8($sp) # customer struct
      sw $s2, 12($sp) # child address
      sw $s3, 16($sp) # parent address
      sw $s4, 20($sp) # s4 s5 and s6 are for copying the contents of the parent node in heapify
      sw $s5, 24($sp) 
      sw $s6, 28($sp) 
      sw $s7, 32($sp) # parent index, starts at child in heapify
     
      move $s0, $a0 # copy CustomerQueue struct
      move $s1, $a1 # copy customer struct
      
      lhu $t0, 0($s0) # size of queue
      lhu $t1, 2($s0) # max_size of queue
      
      beq $t0, $t1, enqueue_fail
      
      lw $t0, 0($s1) # get id from customer struct
      
      move $a0, $s0  # CustomerQueue* queue
      move $a1, $t0  # customer id as int
      jal contains
      
      bgez $v0, enqueue_fail # if result of contains is >= 0, then that means customer's already in queue at level v0
      
      # finding the address of the index queue.size 
      # AKA THE LAST CELL IN THE ARRAY
      lhu $t0, 0($s0) # get size of queue again
      li $t9, 8
      mul $s2, $t9, $t0 
      addi $s2, $s2, 4
      add $s2, $s2, $s0  # address of queue.size index [LAST CELL in array] - child index
      
      # copy customer struct to the queue.size index of the queue.customers array
      move $a0, $s1  # src (pointer to customer struct)
      move $a1, $s2  # dest (address of last index is  4 + 8 * size of Customer queue struct)
      li $a2, 8   # number of bytes we want to copy
      jal memcpy
      
      lhu $s7, 0($s0) # get size of queue again (CHILD INDEX)
      
      heapify_up_loop:
            # index of the added element is size ($t0)
            # get parent index, (i-1)/3
      	    
            addi $s7, $s7, -1
            li $t1, 3
            div $s7, $t1
            mflo $t2  # parent index
            move $s7, $t2  # for the next time around in the loop
      
            li $t3, 8
            mul $t2, $t2, $t3 # to get parent address, subtract (i-1)/3 * 8 from child address
            
            addi $s0, $s0, 4
            add $s3, $s0, $t2 # parent address = [beginning of queue address] + ([child index]-1)/3 * 8
            addi $s0, $s0, -4
      
            move $a0, $s2 # child address 
            move $a1, $s3 # parent address 
      
            jal compare_to
            # if compare_to(child, parent) = 1, swap 
            
            blez $v0, enqueue_success # if the child node is less than or equal to parent node, leave the heap untouched
            
            # swap child and parent because compareto = 1
            
            lw $s4, 0($s3) # copying contents from the parent
            lh $s5, 4($s3)
            lh $s6, 6($s3)
            
            # copying child to parent 
            move $a0, $s2  # src (child)  
            move $a1, $s3  # dest (parent)
            li $a2, 8   # number of bytes we want to copy
            
            jal memcpy
            
            sw $s4, 0($s2) # storing contents of the parent into child node
            sh $s5, 4($s2)
            sh $s6, 6($s2)
            
            j heapify_up_loop
      
      enqueue_success:
            
            li $v0, 1
            
            lhu $t0, 0($s0) # get size of queue again
            addi $t0, $t0, 1
            move $v1, $t0 # return updated size queue
            
            lw $ra, 0($sp)
            lw $s0, 4($sp)
            lw $s1, 8($sp)
            lw $s2, 12($sp)
            lw $s3, 16($sp) 
            lw $s4, 20($sp) 
            lw $s5, 24($sp) 
            lw $s6, 28($sp) 
            lw $s7, 32($sp)
            
            addi $sp, $sp, 36
            
            jr $ra
      
      enqueue_fail:
            
            li $v0, -1
            lhu $t0, 0($s0) # get size of queue again
            move $v1, $t0 # return updated size queue
            
            lw $ra, 0($sp)
            lw $s0, 4($sp)
            lw $s1, 8($sp)
            lw $s2, 12($sp)
            lw $s3, 16($sp) 
            lw $s4, 20($sp) 
            lw $s5, 24($sp) 
            lw $s6, 28($sp) 
            lw $s7, 32($sp)
            
            addi $sp, $sp, 36
            
            jr $ra

# Part VI
heapify_down:
	addi $sp, $sp, -44
        sw $ra, 0($sp)
        sw $s0, 4($sp) # queue struct address
        sw $s1, 8($sp) # index
        sw $s2, 12($sp) # size of the queue
        sw $s3, 16($sp) # "largest" index
        sw $s4, 20($sp) # "largest" memory address
        sw $s5, 24($sp) # parent index
        sw $s6, 28($sp) # parent address
        sw $s7, 28($sp) # number of swaps
        sw $t7, 32($sp) # 
        sw $t8, 36($sp) # t7 t8 and t9 are for the swapping (load parent node contents into these guys)
        sw $t9, 40($sp) # 
        
        bltz $a1, heapify_down_fail
        
        move $s0, $a0 # copy CustomerQueue struct
        move $s1, $a1 # copy index from which to start heapify down
        
        lhu $s2, 0($s0) # size of queue
        
        bge $s1, $s2, heapify_down_fail # -1 if index >= queue.size
        
        # initialize the parent index and address
        
        addi $s0, $s0, 4 # skip the size and max_size
        
        move $s5, $s1 # parent index = initial index
        li $t9, 8
        mul $t1, $s5, $t9 # parent index * 8 for address
        add $s6, $s0, $t1 # memory address of parent
        
        move $s3, $s5 # "largest" index = parent index (INITIALLY)
        move $s4, $s6 # "largest" address = parent address (INITIALLY)
        	
        li $s7, 0 # initialize number of swaps to 0
        
        max_heapify_loop:
        	li $t0, 3
        	li $t9, 8
        	
        	# determine the largest child node
        	mul $t1, $t0, $s5 # 3 * parent index
        	addi $t1, $t1, 1 # left child index
        	
        	bge $t1, $s2, continue_middle # left >= size, doesn't exist
        	
        	# getting the addresses of left and parent index - condition A[left] > A[largest]
        	
        	mul $t0, $s5, $t9 # parent index * 8 for the address of the index [SET TO LARGEST INDEX]
        	mul $t1, $t1, $t9 # left child index * 8 for address
        	
        	add $t4, $s0, $t0 # memory address of index [SET TO LARGEST MEMORY ADDRESS]
        	add $t5, $s0, $t1 # memory address of left child
        	
        	move $s3, $s5 # "largest" index = parent
        	move $s4, $t4 # "largest" memory address
        	
        	# obtain largest index by the logic in the pdf
        	# s3 will hold the "largest" index
        	
        	move $a0, $t5  # left child memory address
        	move $a1, $s4  # "largest" memory address
        	
        	jal compare_to
        	blez $v0, continue_middle  # if A[left] <= A[largest] skip to comparing middle & largest
        	
        	# RECOMPUTE left node index + address
        	# get memory address of left child index and move to memory address of "largest"
        	
        	li $t0, 3
        	li $t9, 8
        	mul $t1, $t0, $s5 # 3 * parent index
        	addi $t1, $t1, 1 # left child inde
        	
        	move $s3, $t1 # largest index = left child index
        	
        	mul $t1, $t1, $t9 # left child index * 8 for address
        	add $t5, $s0, $t1 # memory address of left child
        	
        	move $s4, $t5 # largest address = left address
        	
        	continue_middle:
        	
        		li $t9, 8
        		li $t0, 3
        		
        		mul $t2, $t0, $s5 # 3 * parent index
        	        addi $t2, $t2, 2 # middle child index
        	        
        	        bge $t2, $s2, continue_right # go to third "if" if mid index >= size
        	        
        	        mul $t2, $t2, $t9 # middle child index * 8 for address
        	        add $t6, $s0, $t2 # memory address of middle child
        	
        		move $a0, $t6  # middle child memory address
        		move $a1, $s4  # "largest" memory address
        	
        		jal compare_to
        		blez $v0, continue_right  # if A[middle] <= A[largest] skip to comparing middle & largest
        	        
        	        # RECOMPUTE middle node index + address
        	        # get memory address of left child index and move to memory address of "largest"
        	
        		li $t0, 3
        		li $t9, 8
        		mul $t1, $t0, $s5 # 3 * parent index
        		addi $t1, $t1, 2 # middle child index
        		
        		move $s3, $t1 # largest index = middle child index
        		
        		mul $t1, $t1, $t9 # left child index * 8 for address
        		add $t5, $s0, $t1 # memory address of left child
        	
        		move $s4, $t5 # largest address = left address
        	
        	continue_right:
        	
        		li $t9, 8
        		li $t0, 3
        		
        		mul $t3, $t0, $s5 # 3 * parent index
        	        addi $t3, $t3, 3 # right child index
        	        
        	        bge $t3, $s2, swap_or_not # right index >= size
        	        
        	        mul $t3, $t3, $t9 # right child index * 8 for address
        	        add $t7, $s0, $t3 # memory address of middle child
        	
        		move $a0, $t7  # right child memory address
        		move $a1, $s4  # "largest" memory address
        		
        		jal compare_to
        		blez $v0, swap_or_not
        		
        		# RECOMPUTE right node index + address
        	        # get memory address of left child index and move to memory address of "largest"
        		
        		li $t0, 3
        		li $t9, 8
        		mul $t1, $t0, $s5 # 3 * parent index
        		addi $t1, $t1, 3 # right child index
        		
        		move $s3, $t1 # largest index = right child index
        		
        		mul $t1, $t1, $t9 # right child index * 8 for address
        		add $t5, $s0, $t1 # memory address of right child
        	
        		move $s4, $t5 # largest address = right address
        	
        	swap_or_not:
        	
        		# if largest != index then
        		# swap A[index] and A[largest]
        		# index = largest
        		# else break
        	
        		beq $s3, $s5, heapify_down_success # if parent index = largest, heap is all good
        	
        		# otherwise swap largest node with parent node
        	
        		addi $s7, $s7, 1 # increment number of swaps
        	        
        		lw $t7, 0($s6) # copying contents from the parent ADDRESS. NOT. INDEX!!!!!!
            		lh $t8, 4($s6) 
            		lh $t9, 6($s6)
            
            		# copying child to parent 
            		move $a0, $s4  # src (largest child)  
            		move $a1, $s6  # dest (parent)
            		li $a2, 8   # number of bytes we want to copy
            
            		jal memcpy
            
            		sw $t7, 0($s4) # storing contents of the parent into largest child node
           		sh $t8, 4($s4)
            		sh $t9, 6($s4)
            
        		move $s5, $s3 # move largest node index to parent "s5" index 
        		move $s6, $s4 # move largest node address to parent address
        	
        		j max_heapify_loop
        
        heapify_down_success:
            addi $s0, $s0, -4 # this was incremented before to skip the size and max_size
            
            move $v0, $s7 # returns the number of swaps that were needed for this
            
            lw $ra, 0($sp)
            lw $s0, 4($sp)
            lw $s1, 8($sp)
            lw $s2, 12($sp)
            lw $s3, 16($sp) 
            lw $s4, 20($sp) 
            lw $s5, 24($sp) 
            lw $s6, 28($sp) 
            lw $t7, 32($sp)
            lw $t8, 36($sp)
            lw $t9, 40($sp)
            
            addi $sp, $sp, 44
            
            jr $ra
        
        heapify_down_fail:
                
        	li $v0, -1
            
                lw $ra, 0($sp)
                lw $s0, 4($sp)
                lw $s1, 8($sp)
                lw $s2, 12($sp)
                lw $s3, 16($sp) 
                lw $s4, 20($sp) 
                lw $s5, 24($sp) 
                lw $s6, 28($sp) 
                lw $t7, 32($sp)
                lw $t8, 36($sp)
                lw $t9, 40($sp)
                
                addi $sp, $sp, 44
            
                jr $ra
	
# Part VII
dequeue:
	addi $sp, $sp, -16
        sw $ra, 0($sp)
        sw $s0, 4($sp) # queue struct
        sw $s1, 8($sp) # dequeued_customer address
        sw $s2, 12($sp) # size of queue
        
        move $s0, $a0 # copy CustomerQueue struct
        move $s1, $a1 # copy address of dequeued customer
        
        lhu $s2, 0($s0) # size of queue
        
        blez $s2, dequeue_fail # -1 if size = 0 cause there's nothing to dequeue
        
        addi $s0, $s0, 4 
        
        # copy customer[0] into dequeued_customer address
        move $a0, $s0 # src
        move $a1, $s1 #dest
        li $a2, 8  # number of bytes to copy
        jal memcpy 
        
        addi $t9, $s2, -1  # getting [size - 1]
        li $t0, 8
        mul $t1, $t0, $t9 # [size-1] * 8
        add $t2, $t1, $s0  # address of customers[size - 1]
        
        # copy customers[queue.size - 1] to customers[0]
        move $a0, $t2 # src
        move $a1, $s0 # dest
        li $a2, 8  # number of bytes to copy
        jal memcpy
        
        addi $s0, $s0, -4
        
        # decrement the size of the queue by 1
        lhu $s2, 0($s0) # size of queue
        addi $s2, $s2, -1 # decrement the size of the queue
        sh $s2, 0($s0) # put it back into the queue
        
        move $a0, $s0 #queue struct
        li $a1, 0 # index
        jal heapify_down
        
        j dequeue_success
        
        dequeue_success:
        	move $v0, $s2
            
                lw $ra, 0($sp)
                lw $s0, 4($sp)
                lw $s1, 8($sp)
                lw $s2, 12($sp)
                
                addi $sp, $sp, 16
            
                jr $ra
        
        dequeue_fail:
        	li $v0, -1
            
                lw $ra, 0($sp)
                lw $s0, 4($sp)
                lw $s1, 8($sp)
                lw $s2, 12($sp)
                
                addi $sp, $sp, 16
            
                jr $ra
        
# Part VIII
build_heap:
	addi $sp, $sp, -16
        sw $ra, 0($sp)
        sw $s0, 4($sp) # queue struct
        sw $s1, 8($sp) # sum of return values from heapify_down (aka res)
        sw $s2, 12($sp) # index (starts at queue.size - 1) / 3
        
        move $s0, $a0 # copy CustomerQueue struct
        li $s1, 0 # res
        
        lhu $t0, 0($s0) # size of queue
        beqz $t0, build_heap_success
        
        addi $t0, $t0, -1  # (queue.size - 1) / 3
        li $t1, 3
        div $t0, $t1
        mflo $t0
        
        move $s2, $t0  # index 
        
        build_heap_loop:
        	# call to heapify_down(queue, i)
        	move $a0, $s0  # queue struct
        	move $a1, $s2  # index 
        	jal heapify_down
        	
        	add $s1, $s1, $v0 # res += heapify_down(queue, i)
        	
        	addi $s2, $s2, -1 # decrement the index to 0
        	
        	bltz $s2, build_heap_success  
        	j build_heap_loop
        	
        build_heap_success:
        	move $v0, $s1
        	
        	lw $ra, 0($sp)
       		lw $s0, 4($sp) # queue struct
        	lw $s1, 8($sp) # sum of return values from heapify_down
        	lw $s2, 12($sp) # 
        	
        	addi $sp, $sp, 16
        	
        	jr $ra

# Part IX
increment_time:
	#a0 has the queue struct
	#a1 has the delta_mins
	#a2 has the fame_level
	
	addi $sp, $sp, -20
        sw $ra, 0($sp)
        sw $s0, 4($sp) # queue struct
        sw $s1, 8($sp) # delta_mins - integer
        sw $s2, 12($sp) #  fame_level - integer
        sw $s3, 16($sp) #  average waiting time for the customers in the queue
        
        move $s0, $a0 # copy CustomerQueue struct
        move $s1, $a1 # copy delta_mins
        move $s2, $a2 # copy fame_level
        li $s3, -1 # 
        
        lhu $t0, 0($s0) # get size
        
        blez $t0, increment_time_done
        blez $s1, increment_time_done
        blez $s2, increment_time_done
        
        li $t1, 0
	li $t2, 8
	li $t5, 0 # total wait time after incrementing

	addi $s0, $s0, 4

	increment_queue_loop:
        	mul $t3, $t1, $t2
        	add $t4, $s0, $t3 # address of customer
        
        	lh $t8, 4($t4) # fame
        	bge $t8, $s2, continue_increment # if fame >= fame_level, skip over fame increment
        	add $t8, $t8, $s1 # otherwise, increment curr fame by delta mins
        	sh $t8, 4($t4) 
        	
        	continue_increment:
        	lh $t9, 6($t4) # wait_time
        	add $t9, $t9, $s1 # increment curr wait_time by delta mins
        	sh $t9, 6($t4)
        	
        	add $t5, $t5, $t9 # increment total wait_time
        	
        	addi $t1, $t1, 1
        	beq $t1, $t0, increment_reheapify
        
        	j increment_queue_loop
        	
        increment_reheapify:
                addi $s0, $s0, -4
                div $t5, $t0 # divide total incremented wait_time by # of customers
                mflo $s3
        	move $a0, $s0
        	jal build_heap
        	
	increment_time_done:
		move $v0, $s3
        	
        	lw $ra, 0($sp)
       		lw $s0, 4($sp) # queue struct
        	lw $s1, 8($sp) # delta_mins - integer
        	lw $s2, 12($sp) # fame_level - integer
        	lw $s3, 16($sp) # average waiting time for the customers in the queue
        	
        	addi $sp, $sp, 20
        	
        	jr $ra
	
# Part X
admit_customers:
	addi $sp, $sp, -28
        sw $ra, 0($sp)
        sw $s0, 4($sp) # queue struct
        sw $s1, 8($sp) # max_admits
        sw $s2, 12($sp) # admitted array
        sw $s3, 16($sp) # number of customers admitted to the restaurant
        sw $s4, 20($sp) # counter starting at 0 for the admitted array loop
        sw $s5, 24($sp) # size of the queue
        
        move $s0, $a0 # copy CustomerQueue struct
        move $s1, $a1 # copy max_admits
        move $s2, $a2 # copy admitted array
        li $s3, -1 # return value if max_admits <= 0 or queue is empty
        li $s4, 0 # counter until max_admits
        
        blez $s1, admit_customers_done
        lhu $t0, 0($s0) # size
        blez $t0, admit_customers_done
        
        move $s5, $t0 # size
        
        blt $s5, $s1, fill_admitted_array_until_size_init # if size < max admits, fill until size
        #otherwise, fill the admitted until maxadmit
        move $s3, $s1
        
        fill_admitted_array_until_maxadmit:
        	li $t1, 8
        	mul $t1, $t1, $s4 # 8 * counter for the cell position in admitted  
        	add $t2, $t1, $s2 # admitted[i]
        	
        	move $a0, $s0  # queue that points to the beginning (dequeueing customers[0] 
        	move $a1, $t2  # dequeued customer (admitted)
        	jal dequeue
        	
        	addi $s4, $s4, 1
        	beq $s4, $s1, admit_customers_done  # if it's equal to max_admits
        	
        	j fill_admitted_array_until_maxadmit
        
        fill_admitted_array_until_size_init:
        	move $s3, $s5
        
        fill_admitted_array_until_size:
        	li $t1, 8
        	mul $t1, $t1, $s4 # 8 * counter for the cell position in admitted  
        	add $t2, $t1, $s2 # admitted[i]
        	
        	move $a0, $s0  # queue that points to the beginning (dequeueing customers[0] 
        	move $a1, $t2  # dequeued customer (admitted)
        	jal dequeue
        	
        	addi $s4, $s4, 1
        	beq $s4, $s5, admit_customers_done  # if it's equal to max_admits
        	
        	j fill_admitted_array_until_size
        	
	admit_customers_done:
	        move $v0, $s3 # return value (number of customers admitted or -1)
		
        	lw $ra, 0($sp)
        	lw $s0, 4($sp) # queue struct
        	lw $s1, 8($sp) # max_admits
        	lw $s2, 12($sp) # admitted array
        	lw $s3, 16($sp) #  
        	lw $s4, 20($sp)
        	lw $s5, 24($sp) # size of the queue
        	
        	addi $sp, $sp, 28
		jr $ra

# Part XI
seat_customers:
	#a0 contains the admitted array
	#a1 contains the number of admitted
	#a2 contains the budget
	
	li $t0, 1 # also for the "and" operation
	sllv $t1, $t0, $a1 # 2^ num_admitted
	li $t2, 0 # (i) - number of combinations < 2^num_admitted  
	
	li $s3, 0 # maxCustomers
	li $s4, 0 # maxFame
	
	blez $a1, number_combinations_fail
	blez $a2, number_combinations_fail
	
	# two for-loops
	number_combinations_loop:
	
	li $t3, 1 # (maskbit) this is what we'll keep doing sll on to extract fame & weight
	li $t4, 0 # shiftamount (also represents the customer in the queue) [0 < t4 < num_admitted]
	li $t5, 0 # currTotalFame
	li $t6, 0 # currTotalWeight
	
		extract_weights_loop:
			and $t7, $t2, $t3 # if (maskbit & i == 1)
			srlv $t8, $t7, $t4 # supposed to be a 1
			li $t9, 1
			
			beq $t8, $t9, extract_weight_and_fame # if (maskbit & i == 1, extract weight and fame)
			
			j continue_without_extracting # otherwise, don't extract and keep looping
			
			extract_weight_and_fame:
			# get weight and fame
			li $t7, 8
			
			mul $t8, $t4, $t7 # shiftamt * 8 
			add $s7, $a0, $t8 # address of customer at shiftamount
			
			lh $t7, 4($s7) # fame
			lh $t8, 6($s7) # wait time
			
			add $t5, $t5, $t7 # currTotalFame
			add $t6, $t6, $t8 # currTotalWeight
			
			continue_without_extracting:
			
			sll $t3, $t3, 1 # maskbit = maskbit * 2 (001 -> 010)
			addi $t4, $t4, 1 # add shiftamount
			beq $t4, $a1, extract_weights_loop_done # (if shiftamount >= numAdmitted, i++)
			
			blt $t4, $a1, extract_weights_loop
			
		extract_weights_loop_done:
		
			addi $t2, $t2, 1
			bgt $t2, $t1, number_combinations_success # when i > 2^num_admitted, terminate
			
			bgt $t6, $a2, number_combinations_loop # if total weight > budget, i++ and continue
			
			blt $t5, $s4, number_combinations_loop # if currentTotalFame < maxFame, keep looping
			
			move $s4, $t5 # otherwise if currentTotalFame >= maxFame, maxFame = currentTotalFame
			move $s3, $t2 # customers that were seated 
			
			j number_combinations_loop
			
	number_combinations_success:
		addi $s3, $s3, -1
		move $v0, $s3 # customer encoding (who is seated)
		move $v1, $s4 # max Fame
		jr $ra
	
	number_combinations_fail:
		li $v0, -1
		li $v1, -1
		jr $ra
	
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
#################### DO NOT CREATE A .data SECTION ####################
