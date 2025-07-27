/*
 * Copyright (c) 2018, Marcelo Samsoniuk
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * * Neither the name of the copyright holder nor the names of its
 *   contributors may be used to endorse or promote products derived from
 *   this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
 */

    .option pic
    .section .text
	.align	2
    .globl  _start

/*
    start:
    - read and increent thread counter
    - case not zero, jump to multi thread boot
    - otherwise continue    
*/

_start:

    /* check core id, boot only core 0 */

    la  a1,0x80000000
    lbu a2,2(a1)

_thread_lock:
    bne a2,x0,_thread_lock

/* Small delay before reading button */
#    li t0, 10000
#_delay_loop:
#    addi t0, t0, -1
#    bnez t0, _delay_loop

/* Check boot select pin @ 0x8000002A, bit 0 */
    lui     t0, 0x80000       # Load upper 20 bits of address 0x80000028 into t0
    lw      t1, 0x28(t0)      # Load word from memory address 0x80000028 into t1
    srli    t2, t1, 16        # Shift right logical by 16 bits to bring bit 16 to LSB
    andi    t2, t2, 1         # Mask LSB to isolate bit 16 value
    # Now t2 == 1 if bit 16 was set, a2 == 0 if not

    # print gpio read
    addi a0, t2, '0'          # convert to ASCII
    call _uart_putchar

    # andi a2,a2,1 # Mask LSB

    beq  t2, x0, _normal_boot   # If not pressed, jump to normal boot

/******************************
 * BOOTLOADER MODE START HERE *
 ******************************/
 /*
    uart boot hereÑ

    - get size of program
    - get bytes for program and write them to memory
*/
_uart_boot_forever:
    li a0, 'b'
    call _uart_putchar

    la a3,1024 # Program address
    li a5,8192000

uart_b0:
    # Get first byte
    addi a0,a5,0    # set timeout
    call _uart_getchar
    blt a0, x0, uart_b0
    addi t0,a0,0        # t0 = LSB

uart_b1:
    # Read second byte (MSB)
    addi a0,a5,0    # set timeout
    call _uart_getchar
    blt a0, x0, uart_b1
    addi t1,a0,0  # t1 = MSB

    slli t1, t1, 8           # shift MSB to high byte
    or t2, t0, t1            # t2 = full 16-bit counter

uart_program_rx_loop:
    
    li a0,'.' # Indicate inside loop 
    call _uart_putchar
    
    addi a0,a5,0 # Get next byte
    call _uart_getchar 

    blt a0,x0, uart_program_rx_loop # If timeout restart loop

    sb a0,0(a3)
    addi a3,a3,1

    addi t2, t2, -1
    bne t2, x0, uart_program_rx_loop

    li  a0,'b' # Indicate done rx loop
    call _uart_putchar

# go on to main

/******************************
 * NORMAL BOOT FOLLOWS HERE   *
 ******************************/
 /*
    normal boot here:

    - call main
    - set stack
    - set global pointer
    - plot boot banner
    - repeat forever
*/

_normal_boot:

/*
    RLE code start here:

    register int c,s;
    register char *p = rle_logo; // = a3
   
    while(*p)
    {
        c = *p++; // = a0
        s = *p++; // = a4
      
        while(s--) putchar(c); // uses a0, a1, a2
    }
*/

    addi a0,x0,'\n'
    call _uart_putchar

    lla a3,_rle_banner
    lla a5,_rle_dict

    lbu a4,0(a3)

    _rle_banner_loop1:

        srli a0,a4,6
        add a0,a0,a5
        lbu a0,0(a0)

        andi a4,a4,63
        addi a3,a3,1

        _rle_banner_loop2:

            call _uart_putchar
            addi a4,a4,-1

            bgt a4,x0,_rle_banner_loop2

        lbu a4,0(a3)
        bne a4,x0,_rle_banner_loop1        

    lla a3,_str_banner

    _str_banner_loop3:

    lbu a0,0(a3)
    call _uart_putchar
    addi a3,a3,1
    bne a0,x0,_str_banner_loop3

    /* RLL banner code end */

	la	sp,_stack
	la	gp,_global

    xor    a0,a0,a0 /* argc = 0 */
    xor    a1,a1,a1 /* argv = 0 */
    xor    a2,a2,a2 /* envp = 0 */

	call	main

	j	_start
    
/* 
    uart_putchar:
    
    - wait until not busy
    - a0 = char to print
    - a1 = soc.uart0.stat
    - a2 = *soc.uart0.stat
    - a0 = return the same data
*/

_uart_putchar:

    la a1,0x80000000

    _uart_putchar_busy:

        lb      a2,4(a1)
        not     a2,a2
        andi    a2,a2,1
        beq     a2,x0,_uart_putchar_busy

    sb a0,5(a1)
    li a1,'\n'

    bne a0,a1,_uart_putchar_exit

    li a0,'\r'
    j _uart_putchar

    _uart_putchar_exit:

        ret

/* 
    uart_getchar:

    - a0 = time out in loops
    - a1 = soc.uart0.stat
    - a2 = *soc.uart0.stat
    - a0 = return *soc.uart0.fifo or -1
*/

_uart_getchar:

    la  a1,0x80000000

    _uart_getchar_busy:

        beq     a0,x0,_uart_getchar_tout
        addi    a0,a0,-1

        lb      a2,4(a1)
        andi    a2,a2,2
        beq     a2,x0,_uart_getchar_busy

    lbu a0,5(a1)
    ret

    _uart_getchar_tout:

        li a0,-1
        ret

/*
    data segment here!
*/
/*
    .section .rodata
    .align   1
*/
_rle_banner:

    .byte 0x0e, 0xa0, 0xc1, 0x12, 0x9c, 0xc1, 0x4d, 0x07, 0x9a, 0xc1, 0x50 
    .byte 0x06, 0x98, 0xc1, 0x52, 0x04, 0x98, 0xc1, 0x52, 0x04, 0x98, 0xc1 
    .byte 0x52, 0x04, 0x98, 0xc1, 0x50, 0x06, 0x96, 0x02, 0xc1, 0x4d, 0x07 
    .byte 0x96, 0x04, 0xc1, 0x42, 0x10, 0x96, 0x06, 0xc1, 0x42, 0x0c, 0x98 
    .byte 0x06, 0x42, 0xc1, 0x44, 0x06, 0x9a, 0x06, 0x44, 0xc1, 0x46, 0x06 
    .byte 0x96, 0x06, 0x46, 0xc1, 0x48, 0x06, 0x92, 0x06, 0x48, 0xc1, 0x4a 
    .byte 0x06, 0x8e, 0x06, 0x4a, 0xc1, 0x4c, 0x06, 0x8a, 0x06, 0x4c, 0xc1 
    .byte 0x4e, 0x06, 0x86, 0x06, 0x4e, 0xc1, 0x50, 0x06, 0x82, 0x06, 0x50 
    .byte 0xc1, 0x52, 0x0a, 0x52, 0xc1, 0x54, 0x06, 0x54, 0xc1, 0x56, 0x02 
    .byte 0x56, 0xc2, 0x07, 0x00

_rle_dict:
    
    .byte 0x20, 0x72, 0x76, 0x0a

_str_banner:
    .string "INSTRUCTION SETS WANT TO BE FREE\n\n"
