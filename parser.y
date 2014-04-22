%{
#include <stdio.h>
#include <string.h>
#include <assert.h>
#define ID_SIZE 100
#define MAX_CHILDREN 3

struct Node {
  /* the type of the node */
  int type;

  /* the value of the node if it can have one */
  double value;

  /* the id of the node (used for identifiers only) */
  char id[ID_SIZE];

  /* at most three children nodes */
  int num_children;
  struct Node* children[MAX_CHILDREN];
};

struct symbol{ 
  char name[ID_SIZE];
  double value;
};


 struct Node* tree;
 struct Node* part;
 struct Node* epart;
 struct Node* ifstmt;
 struct symbol sTable[400];
 int first = 0;
  
int yywrap( );
void yyerror(const char* str);
void attach_node(struct Node*, struct Node*);
struct Node* make_node(int, double, char*);
void use_tree(struct Node*);
void addSymbol(char*, double);
double getSymbol(char*);

%}
/* declare type possibilities of symbols */
%union {
  double value;
  char text[100];
  struct Node* node;
}
%left LPAREN RPAREN
%left OR
%left AND
%left LESS LESSEQ GREATER GREATEREQ EQUALS NEQUALS
%left PLUS MINUS
%left TIMES DIVIDE 
%left NOT

/* declare tokens */
%token <text> IDENT  
%token <value> VAL 
%token IDENTIFIER
%token PLUS   
%token MINUS  
%token DIVIDE 
%token TIMES  
%token LESS  
%token GREATER  
%token LESSEQ
%token GREATEREQ 
%token EQUALS 
%token NEQUALS 
%token AND    
%token OR     
%token NOT    
%token SCOL   
%token CEQUAL 
%token LPAREN 
%token RPAREN 
%token BEGINS  
%token IF     
%token THEN   
%token ELSE   
%token WHILE  
%token DO     
%token PRINT  
%token STATEMENT
%token ASSIGN
%token<value> INPUT 
%token END 
/* declare non-terminals */
%type <node> tree stmt stmts expr pers term terma termb termc termd terme



/* give us more detailed errors */
%error-verbose

%%
tree: stmt {tree = $$;}

/* statment */
stmt:
stmts stmt {
        if(first == 0){
        $$ = make_node(STATEMENT,0,"");
        attach_node($$,$1);
        attach_node($$,$2);
        }
        else{
        first = 0;
        }
}
| { $$ = NULL;}
/* assignment */
stmts: expr CEQUAL expr SCOL {
/*      $$ = make_node(STATEMENT, 0, "");*/
        $$ = make_node(ASSIGN, 0, "");
        attach_node($$, $1);
        attach_node($$, $3);
        /*attach_node($$, part);*/
}

/* If Statement */
stmts: IF expr THEN stmts {
        $$ = make_node(IF, 0, "");
        part = make_node(STATEMENT,0,"");
        attach_node($$, $2);
        attach_node(part, $4);
        attach_node($$, part);
}

/* If/else Statement */
stmts: IF expr THEN stmts ELSE stmts {
        $$ = make_node(STATEMENT, 0, "");
        ifstmt = make_node(IF, 0, "");
        part = make_node(STATEMENT, 0,"");
        epart = make_node(STATEMENT,0,"");
        attach_node(ifstmt, $2);
        attach_node(part, $4);
        attach_node(epart, $6);
        attach_node(ifstmt, part);
        attach_node(ifstmt, epart);
        attach_node($$, ifstmt);
        first = 1;
}

/* While Statement */
stmts: WHILE expr DO stmts {
        $$ = make_node(WHILE, 0, "");
        attach_node($$, $2);
        attach_node($$, $4);
}

/* Print Statement */
stmts: PRINT expr SCOL {
        $$ = make_node(PRINT, 0, "");
        attach_node($$, $2);
}

/* Statement Sequence */
stmts: BEGINS stmt END {
        $$ = $2
}
/* additional statements */
expr: LPAREN pers RPAREN {
        $$=$2;
}
| pers {$$ = $1;}
/* or expression */
pers: pers OR term {
        $$ = make_node(OR, 0,"");
        attach_node($$, $1);
        attach_node($$, $3);
}
|  pers OR LPAREN pers RPAREN{
        $$ = make_node(OR, 0, "");
        attach_node($$, $1);
        attach_node($$, $4);
}
| LPAREN pers RPAREN OR term {
        $$ = make_node(OR, 0, "");
        attach_node($$, $2);
        attach_node($$, $5);
}
| LPAREN pers RPAREN OR LPAREN pers RPAREN {
        $$ = make_node(OR, 0, "");
        attach_node($$, $2);
        attach_node($$, $6);
}
 
| term {$$ = $1;}

