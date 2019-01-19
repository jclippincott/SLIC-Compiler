#ifndef ABSTRACT_SYNTAX_TREE_H
#define ABSTRACT_SYNTAX_TREE_H

#include "symbolTable.h"

#define KIND_INTEGER 1
#define KIND_REAL 2
#define KIND_STRING 3
#define KIND_VARIABLE 4
#define KIND_OPERATOR 5

#define VARTYPE_INT 1
#define VARTYPE_REAL 2

//Define operators here
#define _OP_ASSIGN 1
#define _BOOL_AND 2
#define _BOOL_OR 3
#define _BOOL_NOT 4
#define _OP_LT 5
#define _OP_LTE 6
#define _OP_GT 7
#define _OP_GTE 8
#define _OP_EQUAL 9 
#define _OP_NEQ 10
#define _OP_PLUS 11
#define _OP_MINUS 12
#define _OP_TIMES 13
#define _OP_DIVIDE 14
#define _OP_MOD 15
#define _OP_UMINUS 16
#define _NEWLINE 17
#define _PRINT 18
#define _EXIT 19
#define _IF 20
#define _IF_ELSE 21
#define _WHILE 22
#define _COUNTING 23
#define _COUNTING_UP 24
#define _COUNTING_DOWN 25
#define _READ 26

typedef struct TreeNode {
	int kind;
	int operator;
	int extraOp;
	int varType;
	
	struct TreeNode *next;
	struct TreeNode *lChild;
	struct TreeNode *rChild;
	struct TreeNode *extra;
	struct TreeNode *extra2;
	
	int ival;
	float fval;
	char *sval;
}TreeNode;

extern TreeNode *ASTRoot;

#endif