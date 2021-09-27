/*
avr_adc.h

provide functions to use analog to digital converter.

Copyright 2005 EIT European Infotech AB www.eit.se.

This file is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

History

2005-07-02
Created. 
Henrik
*/


#ifndef AVR_ADC_H
#define AVR_ADC_H


#define AVR_ADC_N_SAMPLES_TO_TAKE 1
#define AVR_ADC_N_CHANNELS_TO_SAMPLE 2


// set up hardware (port directions, registers etc.)
void AVR_ADC_init(void);

void AVR_ADC_startSampling(void);

void AVR_ADC_tick(void);

char AVR_ADC_isready(void);

int AVR_ADC_getSample(unsigned char channel, unsigned char index);

char AVR_ADC_isError(void);

#endif
