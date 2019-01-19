#include "codeGenerator.h"
#include "symbolTable.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int numLines = 500;
int numEntries;
int newEntryIndex;

TreeNode *ASTRoot;

char** codeOutput;

void codegenInit(){
	codeOutput = (char**)malloc(numLines * sizeof(char*));
	newEntryIndex = 0;
}

void checkResize(){
	if(numEntries >= numLines){
		//Resize the array holding the code, allowing for 500 more lines
		codeOutput = (char**)realloc(codeOutput, (500 + numLines)*sizeof(char*));
		numLines += 500;
	}
}

void insert (char *instruction){
	numEntries += 1;
	checkResize();
	codeOutput[newEntryIndex] = strdup(instruction);
	newEntryIndex += 1;
}

void overwrite (char *instruction, int index){
	free(codeOutput[index]);
	codeOutput[index] = strdup(instruction);
}

void insertAtIndex (char *instruction, int index){
	numEntries++;
	checkResize();
	for(int i = newEntryIndex+1; i > index; i--){
		codeOutput[i] = codeOutput[i-1];
	}
	codeOutput[index] = strdup(instruction);
	newEntryIndex++;
}

void insertWithIval (char *instruction, int ival){
	char buff[100];
	sprintf(buff,"%s %d",instruction,ival);
	insert(buff);
}

void overwriteWithIval (char *instruction, int index, int ival){
	char buff[100];
	sprintf(buff,"%s %d",instruction,ival);
	overwrite(buff,index);
}

void insertAtIndexWithIval (char *instruction, int index, int ival){
	char buff[100];
	sprintf(buff,"%s %d",instruction,ival);
	insertAtIndex(buff,index);
}

void insertWithFval (char *instruction, float fval){
	char buff[100];
	sprintf(buff,"%s %f",instruction,fval);
	insert(buff);
}

void insertAtIndexWithFval (char *instruction, int index, float fval){
	char buff[100];
	sprintf(buff,"%s %f",instruction,fval);
	insertAtIndex(buff,index);
}

void overwriteWithFval (char *instruction, int index, float fval){
	char buff[100];
	sprintf(buff,"%s %f",instruction,fval);
	overwrite(buff,index);
}

void normalizeAssignmentType (TreeNode *currNode){
	int varType = getEntry(currNode -> lChild -> sval) -> type;
	int resultType = currNode -> rChild -> varType;
	if(varType == VARTYPE_INT  && resultType == VARTYPE_REAL){
		insert("FTI");
	}
	else if(varType == VARTYPE_REAL && resultType == VARTYPE_INT){
		insert("ITF");
	}
	insert("STO");
}

void normalizeToBinaryInt (TreeNode *node){
	if(node -> varType == VARTYPE_REAL){
		insertWithFval("LLF",0);
		insert("NEF");
	}
	else{
		insertWithIval("LLI",0);
		insert("NEI");
	}
}

void normalizeVarTypes (TreeNode *currNode, int lChildEnd, char *intInstruction, char *realInstruction, int typeOverride){
	int lChildType = currNode -> lChild -> varType;
	int rChildType = currNode -> rChild -> varType;
	
	if((lChildType == VARTYPE_REAL) && (rChildType == VARTYPE_INT)){
		insert("ITF");
		currNode -> varType = VARTYPE_REAL;
	}
	else if((lChildType == VARTYPE_INT) && (rChildType == VARTYPE_REAL)){
		insertAtIndex("ITF",lChildEnd);
		currNode -> varType = VARTYPE_REAL;
	}
	else{
		currNode -> varType = lChildType;
	}
	int type = currNode -> varType;
	
	if(typeOverride != 0){
		currNode -> varType = typeOverride;
	}
	
	switch (type){
		case VARTYPE_INT: 	insert(intInstruction); break;
		case VARTYPE_REAL: 	insert(realInstruction); break;
	}
}

