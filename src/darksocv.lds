/* Copyright (c) 2018, Marcelo Samsoniuk
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

/*
    Memory Architectures:

	- Harvard: separate instruction (ROM) and data (RAM), has the
	  advantage that is possible make the ROM memory readonly, in a way
	  that bugs in the code cannot destruct the code.  Also, the use of
	  separate ROM and RAM makes possible share the dual-port ROM and/or
	  RAM between two cores.

	- Von Neumann: unified instruction and data in a single memory
	  (MEM), has the advantage that the .text and .data are contigous
	  and without gaps, which means that the memory is better utilized. 
	  However, as long there is no physical separation, a bug in the
	  code can destroy both data and code.  Also, as long both ports of
	  the dual-port MEM is already in use, there is no way to share to
	  more than one core.
*/

MEMORY
{
    /* 
        darkshell 
    */
    /*
    IO  (rw!x) : ORIGIN = 0x80000000, LENGTH = 0x14
    */    
#if SMALL

    #if HARVARD
        ROM (x!rw) : ORIGIN = 0x00000000, LENGTH = 0x2000
        RAM (rw!x) : ORIGIN = 0x00002000, LENGTH = 0x2000
    #else
        MEM (rwx)  : ORIGIN = 0x00000000, LENGTH = 0x1000
    #endif

#else

    /* 
        coremark 

        Set MLEN in rtl/config.vh:
             HARVARD:    14
            !HARVARD:    15
    */
    
    #if HARVARD
        ROM (x!rw) : ORIGIN = 0x00000000, LENGTH = 0x4000
        RAM (rw!x) : ORIGIN = 0x00004000, LENGTH = 0x4000
    #else
        MEM (rwx)  : ORIGIN = 0x00000000, LENGTH = 0x8000
    #endif
#endif
}

SECTIONS
{
    .text :
    {
#if HARVARD
        *boot*.o(.text)
#else
        *boot*.o(.text)
        *boot*.o(.rodata)
#endif

        /* enable this in order to use the uart boot! */
#if !HARVARD
        . = 1024;
#endif
        _text = .;
        *(.text*)
        _etext = .;
#if HARVARD
    } > ROM
#else
    } > MEM
#endif
    .data :
    {
#if HARVARD
        *boot*.o(.rodata)
#endif
        _data = .;
        *(.rodata*)
        *(.data*)
        _global = . + 0x800;
        *(.sbss*)    
        *(.bss*)
        *(.sdata*)
        *(.*)
	    _edata = .;

#if HARVARD
    } > RAM

   PROVIDE ( _stack = ORIGIN(RAM) + LENGTH(RAM) );

#else
    } > MEM

   PROVIDE ( _stack = ORIGIN(MEM) + LENGTH(MEM) );
#endif

/*
    .io : { * /io.o(COMMON) } > IO
*/

}
