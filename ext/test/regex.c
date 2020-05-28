#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ruby/onigmo.h"
#include "regex.h"

void build_regex(char* str, regex_t **regex) {
  *regex = str;
}

int run_regex(char* str, regex_t *regex) {
  return (strcmp((char*) regex, str) == 0);
}
