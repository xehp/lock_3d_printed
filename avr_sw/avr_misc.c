/*
avr_misc.c 

provide functions to set up hardware

Copyright 2005 EIT European Infotech AB www.eit.se.

This file is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

For a list ov available signals see:
http://www.nongnu.org/avr-libc/user-manual/index.html

History

2005-02-16
Created. 
Henrik Björkman

2005-02-20
Set up timer0 interrupt
Henrik Björkman

2005-02-22
Using timer1 to generate 38 MHz. 
Will need that to send IR later.
Henrik Björkman

2005-02-22
Using timer2 to get a timer with a 1 second resolution
Henrik Björkman

2005-02-22
Will try to use timer2 interrupt to
make a software uart together with timer1

2005-07-01
cleanup
Henrik

2005-07-02
Moved timer drivers to own files.
Henrik

*/

// When reading 16bit reg remember to read low byte first then high byte
// when writing write high byte first then low byte but hopefully the C compiler does this.


// includes

#include <avr/interrupt.h>
//#include <avr/signal.h>
#include <avr/pgmspace.h>
#include <avr/wdt.h>

#include "avr_cfg.h"
#include "avr_misc.h"
#include "avr_uart.h"


#if (!(defined(__AVR_ATmega8__) || defined(__AVR_ATmega88__) || defined(__AVR_ATmega168__)))
#error /* well it should work with other atmega mcus to but that is not tested. */
#endif



// local variables and defines






#ifdef DEBUG_LED_PORT

// Flash n times with the LED, just to see that CPU is running before doing anything else.
// This may be called before debug_init has been called.
int avr_debug_blink(char n)
{
 
  avr_delay_ms(200);
 
  /* INITIALIZE */

  /* set output to off */
  AVR_IO_SET_ACTIVE(DEBUG_LED, 0);

  /* enable debug LED as output */
  AVR_IO_ENABLE(DEBUG_LED);

  /* BLINK, BLINK ... */

  while (n>0) 
  {
    /* set LED on */
    AVR_IO_SET_ACTIVE(DEBUG_LED,1);

    avr_delay_ms(200);

    /* set LED off */
    AVR_IO_SET_ACTIVE(DEBUG_LED,0);

    avr_delay_ms(800);

    n--;
    
  }

  /* disable debug LED as output */
  AVR_IO_DISABLE(DEBUG_LED);


  avr_delay_ms(500);


  avr_delay_ms(500);


  return 0;
}

#endif



// This function will set CPU in idle mode, saving energy.
inline void avr_idle(void) 
{
#ifdef __AVR_ATmega8__

  // enable sleep
  MCUCR|=(1<<SE);
  
  // if needed, reduce master clock speed here
  // using XDIV register

  // if needed, turn of current for analog comparator here
    
  // set sleep mode to idle
  MCUCR&=~(7<<SM0);
  //MCUCR|=(0<<SM0);
  asm ("sleep");

  // we continue here after beeing wakened up by an interrupt.

  // reset clock speed to normal value
  // using XDIV register

  // turn on current for analog comparator here (if we turned it off)

  // disable sleep
  MCUCR&=~(1<<SE);
#elif defined (__AVR_ATmega88__) || defined (__AVR_ATmega168__) 

  
  // if needed, reduce master clock speed here
  // using XDIV register

  // if needed, turn of current for analog comparator here
    
  // set sleep mode to idle
  SMCR&=~(7<<SM0);
  //MCUCR|=(0<<SM0);


  
  SMCR|=(1<<SE); // enable sleep 
  asm ("sleep"); // Here we go to sleep
  SMCR&=~(1<<SE); // disable sleep


  // we continue here after beeing wakened up by an interrupt.

  // reset clock speed to normal value
  // using XDIV register

  // turn on current for analog comparator here (if we turned it off)


#else
#error unknown target
#endif
}






// busy-wait approximatly ms milliseconds (if function is not interrupted)
#if 1
void avr_delay_ms(int ms) 
{
  int i;
  while(ms>0)
  {
    for (i=0; i<(AVR_FOSC/6000); i++)
    {
      //asm ("nop");
      wdt_reset();
    }
    ms--;
  }
}
#else
void avr_delay_ms(int ms) 
{
  while(ms>0)
  {
    delay_us(990);
    ms--;
  }
}
#endif

void avr_delay_us(int us) 
{
  while(us>0)
  {
#if AVR_FOSC==16000000L
      asm ("nop"); 
      asm ("nop"); 
      asm ("nop"); 
      asm ("nop"); 
      asm ("nop"); 
      asm ("nop"); 
      asm ("nop"); 
      asm ("nop"); 
      asm ("nop"); 
#elif AVR_FOSC==8000000L
      asm ("nop"); 
#else
#error selected AVR_FOSC not supported by delay_us
#endif
    us--;
  }
}


// These interrupt service routines do nothing, we enabled these interrupts just to get out of low power mode when something changed

ISR(PCINT0_vect)
{

} 

ISR(PCINT1_vect)
{

} 

ISR(PCINT2_vect)
{

} 


// set up hardware (port directions, registers etc.)
// This will configure some things like interrupt and disable unused HW.
void avr_init() 
{

  // Analog comparator
  // Comment this out if there is a separate module to configure Analog comparator.
  ACSR|=1<<ACD; // disable analog comparator to save power


  // Analog to Digital converter
  // Comment this out if there is a separate module to configure ADC.
  DIDR0=0x3f; // Disable digital input buffers to save power.
  ADCSRA&=~(1<<ADEN); // Turn the ADC off


  // We want interrupt on input pin changes so that it wake up 
  // from low power mode faster, the ISR don't need to do anything.
  // Check with pin assignment in avr_cfg.h for which pins to enable.
  // If changes are made there it may need changes here also.
  // Enable Pin Change Interrupts
  PCIFR |=  (7 << PCIF0); // clear interrupt flags by writing one to them
  PCMSK0 |= (1 << PCINT0); // Enable PCINT0
  PCMSK1 |= (0x3F << PCINT8); // Enable PCINT8, PCINT9, PCINT10, PCINT11, PCINT12 & PCINT13
  PCMSK2 |= (0x7 << PCINT21); // Enable PCINT21, PCINT22 & PCINT23
  PCICR |= (7 << PCIE0); // Pin Change Interrupt Enable 0, 1 & 2


  sei(); // enable global interrupts

  
}