/* and expression */
term: term AND terma {
        $$ = make_node(AND, 0, "");
        attach_node($$, $1);
        attach_node($$, $3);
}
|  term AND LPAREN pers RPAREN{
        $$ = make_node(AND, 0, "");
        attach_node($$, $1);
        attach_node($$, $4);
}
| LPAREN pers RPAREN AND term {
        $$ = make_node(AND, 0, "");
        attach_node($$, $2);
        attach_node($$, $5);
}
| LPAREN pers RPAREN AND LPAREN pers RPAREN {
        $$ = make_node(AND, 0, "");
        attach_node($$, $2);
        attach_node($$, $6);
}
 
| terma{$$ = $1;}


/* comparison operators */
terma: terma LESS termb {
        $$ = make_node(LESS, 0, "");
        attach_node($$, $1);
        attach_node($$, $3);
}
| terma LESS LPAREN pers RPAREN{
        $$ = make_node(LESS, 0, "");
        attach_node($$, $1);
        attach_node($$, $4);
}
| LPAREN pers RPAREN LESS termb {
        $$ = make_node(LESS, 0, "");
        attach_node($$, $2);
        attach_node($$, $5);
}
| LPAREN pers RPAREN LESS LPAREN pers RPAREN {
        $$ = make_node(LESS, 0, "");
        attach_node($$, $2);
        attach_node($$, $6);
}

| terma LESSEQ termb {  
        $$ = make_node(LESSEQ, 0, "");
        attach_node($$, $1);
        attach_node($$, $3);
}
|  terma LESSEQ LPAREN pers RPAREN{
        $$ = make_node(LESSEQ, 0, "");
        attach_node($$, $1);
        attach_node($$, $4);
}
| LPAREN pers RPAREN LESSEQ termb {
        $$ = make_node(LESSEQ, 0, "");
        attach_node($$, $2);
        attach_node($$, $5);
}
| LPAREN pers RPAREN LESSEQ LPAREN pers RPAREN {
        $$ = make_node(LESSEQ, 0, "");
        attach_node($$, $2);
        attach_node($$, $6);
}

| terma GREATER termb { 
        $$ = make_node(GREATER, 0, "");
        attach_node($$, $1);
        attach_node($$, $3);
}
|  terma GREATER LPAREN pers RPAREN{
        $$ = make_node(GREATER, 0, "");
        attach_node($$, $1);
        attach_node($$, $4);
}
| LPAREN pers RPAREN GREATER termb {
        $$ = make_node(GREATER, 0, "");
        attach_node($$, $2);
        attach_node($$, $5);
}
| LPAREN pers RPAREN GREATER LPAREN pers RPAREN {
        $$ = make_node(GREATER, 0, "");
        attach_node($$, $2);
        attach_node($$, $6);
}
 
| terma GREATEREQ termb {       
        $$ = make_node(GREATEREQ, 0, "");
        attach_node($$, $1);
        attach_node($$, $3);
}       
|  terma GREATEREQ LPAREN pers RPAREN{
        $$ = make_node(GREATEREQ, 0, "");
        attach_node($$, $1);
        attach_node($$, $4);
}
| LPAREN pers RPAREN GREATEREQ termb {
        $$ = make_node(GREATEREQ, 0, "");
        attach_node($$, $2);
        attach_node($$, $5);
}
| LPAREN pers RPAREN GREATEREQ LPAREN pers RPAREN {
        $$ = make_node(GREATEREQ, 0, "");
        attach_node($$, $2);
        attach_node($$, $6);
}

| terma EQUALS termb {  
        $$ = make_node(EQUALS, 0, "");
        attach_node($$, $1);
        attach_node($$, $3);
} 
|  terma EQUALS LPAREN pers RPAREN{
        $$ = make_node(EQUALS, 0, "");
        attach_node($$, $1);
        attach_node($$, $4);
}
| LPAREN pers RPAREN EQUALS termb {
        $$ = make_node(EQUALS, 0, "");
        attach_node($$, $2);
        attach_node($$, $5);
}
| LPAREN pers RPAREN EQUALS LPAREN pers RPAREN {
        $$ = make_node(EQUALS, 0, "");
        attach_node($$, $2);
        attach_node($$, $6);
}

| terma NEQUALS termb { 
        $$ = make_node(NEQUALS, 0, "");
        attach_node($$, $1);
        attach_node($$, $3);
} 
|  terma NEQUALS LPAREN pers RPAREN{
        $$ = make_node(NEQUALS, 0, "");
        attach_node($$, $1);
        attach_node($$, $4);
}
| LPAREN pers RPAREN NEQUALS termb {
        $$ = make_node(NEQUALS, 0, "");
        attach_node($$, $2);
        attach_node($$, $5);
}
| LPAREN pers RPAREN NEQUALS LPAREN pers RPAREN {
        $$ = make_node(NEQUALS, 0, "");
        attach_node($$, $2);
        attach_node($$, $6);
}

