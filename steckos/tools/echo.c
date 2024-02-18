#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main (int argc, const char** argv)
{
  while( *++argv != NULL)
    printf("%s ", argv[0]);

  return EXIT_SUCCESS;
}