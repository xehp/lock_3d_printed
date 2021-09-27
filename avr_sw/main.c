/*
main.c

Henriks AVR application
Copyright Henrik Bjorkman www.eit.se/hb 2005
All rights reserved etc etc...

For hardware see: 
H:\d\eget\projects\inteligent_electronic_thermostat\hw\0.1


History

2005-02-14
want to use serial port. Have adapted some code I found
at http://www.lka.ch/projects/avr/
Henrik Bjorkman

2005-02-20
Will try to interpret some commands
Henrik

*/


#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/pgmspace.h>
#include <avr/wdt.h>

#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "avr_cfg.h"
#include "avr_misc.h"
#include "avr_uart.h"
#include "avr_tmr0.h"
#include "avr_adc.h"
#include "version.h"


// Comment or uncomment this macro depending on preference.
#define UNLOCK_AT_POWER_LOSS


#define MOTOR_RESET_STATE 0
#define MOTOR_LOCKED_STATE 1
#define MOTOR_UNLOCKING_STATE 2
#define MOTOR_UNLOCKED_STATE 7
#define MOTOR_OPEN_STATE 3
#define MOTOR_LOCKING_STATE 4
#define MOTOR_ERROR_1_STATE 5
#define MOTOR_ERROR_2_STATE 6
#define MOTOR_LOW_POWER_STATE 8

#define MOTOR_OPEN 1
#define MOTOR_CLOSE -1
#define MOTOR_IDLE 0

#define CODE_MOTOR_LOCKED_STATE 0
#define CODE_ENTER_STATE 1
#define CODE_WRONG_CODE_STATE 2

#define MOTOR_TIMEOUT_WAITING_FOR_CLOSED (600*AVR_TMR0_TICKS_PER_SEC())
#define MOTOR_LOCK_AGAIN_TIMEOUT (30*AVR_TMR0_TICKS_PER_SEC())
#define MOTOR_RUNNING_TIMEOUT (5*AVR_TMR0_TICKS_PER_SEC())
#define MOTOR_MINIMUM_RUN_TIME (AVR_TMR0_TICKS_PER_SEC()/2)


int mainTicks=0;
int mainSecTimer=0;
int mainCounter=0;
int mainSecondCounter=0;
long mainTicksLong=0;

unsigned char motorlasState=MOTOR_RESET_STATE;
long motorlasStateTimeLong=0;

#define KEYBOARD_SAME 8

unsigned char keyboard_ctrl=0;
//int keyboardTime=0;
//char keboardPrevChar=0;
int keyboardChar=-1;
char keboardPrevInMask=0xff;
char keyboardSameCount=0;
char keyboardState=0;


// Use only 0-9 and '#'. The '*' char is used for reset. Change CODE_LEN also if the length of this is changed.
const char* code1 = "2948";    
const char* code2 = "787000"; 


#define CODE_LEN 8            // Shall be same or larger then number of digits in code. 
char codeBuffer[CODE_LEN];
char codeCounter=0;
int codeTimeS=0;
char motorlasCodeOk=0;
//char codeLen=0;
char codeState=0;
char codeClose=0;

// This is counted up each time a key is pressed.
// It is counted down with one per second.
// If it is more than allowed then no code is accepted for a while.
char codeKeyPressCount=0; 

char statusLedState=0;
int statusLedTime=0;


#define POWER_OK_STATE 0
#define POWER_LOW_STATE 1
#define POWER_FAIL_STATE 2
#define POWER_HIGH_STATE 3
#define POWER_MEASURING_IDLE_STATE 0
#define POWER_MEASURING_WAIT_STATE 1

/*
20 V was measured as 0x0130
So we have 0.066V per step in ADC.
We want power fail action at 10V
*/
#define POWER_LOW_VOLTAGE 0x0098
#define POWER_HIGH_VOLTAGE 0x00a0


char powerState=POWER_OK_STATE;
char powerMeasuringState=POWER_MEASURING_IDLE_STATE;
int powerSecondCounter=0;
int powerCounter=0;
char powerMeasurementFail=0;
int powerVoltage1=0;
int powerVoltage2=0;


#define LED_FLASH_TIME (AVR_TMR0_TICKS_PER_SEC()/32)


void motorlas_init(void)
{
  // activate pull up on input pins
  AVR_IO_INIT(OPEN_BUTTON);
  AVR_IO_INIT(BLOCK_RETRACTED);
  AVR_IO_INIT(BLOCK_EXTENDED);
  AVR_IO_INIT(DOOR_CLOSED_INDICATOR);
  KEYBOARD_IN_INIT();
  //AVR_IO_INIT(PWR0_IND); // or no, don't init pullups, these shall have pull downs in HW.
  //AVR_IO_INIT(PWR1_IND);



  // enable pins as output.
  AVR_IO_SET_ACTIVE(MOTOR_CTRL1, 0);
  AVR_IO_SET_ACTIVE(MOTOR_CTRL2, 0);
  AVR_IO_ENABLE(MOTOR_CTRL1);
  AVR_IO_ENABLE(MOTOR_CTRL2);

  KEYBOARD_CTR_SET_ACTIVE(0x7);
  KEYBOARD_CTR_ENABLE();

  AVR_IO_SET_ACTIVE(STATUS_LED, 0);
  AVR_IO_ENABLE(STATUS_LED);

  codeBuffer[sizeof(codeBuffer)-1]=0;
  //codeLen=strlen(code);

}


