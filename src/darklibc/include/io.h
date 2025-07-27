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

#ifndef __IO__
#define __IO__

extern volatile int utimers; // microsecond timer

struct DARKIO {

    unsigned char board_id; // 00
    unsigned char board_cm; // 01
    unsigned char core_id;  // 02
    unsigned char irq;      // 03

    struct DARKUART {
        
        unsigned char  stat; // 04 
        unsigned char  fifo; // 05
        unsigned short baud; // 06/07

    } uart;

    unsigned short led;     // 08/09
    unsigned short gpio;    // 0a/0b

    unsigned int timer;     // 0c/0d/0e/0f
    unsigned int timeus;    // 10/11/12/13

    unsigned int spi;       // 14/15/16/17
    unsigned int i2c_data;  // 18/19/1a/1b
    unsigned int i2c_ctrl;  // 1c/1d/1e/1f

    unsigned short gpio_ctrl;     // 20/21
    unsigned short gpio_function; // 22/23

    unsigned int pwm_control; // 24/25/26/27

    unsigned short switches; // 28/29
    unsigned short buttons;  // 2a/2b

    unsigned int display_control; // 2c/2d/2e/2f
};

extern volatile struct DARKIO *io;

extern char *board_name(int);

#ifdef __RISCV__
#define kmem 0
#else
extern unsigned char kmem[8192];
#endif

#define IRQ_TIMR 0x80
#define IRQ_UART 0x02

int  check4rv32i(void);
void set_mtvec(void (*f)(void));
void set_mepc(void (*f)(void));
void set_mie(int);
int  get_mtvec(void);
int  get_mepc(void);
int  get_mie(void);
void banner(void);

__attribute__ ((interrupt ("machine"))) void irq_handler(void);

extern unsigned _text;
extern unsigned _data;
extern unsigned _etext; 
extern unsigned _edata; 
extern unsigned _stack;

#endif
