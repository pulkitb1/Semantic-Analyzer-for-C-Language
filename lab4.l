%{
    #include<bits/stdc++.h>
	using namespace::std;
    #include "lab4.tab.h"
    void printfile()
    {
        fprintf(yyout,"%s",yytext);
        return;
    }
%}

MULTILINE_COMMENT "/*"([^*]|\*+[^*/])*\*+"/"
KEYWORD auto|double|int|struct|break|else|long|switch|case|enum|register|typedef|char|extern|return|union|const|float|short|unsigned|continue|for|signed|void|default|goto|sizeof|voltile|do|if|static|while

%%

[ \t] {
    printfile();
} 
"\n" {
    printfile();
    return NEWLINE;
}

^[#]+[a-zA-Z]+ {printfile();}
[<a-zA-Z]+".h>" {printfile();}

\/\/(.*) {printfile();}

{MULTILINE_COMMENT} {
    int count=0;
    for(int i=0;yytext[i]!='\0';i++)
    {
        if(yytext[i]=='\n')
        {
            count++;
        }    
    }
    printfile();
    yylval.num=count;
    return MULTINEWLINE;
    }

"exit" {
    //return exit_command;
}

"break" {
    return BREAK;
}

"continue" {
    return CONTINUE;
}

"main" {
    printfile();
    return MAIN;
}

"int" {
    
    yylval.id = 'i';
    printfile();
    return INT;
}

"return".*[;] {
    printfile();
    return RETURN;
}

"if" {
    printfile();
    return IF;
}

"else" {
    printfile();
    return ELSE;
}

[a-zA-Z] {
    yylval.id = yytext[0];
    printfile(); 
    return identifier; 
}
[0-9]+ {
    yylval.num = atoi(yytext); 
    printfile(); 
    return number;
}

[+-] {
    printfile();
    return yytext[0];
}

"*" {
    printfile();
    return yytext[0];
}

"/" {
    printfile();
    return '/';
}

[=,;] {
    printfile();
    return yytext[0];
}

"!" {
    printfile();
    return yytext[0];
}

"<" {
    printfile();
    return yytext[0];
}

">" {
    printfile();
    return yytext[0];
}

"&&" {
    printfile();
    return LOGICAL;

}

"||" {
    printfile();
    return LOGICAL;
}

"{" {
    yylval.id=yytext[0];
    printfile();
    return BRACKET;
}

"}" {
    yylval.id=yytext[0];
    printfile();
    return BRACKET;
}

"(" {
    printfile();
    return yytext[0];
}

")" {
    printfile();
    return yytext[0];
}

{KEYWORD} {
    printfile();
    return KEYTOKEN;
}

%%

int yywrap(void) {return 1;}