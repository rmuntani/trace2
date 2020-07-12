#include <string.h>
#include <stdlib.h>
#include "hash_table.h" 

/*djb2 hash function*/
__attribute__((weak)) long hash(unsigned char *str) {
  unsigned long hash = 5381;
  int c;

  while (c = *str++)
    hash = ((hash << 5) + hash) + c;

  return hash;
}

hash_table *create_table(int size) {
  int i;
  hash_table *new_table = malloc(sizeof(hash_table));

  new_table->size = size;
  new_table->table = malloc(sizeof(table_item*)*size); 

  for(i = 0; i < size; i++) { 
    new_table->table[i] = NULL;
  }

  return new_table;
}

void table_insert(hash_table* table, void* value, char* key) {
  int size = table->size, item_index;
  long hash_value = hash(key);
  table_item *new_item = malloc(sizeof(table_item)),
             *curr_item;

  item_index = hash_value % size;

  new_item->next = NULL;
  new_item->key = key;
  new_item->value = value;

  curr_item = table->table[item_index];

  if(curr_item == NULL) { 
    table->table[hash_value % size] = new_item;
  } else {
    while(curr_item->next != NULL && 
            strcmp(key, curr_item->key) != 0) curr_item = curr_item->next; 
    if (strcmp(curr_item->key, key) != 0) curr_item->next = new_item;
  }
}
