%{
	#include <stdio.h>
     #include <string.h>
#include<stdlib.h>
#include<iostream>
#include<string>
#include<algorithm>

	extern int yylex();
	int yyerror(const char *msg);
	extern int lineNo;
	extern int colNo;
     int EsteCorecta = 1;
	int ACCES=0;
	char msg[500];

	class TVAR
	{
	     char* nume;
	     int valoare;
	     TVAR* next;
 
	  
	  public:
	     static TVAR* head;
	     static TVAR* tail;

	     TVAR(char* n, int v = -1);
	     TVAR();
	     int exists(char* n);
             void add(char* n, int v = -1);
             int getValue(char* n);
	     void setValue(char* n, int v);
	};

	TVAR* TVAR::head;
	TVAR* TVAR::tail;

	TVAR::TVAR(char* n, int v)
	{
	 this->nume = new char[strlen(n)+1];
	 strcpy(this->nume,n);
	 this->valoare = v;
	 this->next = NULL;
	}

	TVAR::TVAR()
	{
	  TVAR::head = NULL;
	  TVAR::tail = NULL;
	}

	int TVAR::exists(char* n)
	{
	  TVAR* tmp = TVAR::head;
	  while(tmp != NULL)
	  {
	    if(strcmp(tmp->nume,n) == 0)
	      return 1;
            tmp = tmp->next;
	  }
	  return 0;
	 }

         void TVAR::add(char* n, int v)
	 {
	   TVAR* elem = new TVAR(n, v);
	   if(head == NULL)
	   {
	     TVAR::head = TVAR::tail = elem;
	   }
	   else
	   {
	     TVAR::tail->next = elem;
	     TVAR::tail = elem;
	   }
	 }

         int TVAR::getValue(char* n)
	 {
	   TVAR* tmp = TVAR::head;
	   while(tmp != NULL)
	   {
	     if(strcmp(tmp->nume,n) == 0)
	      return tmp->valoare;
	     tmp = tmp->next;
	   }
	   return -1;
	  }

	  void TVAR::setValue(char* n, int v)
	  {
	    TVAR* tmp = TVAR::head;
	    while(tmp != NULL)
	    {
	      if(strcmp(tmp->nume,n) == 0)
	      {
		tmp->valoare = v;
	      }
	      tmp = tmp->next;
	    }
	  }

	TVAR* ts = NULL;
%}

%union { char* number; char* name; }

%token TOK_SEMICOLON  TOK_COLON TOK_COMMA TOK_ASSIGNEMENT TOK_PLUS TOK_MINUS TOK_MULTIPLY 
%token TOK_DIVIDE  TOK_READ TOK_WRITE 
%token TOK_FOR TOK_DO TOK_TO TOK_PROGRAM TOK_VAR TOK_BEGIN TOK_END TOK_INTEGER TOK_ERROR

%token <name> TOK_INT  TOK_LEFT TOK_RIGHT
%token <name> TOK_ID
 
%type <name> factor listID
%type <name> exp term dec dec_list

%left TOK_LEFT TOK_RIGHT
%left TOK_PLUS TOK_MINUS
%left TOK_MULTIPLY TOK_DIVIDE

%start prog



%%

prog: TOK_PROGRAM prog_name TOK_VAR dec_list TOK_BEGIN stmtlist TOK_END
	;
prog_name: TOK_ID
	;
dec_list: dec
	|
	dec_list TOK_SEMICOLON dec
	;
dec: listID TOK_COLON type
{	
		char * token = strtok($1,"|");
		while(token != NULL)
		{
			if(ts != NULL)
	{
	  if(ts->exists(token) == 0)
	  {
	    ts->add(token);
	  }
	  else
	  {
	    sprintf(msg,"%d:%d Eroare semantica: Declaratii multiple pentru variabila %s!", @1.first_line, @1.first_column, token);
	    yyerror(msg);
	    YYERROR;
	  }
	}
	else
	{
	  ts = new TVAR();
	  ts->add(token);
	}

		token = strtok(NULL,"|");
		}


	}
	;
type: TOK_INTEGER 
	;
listID: TOK_ID
	{	strcat($1,"|");
	}
	|
	listID TOK_COMMA TOK_ID
	{	strcat($3,"|");
		strcat($$,$3);}
	;
