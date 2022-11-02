%{
    #include <bits/stdc++.h>
    using namespace::std;
    ofstream symfile;
    int lc=1;
    int errorbit=0;
    void yyerror(char *s);
    int yylex(void);
    vector<vector<pair<int,int>>> symtab;
    stack<int> ifstack;
    stack<char> brackets;
    int currdepth=-1;   
    void setSymbolValue(char symbol, int val, int flag);
    void getSymbolValue(char symbol1,char symbol2 , int flag);
    void declareSymbol(char symbol);
    void checkScope(char bracket);
    void checkValidIdentifier (char symbol1);
    void generateError(string str);
    int getValue (char symbol);
    void operationsIF(int mode);
    void checkDivide (int val);
    void beginScope(int mode);
    void printSymbolTable(int i);
%}

%start line
%union {int num; char id;}

%token <id> identifier
%token <num> number
%token IF ELSE
%token BREAK
%token CONTINUE
%token RETURN
%token KEYTOKEN
%token INT
%token MAIN
%token <id> BRACKET
%token <id> LOGICAL
%token NEWLINE
%token <num> MULTINEWLINE

%type <id> term exp arithmetic_operation key conditions

%%
line        :   line BREAK                          {yyerror("error:break statement not inside loop.");}
            |   line CONTINUE                       {yyerror("error:continue statement not inside loop.");}
            |   line RETURN                         {;}
            |   line NEWLINE                        {lc++;}
            |   line MULTINEWLINE                   {lc+=$2;}
            |   line BRACKET                        {checkScope($2);}
            |   line arithmetic_operation           {;}
            |   line INT key                        {;}
            |   line IF '(' conditions ')'          {operationsIF(0);}
            |   line ELSE                           {operationsIF(2);}
            |   line '('                            {;}
            |   line ')'                            {;}
            |   /*Epsilon*/                         {;}
            ;

arithmetic_operation : identifier '=' exp ';'       {setSymbolValue($1,$3,0);}
                     ;

exp         : term                                  {$$=$1;}
            | exp '+' term                          {$$=$1 + $3;}
            | exp '-' term                          {$$=$1 - $3;}
            | exp '*' term                          {$$=$1 * $3;}
            | exp '/' term                          {checkDivide($3);$$=$1 / $3;}
            ;


term        : number                                {$$ = $1;}
            | identifier                            {checkValidIdentifier($1); $$ = getValue($1);}
            ;


key         :   MAIN                                {;}
            |   identifier ';'                      {declareSymbol($1);}
            |   identifier ',' key                  {declareSymbol($1);}
            |   identifier '=' identifier ';'       {getSymbolValue($1,$3,1);}
            |   identifier '=' number ';'           {setSymbolValue($1,$3,1);}
            |   identifier '=' number ',' key       {setSymbolValue($1,$3,1);}
            |   KEYTOKEN                            {yyerror("error:cannot use keyword as variable")}
            ;

conditions  :  conditions LOGICAL conditions        {;}
            |  identifier                           {checkValidIdentifier($1);}
            |  '!' identifier                       {checkValidIdentifier($2);}
            |  identifier '=' '=' identifier        {checkValidIdentifier($1);checkValidIdentifier($4);}
            |  identifier '<' identifier            {checkValidIdentifier($1);checkValidIdentifier($3);}
            |  identifier '>' identifier            {checkValidIdentifier($1);checkValidIdentifier($3);}
            |  identifier '<' '=' identifier        {checkValidIdentifier($1);checkValidIdentifier($4);}
            |  identifier '>' '=' identifier        {checkValidIdentifier($1);checkValidIdentifier($4);}
            |  identifier '!' '=' identifier        {checkValidIdentifier($1);checkValidIdentifier($4);}
            ;
%%


void operationsIF(int mode) {
    if (mode==0) {                                                         // pushing mode.
        if (!ifstack.empty()&&ifstack.top()!=currdepth)
            ifstack.push(currdepth);
        else if (ifstack.empty()){
            ifstack.push(currdepth);
        }
    }
    else if (mode==1){
        ifstack.pop();
    }
    else
    {
       
        if (ifstack.empty() || ifstack.top()!=currdepth)
        {
            yyerror("error: 'else' without a previous 'if'");
        }
        else
        {
             ifstack.pop();
        }
    }  
}

void checkDivide (int val){
    if (val==0){
        yyerror("error:division by zero");
        exit(0);
    }
}

int getValue (char symbol){
    
    int temp = symbol,index;
    if(temp>=97&&temp<=122)
        index=temp-97;
    else
        index = temp-39;

    for (int i=currdepth;i>=0;i--){
        if (symtab[index][i].first==1){
            return symtab[index][i].second;
        }
    }
}

void generateError(string str){
    char *msg= new char[str.length()];
    for(int j=0;j<str.length();j++)
    {
        msg[j]=str[j];
    }
    yyerror(msg);
}

void checkValidIdentifier (char symbol1){
    

    int temp = symbol1;
    int index;

    if (temp>=65&&temp<=90)
        index = temp - 39;  
    else
        index = temp - 97;

    int cnt=0;
    for (int i=currdepth;i>=0;i--) {                     
        if (symtab[index][i].first==1){
            cnt++;
            break;    
        }
    }

    if (!cnt){                                  //if count is 0 then the variable was not declared anywhere
        string str = "error: '";
        str+=char(temp);
        str+="' undeclared";
        generateError(str);   
    }
}

void beginScope(int mode){

    // mode -> 0 first time
    // mode -> 1 rest of the time

    currdepth++;
    
    if (!mode){
        pair<int,int> p={0,0};
        vector<pair<int,int>> temp;
        temp.push_back(p);
        
        for(int i=0;i<52;i++)
        {
            symtab.push_back(temp);
        }
    }
    
    else {

        pair<int,int> p={0,0};               
        for(int i=0;i<52;i++)
        {
            symtab[i].push_back(p);
        }
    }
    
}

