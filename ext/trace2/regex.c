#include <stdio.h>
#include <string.h>
#include "ruby/onigmo.h"

void build_regex(char* str, regex_t **regex) {
  UChar *pattern = (UChar*)str;
  OnigErrorInfo einfo;

  onig_new(regex, pattern, pattern + strlen((char* )pattern),
      ONIG_OPTION_DEFAULT, ONIG_ENCODING_ASCII, ONIG_SYNTAX_DEFAULT, &einfo);
}

int run_regex(char* str, regex_t *regex) {
  UChar *target = (UChar*)str;
  UChar *start, *end, *range;
  OnigRegion *region;
  int result;

  region = onig_region_new();

  start = target;
  end   = target + strlen((char* )target);
  range = end;
  result = onig_search(regex, target, end, start, range, region, ONIG_OPTION_NONE);

  if(result == ONIG_MISMATCH) return 0;
  else return 1;
}