char encodeHexDigit(char d)
{
  if ((d<0) || (d>15))
  {
    return('?');
  }
  else if (d<10)
  {
    return(d+'0');
  }
  return(d-10+'a');
}


void hPrintln(const char* str)
{
  while(*str!=0)
  {
    uart_putchar(*str);
    ++str;
  }
  uart_putchar('\r');
  uart_putchar('\n');
}

char *hStrcpy(char* dst, const char* src)
{
  while(*src!=0)
  {
    *dst=*src;
    ++dst;
    ++src;
  }
  *dst=0;
  return dst;
}

char *h4bitToHex(char* dst, char d)
{
  *dst=encodeHexDigit(d&0xf);
  ++dst;
  return dst;
}

char *h8bitToHex(char* dst, char d)
{
  dst=h4bitToHex(dst, d>>4);
  dst=h4bitToHex(dst, d&0xF);
  return dst;
}

char *h16bitToHex(char* dst, int d)
{
  dst=h8bitToHex(dst, (d>>8));
  dst=h8bitToHex(dst, d&0xFF);
  return dst;
}



char isPowerOK(void)
{
  return (powerState==POWER_OK_STATE) || (powerState==POWER_LOW_STATE);
}




void powerInit(void)
{
  AVR_ADC_init();
  powerSecondCounter=mainSecondCounter;
}



// Don't give a long string in msg, it will overwrite the buffer.
void powerPrint(const char* msg, int voltage)
{
     char tmp[80];
     char *ptr=tmp;
     ptr=hStrcpy(ptr, "power: ");
     ptr=h16bitToHex(ptr, mainSecondCounter);
     ptr=hStrcpy(ptr, " ");
     ptr=hStrcpy(ptr, msg);
     ptr=hStrcpy(ptr, " ");
     ptr=h16bitToHex(ptr, voltage);
     *ptr=0;
     hPrintln(tmp);
}

void powerStateProcess(int voltage)
{
    switch (powerState)
    {
      default:
      case POWER_OK_STATE:
      {
        if (voltage<POWER_LOW_VOLTAGE)
        {
          powerPrint("low", voltage);
          powerState=POWER_LOW_STATE;
        }
        break;
      }

      case POWER_LOW_STATE:
      {
        if (voltage<POWER_LOW_VOLTAGE)
        {
           powerPrint("lost", voltage);
           powerState=POWER_FAIL_STATE;
        }
        else
        {
           powerPrint("ok", voltage);
           powerState=POWER_OK_STATE;
        }
        break;
      }

      case POWER_FAIL_STATE:
      {
        if (voltage>POWER_HIGH_VOLTAGE)
        {
           powerPrint("high", voltage);
           powerState=POWER_HIGH_STATE;
        }
        break;
      }

      case POWER_HIGH_STATE:
      {
        if (voltage>POWER_HIGH_VOLTAGE)
        {
           powerPrint("restored", voltage);
           powerState=POWER_OK_STATE;
        }
	else
	{
           powerPrint("nok", voltage);
           powerState=POWER_FAIL_STATE;
	}
        break;
      }

    }         

}


void powerProcess(void)
{
    switch (powerMeasuringState)
    {
      default:
      case POWER_MEASURING_IDLE_STATE:
      {
        if (powerSecondCounter != mainSecondCounter)
        {
           powerSecondCounter=mainSecondCounter;
           powerMeasuringState=POWER_MEASURING_WAIT_STATE;
           AVR_ADC_startSampling();
        }
        break;
      }

      case POWER_MEASURING_WAIT_STATE:
      {
        if (AVR_ADC_isError())
        {
          //uart_print_P(".\r\n");
          powerMeasurementFail++;
          powerMeasuringState=POWER_MEASURING_IDLE_STATE;
	}
        else if (AVR_ADC_isready())
        {
          powerVoltage1=AVR_ADC_getSample(0, 0);
          powerVoltage2=AVR_ADC_getSample(1, 0);
          /*
          char tmp[80];
          char *ptr=tmp;
          char i=0;
          ptr=hStrcpy(ptr, "Power:");
          for (i=0;i<AVR_ADC_N_CHANNELS_TO_SAMPLE;++i)
          {
            int d=AVR_ADC_getSample(i, 0);
            ptr=hStrcpy(ptr, " ");
            ptr=h16bitToHex(ptr, d);
          }
          *ptr=0;
          hPrintln(tmp);
          */

          powerStateProcess(powerVoltage1);
          powerMeasuringState=POWER_MEASURING_IDLE_STATE;
        }
        else
        {
           //uart_print_P(PSTR(".")); 
        }
        break;
      }

    }
}



char decodeKeyboard0(char in)
{
  switch (in)
  {
    // one key, correct mapping
    case 0x1: return '3';
    case 0x2: return '6';
    case 0x4: return '9';
    case 0x8: return '#';

    // more than one key pressed, map these to some unused keys
    case 0x0: return 'a';
    case 0x3: return 'b';
    case 0x5: return 'c';
    case 0x6: return 'd';
    case 0x7: return 'e';
    case 0x9: return 'f';
    case 0xa: return 'g';
    case 0xb: return 'h';
    case 0xc: return 'i';
    case 0xd: return 'j';
    case 0xe: return 'k';
    case 0xf: return 'l';
    default: break;
  }
  return '?';
}