void getSymbolValue(char symbol1, char symbol2 , int flag){
    int temp1 = symbol1;
    int temp2 = symbol2;

    int index1,index2;

    if(temp1>=97&&temp1<=122)
        index1=temp1-97;
    else
        index1 = temp1-39;

    if(temp2>=97&&temp2<=122)
        index2=temp2-97;
    else
        index2 = temp2-39;


    if (flag==0){

        int fl1=0,i,fl2=0,i1,i2;
        for (i=currdepth;i>=0;i--){
            if (!fl1&&symtab[index1][i].first==1)
            {
                fl1 = 1;
                i1=i;
            }

            if (!fl2&&symtab[index2][i].first==1){
                fl2 = 1;
                i2=i;
            }
        }
        if (!fl1&&!fl2) {
            yyerror("error:Variable Not Initialized");
        }
        else {
            symtab[index1][i1].second = symtab[index2][i2].second;
        }
    }

    else {

        int i,fl = 0;
        for (i=currdepth;i>=0;i--){
            if (symtab[index2][i].first==1){
                fl=1;
                break;
            }
        }
        if (!fl) {
            yyerror("error:Variable Not Initialized");
        }
    }

}

void declareSymbol(char symbol) {

    int index,temp=symbol;
    if(temp>=97&&temp<=122)
    {
        index=temp-97;
        if(symtab[index][currdepth].first==1)	//variable in this scope already declared
        {
            string str="error: redeclaration of '";
            str+=char(temp);
            str+="' with no linkage";
            char *msg= new char[str.length()];

            for(int j=0;j<str.length();j++)
            {
                msg[j]=str[j];
            }
            yyerror(msg);
        }
        else
        {
            symtab[index][currdepth].first=1;
        }
    }
    else if(temp>=65&&temp<=90)
    {
        index=temp-39;
        if(symtab[index][currdepth].first==1)	//variable in this scope already declared
        {
            string str="error: redeclaration of '";
            str+=char(temp);
            str+="' with no linkage";
            char *msg= new char[str.length()];

            for(int j=0;j<str.length();j++)
            {
                msg[j]=str[j];
            }
            yyerror(msg);
        }
        else
        {
            symtab[index][currdepth].first=1;
        }
    }
}

void setSymbolValue(char symbol, int val, int flag) {   
    int temp=symbol;
    int index;
    if(temp>=97&&temp<=122)
    {
        index=temp-97;
    }
    else if(temp>=65&&temp<=90)
    {
        index=temp-39;
    }

    int i,fl=0;
    for (i=currdepth;i>=0;i--)
    {
        if (symtab[index][i].first==1)
        {
            fl=1;
            break;
        }
    }

    if(flag==0&&fl)     // some fl should be found ie variable should be declared in some scope
    {
        symtab[index][i].second=val;
    }
    else if(flag==1&&!fl) // flag =  1 and changing value of uninitialized variable.
    {
        symtab[index][currdepth].first=1;
        symtab[index][currdepth].second=val;
    }
    else if(flag==0&&!fl)
    {
        string str="error: uninitialized variable '";
        str+=char(temp);
        str+="' used";
        generateError(str);       
    }
    else if(flag==1&&fl)
    {
        if(currdepth>i)
        {
            symtab[index][currdepth].first=1;
            symtab[index][currdepth].second=val;
        }
        else if(currdepth==i)
        {
            string str="variable already initialized";
            generateError(str);  
        }     
    }
}

void printSymbolTable(int i) {

        for(int j=0;j<i;j++)
            symfile<<"\t\t";
        symfile<<"SYMBOL TABLE FOR SCOPE : "<<i<<endl;
        for (int j=0;j<52;j++){
            if (symtab[j][i].first==1){
                if (j>=0&&j<=25)
                {
                    for(int j=0;j<i;j++)
                        symfile<<"\t\t";
                    symfile<<char(j+97)<<" : "<<symtab[j][i].second<<endl;
                }
                else
                {
                    for(int j=0;j<i;j++)
                        symfile<<"\t\t";
                    symfile<<char(j+65)<<" : "<<symtab[j][i].second<<endl;
                }
            }
        }
}

void checkScope (char bracket) {
    if (bracket=='{'){
        if (currdepth==-1){           
            beginScope(0);
        }
        else if (currdepth>=symtab[0].size()-1){          
            beginScope(1);
        }       

        else {   // if we already in a previously created scope.
            currdepth++;
        }

        brackets.push('{');
    }
    else{
        if(brackets.empty()){
            yyerror("error: stray }");
        }
        else{
            printSymbolTable(currdepth);
            brackets.pop();
            for(int i=0;i<52;i++)                   //deprecating variables after exiting scope
            {
                symtab[i][currdepth].first=0;
                symtab[i][currdepth].second=0;

            }
            currdepth--;
            if (!ifstack.empty()&&ifstack.top()>currdepth)
            {
                operationsIF(1);
            }
            
        }
    }
}

int main() {   
    symfile.open ("symboltable.txt");
    extern FILE *yyin, *yyout; 
	yyin = fopen("input.c","r");
    yyout = fopen("output.c", "w");
    int x = yyparse();

    if (!brackets.empty()){
        yyerror("error:unbalanced brackets");
    }
    if(!errorbit)
    {
       cout<<"Compiled Successfully!!\n";
    }
    return 0;
}

void yyerror(char *s) {
    fprintf(stderr, "%s on line no. %d\n", s,lc);
    errorbit=1;
}