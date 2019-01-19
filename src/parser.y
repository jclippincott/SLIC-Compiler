%{

/*
 * ========================================================================
 * 
 * parser.y ----- Parser for the SLIC language, with complete data section
 *                and empty algorithm section. Includes code to add into
				  symbol table.
 * 
 * Programmer --- Jesse Lippincott
 * 
 * ========================================================================
 */
#include <stdio.h>
#include <stdlib.h>
int yyerror();
extern int yylex();
%}

%code requires {
	#include "symbolTable.h"
	#include "abstractSyntaxTree.h"
	int dataType;
	extern TreeNode *ASTRoot;
}

%union {
	int ival;
	float fval;
	char *sval;
	TreeNode *node;
}

%token RES_MAIN
%token RES_END
%token RES_IF
%token RES_ELSE
%token RES_WHILE
%token RES_COUNTING
%token RES_UPWARD
%token RES_DOWNWARD
%token RES_TO
%token RES_DATA
%token RES_ALGORITHM
%token RES_EXIT
%token RES_REAL
%token RES_INTEGER
%token RES_READ
%token RES_PRINT
%token OP_ASSIGN
%token BOOL_AND
%token BOOL_OR
%token BOOL_NOT
%token OP_PLUS
%token OP_MINUS
%token OP_TIMES
%token OP_DIVIDE
%token OP_UMINUS
%token OP_MOD
%token OP_LT
%token OP_LTE
%token OP_GT
%token OP_GTE
%token OP_EQUAL
%token OP_NEQ
%token WHITESPACE
%token NEWLINE
%token LBRACKET
%token RBRACKET
%token LPAREN
%token RPAREN
%token SEMICOLON
%token COLON
%token EXCLAIM
%token COMMA
%token COMMENT
%token <fval> CONST_REAL
%token <ival> CONST_INT
%token <sval> CONST_STR
%token <sval> VARNAME

%type <node> statementlist
%type <node> statement
%type <node> assignstmt
%type <node> exp
%type <node> mathexp
%type <node> comparativeexp
%type <node> term
%type <node> factor
%type <node> atom
%type <node> variable
%type <node> printstmt
%type <node> printlist
%type <node> printitem
%type <node> exitstmt
%type <node> ifstmt
%type <node> ifelse
%type <node> whileloop
%type <node> countloop
%type <node> readstmt
%type <ival> direction
%%
program: RES_MAIN SEMICOLON datasection algsection RES_END RES_MAIN SEMICOLON

datasection: datahead {symbolTableInit();} dclrstmtlist 
		   ;
			 
datahead: RES_DATA COLON
		;
		
dclrstmtlist: dclrstmt dclrstmtlist
			| dclrstmt
			;

dclrstmt: datatype COLON dclritemlist SEMICOLON
		;
			
datatype: RES_INTEGER {dataType = VARTYPE_INT;}
		| RES_REAL {dataType = VARTYPE_REAL;}
		;
		
dclritemlist: dclritem COMMA dclritemlist
			| dclritem
			;
			
dclritem: VARNAME {symbolTableInsert($1,KIND_SCALAR,dataType,1);}
		| VARNAME LBRACKET CONST_INT RBRACKET {symbolTableInsert($1,KIND_ARRAY,dataType,$3);}

algsection: alghead algbody
		  ;

alghead: RES_ALGORITHM COLON
	   ;
	   
algbody: statementlist {ASTRoot = $1;}

statementlist: statement statementlist {
				$$ = $1;
				$$ -> next = $2;
			   }
			 
			 | statement {
				$$ = $1;
				$$ -> next = NULL;
			   }
			 ;
		 
statement: assignstmt {$$ = $1;}
		 | printstmt {$$ = $1;}
		 | exitstmt {$$ = $1;}
		 | ifstmt {$$ = $1;}
		 | ifelse {$$ = $1;}
		 | readstmt {$$ = $1;}
		 | printstmt {$$ = $1;}
		 | whileloop {$$ = $1;}
		 | countloop {$$ = $1;}
		 | exitstmt {$$ = $1;}
		 ;
		 
assignstmt: variable OP_ASSIGN exp SEMICOLON{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _OP_ASSIGN;
				$$ -> lChild = $1;
				$$ -> rChild = $3;
			}	

exp: exp BOOL_AND comparativeexp{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _BOOL_AND;
				$$ -> lChild = $1;
				$$ -> rChild = $3;
			}		  
		  | exp BOOL_OR comparativeexp{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _BOOL_OR;
				$$ -> lChild = $1;
				$$ -> rChild = $3;
			}
		  | BOOL_NOT comparativeexp{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _BOOL_NOT;
				$$ -> lChild = NULL;
				$$ -> rChild = $2;
			}
		  | comparativeexp {$$ = $1;}
		  ;
		  
