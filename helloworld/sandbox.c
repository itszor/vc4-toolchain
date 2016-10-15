#include "hardware_vc4.h"
#define _INCLUDE_BCM2708_CHIP_REGISTER_MAP_H 1
#include "bcm2708_chip/hardware.h"
#include <stdio.h>

int main(void)
{
  /*int status;
  __asm__ __volatile__ ("mov %0,sr" : "=r" (status));
  printf ("sr: %x\n", status);
  __asm__ __volatile__ ("user");
  __asm__ __volatile__ ("mov %0,sr" : "=r" (status));
  printf ("sr: %x\n", status);*/

#if 0
  printf ("sandbox 0: %x : %x\n", L1_L1_SANDBOX_START0, L1_L1_SANDBOX_END0);
  printf ("sandbox 1: %x : %x\n", L1_L1_SANDBOX_START1, L1_L1_SANDBOX_END1);
  printf ("sandbox 2: %x : %x\n", L1_L1_SANDBOX_START2, L1_L1_SANDBOX_END2);
  printf ("sandbox 3: %x : %x\n", L1_L1_SANDBOX_START3, L1_L1_SANDBOX_END3);
  printf ("sandbox 4: %x : %x\n", L1_L1_SANDBOX_START4, L1_L1_SANDBOX_END4);
  printf ("sandbox 5: %x : %x\n", L1_L1_SANDBOX_START5, L1_L1_SANDBOX_END5);
  printf ("sandbox 6: %x : %x\n", L1_L1_SANDBOX_START6, L1_L1_SANDBOX_END6);
  printf ("sandbox 7: %x : %x\n", L1_L1_SANDBOX_START7, L1_L1_SANDBOX_END7);
  L1_L1_SANDBOX_START0 = 7;
  L1_L1_SANDBOX_END0 = 0x3fffffff;
  L1_L1_SANDBOX_START0 = (128 * 1024) | 7;

  /* bit 0: enable sandbox area
     bit 1: enable write
     bit 2: enable read.  */

  /* We've got to keep the vectors!  */
  L1_L1_SANDBOX_START1 = 7;
  L1_L1_SANDBOX_END1 = 0x1ffff;
  L1_L1_SANDBOX_START1 = 0x0 | 5;
#endif
  
#if 0
  printf ("read from 0x10000...\n");
  int q = *(volatile int*) 0x10000;
  printf ("done (q=%d).\n", q);
#else
  printf ("write to 0x10000...\n");
  *(int*) 0x10000 = 5;
  printf ("done.\n");
#endif

#if 0
  L1_L1_SANDBOX_START0 = 7;
  L1_L1_SANDBOX_END0 = 0x3fffffff;
  L1_L1_SANDBOX_START1 = 7;
  L1_L1_SANDBOX_END1 = 0x1f;
  L1_L1_SANDBOX_START1 = 0;
#endif

  return 0;
}
