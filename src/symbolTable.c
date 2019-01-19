#include <stdio.h>#include <stdlib.h>#include <string.h>#include "symbolTable.h"SymbolTable table;void symbolTableInit (){	table.numEntries = 0;	table.nextAddress = 0;}int exists(char *name){	for(int i = 0; i < table.numEntries; i++){		char *currentVarName = table.entries[i].name;		if(strcmp(currentVarName, name) == 0){			return 1;		}	}	return 0;}SymbolTableEntry* getEntry (char *name){	for(int i = 0; i < table.numEntries; i++){		char *currentVarName = (table.entries[i]).name;		if(strcmp(currentVarName, name) == 0){			return &(table.entries[i]);		}	}	return NULL;}
void symbolTableInsert (char *name, int kind, int varType, int size){	if(!exists(name) && (table.nextAddress < 1000)){
	
		SymbolTableEntry *newEntry = &table.entries[table.numEntries];
		
		newEntry -> name = name;
		newEntry -> kind = kind;
		newEntry -> type = varType;
		newEntry -> size = size;
		newEntry -> address = table.nextAddress;
		
		table.nextAddress += size;
		table.numEntries += 1;		return;
	}	printf("Error: Entry into symbol table failed.");	exit(-1); //Entry not successful, entry either already exists or symbol table is full
	
}
int getSymbolTableSize(){	return table.nextAddress;}void printSymbolTable (){	for(int i = 0; i < table.numEntries; i++){		SymbolTableEntry currentEntry = table.entries[i];		char *currName = currentEntry.name;		int currKind = currentEntry.kind;		int currType = currentEntry.type;		int currAddress = currentEntry.address;		char *type;				if(currType == VARTYPE_REAL){			type = "Real";		}		else{			type = "Integer";		}				if(currKind == KIND_ARRAY){			printf("Array(%s)[%d] %-10sAddress: %d\n",type,currentEntry.size,currName,currAddress);		}		else{			printf("%-8s%-20sAddress: %d\n",type,currName,currAddress);			}	}}