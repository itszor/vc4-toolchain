#include <stdio.h>

int main(void)
{
  int status;
  __asm__ __volatile__ ("mov %0,sr" : "=r" (status));
  printf("status: %x\n", status);
  __asm__ __volatile__ ("swi 0");
  __asm__ __volatile__ ("mov %0,sr" : "=r" (status));
  printf("status: %x\n", status);
  return 0;
}
