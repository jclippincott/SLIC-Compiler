%{

/*
 *===================================
 * Written by Jesse Lippincott
 * scanner.l - Scanner for Checkpoint #5
 * CS 4223 Compiler Construction
 *===================================
 */

#define PRINT 0
#include "y.tab.h"
#include <stdio.h>
#include <string.h>

%}

%%


[Mm][Aa][Ii][Nn]												{ if(PRINT) printf("RES_MAIN: %s\n", yytext);
																  return (RES_MAIN);
																}
																
[Ee][Nn][Dd]													{ if(PRINT) printf("RES_END: %s\n", yytext);
																  return (RES_END);
																}
																
[Ii][Ff]														{ if(PRINT) printf("RES_IF: %s\n", yytext);
																  return (RES_IF);
																}
																
[Ee][Ll][Ss][Ee]												{ if(PRINT) printf("RES_ELSE: %s\n", yytext);
																  return (RES_ELSE);
																}

[Ww][Hh][Ii][Ll][Ee]											{ if(PRINT) printf("RES_WHILE: %s\n", yytext);
																  return (RES_WHILE);
																}
																
[Cc][Oo][Uu][Nn][Tt][Ii][Nn][Gg]								{ if(PRINT) printf("RES_COUNTING: %s\n", yytext);
																  return (RES_COUNTING);
																}

[Uu][Pp][Ww][Aa][Rr][Dd]										{ if(PRINT) printf("RES_UPWARD: %s\n", yytext);
																  return (RES_UPWARD);
																}

[Dd][Oo][Ww][Nn][Ww][Aa][Rr][Dd]								{ if(PRINT) printf("RES_DOWNWARD: %s\n", yytext);
																  return (RES_DOWNWARD);
																}

[Tt][Oo]														{ if(PRINT) printf("RES_TO: %s\n", yytext);
																  return (RES_TO);
																}

[Dd][Aa][Tt][Aa]												{ if(PRINT) printf("RES_DATA: %s\n", yytext);
																  return (RES_DATA);
																}

[Aa][Ll][Gg][Oo][Rr][Ii][Tt][Hh][Mm]							{ if(PRINT) printf("RES_ALGORITHM: %s\n", yytext);
																  return (RES_ALGORITHM);
																}

[Ee][Xx][Ii][Tt]												{ if(PRINT) printf("RES_EXIT: %s\n", yytext);
																  return (RES_EXIT);
																}

[Rr][Ee][Aa][Ll]												{ if(PRINT) printf("RES_REAL: %s\n", yytext);
																  return (RES_REAL);
																}

[Ii][Nn][Tt][Ee][Gg][Ee][Rr]									{ if(PRINT) printf("RES_INTEGER: %s\n", yytext);
																  return (RES_INTEGER);
																}

[Rr][Ee][Aa][Dd]												{ if(PRINT) printf("RES_READ: %s\n", yytext);
																  return (RES_READ);
																}

[Pp][Rr][Ii][Nn][Tt]											{ if(PRINT) printf("RES_PRINT: %s\n", yytext);
																  return (RES_PRINT);
																}

":="															{ if(PRINT) printf("OP_ASSIGN: %s\n", yytext);
																  return (OP_ASSIGN);
																}

"-"																{ if(PRINT) printf("OP_MINUS: %s\n", yytext);
																  return (OP_MINUS);
																}

"*"																{ if(PRINT) printf("OP_TIMES: %s\n", yytext);
																  return (OP_TIMES);
																}

"/"																{ if(PRINT) printf("OP_DIVIDE: %s\n", yytext);
																  return (OP_DIVIDE);
																}

"%"																{ if(PRINT) printf("OP_MOD: %s\n", yytext);
																  return (OP_MOD);
																}

"+"																{ if(PRINT) printf("OP_PLUS: %s\n", yytext);
																  return (OP_PLUS);
																}

"<"																{ if(PRINT) printf("OP_LT: %s\n", yytext);
																  return (OP_LT);
																}


"<="															{ if(PRINT) printf("OP_LTE: %s\n", yytext);
																  return (OP_LTE);
																}

">"																{ if(PRINT) printf("OP_GT: %s\n", yytext);
																  return (OP_GT);
																}


">="															{ if(PRINT) printf("OP_GTE: %s\n", yytext);
																  return (OP_GTE);
																}

"="																{ if(PRINT) printf("OP_EQ: %s\n", yytext);
																  return (OP_EQUAL);
																}


"<>"															{ if(PRINT) printf("OP_NEQ: %s\n", yytext);
																  return (OP_NEQ);
																}

"&"																{ if(PRINT) printf("BOOL_AND: %s\n", yytext);
																  return (BOOL_AND);
																}

"|"																{ if(PRINT) printf("BOOL_OR: %s\n", yytext);
																  return (BOOL_OR);
																}

"~"																{ if(PRINT) printf("BOOL_NOT: %s\n", yytext);
																  return (BOOL_NOT);
																}

[\t ]*															{ /* Ignore whitespace */
																}

[\n]															{ if(PRINT) printf("NEWLINE: %s", yytext);
																}

"["																{ if(PRINT) printf("LBRACKET: %s\n", yytext);
																  return (LBRACKET);
																}

"]"																{ if(PRINT) printf("RBRACKET: %s\n", yytext);
																  return (RBRACKET);
																}

"("																{ if(PRINT) printf("LPAREN: %s\n", yytext);
																  return (LPAREN);
																}

")"																{ if(PRINT) printf("RPAREN: %s\n", yytext);
																  return (RPAREN);
																}

";"																{ if(PRINT) printf("SEMICOLON: %s\n", yytext);
																  return (SEMICOLON);
																}

":"																{ if(PRINT) printf("COLON: %s\n", yytext);
																  return (COLON);
																}

"!"																{ if(PRINT) printf("EXCLAIM: %s\n", yytext);
																  return (EXCLAIM);
																}

","																{ if(PRINT) printf("COMMA: %s\n", yytext);
																  return (COMMA);
																}

#.*																{ if(PRINT) printf("COMMENT: %s\n", yytext);
																}

(([0-9]+[.][0-9]+)|([0-9]+([.][0-9]+)?[Ee][+-]?[0-9]+))			{ if(PRINT) printf("CONST_REAL: %s\n", yytext);
																  yylval.fval = atof(yytext);
																  return (CONST_REAL);
																}

[0-9]+														{ 
																  if(PRINT) printf("CONST_INT: %s\n", yytext);
																  yylval.ival = atoi(yytext);
																  return(CONST_INT);
																}

["]([^"\n]|(["]["]))*["\n]										{ if(PRINT) printf("CONST_STR: %s\n", yytext);
 																  yylval.sval = strdup(yytext);
																  return (CONST_STR);
																}

[a-zA-Z][a-zA-Z0-9]*											{ if(PRINT) printf("VARNAME: %s\n", yytext);
																  yylval.sval = strdup(yytext);
																  return (VARNAME);
																}

.																{ if(PRINT) printf("TRASH\n"); }
%%