char decodeKeyboard1(char in)
{
  switch (in)
  {
    // one key, correct mapping
    case 0x1: return '2';
    case 0x2: return '5';
    case 0x4: return '8';
    case 0x8: return '0';

    // more than one key pressed, map these to some unused keys
    case 0x0: return 'm';
    case 0x3: return 'n';
    case 0x5: return 'o';
    case 0x6: return 'p';
    case 0x7: return 'q';
    case 0x9: return 'r';
    case 0xa: return 's';
    case 0xb: return 't';
    case 0xc: return 'u';
    case 0xd: return 'v';
    case 0xe: return 'x';
    case 0xf: return 'y';
    default: break;
  }
  return '?';
}

char decodeKeyboard2(char in)
{
  switch (in)
  {
    // one key, correct mapping
    case 0x1: return '1';
    case 0x2: return '4';
    case 0x4: return '7';
    case 0x8: return '*';

    // more than one key pressed, map these to some unused keys
    case 0x0: return 'A';
    case 0x3: return 'B';
    case 0x5: return 'C';
    case 0x6: return 'D';
    case 0x7: return 'E';
    case 0x9: return 'F';
    case 0xa: return 'G';
    case 0xb: return 'H';
    case 0xc: return 'I';
    case 0xd: return 'J';
    case 0xe: return 'K';
    case 0xf: return 'L';

    default: break;
  }
  return '?';
}

char decodeKeyboard(char ctr, char in)
{
  switch (ctr)
  {
    case 0: return decodeKeyboard0(in);
    case 1: return decodeKeyboard1(in);
    case 2: return decodeKeyboard2(in);
    default: break;
  }
  return '?';
}


void setMotorOperation(int operation)
{
  switch(operation)
  {
    default:
    case MOTOR_IDLE:
    {
      AVR_IO_SET_ACTIVE(MOTOR_CTRL1, 0);
      AVR_IO_SET_ACTIVE(MOTOR_CTRL2, 0);
      break;
    }
    case MOTOR_OPEN:
    {
      AVR_IO_SET_ACTIVE(MOTOR_CTRL1, 1);
      AVR_IO_SET_ACTIVE(MOTOR_CTRL2, 0);
      break;
    }
    case MOTOR_CLOSE:
    {
      AVR_IO_SET_ACTIVE(MOTOR_CTRL1, 0);
      AVR_IO_SET_ACTIVE(MOTOR_CTRL2, 1);
      break;
    }
  }
}

void keyboardStateIdle(void)
{
      const char keyInMask = KEYBOARD_IN_IS_ACTIVE();

      if (keyInMask!=0)
      {
          // A key has been pressed, time to find out which.
          keyboard_ctrl=0;
          KEYBOARD_CTR_SET_ACTIVE(1<<keyboard_ctrl);
          keboardPrevInMask = 0xff;
          keyboardSameCount=0;
          keyboardState=1;

          //uart_print_P(PSTR("keyInMask ")); 
          //uart_putchar('0'+keyInMask);
          //uart_print_P(PSTR("\r\n")); 
    
      }
      else
      {
          KEYBOARD_CTR_SET_ACTIVE(0x7);
      }
}


void keyboardStateFindKey(void)
{
      const char keyInMask = KEYBOARD_IN_IS_ACTIVE();

      // is input stable?
      if (keboardPrevInMask==keyInMask)
      {
        // yes
        
        // We need a few of same in a row (to filter out noice and contact bounces)
        if (keyboardSameCount>=KEYBOARD_SAME)
        {

          // Is it zero
          if (keyInMask == 0)
          {
            // It is zero, No button in this column pressed
            keboardPrevInMask = 0xff;
            keyboardSameCount = 0;

            // Have we tested all columns
            if (keyboard_ctrl>(3-1))
            {
              // yes, we have tested all columns, go to idle
              keyboardState=0;
              KEYBOARD_CTR_SET_ACTIVE(0x7);
            }
            else
            {
              // no, Prepare to read next column of buttons
              keyboard_ctrl++;
              KEYBOARD_CTR_SET_ACTIVE(1<<keyboard_ctrl);
            }
          }
          else 
          {
            // It is not zero, decode the keyboard input
            keyboardChar = decodeKeyboard(keyboard_ctrl, keyInMask);

            // debug logging
            if (keyboardChar>=0)
            {
              uart_print_P(PSTR("keyboard: ")); 
              uart_putchar(keyboardChar);
              uart_print_P(PSTR("\r\n")); 
            }

            // go to state, wait for idle
            KEYBOARD_CTR_SET_ACTIVE(0x7);
            keyboardState=2;
            keyboardSameCount=0;
          }
        }
        else
        {
          keyboardSameCount++;
        }
      }
      else
      {
        // wait for input to stabilize
        // Remember latest input.
        keboardPrevInMask = keyInMask;
        keyboardSameCount = 0;
      }
}

void keyboardStateWaitForIdle(void)
{
    keyboardSameCount=0;

    // check if no key is active for a few samples in a row.
    while (keyboardSameCount<KEYBOARD_SAME)
    {
       const char keyInMask = KEYBOARD_IN_IS_ACTIVE();
       if (keyInMask==0)
       {
         // no key is active
         keyboardSameCount++;
       }
       else
       {
         break;
       }
    }

    if (keyboardSameCount>=3)
    {
       // no key have been pressed for a while so go to idle state.
       uart_print_P(PSTR("keyboard: release\r\n")); 
       keyboardState=0;
       KEYBOARD_CTR_SET_ACTIVE(0x7);
    }
}



void keyboardStateProcess(void)
{
    
      switch(keyboardState)
      {
        case 0:
          keyboardStateIdle();
          // no break here is intentional
        case 1:
          while(keyboardState==1)
          {
            keyboardStateFindKey();
          }
          break;
        case 2:
          keyboardStateWaitForIdle();
          break;
      }
}


