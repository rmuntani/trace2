typedef struct table_item {
  char* key;
  void* value;
  struct table_item* next;
} table_item;

typedef struct hash_table {
  int size;
  table_item** table;
} hash_table;

hash_table *create_table(int);
void table_insert(hash_table*, void*, char*);
