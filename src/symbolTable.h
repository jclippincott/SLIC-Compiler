#ifndef SYMBOL_TABLE_H#define SYMBOL_TABLE_H#define VARTYPE_INT 1#define VARTYPE_REAL 2#define KIND_SCALAR 0
#define KIND_ARRAY 1typedef struct {	char *name;	int kind;	//Array or scalar	int type;	//Real or int	int size;	int address;} SymbolTableEntry;
typedef struct {
	int numEntries;
	int nextAddress;
	SymbolTableEntry entries[1000];
} SymbolTable;

void symbolTableInit ();

int exists (char *name);SymbolTableEntry* getEntry (char *name);
void symbolTableInsert (char *name, int vartype, int datatype, int size);void printSymbolTable ();#endif