int keyboardGetchar(void)
{
  int tmp=keyboardChar;

  keyboardChar=-1;
  return tmp;
}


/*
void codeTry(int ch)
{
    codeBuffer[(unsigned char)codeCounter]=ch; // store the key

    if (codeCounter >= (CODE_LEN-1))
    {
         // We have received a full code.

         // Some debug output
         uart_print_P(PSTR("code: trying "));
         int i;
         for (i=0;i<CODE_LEN;i++)
         {
            uart_putchar(codeBuffer[i]);
         }
         uart_print_P(PSTR("\r\n"));

         // compare with expected code
         if (strcmp(code, codeBuffer)==0)
         {
             // Code was ok
             uart_print_P(PSTR("code: OK\r\n"));
             motorlasCodeOk=1;
             codeTimeS=mainSecondCounter;
             codeCounter=0;
             codeState=CODE_MOTOR_LOCKED_STATE;
         }
         else
         {
             // Code was not ok
             uart_print_P(PSTR("code: not OK\r\n")); 

             // Move all digits in code buffer.
             for (i=0;i<sizeof(codeBuffer)-1;i++)
             {
               codeBuffer[i]=codeBuffer[i+1];
             }

             //codeTimeS=mainSecondCounter;
             //codeState=CODE_WRONG_CODE_STATE;
         }
    }
    else
    {
         // one more character entered from keyboard
         codeCounter++;
    }
}
*/


char isCodeOk(const char *code1)
{
    int len1=strlen(code1);

    if (codeCounter>=len1)
    {
      const int offset=codeCounter-len1;
      if (strncmp(code1, codeBuffer+offset, len1)==0)
      {
         return 1;
      }
    }

    return 0;
}

void codeOk(void)
{
    motorlasCodeOk=1;
    codeTimeS=mainSecondCounter;
    codeCounter=0;
    memset(codeBuffer, 0, sizeof(codeBuffer));
    codeState=CODE_MOTOR_LOCKED_STATE;
}


void codeTry(int ch)
{
    unsigned char i;

    // First store latest char
    if (codeCounter >= (sizeof(codeBuffer)))
    {
         // We have received a full code.

         // Move all digits in code buffer.
         for (i=0;i<sizeof(codeBuffer)-1;i++)
         {
           codeBuffer[i]=codeBuffer[i+1];
         }


         codeBuffer[(unsigned char)sizeof(codeBuffer)-1]=ch; // store the key

    }
    else
    {
         // one more character entered from keyboard
         codeBuffer[(unsigned char)codeCounter]=ch; // store the key
         codeCounter++;
    }


    // Some debug output
    uart_print_P(PSTR("code: trying "));
    for (i=0;i<codeCounter;i++)
    {
        uart_putchar(codeBuffer[i]);
    }
    uart_print_P(PSTR("\r\n"));


    // now compare the end of codeBuffer with expected code

    if (isCodeOk(code1))
    {
        codeOk();
    }

    if (isCodeOk(code2))
    {
        codeOk();
    }


}


void codeLog(int ch)
{
   // a key has been pressed
   uart_print_P(PSTR("code: key ")); 
   uart_putchar(ch);
   uart_print_P(PSTR("\r\n"));

   // Use this to trigger a reboot using the whatchdog
/* if (ch==27)
   {
      for(;;)
      {
         uart_print_P(PSTR("code: eternal loop"));   
      }
   }
*/
 
}


void codeStateProcess(void)
{
  //const int timeSinceLastKey=mainSecondCounter - codeTimeS;
  int ch=keyboardGetchar();

  /*
  // For debugging we could read from serial port also.
  if (ch<0)
  {
    ch=uart_getchar();
  }
  */

  switch(codeState)
  {
    case CODE_MOTOR_LOCKED_STATE:
    {
      if (ch!=-1)
      {
        // a key has been pressed
        codeLog(ch);

        if (ch=='*')
        {
           // It was the error/restart alias reset button.
           uart_print_P(PSTR("code: reset\r\n")); 
           codeClose=1;
        }
        else
        {
          codeState=CODE_ENTER_STATE;
          codeTimeS=mainSecondCounter;
          codeKeyPressCount=0;
          codeCounter=0;
          codeTry(ch);
        }
      }
      break;
    } 
    case CODE_ENTER_STATE:
    {
      const int timeSinceLastInput = mainSecondCounter - codeTimeS;

      if (ch!=-1)
      {
        // a key has been pressed
        codeLog(ch);

        codeTimeS=mainSecondCounter;
        codeKeyPressCount++;

        if (ch=='*')
        {
          // It was the error/restart alias reset button.
          uart_print_P(PSTR("code: reset\r\n")); 
          codeClose=1;
	}
	else if (codeKeyPressCount>(CODE_LEN*2))
        {
           uart_print_P(PSTR("code: to much trying\r\n"));
           codeState=CODE_WRONG_CODE_STATE;
        }
        else
        {
           codeTry(ch);
        }
      }
      else if (timeSinceLastInput>10)
      {
        uart_print_P(PSTR("code: timeout\r\n")); 
        codeCounter=0;
        codeKeyPressCount=0;
        codeState=CODE_MOTOR_LOCKED_STATE;
      }

      break;
    }
    case CODE_WRONG_CODE_STATE:
    default:
    {
      // We come to this state if someone tried to many times
      // Wait for timeout.

      const int timeSinceLastInput = mainSecondCounter - codeTimeS;

      if (ch!=-1)
      {
        // a key has been pressed
        codeLog(ch);

        if (ch=='*')
        {
          // It was the error/restart alias reset button.
          uart_print_P(PSTR("code: reset\r\n")); 
          codeClose=1;
        }
      }

      
      if (timeSinceLastInput>60)
      {
        uart_print_P(PSTR("code: return\r\n")); 
        codeCounter=0;
        codeKeyPressCount=0;
        codeState=CODE_MOTOR_LOCKED_STATE;
      }

      break;
    }
  }
}