void exprgen(TreeNode *node)
{
	int lChildEnd;
	if (node -> kind == KIND_OPERATOR){
		switch (node -> operator) {
			case _OP_PLUS:		exprgen(node -> lChild);
								lChildEnd = newEntryIndex;
								exprgen(node -> rChild);
								normalizeVarTypes(node, lChildEnd, "ADI", "ADF",0);
								break;
			case _OP_MINUS:		exprgen(node -> lChild);
								lChildEnd = newEntryIndex;
								exprgen(node -> rChild);
								normalizeVarTypes(node, lChildEnd, "SBI","SBF",0);
								break;
			case _OP_TIMES:		exprgen(node -> lChild);
								lChildEnd = newEntryIndex;
								exprgen(node -> rChild);
								normalizeVarTypes(node, lChildEnd, "MLI","MLF",0);
								break;							
			case _OP_DIVIDE:	exprgen(node -> lChild);
								lChildEnd = newEntryIndex;
								exprgen(node -> rChild);
								normalizeVarTypes(node, lChildEnd, "DVI","DVF",0);
								break;
			case _OP_UMINUS: 	exprgen(node -> rChild);
								if(node -> rChild -> varType == VARTYPE_INT){
									insert("NGI");
								}
								else{
									insert("NGF");
								}
								break;
			case _BOOL_AND:		exprgen(node -> lChild);
								normalizeToBinaryInt(node -> lChild);
								exprgen(node -> rChild);
								normalizeToBinaryInt(node ->rChild);
								insert("MLI");
								break;
			case _BOOL_OR:		exprgen(node -> lChild);
								normalizeToBinaryInt(node -> lChild);
								exprgen(node -> rChild);
								normalizeToBinaryInt(node ->rChild);
								insert("ADI");
								break;
			case _BOOL_NOT:		exprgen(node -> rChild);
								normalizeToBinaryInt(node ->rChild);
								insertWithIval("LLI",0);
								insert("EQI");
								break;
			case _OP_LT:		exprgen(node -> lChild);
								lChildEnd = newEntryIndex;
								exprgen(node -> rChild);
								normalizeVarTypes(node, lChildEnd, "LTI","LTF",VARTYPE_INT);
								break;
			case _OP_LTE:		exprgen(node -> lChild);
								lChildEnd = newEntryIndex;
								exprgen(node -> rChild);
								normalizeVarTypes(node, lChildEnd, "LEI","LEF",VARTYPE_INT);
								break;
			case _OP_GT:		exprgen(node -> lChild);
								lChildEnd = newEntryIndex;
								exprgen(node -> rChild);
								normalizeVarTypes(node, lChildEnd, "GTI","GTF",VARTYPE_INT);
								break;
			case _OP_GTE:		exprgen(node -> lChild);
								lChildEnd = newEntryIndex;
								exprgen(node -> rChild);
								normalizeVarTypes(node, lChildEnd, "GEI","GEF",VARTYPE_INT);
								break;
			case _OP_EQUAL:		exprgen(node -> lChild);
								lChildEnd = newEntryIndex;
								exprgen(node -> rChild);
								normalizeVarTypes(node, lChildEnd, "EQI","EQF",VARTYPE_INT);
								break;
			case _OP_NEQ:		exprgen(node -> lChild);
								lChildEnd = newEntryIndex;
								exprgen(node -> rChild);
								normalizeVarTypes(node, lChildEnd, "NEI","NEF",VARTYPE_INT);
								break;
								
			case _OP_MOD:		;
								int leftOperandType = node -> lChild -> varType;
								int rightOperandType = node -> rChild -> varType;
								exprgen(node -> lChild);
								if(leftOperandType == VARTYPE_REAL){
									insert("FTI");
								}
								exprgen(node -> rChild);
								if(rightOperandType == VARTYPE_REAL){
									insert("FTI");
								}
								exprgen(node -> lChild);
								if(leftOperandType == VARTYPE_REAL){
									insert("FTI");
								}
								exprgen(node -> rChild);
								if(rightOperandType == VARTYPE_REAL){
									insert("FTI");
								}
								insert("DVI");
								insert("MLI");
								insert("SBI");
								; break;
		}
	}
	else{
		switch (node -> kind){
			case KIND_INTEGER: insertWithIval("LLI",node -> ival); break;
			case KIND_REAL: insertWithFval("LLF",node -> fval); break;
			case KIND_VARIABLE: loadVarAddress(node,0); insert("LOD"); node -> varType = getEntry(node -> sval) -> type; break;
		}
	}
    return;
}

int loadVarAddress (TreeNode *currNode, int repeat){
	int currentIter = 0;
	SymbolTableEntry *varEntry = getEntry(currNode -> sval);
	currNode -> varType = varEntry -> type;
	if(varEntry != NULL){
		while(currentIter <= repeat){
			switch (varEntry -> kind){
				case KIND_SCALAR:		insertWithIval("LRA",varEntry -> address); break;
				case KIND_ARRAY:		;TreeNode *indexExpression = currNode -> rChild;
										exprgen(indexExpression);	
										if(indexExpression -> varType != VARTYPE_INT){
											insert("FTI");
										}
										insertWithIval("LRA",varEntry -> address);
										insert("ADI");
			}
			currentIter += 1;
		}
	}
	else{
		printf("Couldn't find variable, exiting now...");
		exit(-1);
	}
	return 0;
}

