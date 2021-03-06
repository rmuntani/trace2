#define RUBY_EVENT_CALL 0
#define RUBY_EVENT_B_CALL 1
#define RUBY_EVENT_RETURN 2
#define RUBY_EVENT_B_RETURN 3
#define T_MODULE 0
#define T_CLASS 1
#define T_NIL 2
#define T_REGEXP 3

// PRIsVALUE is used on event_processor.c
#define RUBY_PRI_VALUE_MARK "\v"
#define PRIsVALUE PRI_VALUE_PREFIX"i" RUBY_PRI_VALUE_MARK
#define PRI_VALUE_PREFIX ""

typedef struct {

} VALUE;

typedef struct {

} rb_trace_arg_t;

typedef struct {

} ID;

VALUE rb_cObject;

typedef unsigned long rb_event_flag_t;

VALUE rb_tracearg_self(rb_trace_arg_t*);

VALUE rb_tracearg_path(rb_trace_arg_t*);

char* rb_string_value_ptr(VALUE*);

VALUE rb_tracearg_callee_id(rb_trace_arg_t*);

char* rb_id2name(VALUE);

VALUE rb_tracearg_lineno(rb_trace_arg_t*);

int FIX2INT(VALUE);

rb_trace_arg_t* rb_tracearg_from_tracepoint(VALUE);

rb_event_flag_t rb_tracearg_event_flag(rb_trace_arg_t*);

VALUE rb_define_class_under(VALUE, char*, VALUE);

void rb_define_method(VALUE, const char*, void (*)(), int);

void rb_define_const(VALUE, const char*, VALUE);

int TYPE(VALUE);

char* rb_class2name(VALUE);

char *rb_obj_classname(VALUE);

VALUE rb_str_new_cstr(const char*);

VALUE rb_define_module_under(VALUE, const char*);

VALUE Qnil;

VALUE rb_sprintf(char*, ...);

VALUE rb_ary_new();

VALUE rb_ary_push(VALUE, VALUE);

VALUE SYM2ID(VALUE);

VALUE rb_ary_entry(VALUE, long);

long RARRAY_LEN(VALUE);

char* StringValueCStr(VALUE);

VALUE ID2SYM(ID);

ID rb_intern(char*);

void rb_define_const(VALUE, const char*, VALUE);
