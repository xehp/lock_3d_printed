/*
avr_misc.h

provide functions to set up hardware

Copyright (C) 2013 Henrik Björkman www.eit.se/hb.


History

2005-02-16
Created. 
Henrik Björkman

2005-07-01
cleanup
Henrik

2013-10-26
Adapted for "motorlas" project.
Henrik

*/


#ifndef AVR_MISC_H
#define AVR_MISC_H


#ifndef NULL
#define NULL 0
#endif


// Help macros
#define AVR_GLUE(a,b) a##b
#define POWER_OF_2(x) (1<<(x))
#define POWER_MASK(x) (POWER_OF_2(x) - 1)
#define AVR_CFG_SET_BIT(port,bit,value) {if (value) {port |= _BV(bit);} else {port &= ~_BV(bit);};};
#define AVR_CFG_SET_BITS(port,bit,nBits,value) {unsigned char tmp = ((port) & (~(POWER_MASK(nBits)<<bit))); port = (tmp | ((value&POWER_MASK(nBits)) << (bit)));}




/* compatibilty macros for old style */
/* for new design instead of "sbi(DDRC,PC5);" use "DDRC|= _BV(PC5);" */
#if 0

#ifndef cbi
#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#endif

#ifndef sbi
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
#endif

#ifndef outp
#define outp(value,sfr) (_SFR_BYTE(sfr) = value)
#endif

#ifndef inp
#define inp(sfr) (_SFR_BYTE(sfr))
#endif

#endif





// These are the macros to be used by the application

// initiate a port pin as input with active pull up
#define AVR_IO_INIT(name) {AVR_GLUE(name, _PORT) |= _BV(AVR_GLUE(name, _BIT));}

// read a port pin (preferably initiated as input with active pull up)
#define AVR_IO_READ(name) ((AVR_GLUE(name, _PIN) >> AVR_GLUE(name, _BIT))&1)

// check if a port pin input is active (preferably initiated as input with active pull up)
#define AVR_IO_IS_ACTIVE(name) (AVR_IO_READ(name) == (AVR_GLUE(name, _ACTIVE_HIGH)))

// enable a port pin as output
#define AVR_IO_ENABLE(name) {AVR_GLUE(name, _DDR) |= _BV(AVR_GLUE(name, _BIT));};

// disable a port pin (previously enabled as output)
#define AVR_IO_DISABLE(name) {AVR_GLUE(name, _DDR) &= ~(_BV(AVR_GLUE(name, _BIT)));};

// write data to port pin (preferably initiated as output)
#define AVR_IO_WRITE(name, v) {AVR_CFG_SET_BIT(AVR_GLUE(name,_PORT), AVR_GLUE(name,_BIT), (v));}

// set port pin to active state (preferably initiated as output). Give: v=0 for inactive, v=1 for active
#define AVR_IO_SET_ACTIVE(name, v) {AVR_IO_WRITE(name, AVR_GLUE(name,_ACTIVE_HIGH)==(v));}



/* activate pull up on input pins (initiates input pins) */
#define KEYBOARD_IN_INIT() {KEYBOARD_IN_PORT |= (POWER_MASK(KEYBOARD_IN_NBIT) << KEYBOARD_IN_BIT);}


/* read the inputs */
#define KEYBOARD_IN_READ() ((KEYBOARD_IN_PIN>>KEYBOARD_IN_BIT) & POWER_MASK(KEYBOARD_IN_NBIT))

#define KEYBOARD_IN_IS_ACTIVE() (DOOR_CLOSED_INDICATOR_ACTIVE_HIGH ? KEYBOARD_IN_READ() : (KEYBOARD_IN_READ() ^ POWER_MASK(KEYBOARD_IN_NBIT)))



/* enable output (initiates output pins) */
#define KEYBOARD_CTR_ENABLE() KEYBOARD_CTR_DDR |= (POWER_MASK(KEYBOARD_CTR_NBIT) << (KEYBOARD_CTR_BIT));


/* disable output */
#define KEYBOARD_CTR_DISABLE() KEYBOARD_CTR_DDR &= ~(POWER_MASK(KEYBOARD_CTR_NBIT) << (KEYBOARD_CTR_BIT));


/* write to output pin */
#define KEYBOARD_CTR_WRITE(v) {AVR_CFG_SET_BITS(KEYBOARD_CTR_PORT, KEYBOARD_CTR_BIT, KEYBOARD_CTR_NBIT, (v));}

/* set output to on, give argument v as 0 or 1 only */
#define KEYBOARD_CTR_SET_ACTIVE(v) {KEYBOARD_CTR_WRITE(KEYBOARD_CTR_ACTIVE_HIGH?(v):~(v));}

















int avr_debug_blink(char n);


// set up hardware (port directions, registers etc.)
void avr_init(void);


// busy-wait ms milliseconds or microseconds (if function is not interrupted)
void avr_delay_ms(int ms);
void avr_delay_us(int us);

// Enter power save mode
inline void avr_idle(void);


#endif // AVR_H
