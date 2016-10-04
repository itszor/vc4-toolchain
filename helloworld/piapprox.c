#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <termios.h>

void
newlines_on(void)
{
  struct termios t;
  tcgetattr(0, &t);
  t.c_oflag |= (ONLCR | OPOST);
  tcsetattr(0, TCSADRAIN, &t);
}

void
approximate_pi(void)
{
  int samples, inside = 0;
  for (samples = 1; samples < (1<<30); samples++)
    {
      float x = drand48() * 2.0 - 1.0;
      float y = drand48() * 2.0 - 1.0;
      float radius = x * x + y * y;
      if (radius <= 1.0)
        inside++;
      if ((samples % 100000) == 1)
        printf ("approximation %d: %f\n", samples, 4 * (float)inside / samples);
    }
}

int
main(int argc, char *argv[])
{
  newlines_on();
  printf ("Hello world\n");
  printf ("This code is running on the VideoCore4!\n");

  approximate_pi();

  return 0;
}
