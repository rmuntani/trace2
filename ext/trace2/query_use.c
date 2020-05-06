#include <stdlib.h>
#include <string.h>
#include "ruby.h"
#include "event_processor.h"

#define NAME 0
#define METHOD 1
#define PATH 2
#define LINENO 3
#define CALLER 4

#define ALLOW 0
#define REJECT 1

int valid_name(class_use *use, char** names) {
  while(*names != NULL) {
    if (strcmp(use->name, *names) == 0) return 1;
    names++;
  }
  return 0;
}