void addPrintStatement (TreeNode *node){
	while (node != NULL){
		switch (node -> kind){
			case KIND_STRING:	; //Empty statement to start case so C doesn't get mad at me
								char *sval = node -> sval;
								//Loops and prints every character except the starting and ending quotes
								for(int i = 1; i < strlen(sval)-1; i++){ 
									if(sval[i] == '"') i++; //Don't print double quote escape character
									insertWithIval("LLI",(int)(sval[i]));
									insert("PTC");
								}
								break;
			case KIND_OPERATOR:
								if(node -> operator == _NEWLINE) insert("PTL");
								else{
									exprgen(node);
									switch(node -> varType){
										case VARTYPE_INT: 	insert("PTI"); break;
										case VARTYPE_REAL: 	insert("PTF"); break;
									}
								}
								break;
			case KIND_VARIABLE:
								exprgen(node);
								switch(node -> varType){
									case VARTYPE_INT: 	insert("PTI"); break;
									case VARTYPE_REAL: 	insert("PTF"); break;
								}
		}
		node = node -> next;
	}
}

void typeSwitch (TreeNode *node){
	static int countingLoopCounter = 0;
	while(node != NULL){		
		switch (node -> operator){
			case _OP_ASSIGN:	loadVarAddress(node -> lChild,0);
								exprgen(node -> rChild);
								normalizeAssignmentType(node);
								break;
								
			case _IF:			exprgen(node -> lChild);
								normalizeToBinaryInt(node -> lChild);
								int lChildEnd = newEntryIndex;
								insert("NOP");
								typeSwitch(node -> rChild);
								overwriteWithIval("JPF",lChildEnd,newEntryIndex+1);
								break;
								
			case _IF_ELSE:		exprgen(node -> lChild);
								normalizeToBinaryInt(node -> lChild);
								int ifJump = newEntryIndex;
								insert("NOP");
								typeSwitch(node -> rChild);
								int elseJump = newEntryIndex;
								insert("NOP");
								typeSwitch(node -> extra);
								overwriteWithIval("JPF",ifJump,elseJump+2);
								overwriteWithIval("JMP",elseJump,newEntryIndex+1);
								break;
								
			case _WHILE:		;int JMPIndex = newEntryIndex;
								exprgen(node -> lChild);
								normalizeToBinaryInt(node -> lChild);
								int JPFIndex = newEntryIndex;
								insert("NOP");
								typeSwitch(node -> rChild);
								insertWithIval("JMP",JMPIndex+1);
								overwriteWithIval("JPF",JPFIndex,newEntryIndex+1);
								break;
								
			case _COUNTING:		;TreeNode *variable = node -> lChild;
								TreeNode *lowerExpression = node -> rChild;
								TreeNode *upperExpression = node -> extra;
								TreeNode *loopBody = node -> extra2;
								
								loadVarAddress(variable,0);
								exprgen(lowerExpression);
								if(lowerExpression -> varType != VARTYPE_INT){
									insert("FTI");
								}
								insert("STO");
								char loopConditionVar[100];
								sprintf(loopConditionVar,"_loop%d",countingLoopCounter);
								symbolTableInsert(strdup(loopConditionVar),KIND_SCALAR,VARTYPE_INT,1);
								TreeNode *loopCondition = malloc(sizeof(TreeNode));
								loopCondition -> sval = strdup(loopConditionVar);
								loadVarAddress(loopCondition,0);
								exprgen(upperExpression);
								insert("STO");
								countingLoopCounter += 1;
								
								int loopConditionStart = newEntryIndex;
								loadVarAddress(variable,0);
								insert("LOD");
								loadVarAddress(loopCondition,0);
								insert("LOD");
								switch(node -> extraOp){
									case _COUNTING_UP: 		insert("LEI"); break;
									case _COUNTING_DOWN:	insert("GEI"); break;
								}
								int loopConditionEnd = newEntryIndex;
								insert("NOP");
								typeSwitch(loopBody);
								
								loadVarAddress(variable,1);
								insert("LOD");
								insert("LLI 1");
								switch(node -> extraOp){
									case _COUNTING_UP: 		insert("ADI"); break;
									case _COUNTING_DOWN:	insert("SBI"); break;
								}
								insert("STO");
								insertWithIval("JMP",loopConditionStart+1);
								int jumpOutOfLoop = newEntryIndex;
								overwriteWithIval("JPF",loopConditionEnd,jumpOutOfLoop+1);
								break;
			
			case _READ:			; TreeNode *var = node -> rChild;
								loadVarAddress(var,0);
								switch(var -> varType){
									case VARTYPE_INT:	insert("INI"); break;
									case VARTYPE_REAL: 	insert("INF"); break;
								}
								insert("STO");
								break;
			
			case _PRINT:		addPrintStatement(node -> rChild);
								break;
								
			case _EXIT:			insert("HLT");
								break;
		}
		node = node -> next;
	}
}

void outputCode (){
	for(int i = 0; i < numEntries; i++){
		printf("%s\n",codeOutput[i]);
	}
}

void codegen(){
	codegenInit();
	typeSwitch(ASTRoot);
	insertAtIndexWithIval("ISP",0,getSymbolTableSize());
	insert("HLT");
	outputCode();
	return;
}