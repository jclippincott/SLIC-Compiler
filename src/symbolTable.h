#ifndef SYMBOL_TABLE_H
#define KIND_ARRAY 1
typedef struct {
	int numEntries;
	int nextAddress;
	SymbolTableEntry entries[1000];
} SymbolTable;

void symbolTableInit ();

int exists (char *name);
