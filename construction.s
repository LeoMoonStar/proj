.data

.global VGA_ADDRESS
.global BACKGROUND_HEIGHT
.global BACKGROUND_WIDTH

.equ 	GPIO_JP1,	0xFF200060         	#JP1
.equ	TIMER,0xff202000             	 #set timer address
.equ	PERIOD1,50000000             	 #set period of 1 second
.equ	PERIOD2,50000000             	 #set period of 2 second
.equ	RED_LEDS,0xff200000             #LEDR
.equ	BUTTON, 0xff200050					#push button
.equ  VGA_ADDRESS,0x08000000      #pixel buffer address
.equ BACKGROUND_HEIGHT,240
.equ BACKGROUND_WIDTH, 320

.align 1
background_image: .incbin "forProject.rgb565"

.text

.section .exceptions,"ax"
ISR:
bne r4,r0, STOP
beq r2,r0, OFF
ON:
movi r2, 0x00000000
movui	r17, %lo(PERIOD1)
stwio	r17, 8(r16)
movui	r17, %hi(PERIOD1)
stwio	r17, 12(r16)
stwio	r0, 0(r16)				#clear timer
movia r3, 0xfffffffe
stwio r3, 0(r6)
br CHANGE_MOTOR

OFF:
movi r4, 0x00000001
movi r2, 0x00000001
movui	r17, %lo(PERIOD2)
stwio	r17, 8(r16)
movui	r17, %hi(PERIOD2)
stwio	r17, 12(r16)
stwio	r0, 0(r16)				#clear timer
movi	r17, 0b0111				#initializing TIMER to interrupt, continue and start
stwio	r17, 4(r16)
movia r3, 0xfffffffc
stwio r3, 0(r6)
br CHANGE_MOTOR

STOP:
movui	r17, %lo(PERIOD2)
stwio	r17, 8(r16)
movui	r17, %hi(PERIOD2)
stwio	r17, 12(r16)
stwio	r0, 0(r16)				#clear timer
movi	r17, 0b0111				#initializing TIMER to interrupt, continue and start
stwio	r17, 4(r16)
movia r3, 0xffffffff
stwio r3, 0(r6)
movi r5, 0x00000001
br E_FINISH

CHANGE_MOTOR:
movia	r8,RED_LEDS
ldwio	et,0(r8)
xori	et,et,0x01
stwio	et,0(r8)
movi	r17, 0b0111				#initializing TIMER to interrupt, continue and start
stwio	r17, 4(r16)

movia	et,TIMER
stwio	r0,0(et)

E_FINISH:
addi	ea,ea,-4
eret




.global _start
_start:
movia r4, background_image
movi r5, BACKGROUND_WIDTH
movi r6, BACKGROUND_HEIGHT
mov r7, r0
call draw_on_vga

#start the LED setting
movia r2, RED_LEDS
movi  r3,0x00
stwio r3,0(r2)
movi r5, 0x00000000	#stop
movi r2, 0x00000001	#reverse
movi r4, 0x00000000	#reverse finish
movia r18, BUTTON


#start the LEGO motor setting
movia r6, GPIO_JP1             #r8 saves address of JP1

movia  r3, 0x07f557ff
stwio  r3, 4(r6)                #direction register
movia r3, 0xffffffff
stwio r3, 0(r6)                 #all set to off


#begin							#modify it to sensor after all
CHECK_BEGIN:
ldwio r19, 0(r18)
beq r19, r0, CHECK_BEGIN


#initial condition after begino of motors
movia r3, 0xfffffff3
stwio r3, 0(r6)



movia	r16,TIMER
#configurate timer
movui	r17, %lo(PERIOD1)
stwio	r17, 8(r16)
movui	r17, %hi(PERIOD1)
stwio	r17, 12(r16)
stwio	r0, 0(r16)				#clear timer
movi	r17, 0b0111				#initializing TIMER to interrupt, continue and start
stwio	r17, 4(r16)

movi	r17,0x01		#enable IRQ line 0
wrctl	ctl3,r17

movi	r17,0x01				#enable PIE
wrctl	ctl0,r17


END:
bne r5, r0, _start
br END
