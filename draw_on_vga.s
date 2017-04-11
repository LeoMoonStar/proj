.equ WHITE, 0xffff
.global draw_on_vga

draw_on_vga:
	#use r8 to hold the pixel buffer address

	movia r8, VGA_ADDRESS


	ldw r10, 0(sp) #pop, r10 = starty
	addi sp, sp, -4
	add r6, r10, r6 #r6 = MAX_HEIGHT + starty

	mov r11, r7 #r11 = startx
	add r5, r5, r11 #r5 = MAX_WIDTH + startx

	OUTER_FOR: #outer for loop should go through the height (y coordinate) r10:r6-1
		bge r10, r6, FINISHED_OUTER_FOR

		#using r11 as inner variable loop counter int j = r7;
		mov r11, r7
		INNER_FOR: #inner loop goes through the width (x coordinate) r7:r5-1
			bge r11, r5, FINISHED_INNER_FOR #exit the loop

			ldh r9, (r4) #load the half word out of memory (pixel value)

			#Check if drawing a character
			movia r12, DRAW_CHAR
			ldb r12, 0(r12)
			movi r13, 1
			bne r12, r13, CONTINUE

			#If drawing a character, check if pixel is green
			movia r13, 0x00000180
			bne r9, r13, CONTINUE

			#If pixel is green, ignore it as it is a part of the background
			addi r4, r4, 2
			addi r11, r11, 1

			br INNER_FOR

		CONTINUE:
			#compute the coordinate
			muli r12, r10, 1024 #1024*r10 i.e. 1024y
			muli r13, r11, 2 #2*r11 i.e. 2x
			add r12, r12, r13 #r12 = 2*r11 + 1024*r10 = 2x + 1024y
			add r12, r12, r8 #find pixel to write to (vga start address + same offset)

			sthio r9, (r12) #store the picture pixel into vga
			#go to the next picture hword
			addi r4, r4, 2
			#increment inner loop counter
			addi r11, r11, 1
			br INNER_FOR
		FINISHED_INNER_FOR:
			addi r10, r10, 1 #increment the outer loop counter
			br OUTER_FOR
	FINISHED_OUTER_FOR:

	#make sp back to what it was before
	addi sp, sp, 4
	#done
	ret
