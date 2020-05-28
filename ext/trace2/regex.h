typedef struct regex_t regex_t;
typedef unsigned char UChar;

void build_regex(char*, regex_t**);
int run_regex(char*, regex_t*);

