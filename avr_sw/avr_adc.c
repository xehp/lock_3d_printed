/*
avr_adc.c 

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

For a list of available signals see:
http://www.nongnu.org/avr-libc/user-manual/index.html

History

2005-07-02
Created. 
Henrik Björkman

*/

// When reading 16bit reg remember to read low byte first then high byte
// when writing write high byte first then low byte but hopefully the C compiler does this.


// includes

#include <avr/interrupt.h>
#include <avr/pgmspace.h>

#include "avr_cfg.h"
#include "avr_misc.h"
#include "avr_adc.h"

// local variables and defines







// Store samples for a channel in this struct
typedef struct avr_adc_samples
{
  int sample[AVR_ADC_N_SAMPLES_TO_TAKE];
} avr_adc_samples;


static volatile avr_adc_samples result[AVR_ADC_N_CHANNELS_TO_SAMPLE]; // Store results for each channel in this array.

static volatile unsigned char avr_adc_channel=AVR_ADC_N_CHANNELS_TO_SAMPLE;  // This is the channel currently being converted. 
static volatile unsigned char avr_adc_counter=0;
static volatile unsigned char avr_adc_notReadyErrorCounter=0;




static inline void AVR_ADC_setChannelAndStartConversion(unsigned char channel) 
{
  // Set the ADMUX to channel
  ADMUX&=(unsigned char)~(0xf<<MUX0);
  ADMUX|=(unsigned char)((channel&0xf)<<MUX0);

  // Start conversion
  ADCSRA|=(1<<ADSC);  
}


// This is called when a conversion is compleated. 
SIGNAL(ADC_vect) // old name SIG_ADC
{
  int i;

  // get reasult from ADC
  // ADCL must be read first and then ADCH
  i=ADCL;
  i|=(ADCH<<8);

  // The result is now in variable i.

  // store result
  result[avr_adc_counter].sample[avr_adc_channel]=i;

  // get ready to convert next channel (if any)
  avr_adc_channel++;

  if (avr_adc_channel < AVR_ADC_N_CHANNELS_TO_SAMPLE)
  {
    // Start sampling next channel.
    AVR_ADC_setChannelAndStartConversion(avr_adc_channel);    
  }
  else
  {
    // All channels have been converted.

    // disable adc compleate interrupt
    ADCSRA&=~(1<<ADIE);


    // Get ready to convert next set of samples (it is started by tick).
    avr_adc_counter++;  
  } 
}


// Intended to be called from timer 2 interrupt.
// It starts a new conversion
void AVR_ADC_tick(void)
{
  if (avr_adc_channel < AVR_ADC_N_CHANNELS_TO_SAMPLE)
  {
    // This is for debugging. The prevoius convertion was not ready. timer2 is perhaps running to fast.
    avr_adc_notReadyErrorCounter++;
  }
  else
  {
    // Start with channel 0
    avr_adc_channel=0;
    
    // enable adc compleate interrupt
    ADCSRA|=(1<<ADIE);

    // Start the conversion  
    AVR_ADC_setChannelAndStartConversion(avr_adc_channel);    
  }
}


/*
static inline unsigned char sampling_channels_done(void)
{
  return avr_adc_channel>=SIZE_OF_ARRAY(result[0].sample);
}

static inline unsigned char sampling_done(void)
{
  return (sampling_channels_done()) && (avr_adc_counter>=SIZE_OF_ARRAY(result));
}
*/

void AVR_ADC_init(void)
{

  // Disable digital input buffers to save power.
  //DIDR0=0x3f;


  // ADMUX: REFS1, REFS0, ADLAR, -, MUX3, MUX2, MUX1, MUX0
  // REFS1:0 = 3 means use internal bandgap reference
  //ADMUX=(3<<REFS0);
  // REFS1:0 = 1 means use Vcc reference
  ADMUX=(1<<REFS0);
  
  // ADCSRA: ADEN, ADSC, ADFR, ADIF, ADIE, ADPS2, ADPS1, ADPS0
  // ADEN: 1 = enable ADC (The user is advised to write zero to ADEN before entering some sleep modes to avoid excessive power consumption.)
  // ADPS2:0 = 7 we assume 16MHz OSC so we need to divide with 128
  #if AVR_FOSC>25600000L
  #error AVR_FOSC to high fo ADC
  #elif AVR_FOSC>=12800000L
  ADCSRA=(1<<ADEN) | (7<<ADPS0);
  #elif AVR_FOSC>=6400000L
  ADCSRA=(1<<ADEN) | (6<<ADPS0);
  #elif AVR_FOSC>=3200000L
  ADCSRA=(1<<ADEN) | (5<<ADPS0);
  #elif AVR_FOSC>=1600000L
  ADCSRA=(1<<ADEN) | (4<<ADPS0);
  #elif AVR_FOSC>=800000L
  ADCSRA=(1<<ADEN) | (3<<ADPS0);
  #elif AVR_FOSC>=400000L
  ADCSRA=(1<<ADEN) | (2<<ADPS0);
  #elif AVR_FOSC>=200000L
  ADCSRA=(1<<ADEN) | (1<<ADPS0);
  #elif AVR_FOSC>=50000L
  ADCSRA=(1<<ADEN) | (0<<ADPS0);
  #else
  #error AVR_FOSC to low for ADC
  #endif

}




void AVR_ADC_startSampling(void)
{
  avr_adc_counter=0;
  avr_adc_channel = 0xFF; // Not to zero, AVR_ADC_tick will set it to zero.
  avr_adc_notReadyErrorCounter=0;

  // If only one sample per channel is needed then timer2 is not needed.
  // We can start convertion by calling AVR_ADC_tick here. 
  // If more then one sample per channel is needed then remove the call below
  // and setup timer2 to do it.
  if (AVR_ADC_N_SAMPLES_TO_TAKE==1)
  {
    AVR_ADC_tick();
  }
}


// Returns true if the requested number of samples are ready.
char AVR_ADC_isready(void) 
{
  return (avr_adc_counter==AVR_ADC_N_SAMPLES_TO_TAKE);
}


int AVR_ADC_getSample(unsigned char channel, unsigned char index)
{
  return result[channel].sample[index];
} 


char AVR_ADC_isError(void)
{
  return avr_adc_notReadyErrorCounter;
}
 