comparativeexp: comparativeexp OP_LT mathexp{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _OP_LT;
				$$ -> lChild = $1;
				$$ -> rChild = $3;
				}		  
			  | comparativeexp OP_LTE mathexp{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _OP_LTE;
				$$ -> lChild = $1;
				$$ -> rChild = $3;
				}
			  | comparativeexp OP_GT mathexp{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _OP_GT;
				$$ -> lChild = $1;
				$$ -> rChild = $3;
				}
			  | comparativeexp OP_GTE mathexp{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _OP_GTE;
				$$ -> lChild = $1;
				$$ -> rChild = $3;
				} 
			  | comparativeexp OP_EQUAL mathexp{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _OP_EQUAL;
				$$ -> lChild = $1;
				$$ -> rChild = $3;
				}
			  | comparativeexp OP_NEQ mathexp{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _OP_NEQ;
				$$ -> lChild = $1;
				$$ -> rChild = $3;
				}
			  | mathexp {$$ = $1;}
			  
mathexp: exp OP_PLUS term{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _OP_PLUS;
				$$ -> lChild = $1;
				$$ -> rChild = $3;
			}
		  | exp OP_MINUS term{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _OP_MINUS;
				$$ -> lChild = $1;
				$$ -> rChild = $3;
			}		  
		  | term {$$ = $1;}

term: term OP_TIMES factor{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _OP_TIMES;
				$$ -> lChild = $1;
				$$ -> rChild = $3;
      }		  
	| term OP_DIVIDE factor{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _OP_DIVIDE;
				$$ -> lChild = $1;
				$$ -> rChild = $3;
      }		  
	| term OP_MOD factor{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _OP_MOD;
				$$ -> lChild = $1;
				$$ -> rChild = $3;
      }		  
	| factor {$$ = $1;}
	;

factor: OP_MINUS exp {
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _OP_UMINUS;
				$$ -> rChild = $2;	
		}		  
	  | LPAREN exp RPAREN {$$ = $2;}		  
	  | atom {$$ = $1;}
	  ;

atom: CONST_REAL {
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_REAL;
				$$ -> varType = VARTYPE_REAL;
				$$ -> fval = $1;
	  }		  
	| CONST_INT {
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_INTEGER;
				$$ -> varType = VARTYPE_INT;
				$$ -> ival = $1;
	  }		  
	| variable {$$ = $1;}
	;

variable: VARNAME {
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_VARIABLE;
				$$ -> sval = $1;
		  }		  
		| VARNAME LBRACKET exp RBRACKET{
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_VARIABLE;
				$$ -> sval = $1;
				$$ -> rChild = $3;
		  }		  
		;

printstmt: RES_PRINT printlist SEMICOLON {
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _PRINT;
				$$ -> rChild = $2;
		   }
		 ;
		 
printlist: printitem COMMA printlist {$$ = $1; $$ -> next = $3;}
		 | printitem {$$ = $1;}
		 ;
		 
printitem: exp {$$ = $1;}
		 | CONST_STR {
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_STRING;
				$$ -> sval = $1;
		   }
		 | EXCLAIM {
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _NEWLINE;
		   }
		 ;
		 
exitstmt: RES_EXIT SEMICOLON {
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _EXIT;
		  }
		  
ifstmt: RES_IF exp SEMICOLON statementlist RES_END RES_IF SEMICOLON{
			$$ = malloc(sizeof(TreeNode));
			$$ -> kind = KIND_OPERATOR;
			$$ -> operator = _IF;
			$$ -> lChild = $2;
			$$ -> rChild = $4;
		}
	  ;

ifelse: RES_IF exp SEMICOLON statementlist RES_ELSE SEMICOLON statementlist RES_END RES_IF SEMICOLON{
			$$ = malloc(sizeof(TreeNode));
			$$ -> kind = KIND_OPERATOR;
			$$ -> operator = _IF_ELSE;
			$$ -> lChild = $2;
			$$ -> rChild = $4;
			$$ -> extra = $7;
		}
	  ;
	  
whileloop: RES_WHILE exp SEMICOLON statementlist RES_END RES_WHILE SEMICOLON{
			$$ = malloc(sizeof(TreeNode));
			$$ -> kind = KIND_OPERATOR;
			$$ -> operator = _WHILE;
			$$ -> lChild = $2;
			$$ -> rChild = $4;
			}
		  ;
countloop: RES_COUNTING variable direction exp RES_TO exp SEMICOLON statementlist RES_END RES_COUNTING SEMICOLON {
				$$ = malloc(sizeof(TreeNode));
				$$ -> kind = KIND_OPERATOR;
				$$ -> operator = _COUNTING;
				$$ -> extraOp = $3;
				$$ -> lChild = $2;
				$$ -> rChild = $4; 
				$$ -> extra = $6;
				$$ -> extra2 = $8;
		   }
		 ;  
direction: RES_UPWARD {$$ = _COUNTING_UP;}
		 | RES_DOWNWARD {$$ = _COUNTING_DOWN;}
		 ;

readstmt: RES_READ variable SEMICOLON{
			$$ = malloc(sizeof(TreeNode));
			$$ -> kind = KIND_OPERATOR;
			$$ -> operator = _READ;
			$$ -> rChild = $2;
		} 
		;
	  
%%

int yyerror() {
   printf("Called yyerror()\n");
   return  0;
}