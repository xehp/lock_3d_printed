/*
avr_cfg.h

provide functions to set up hardware

Copyright (C) 2013 Henrik Björkman www.eit.se/hb.


History

2005-03-23
Created by Henrik Björkman

2013-10-26
Adapted for "motorlas" project.
Henrik

*/


#ifndef AVR_CFG_H
#define AVR_CFG_H


#define AVR_FOSC 16000000L

#define UART_BAUDRATE 19200





// Here specify on which ports and pins each input or output is located
// These are intended to be used internally in this file or in avr_misc.h.
// The macros to be used by the application are further down or in avr_misc.h.


/*

Some ports are used in HW:


1  PC6 (PCINT14/RESET)      reset (HW)
2  PD0 (PCINT16/RXD)        serial port (HW)
3  PD1 (PCINT17/TXD)        -"-
4  PD2 (PCINT18/INT0)       Keyboard ctrl
5  PD3 (PCINT19/OC2B/INT1)  -"-
6  PD4 (PCINT20/XCK/T0)     -"-
7  VCC                      5V
8  GND                      GND
9  PB6 (PCINT6/XTAL1/TOSC1) 16 MHz Resonator (HW)
10 PB7 (PCINT7/XTAL2/TOSC2) -"-
11 PD5 (PCINT21/OC0B/T1)    Block retracted
12 PD6 (PCINT22/OC0A/AIN0)  Block extended
13 PD7 (PCINT23/AIN1)       Door closed indicator
14 PB0 (PCINT0/CLKO/ICP1)   Open button

15 PB1 (OC1A/PCINT1)        PWM (sound if any)
16 PB2 (SS/OC1B/PCINT2)     Status LED
17 PB3 (MOSI/OC2A/PCINT3)   Motor ctr
18 PB4 (MISO/PCINT4)        debug LED
19 PB5 (SCK/PCINT5)         Motor ctr
20 AVCC                     Connected to VCC alias 5V
21 AREF                     To be coupled to GND via capacitor
22 GND                      GND
23 PC0 (ADC0/PCINT8)        Not used  (Power supply measurement perhaps?)
24 PC1 (ADC1/PCINT9)        -"-
25 PC2 (ADC2/PCINT10)       Keyboard in
26 PC3 (ADC3/PCINT11)       -"-
27 PC4 (ADC4/SDA/PCINT12)   -"-
28 PC5 (ADC5/SCL/PCINT13)   -"-



If reassigning the pins consider the "Enable Pin Change Interrupt" in method "avr_init()".

*/




// The debug LED is used to show that the CPU is running ok, it will be toggled by interrupt routine (probably its tmr2).
// The following macros are used to tell on which pin it is connected and if its active high or low.

// Debug LED is an output
#define DEBUG_LED_DDR DDRB
#define DEBUG_LED_PORT PORTB
#define DEBUG_LED_PIN PINB
#define DEBUG_LED_BIT PB4
#define DEBUG_LED_ACTIVE_HIGH 0

// Status LED is an output
#define STATUS_LED_DDR DDRB
#define STATUS_LED_PORT PORTB
#define STATUS_LED_PIN PINB
#define STATUS_LED_BIT PB2
#define STATUS_LED_ACTIVE_HIGH 1


/* ACTIVE_HIGH: 0 for active low, 1 for active high */

// open button is an input
#define OPEN_BUTTON_DDR DDRB
#define OPEN_BUTTON_PORT PORTB
#define OPEN_BUTTON_PIN PINB
#define OPEN_BUTTON_BIT PB0
#define OPEN_BUTTON_ACTIVE_HIGH 0

// block retracted is an input
#define BLOCK_RETRACTED_DDR DDRD
#define BLOCK_RETRACTED_PORT PORTD
#define BLOCK_RETRACTED_PIN PIND
#define BLOCK_RETRACTED_BIT PD5
#define BLOCK_RETRACTED_ACTIVE_HIGH 0

// block extended is an input
#define BLOCK_EXTENDED_DDR DDRD
#define BLOCK_EXTENDED_PORT PORTD
#define BLOCK_EXTENDED_PIN PIND
#define BLOCK_EXTENDED_BIT PD6
#define BLOCK_EXTENDED_ACTIVE_HIGH 1

// door closed is an input
#define DOOR_CLOSED_INDICATOR_DDR DDRD
#define DOOR_CLOSED_INDICATOR_PORT PORTD
#define DOOR_CLOSED_INDICATOR_PIN PIND
#define DOOR_CLOSED_INDICATOR_BIT PD7
#define DOOR_CLOSED_INDICATOR_ACTIVE_HIGH 0

// Motor control 1 is an output
#define MOTOR_CTRL1_DDR DDRB
#define MOTOR_CTRL1_PORT PORTB
#define MOTOR_CTRL1_PIN PINB
#define MOTOR_CTRL1_BIT PB3
#define MOTOR_CTRL1_ACTIVE_HIGH 0

// Motor control 2 is an output
#define MOTOR_CTRL2_DDR DDRB
#define MOTOR_CTRL2_PORT PORTB
#define MOTOR_CTRL2_PIN PINB
#define MOTOR_CTRL2_BIT PB5
#define MOTOR_CTRL2_ACTIVE_HIGH 0

// Keyboard needs 3 pins for control, output
// pins must be consecutive after KEYBOARD_CTR_NBIT
#define KEYBOARD_CTR_DDR DDRD
#define KEYBOARD_CTR_PORT PORTD
#define KEYBOARD_CTR_PIN PIND
#define KEYBOARD_CTR_BIT PD2
#define KEYBOARD_CTR_NBIT 3
#define KEYBOARD_CTR_ACTIVE_HIGH 0

// Keyboard needs 4 pins for input, 
// pins must be consecutive after KEYBOARD_IN_NBIT
#define KEYBOARD_IN_DDR DDRC  
#define KEYBOARD_IN_PORT PORTC  
#define KEYBOARD_IN_PIN PINC  
#define KEYBOARD_IN_BIT PC2  
#define KEYBOARD_IN_NBIT 4
#define KEYBOARD_IN_ACTIVE_HIGH 0  



// power fail indication
#define PWR0_IND_DDR DDRC
#define PWR0_IND_PORT PORTC
#define PWR0_IND_PIN PINC
#define PWR0_IND_BIT PC0
#define PWR0_IND_ACTIVE_HIGH 0

/*
#define PWR1_IND_DDR DDRC
#define PWR1_IND_PORT PORTC
#define PWR1_IND_PIN PINC
#define PWR1_IND_BIT PC1
#define PWR1_IND_ACTIVE_HIGH 0
*/

#endif
