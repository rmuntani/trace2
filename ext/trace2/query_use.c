#include <stdlib.h>
#include <string.h>
#include "ruby.h"
#include "event_processor.h"
#include "munit/munit.h"

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

int valid_method(class_use *use, char** methods) {
  while(*methods != NULL) {
    if (strcmp(use->method, *methods) == 0) return 1;
    methods++;
  }
  return 0;
}

int valid_path(class_use *use, char** paths) {
  while(*paths != NULL) {
    if (strcmp(use->path, *paths) == 0) return 1;
    paths++;
  }
  return 0;
}

int valid_lineno(class_use *use, int* linenos) {
  while(*linenos != 0) {
    if (*linenos == use->lineno) return 1;
    linenos++;
  }
  return 0;
}
