#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdbool.h>

static void
set_serial_opts (int fd)
{
  struct termios options;
  if (tcgetattr (fd, &options) == -1)
    perror ("tcgetattr");
  options.c_iflag = IGNPAR; // PARENB;
  options.c_cflag = CS8 | CREAD | CLOCAL;
  options.c_oflag = 0; // PARENB;
  options.c_lflag = 0;
  cfsetispeed (&options, B115200);
  cfsetospeed (&options, B115200);
  tcflush (fd, TCIFLUSH);
  if (tcsetattr (fd, TCSANOW, &options) == -1)
    perror ("tcsetattr");
}

static bool
input_ready (int fd)
{
  fd_set rfds;
  struct timeval tv;
  int retval;
  FD_ZERO (&rfds);
  FD_SET (fd, &rfds);
  
  tv.tv_sec = 0;
  tv.tv_usec = 1000;
  retval = select (fd + 1, &rfds, NULL, NULL, &tv);
  if (retval == -1)
    perror ("select");

  return retval != 0;
}

enum state
{
  UNKNOWN,
  CHECK_OK,
  LOAD_CMD,
  LOAD_IN_PROGRESS,
  RUN_CMD,
  RUN_IN_PROGRESS,
  WAITING
};

static void
send_command (int fd, const char *cmd)
{
  int rc = write (fd, cmd, 1);
  if (rc == -1)
    perror ("write");
  else if (rc < 1)
    {
      fprintf (stderr, "Couldn't send %s command\n", cmd);
      exit (1);
    }
}

int
main (int argc, char *argv[])
{
  int arg = 1;
  const char *dev = 0;
  const char *input = 0;
  int fd;
  enum state curstate = UNKNOWN;
  int finished = false;
  bool verbose = false;
  bool timeout = false;
  int ok_tries = 10;

  while (arg < argc)
    {
      if (strncmp (argv[arg], "-d", 2) == 0)
        {
          if (strlen (argv[arg]) > 2)
            dev = argv[arg] + 2;
          else if ((arg + 1) < argc)
            dev = argv[++arg];
          arg++;
        }
      else if (strcmp (argv[arg], "-v") == 0)
        {
          verbose = true;
          arg++;
        }
      else if (strcmp (argv[arg], "-t") == 0)
	{
	  timeout = true;
	  arg++;
	}
      else
        {
          input = argv[arg++];
          break;
        }
    }

  if (!input)
    {
      fprintf (stderr, "No input file?\n");
      exit (1);
    }

  if (arg < argc)
    {
      fprintf (stderr, "Too many arguments.\n");
      exit (1);
    }

  if (!dev)
    dev = "/dev/ttyUSB0";

  if (verbose)
    {
      fprintf (stderr, "Device: '%s'\n", dev);
      fprintf (stderr, "Input: '%s'\n", input);
    }

  fd = open (dev, O_RDWR);
  if (fd == -1)
    {
      perror ("open");
      exit (1);
    }

  set_serial_opts (fd);

  FILE *f = fdopen (fd, "r");
  if (!f)
    {
      fprintf (stderr, "Couldn't open input stream on fd %d\n", fd);
      exit (1);
    }
  
  while (!finished)
    {
      char *line;
      ssize_t len;
      size_t n;
      bool have_line = false;
      bool getline_called = false;

      if (input_ready (fd))
        {
          line = NULL;
          n = 0;
          if ((len = getline (&line, &n, f)))
            {
              if (verbose)
                fprintf (stderr, "Read line '%s'\n", line);
              have_line = true;
            }
          getline_called = true;
        }

      switch (curstate)
        {
        case UNKNOWN:
          {
            send_command (fd, "?");
            curstate = CHECK_OK;
          }
          break;
        case CHECK_OK:
          if (have_line && strncmp (line, "OK.", 3) == 0)
            {
              if (verbose)
                fprintf (stderr, "Everything is awesome.\n");
              curstate = LOAD_CMD;
            }
          else if (ok_tries > 0)
            {
              if (!have_line)
                {
	          usleep (200000);
                  send_command (fd, "?");
                  ok_tries--;
                }
            }
          else
            {
              fprintf (stderr, "Couldn't start communication with board.\n");
              finished = true;
            }
          break;
        case LOAD_CMD:
          {
	    /* Start timing now!  */
	    if (timeout)
	      send_command (fd, "T");
            send_command (fd, "L");
            curstate = LOAD_IN_PROGRESS;
          }
          break;
        case LOAD_IN_PROGRESS:
          {
            pid_t pid;
            pid = fork ();
            if (pid == (pid_t) 0)
              {
                /* This is the child process.  */
                /* Make fd both stdin and stdout for the child process.  */
                dup2 (fd, STDIN_FILENO);
                dup2 (fd, STDOUT_FILENO);
                close (STDERR_FILENO);
                execlp ("sx", "sx", "-q", "-X", input, 0);
              }
            else
              {
                /* This is the parent process.  */
                waitpid (pid, NULL, 0);
                if (verbose)
                  fprintf (stderr, "Done, can run now.\n");
                curstate = RUN_CMD;
              }
          }
          break;
        case RUN_CMD:
          send_command (fd, "G");
          curstate = RUN_IN_PROGRESS;
          break;
        case RUN_IN_PROGRESS:
          if (have_line)
            {
              if (strncmp (line, "Signature looks OK, starting program!",
                           37) == 0)
                ;
              else if (strncmp (line, ">>> Test harness", 16) == 0)
                finished = true;
              else if (strncmp (line, ">>> Resetting", 13) == 0)
                finished = true;
              else
                fputs (line, stdout);
            }
          break;
        case WAITING:
          break;
        }

      if (getline_called)
        free (line);
    }

  close (fd);
}