void codeTickS(void)
{
  if (codeKeyPressCount)
  {
    codeKeyPressCount--;
  }
}



void motorlasDebugSecondsTick(void)
{
/*
      const char keyInMask=KEYBOARD_IN_IS_ACTIVE();

      // Print something on console once per second.
      uart_putchar('0'+AVR_IO_IS_ACTIVE(OPEN_BUTTON));
      uart_putchar('0'+AVR_IO_IS_ACTIVE(BLOCK_RETRACTED));
      uart_putchar('0'+AVR_IO_IS_ACTIVE(BLOCK_EXTENDED));
      uart_putchar('0'+AVR_IO_IS_ACTIVE(DOOR_CLOSED_INDICATOR));
      uart_putchar('0'+keyInMask);
      uart_putchar('0'+motorlasState);
      if (keyboardChar>=0)
      {
        uart_putchar(keyboardChar);
      }
            

      uart_print_P(PSTR("\r\n")); 

*/
}

char prevOpenButton=0;
char prevRetracted=0;
char prevExtended=0;
char prevDoorClosed=0;

void motorlasDebugProcess(void)
{
  const char openButton=AVR_IO_IS_ACTIVE(OPEN_BUTTON);
  const char retracted=AVR_IO_IS_ACTIVE(BLOCK_RETRACTED);
  const char extended=AVR_IO_IS_ACTIVE(BLOCK_EXTENDED);
  const char doorClosed=AVR_IO_IS_ACTIVE(DOOR_CLOSED_INDICATOR);

  if (openButton!=prevOpenButton)
  {
    uart_print_P(PSTR("dbg: OpenButton ")); 
    uart_putchar('0'+openButton);
    uart_print_P(PSTR("\r\n")); 
    prevOpenButton=openButton;
  }

  if (retracted!=prevRetracted)
  {
    uart_print_P(PSTR("dbg: Retracted "));
    uart_putchar('0'+retracted);
    uart_print_P(PSTR("\r\n")); 
    prevRetracted=retracted;
  }

  if (extended!=prevExtended)
  {
    uart_print_P(PSTR("dbg: Extended "));
    uart_putchar('0'+extended);
    uart_print_P(PSTR("\r\n")); 
    prevExtended=extended;
  }

  if (doorClosed!=prevDoorClosed)
  {
    uart_print_P(PSTR("dbg: DoorClosed "));
    uart_putchar('0'+doorClosed);
    uart_print_P(PSTR("\r\n")); 
    prevDoorClosed=doorClosed;
  }

}



int statusLedGetTime(void)
{

    if (!isPowerOK())
    {
       // one of the two power inputs is missing,
       // Perhaps the LEDs should go dark in this mode to save as much power as possible?
       return AVR_TMR0_TICKS_PER_SEC()/16;
    }

    if (codeState==CODE_WRONG_CODE_STATE)
    {
       return AVR_TMR0_TICKS_PER_SEC()/16;
    }


    switch (motorlasState)
    {
      case MOTOR_RESET_STATE:
      {
        break;
      }
      case MOTOR_LOCKED_STATE:
      {
        return (AVR_TMR0_TICKS_PER_SEC()*4)-LED_FLASH_TIME;
        break;
      }
      case MOTOR_UNLOCKING_STATE:
      {
        return AVR_TMR0_TICKS_PER_SEC()-LED_FLASH_TIME;
        break;
      }
      case MOTOR_OPEN_STATE:
      {
        return (AVR_TMR0_TICKS_PER_SEC()/4)-LED_FLASH_TIME;
        break;
      }
      case MOTOR_LOCKING_STATE:
      {
        return AVR_TMR0_TICKS_PER_SEC()-LED_FLASH_TIME;
        break;
      }
      case MOTOR_ERROR_1_STATE:
      default:
      {
        break;
      }
      case MOTOR_ERROR_2_STATE:
      {
        break;
      }
    }


    return AVR_TMR0_TICKS_PER_SEC()/16;
}


