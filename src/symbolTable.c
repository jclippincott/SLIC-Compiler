#include <stdio.h>
void symbolTableInsert (char *name, int kind, int varType, int size){
	
		SymbolTableEntry *newEntry = &table.entries[table.numEntries];
		
		newEntry -> name = name;
		newEntry -> kind = kind;
		newEntry -> type = varType;
		newEntry -> size = size;
		newEntry -> address = table.nextAddress;
		
		table.nextAddress += size;
		table.numEntries += 1;
	}
	
}