| termb {$$ = $1;}

/* + - operators */
termb: termb PLUS termc {
        $$ = make_node(PLUS, 0, "");
        attach_node($$, $1);
        attach_node($$, $3);
}
|  termb PLUS LPAREN pers RPAREN{
        $$ = make_node(PLUS, 0, "");
        attach_node($$, $1);
        attach_node($$, $4);
}
| LPAREN pers RPAREN PLUS termc {
        $$ = make_node(PLUS, 0, "");
        attach_node($$, $2);
        attach_node($$, $5);
}
| LPAREN pers RPAREN PLUS LPAREN pers RPAREN {
        $$ = make_node(PLUS, 0, "");
        attach_node($$, $2);
        attach_node($$, $6);
}
 
| termb MINUS termc {
        $$ = make_node(MINUS, 0, "");
        attach_node($$, $1);
        attach_node($$, $3);
}
|  termb MINUS LPAREN pers RPAREN{
        $$ = make_node(MINUS, 0, "");
        attach_node($$, $1);
        attach_node($$, $4);
}
| LPAREN pers RPAREN MINUS termc {
        $$ = make_node(MINUS, 0, "");
        attach_node($$, $2);
        attach_node($$, $5);
}
| LPAREN pers RPAREN MINUS LPAREN pers RPAREN {
        $$ = make_node(MINUS, 0, "");
        attach_node($$, $2);
        attach_node($$, $6);
}
 
| termc {$$ = $1;}

/* * / operators */
termc: termc TIMES termd {
        $$ = make_node(TIMES, 0, "");
        attach_node($$, $1);
        attach_node($$, $3);
}
| termc TIMES LPAREN pers RPAREN {
        $$ = make_node(TIMES, 0, "");
        attach_node($$, $1);
        attach_node($$, $4);
}
| LPAREN pers RPAREN TIMES termd{
        $$ = make_node(TIMES, 0,"");
        attach_node($$, $2);
        attach_node($$, $5);
}
| LPAREN pers RPAREN TIMES LPAREN pers RPAREN {
        $$ = make_node(TIMES, 0, "");
        attach_node($$,$2);
        attach_node($$, $6);
        } 
| termc DIVIDE termd {
        $$ = make_node(DIVIDE, 0, "");
        attach_node($$, $1);
        attach_node($$, $3);
}
| termc DIVIDE LPAREN pers RPAREN{
        $$ = make_node(DIVIDE, 0, "");
        attach_node($$, $1);
        attach_node($$, $4);
}
| LPAREN pers RPAREN DIVIDE termd {
        $$ = make_node(DIVIDE, 0, "");
        attach_node($$, $2);
        attach_node($$, $5);
}
| LPAREN pers RPAREN DIVIDE LPAREN pers RPAREN {
        $$ = make_node(DIVIDE, 0, "");
        attach_node($$, $2);
        attach_node($$, $6);
}
| termd {$$ = $1;}

/* not operator */
termd:  
 NOT termd {
        $$ = make_node(NOT, 0, "");
        attach_node($$, $2);
}
| NOT LPAREN pers RPAREN{
        $$ = make_node(NOT, 0, "");
        attach_node($$, $3);
}
| terme {$$=$1;}

/* values */
terme: VAL {
        $$ = make_node(VAL, $1, "");
} | IDENT {
        $$ = make_node(IDENTIFIER, 0, $1);
} 
  | INPUT {
        $$ = make_node(INPUT, INPUT, "");
}

%%
int numSymbols = 0;


int yywrap( ) {
  return 1;
}

void yyerror(const char* str) {
  fprintf(stderr, "Compiler error: '%s'.\n", str);
}

/* creates a new node and returns it */
struct Node* make_node(int type, double value, char* id) {
  int i;

  /* allocate space */
  struct Node* node = malloc(sizeof(struct Node));

  /* set properties */
  node->type = type;
  node->value = value;
  strcpy(node->id, id);
  node->num_children = 0;
  for(i = 0; i < MAX_CHILDREN; i++) {
    node->children[i] = NULL;
  }

  /* return new node */
  return node;
}

/* attach an existing node onto a parent */
void attach_node(struct Node* parent, struct Node* child) {
  /* connect it */
  parent->children[parent->num_children] = child;
  parent->num_children++;
  assert(parent->num_children <= MAX_CHILDREN);
}


double getSymbol(char* name){
                int i;
                for(i = 0; i<numSymbols; i++){
                        if((!strcmp(sTable[i].name, name)) > 0){
                        return sTable[i].value;
                                
		}
	}
}

void addSymbol(char* name, double value){
        strcpy(sTable[numSymbols].name, name);
        sTable[numSymbols].value = value;
        numSymbols++;
}