void statusLed(void)
{
    const int t=avr_tmr0_gettick();


    if (!isPowerOK())
    {
      // Power is lost, don't use LEDs
      AVR_IO_SET_ACTIVE(STATUS_LED, 0);
      AVR_IO_SET_ACTIVE(DEBUG_LED, 0);
    }
    else
    {
       switch(statusLedState)
       {
	 default:
         case 0:
            // a normal state with LED off
            if (keyboardState!=0)
            {
                // A code is being entered, go to expect input state
                uart_print_P(PSTR("statusLed: keyboard\r\n"));  
	        AVR_IO_SET_ACTIVE(STATUS_LED, 0);
  	        statusLedTime=t+AVR_TMR0_TICKS_PER_SEC()*10;
		statusLedState=2;              
            }
	    else if ((statusLedTime-t)<=0)
	    {
                // time to flash LED
	        AVR_IO_SET_ACTIVE(STATUS_LED, 1);
  	        statusLedTime=t+LED_FLASH_TIME;
	        statusLedState=1;
            }            
	    break;
         case 1:
            // a normal state with LED on
            if (keyboardState!=0)
            {
                // A code is being entered, go to expect input state
	        AVR_IO_SET_ACTIVE(STATUS_LED, 0);
  	        statusLedTime=t+AVR_TMR0_TICKS_PER_SEC()*10;
		statusLedState=2;              
            }
	    else if ((statusLedTime-t)<=0)
	    {
                // time to toggle LED
		AVR_IO_SET_ACTIVE(STATUS_LED, 0);
  	        statusLedTime=t+statusLedGetTime();
		statusLedState=0;
            }            
	    break;
         case 2:
             // In this state we expect input from keyboard or keypad,
             // No status flashing on LED, instead light up when a key is pressed
             // so that we can see that something happens.
             if (keyboardState==0)
             {
                // A code is not being entered
                if ((statusLedTime-t)<=0)
                {
                  // no key pressed for some time, go to idle state
                  uart_print_P(PSTR("statusLed: timeout\r\n"));  
		  AVR_IO_SET_ACTIVE(STATUS_LED, 0);
  	          statusLedTime=t+statusLedGetTime();
		  statusLedState=0;
                }
             }
             else
             {
                // stay in this state, set timer to 1s
  	        statusLedTime=t+AVR_TMR0_TICKS_PER_SEC()/4;
             }

             if (keyboardState!=0)
             {
		AVR_IO_SET_ACTIVE(STATUS_LED, 1);
             }
             else
             {
		AVR_IO_SET_ACTIVE(STATUS_LED, 0);
             }

	    break;
         }
    }
}

void mainCountSeconds(void)
{
    const int ticks = avr_tmr0_gettick();
    const int ticksDiff = ticks - mainTicks;
    const int timeToNextSec = mainSecTimer - mainTicks;

    mainTicksLong += ticksDiff;
    mainTicks = ticks;

    if (timeToNextSec<0)
    {
      // A call to applications that needs to be called once per second can be placed here:
      motorlasDebugSecondsTick();

      mainSecTimer+=AVR_TMR0_TICKS_PER_SEC();
      mainSecondCounter++;

      codeTickS();

    }
}

#define DOOR_OPEN_STATE 0
#define DOOR_CLOSING_STATE 1
#define DOOR_CLOSED_STATE 2

#define DOOR_CLOSE_TIME_DELAY (1*AVR_TMR0_TICKS_PER_SEC())

char doorState=DOOR_OPEN_STATE;
int doorTicks=0;

char doorIsClosed(void)
{
  return doorState==DOOR_CLOSED_STATE;
}


void doorEnterClosingState(void)
{
	doorTicks=mainTicks;
	doorState=DOOR_CLOSING_STATE;
}

void doorEnterOpenState(void)
{
	doorState=DOOR_OPEN_STATE;
}

void doorEnterClosedState(void)
{
	doorState=DOOR_CLOSED_STATE;
}


void doorProcess(void)
{
  switch(doorState)
  {
    case DOOR_OPEN_STATE: 
      // door is open state
      if (AVR_IO_IS_ACTIVE(DOOR_CLOSED_INDICATOR))
      {
        // Door indicator is active
        uart_print_P(PSTR("Door closing\r\n"));  
        doorEnterClosingState();
      }
      break;
    case DOOR_CLOSING_STATE:
      {
        // In this state we wait a little time to be sure the door is really closed.
        const int timeInState=mainTicks-doorTicks;
        if (!AVR_IO_IS_ACTIVE(DOOR_CLOSED_INDICATOR))
        {
          uart_print_P(PSTR("Door not closed\r\n"));  
          doorEnterOpenState();
        }
        else if (timeInState>DOOR_CLOSE_TIME_DELAY)
        {
          // We have been in this state long enough to consider the door to be really closed.
          uart_print_P(PSTR("Door closed\r\n"));  
          doorEnterClosedState();
        }
        break;
      }      
    case DOOR_CLOSED_STATE:
      {
        // In this state the door is closed.
        if (!AVR_IO_IS_ACTIVE(DOOR_CLOSED_INDICATOR))
        {
          // door closed indicator is no longer avtive, go to state door is open.
          uart_print_P(PSTR("Door open\r\n"));  
          doorEnterOpenState();
        }
        break;
      }
  }
}




void motorEnterUnlockingState(void)
{
	motorlasCodeOk=0;
	setMotorOperation(MOTOR_OPEN);
	motorlasStateTimeLong=mainTicksLong;
	motorlasState=MOTOR_UNLOCKING_STATE;
}

void motorEnterErrorState(void)
{
	setMotorOperation(MOTOR_IDLE);
	motorlasStateTimeLong=mainTicksLong;
	AVR_IO_SET_ACTIVE(DEBUG_LED, 1);
	AVR_IO_ENABLE(DEBUG_LED);
	motorlasState=MOTOR_ERROR_1_STATE;
	motorlasCodeOk=0;
}

void motorEnterLockedState(void)
{
	setMotorOperation(MOTOR_IDLE);
	motorlasStateTimeLong=mainTicksLong;
	motorlasCodeOk=0;
	motorlasState=MOTOR_LOCKED_STATE;
}

void motorEnterLockingState(void)
{
	setMotorOperation(MOTOR_CLOSE);
	motorlasStateTimeLong=mainTicksLong;
	motorlasState=MOTOR_LOCKING_STATE;
	codeClose=0;
}

