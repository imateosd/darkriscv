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

#include <io.h>
#include <stdio.h>

int main(void)
{
    // unsigned mtvec=0;

#ifndef SMALL

    // set_mtvec(irq_handler);

    // mtvec = get_mtvec();

#endif

    /*io->irq = IRQ_TIMR; // clear interrupts
    utimers = 0;


    while(1)
    {
        if(mtvec==0)
        {
            while(1)
            {
                if(io->irq&IRQ_TIMR)
                {
                    if(!utimers--)
                    {
                        io->led++;
                        utimers=999999;
                    }
                    io->irq = IRQ_TIMR;
                }

            }
        }
    }*/

    int i,j;

    while(1)
    {
        for (i = 0; i<2000000000; i++) // 200000
        {
                if(i==1999999999)  //199999
                    io->led++;
        }
        // for (j = 0; j<2000000; j++) // 200000
        // {
        //         if(j==1999999)  //199999
        //             io->led++;
        // }
        io->i2c = 0x03030155;
        printf("i2c = %x\n",io->i2c);   
    }
}