stmtlist: stmt
	|
	stmtlist TOK_SEMICOLON stmt
	;
stmt: assign
	|
	read
	|
	write
	|
	for
	;
assign: TOK_ID TOK_ASSIGNEMENT exp
	{
		
			printf("%s\n",$3);
		if( ts->exists($1) == 0 )
			{
				
				    	sprintf(msg,"Eroare semantica: Variabila este utilizata 						fara sa fi fost declarata!");
	    				yyerror(msg);
	    				YYERROR;
			}else
				{
					if( ts->exists($3) == 0 )
						{
							
							ts->setValue($1,atoi($3));
							
						}else
							{
								ts->setValue($1,ts->getValue($3));
							}					


				}


	}

	;
exp: term
	|
	exp TOK_PLUS term 
	
	{
		
		int aux1,aux2,aux3;
		char b[10];
		if( ts->exists($1) == 1 )
			{
				aux1=ts->getValue($1);

			}
		else { aux1=atoi($1);}

		if( ts->exists($3) == 1 )
			{
				aux2=ts->getValue($3);

			}
		else { aux2=atoi($3);}
	aux3=aux1+aux2;
	snprintf(b, 10, "%d", aux3);
	$$=b;
	

	}

	|
	exp TOK_MINUS term 
	{
		
		int aux1,aux2,aux3;
		char b[10];
		if( ts->exists($1) == 1 )
			{
				aux1=ts->getValue($1);

			}
		else { aux1=atoi($1);}

		if( ts->exists($3) == 1 )
			{
				aux2=ts->getValue($3);

			}
		else { aux2=atoi($3);}
	aux3=aux1-aux2;
	snprintf(b, 10, "%d", aux3);
	$$=b;
	

	}

	;
term: factor
	|
	factor TOK_MULTIPLY factor 
{	

		
		int aux1,aux2,aux3;
		char b[10];
		if( ts->exists($1) == 1 )
			{
				aux1=ts->getValue($1);

			}
		else { aux1=atoi($1);}

		if( ts->exists($3) == 1 )
			{
				aux2=ts->getValue($3);

			}
		else { aux2=atoi($3);}
	aux3=aux1*aux2;
	snprintf(b, 10, "%d", aux3);
	$$=b;
	

	}

	|
	factor TOK_DIVIDE term 
	
	;
factor: TOK_ID
	|
	TOK_INT
	|
	TOK_LEFT exp TOK_RIGHT 
	;
read: TOK_READ TOK_LEFT listID TOK_RIGHT
{
		char * token1 = strtok($3,"\n|");
		while(token1 != NULL)
		{
			if(ts->exists(token1)==0)
				{
					 sprintf(msg,"%d:%d Eroare semantica: Variabila %s este 					utilizata fara sa fi fost declarata!", @1.first_line, 						@1.first_column, token1);
	    					yyerror(msg);
	    					YYERROR;
				}
				else
				{
				ts->setValue(token1,1);
				}

		token1 = strtok(NULL,"\n|");
		}



	}
	;
write: TOK_WRITE TOK_LEFT listID TOK_RIGHT
{
char * token1 = strtok($3,"\n|");
		while(token1 != NULL)
		{
			if(ts->exists(token1)==1)
				{
					if(ts->getValue(token1)==-1)
{
sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost initializata!", @1.first_line, @1.first_column, token1);yyerror(msg);YYERROR;
}
else
		printf("%s = %d\n",token1,ts->getValue(token1));
					 
				}
				else
				{
						

			sprintf(msg,"%d:%d Eroare semantica: Variabila %s este utilizata fara sa fi fost declarata!", @1.first_line, @1.first_column, token1);yyerror(msg);YYERROR;}

		token1 = strtok(NULL,"\n|");
		}



}
	;
for: TOK_FOR index_exp TOK_DO body
	;
index_exp: TOK_ID TOK_ASSIGNEMENT exp TOK_TO exp
	;
body: stmt
	|
	TOK_BEGIN stmtlist TOK_END
	;

%%

int main()
{
	yyparse();
	
	if(EsteCorecta == 1)
	{
		printf("CORECTA\n");		
	}	

       return 0;
}

int yyerror(const char *msg)
{
	printf("Error: %s pe linia %d si coloana %d \n", msg,lineNo,colNo);
	EsteCorecta=0;
	return 1;
}








