void motorEnterUnlockedState(void)
{
	setMotorOperation(MOTOR_IDLE);
	motorlasStateTimeLong=mainTicksLong;
	motorlasState=MOTOR_UNLOCKED_STATE;
	codeClose=0;
}

void motorEnterOpenState(void)
{
	setMotorOperation(MOTOR_IDLE);
	codeClose=0;
	motorlasStateTimeLong=mainTicksLong;
	motorlasState=MOTOR_OPEN_STATE;
}

void motorEnterLowPowerState(void)
{
	setMotorOperation(MOTOR_IDLE);
	motorlasStateTimeLong=mainTicksLong;
	motorlasState=MOTOR_LOW_POWER_STATE;
	codeClose=0;
	AVR_IO_SET_ACTIVE(DEBUG_LED, 0);
	AVR_IO_DISABLE(DEBUG_LED);
}

void motorEnterError2State(void)
{
	motorlasStateTimeLong=mainTicksLong;
	motorlasState=MOTOR_ERROR_2_STATE;
}


void motorlasStateProcess(void)
{
	const long timeInStateT=mainTicksLong-motorlasStateTimeLong;

	switch (motorlasState)
	{
		case MOTOR_RESET_STATE:
		{
			// The first state. should we go to locked or Opening? 

			if (!isPowerOK())
			{
				uart_print_P(PSTR("motor: power loss\r\n"));  
				#ifdef UNLOCK_AT_POWER_LOSS
				motorEnterUnlockingState();
				#else
				// power has been lost go to error state 
				motorEnterErrorState();
				#endif
			}
			else if (AVR_IO_IS_ACTIVE(BLOCK_EXTENDED))
			{
				motorEnterLockedState();
			}
			else if (AVR_IO_IS_ACTIVE(BLOCK_RETRACTED))
			{
				motorEnterUnlockedState();
			}
			else
			{
				motorEnterOpenState();
			}
			break;
		}
		case MOTOR_LOCKED_STATE:
		{
			#ifdef UNLOCK_AT_POWER_LOSS
			if (!isPowerOK())
			{
				uart_print_P(PSTR("motor: power loss\r\n"));  
				motorEnterUnlockingState();
			}
			else 
			#endif
			if (AVR_IO_IS_ACTIVE(OPEN_BUTTON))
			{
				uart_print_P(PSTR("motor: unlock requested\r\n"));  
				motorEnterUnlockingState();
			}
			else if (motorlasCodeOk)
			{
				uart_print_P(PSTR("motor: code OK\r\n"));  
				motorEnterUnlockingState();
			}
			break;
			}
		case MOTOR_UNLOCKING_STATE:
		{
			// In this motorlasState motor is running to open the block, door is being unlocked.
			if ((timeInStateT>MOTOR_MINIMUM_RUN_TIME) && (AVR_IO_IS_ACTIVE(BLOCK_RETRACTED)))
			{
				uart_print_P(PSTR("motor: retracted OK\r\n"));  
				setMotorOperation(MOTOR_IDLE);
				motorEnterUnlockedState();
			}
			else if (timeInStateT>MOTOR_RUNNING_TIMEOUT)
			{
				// Did not reach retracted indication within timeout.
				uart_print_P(PSTR("motor: timeout unlocking\r\n"));  
				setMotorOperation(MOTOR_IDLE);
				motorEnterErrorState();
			}
			break;
		}
		case MOTOR_UNLOCKED_STATE:
		{
			// Door is unlocked but not yet opened
			if (!isPowerOK())
			{
				uart_print_P(PSTR("motor: power loss\r\n"));  
				motorEnterLowPowerState();
			}
			else if (!doorIsClosed())
			{
				// Door has been opened
				uart_print_P(PSTR("motor: door opened\r\n"));
				motorEnterOpenState();
			}
			else if (codeClose)
			{
				// Door has been unlocked but shall now go back to be locked again.
				uart_print_P(PSTR("motor: manual close request\r\n"));
				motorEnterLockingState();
			}
			else if (timeInStateT>MOTOR_LOCK_AGAIN_TIMEOUT)
			{
				// Door has been unlocked but shall now go back to be locked again.
				uart_print_P(PSTR("motor: lock again timeout\r\n"));
				motorEnterLockingState();
			}
			else if (motorlasCodeOk)
			{
				uart_print_P(PSTR("motor: code OK\r\n"));  
				motorEnterUnlockingState();
			}
			break;
		}
		case MOTOR_OPEN_STATE:
		{
			// Door is unlocked and open
			if (!isPowerOK())
			{
				// power has been lost go to low power state 
				uart_print_P(PSTR("motor: power loss\r\n"));  
				motorEnterLowPowerState();
			}
			else if (doorIsClosed())
			{
				// Door has been closed after being open, so not it shall bo locked.
				uart_print_P(PSTR("motor: door closed\r\n"));  
				motorEnterLockingState();
			}
			else if (codeClose)
			{
				// Door is open but manual locking has been requested so do that.
				uart_print_P(PSTR("motor: close request while open\r\n"));  
				motorEnterLockingState();
			}
			else if (timeInStateT>MOTOR_TIMEOUT_WAITING_FOR_CLOSED)
			{
				// Door has been open too long, perhaps something is wrong?
				uart_print_P(PSTR("motor: door open timeout\r\n"));  
				motorEnterLockingState();
			}
			break;
		}
		case MOTOR_LOCKING_STATE:
		{
			// In this motorlas state motor is running to close the block, door is being locked.
			#ifdef UNLOCK_AT_POWER_LOSS
			if (!isPowerOK())
			{
				uart_print_P(PSTR("motor: power loss\r\n"));  
				setMotorOperation(MOTOR_IDLE);
				motorEnterUnlockingState();
			}
			else 
			#endif
			if ((timeInStateT>MOTOR_MINIMUM_RUN_TIME) && (AVR_IO_IS_ACTIVE(BLOCK_EXTENDED))) // or use BLOCK_EXTENDED_IS_ACTIVE() ?
			{
				uart_print_P(PSTR("motor: extended OK\r\n"));  
				setMotorOperation(MOTOR_IDLE);
				motorEnterLockedState();
			}
			else if (timeInStateT>MOTOR_RUNNING_TIMEOUT)
			{
				// Did not reach retracted indication within timeout.
				uart_print_P(PSTR("motor: timeout locking\r\n"));  
				setMotorOperation(MOTOR_IDLE);
				motorEnterErrorState();
			}
			break;
		}
		case MOTOR_ERROR_1_STATE:
		default:
		{
			// In this state something was wrong. Wait for open button to be inactive (if it was active).
			if (!AVR_IO_IS_ACTIVE(OPEN_BUTTON)) 
			{
				uart_print_P(PSTR("motor: next error state\r\n"));  
				motorEnterError2State();
			}
			else if (motorlasCodeOk)
			{
				uart_print_P(PSTR("motor: unlock requested\r\n"));  
				AVR_IO_SET_ACTIVE(DEBUG_LED, 0);
				AVR_IO_DISABLE(DEBUG_LED);
				motorEnterUnlockingState();
			}
			break;
		}
		case MOTOR_ERROR_2_STATE:
		{
			// The real error state, MOTOR_ERROR_1_STATE was just to be sure we do not leave error state immediately due to a stuck open button.
			if (AVR_IO_IS_ACTIVE(OPEN_BUTTON))
			{
				uart_print_P(PSTR("motor: unlock requested\r\n"));
				AVR_IO_SET_ACTIVE(DEBUG_LED, 0);
				AVR_IO_DISABLE(DEBUG_LED);
				motorEnterUnlockingState();
			}
			else if (motorlasCodeOk)
			{
				uart_print_P(PSTR("motor: code OK\r\n"));
				AVR_IO_SET_ACTIVE(DEBUG_LED, 0);
				AVR_IO_DISABLE(DEBUG_LED);
				motorEnterUnlockingState();
			}
			break;
		}
		case MOTOR_LOW_POWER_STATE:
		{
			if (isPowerOK())
			{
				uart_print_P(PSTR("motor: power restored\r\n"));  
				motorEnterUnlockingState();
			}
			break;
		}
	}
}