int inTable(char* name){
	int x;
	for(x=0; x<numSymbols; x++){
		if((!strcmp(sTable[x].name, name))>0 ){
			return x;
		}
    }
	return -1;
}
double evalExpression(struct Node* node){
  int b;
  double z[2];
  double d;
  switch(node->type) {
    case IDENTIFIER: 		return getSymbol(node->id); break;
    case VAL: 		        return node->value; break;
    case PLUS:  
		                for(b=0; b<node->num_children; b++){
                                z[b] = evalExpression(node->children[b]);
                                }
                                return z[0] + z[1];
                                break;
    case MINUS: 
                                for(b=0; b<node->num_children; b++){
                                z[b] = evalExpression(node->children[b]);
                                }
                                return z[0] - z[1];
                                break;
    case DIVIDE:
                                for(b=0; b<node->num_children; b++){
                                z[b] = evalExpression(node->children[b]);
                                }
                                return z[0] / z[1];
                                break;
    case TIMES:
                                for(b=0; b<node->num_children; b++){
                                z[b] = evalExpression(node->children[b]);
                                }
                                return z[0] * z[1];
                                break;
    case LESS:
                                for(b=0; b<node->num_children; b++){
                                z[b] = evalExpression(node->children[b]);
                                }
                                return (z[0] < z[1]);
                                break;
    case GREATER: 
                                for(b=0; b<node->num_children; b++){
                                z[b] = evalExpression(node->children[b]);
                                }
                                return (z[0] > z[1]);
                                break;
    case LESSEQ:
                                for(b=0; b<node->num_children; b++){
                                z[b] = evalExpression(node->children[b]);
                                }
                                return (z[0] <= z[1]);
                                break;
    case GREATEREQ:
                                for(b=0; b<node->num_children; b++){
                                z[b] = evalExpression(node->children[b]);
                                }
                                return (z[0] >= z[1]);
                                break;
    case EQUALS:
                                for(b=0; b<node->num_children; b++){
                                z[b] = evalExpression(node->children[b]);
                                }
                                return (z[0] == z[1]);
                                break;
    case NEQUALS:
                                for(b=0; b<node->num_children; b++){
                                z[b] = evalExpression(node->children[b]);
                                }
                                return (z[0] != z[1]);
                                break;
    case AND:
                                for(b=0; b<node->num_children; b++){
                                z[b] = evalExpression(node->children[b]);
                                }
                                return (z[0] && z[1]);
                                break;
    case OR:
                                for(b=0; b<node->num_children; b++){
                                z[b] = evalExpression(node->children[b]);
                                }
                                return (z[0] || z[1]);
                                break;
    case NOT:
                                for(b=0; b<node->num_children; b++){
                                z[b] = evalExpression(node->children[b]);
                                }
                                return !z[0];
                                break;
    case INPUT: 		
				printf("Input Value: ");
				scanf("%lg", &d);
				return d;
				break;
    default:
      printf("Error, %d not a valid node type for an expression.\n", node->type);
      exit(1);
  }

        }
        
void evalStatement(struct Node* node){
	int x;
        switch(node->type){
		
    case PRINT:  printf("%9.6f\n",evalExpression(node->children[0])); break;
    case IF: 
		if(evalExpression(node->children[0])){
			evalStatement(node->children[1]);
		}
		else if(node->children[2] != NULL){
			evalStatement(node->children[2]);
		}
		break;
	case STATEMENT:
		for(x=0; x < node->num_children; x++){
			if(node->children[x] != NULL){
				evalStatement(node->children[x]);
			}
		}
		break;
	case WHILE: 
		while(evalExpression(node->children[0])){
			evalStatement(node->children[1]);
		}
		break;
	case ASSIGN:
		if((x = inTable(node->children[0]->id)) >= 0){
			sTable[x].value = evalExpression(node->children[1]);
		}
		else{
			addSymbol(node->children[0]->id, evalExpression(node->children[1]));
		}
		break;
	
	default:
      		printf("Error, %d not a valid node type for a statement.\n", node->type);
      		exit(1);
	}
}

        
void use_tree(struct Node* node) {
  /* base case */
  if(!node) return;
  
  if(node->type == STATEMENT){
		if(node->children[0] != NULL){
			evalStatement(node->children[0]);
		}
		if(node->children[1]!=NULL){
        		evalStatement(node->children[1]);
		}
	
       }
  else{
        printf("something is wrong with your tree (first node is not a statement)");
        }
}

int main(int argc, char *argv[] ) {

FILE* orig_stdin = stdin;
stdin = fopen(argv[1], "r");
    if(stdin == NULL){
        printf("Could not open file or file does not exist\nexiting...\n");
        return 0;
  }
 yyparse( );
 fclose(stdin);
 stdin = orig_stdin;
 use_tree(tree);
 return 0;
}
