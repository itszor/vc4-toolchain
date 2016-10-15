#include "hardware_vc4.h"
#define _INCLUDE_BCM2708_CHIP_REGISTER_MAP_H 1
#include "bcm2708_chip/hardware.h"
#include <stdio.h>

unsigned long ctr = 0;

int main(void)
{
  unsigned starttime = ST_CLO;
  printf("microsecs: %u\n", starttime);
  
  ST_C0 = starttime + 2000000u;
  ST_CS |= 1;
  
  while (ctr < 1000000 * 250)
    {
      ctr++;
      __asm__ __volatile__ ("nop");
    }
  printf("microsecs: %u\n", ST_CLO);
  return 0;
}