void termProcess(void)
{
    int ch=uart_getchar();
    if (ch>=0)
    {
        char tmp[80];
        char *ptr=tmp;
        ptr=hStrcpy(ptr, "Term:");

        switch(ch)
        {
            case 27:
            case '+':
              for(;;)
              {
                uart_print_P(PSTR("term: eternal loop\r\n"));   
              }
              break;
            case 'v':
            {
              ptr=hStrcpy(ptr, " pmf=");
              ptr=h8bitToHex(ptr, powerMeasurementFail);
              ptr=hStrcpy(ptr, " v1=");
              ptr=h16bitToHex(ptr, powerVoltage1);
              ptr=hStrcpy(ptr, " v2=");
              ptr=h16bitToHex(ptr, powerVoltage2);
              break;
            }
            case 'm':
            {
              ptr=hStrcpy(ptr, " motorlasState=");
              ptr=h8bitToHex(ptr, motorlasState);
              break;
            }
            case 't':
            {
              ptr=hStrcpy(ptr, " mainSecondCounter=");
              ptr=h8bitToHex(ptr, mainSecondCounter);
              break;
            }
            default:
              ptr=hStrcpy(ptr, " ch=");
              ptr=h16bitToHex(ptr, ch);
              break;
        }

        *ptr=0;
        hPrintln(tmp);


        // TODO: collect characters into a command line and process command lines.

    }
}


int main( void ) 
{
  wdt_enable(WDTO_2S);

  avr_init(); // This will configure some things like interrupt and disable unused HW.

  
  AVR_IO_SET_ACTIVE(DEBUG_LED,1); // set debug LED on
  AVR_IO_ENABLE(DEBUG_LED);       // enable debug LED as output 


  uart_init();

  wdt_reset();
  uart_print_P(PSTR("\r\n" VERSION_STRING "\r\n")); 
  wdt_reset();



  avr_tmr0_init();

  powerInit();

  motorlas_init();

  //wdt_reset();
  //avr_debug_blink(3);
  //wdt_reset();

  mainTicks=avr_tmr0_gettick();
  mainSecTimer=mainTicks;


  AVR_IO_ENABLE(DEBUG_LED);       // disable debug LED as output 
  AVR_IO_SET_ACTIVE(DEBUG_LED,0); // set debug LED off


  for(;;)
  {
    mainCountSeconds();

    // A call to applications that needs to be called once per turn in main loop can be placed here:
    powerProcess();
    motorlasDebugProcess();
    statusLed();
    keyboardStateProcess();
    codeStateProcess();
    doorProcess();
    motorlasStateProcess();
    termProcess();

    wdt_reset();

    // Set CPU in idle mode to save energy, it will wake up next time there is an interrupt
    avr_idle();

  }

  

  return(0);
} // end main()



