grammar IsiLang;

@header{
	import br.edu.ufabc.isilanguage.compiler.datastructures.Symbol;
	import br.edu.ufabc.isilanguage.compiler.datastructures.Variable;
	import br.edu.ufabc.isilanguage.compiler.datastructures.SymbolTable;
	import br.edu.ufabc.isilanguage.compiler.exceptions.IsiException;
	import br.edu.ufabc.isilanguage.compiler.ast.IsiProgram;
	import br.edu.ufabc.isilanguage.compiler.ast.AbstractCommand;
	import br.edu.ufabc.isilanguage.compiler.ast.CommandEnquanto;
	import br.edu.ufabc.isilanguage.compiler.ast.CommandLeitura;
	import br.edu.ufabc.isilanguage.compiler.ast.CommandEscrita;
	import br.edu.ufabc.isilanguage.compiler.ast.CommandAtribuicao;
	import br.edu.ufabc.isilanguage.compiler.ast.CommandDecisao;
	import java.util.ArrayList;
	import java.util.Stack;
}

@members{
	private int _tipo;
	private String _varName;
	private String _varValue;
	private ArrayList<Integer> _tipoVar = new ArrayList<Integer>();
	private IsiSymbolTable symbolTable = new IsiSymbolTable();
	private IsiSymbol symbol;
	private IsiProgram program = new IsiProgram();
	private ArrayList<AbstractCommand> curThread;
	private Stack<ArrayList<AbstractCommand>> stack = new Stack<ArrayList<AbstractCommand>>();
	private String _opfunmat;
	private String _readID;
	private String _writeID;
	private String _exprID;
	private String _exprContent;
	private String _exprDecision;
	private ArrayList<AbstractCommand> listaTrue;
	private ArrayList<AbstractCommand> listaFalse;
	private ArrayList<AbstractCommand> listaEnq;


	public void verificaID(String id){
		if (!symbolTable.exists(id))
			throw new IsiSemanticException("Symbol "+id+" not declared");
	}

	public String typeToString(int isiType) {
		switch (isiType) {
			case 0:
				return "NUMBER";
			case 1:
				return "TEXT";
			case 2:
				return "CHAR";
			case 3:
				return "BOOLEAN";
			default:
				return "";
		}
	}

	public void verificaCompatibilidade(ArrayList<Integer> tipos) {
		int tipoEsq = tipos.get(0);
		for (int tipo: tipos) {
			if (tipoEsq != tipo) {
				String errorMsg = String.format("Type mismatch: %s and %s", typeToString(tipoEsq), typeToString(tipo));
				tipos.removeAll(tipos);
				throw new IsiSemanticException(errorMsg);
			}
		}
		tipos.removeAll(tipos);
	}

	public void verificaAttrib(String id) {
		if (symbolTable.exists(id) && symbolTable.get(id) == null)
			throw new IsiSemanticException(String.format("\"%s\" has not been initialized.", id));
	}

	public void checkInitialized(String id) {
        if(!symbolTable.checkInitialized(id))
            throw new IsiSemanticException("Symbol "+id+" not initialized");
    }

    public void setInitialized(String id) {
        symbolTable.setInitializedBy(id);
    }

    public void showWarningsUnusedVariables() {
        for(IsiSymbol s: symbolTable.getNotUsedSymbols())
            System.out.println("Warning: Variável <" + s.getName() + "> foi declarada, mas nao utilizada");
    }

	public void exibeComandos(){
		for (AbstractCommand c: program.getComandos())
			System.out.println(c);
	}

	public String generateCode(){
		return program.generateTarget();
	}

	public ArrayList<String> getWarnings() {
        ArrayList<String> warnings = new ArrayList<String>();
        for(IsiSymbol s: symbolTable.getNotUsedSymbols())
            warnings.add(String.format("Warning: Variavel <%s> foi declarada, mas nao utilizada", s.getName()));
        return warnings;
    }
}

prog : 'programa'
	   decl
	   bloco
	   'fimprog;' {
					program.setVarTable(symbolTable);
					program.setComandos(stack.pop());
					showWarningsUnusedVariables();
				  }
	 ;

decl    :  (declaravar)+
        ;


declaravar :  tipo  ID   {
	                      	 _varName = _input.LT(-1).getText();
	                      	 _varValue = null;
	                      	 symbol = new IsiVariable(_varName, _tipo, _varValue);
	                      	 if (!symbolTable.exists(_varName))
	                      	    symbolTable.add(symbol);
	                      	 else
	                      	 	 throw new IsiSemanticException("Symbol "+_varName+" already declared");
                         }
                    (
					VIR
              	    ID   {
	                  		 _varName = _input.LT(-1).getText();
	                  		 _varValue = null;
	                  		 symbol = new IsiVariable(_varName, _tipo, _varValue);
	                  		 if (!symbolTable.exists(_varName))
	                  		    symbolTable.add(symbol);
	                  		 else
	                  		 	 throw new IsiSemanticException("Symbol "+_varName+" already declared");
                         }
              	    )*
               	    SC
           ;

tipo       : 'numero' 	 { _tipo = IsiVariable.NUMBER;  }
           | 'texto' 	 { _tipo = IsiVariable.TEXT;  }
           | 'caractere' { _tipo = IsiVariable.CHAR;  }
           | 'logico' 	 { _tipo = IsiVariable.BOOLEAN;  }
           ;

bloco	: {
			curThread = new ArrayList<AbstractCommand>();
	        stack.push(curThread);
          }
          (cmd)+
		;


cmd		:  cmdleitura
 		|  cmdescrita
 		|  cmdattrib
 		|  cmdselecao
		|  cmdenquanto
		;

cmdleitura	: 'leia'
			  AP
			  ID {
					verificaID(_input.LT(-1).getText());
					_readID = _input.LT(-1).getText();
				 }
			  FP
			  SC {
					IsiVariable var = (IsiVariable)symbolTable.get(_readID);
					CommandLeitura cmd = new CommandLeitura(_readID, var);
					setInitialized(_readID);
					stack.peek().add(cmd);
				 }
			;
cmdescrita	: 'escreva'
                 AP
                 ID  {
						verificaID(_input.LT(-1).getText());
	                  	_writeID = _input.LT(-1).getText();
						checkInitialized(_writeID);
                     }
                 FP
                 SC  {
               		 	CommandEscrita cmd = new CommandEscrita(_writeID);
               	  		stack.peek().add(cmd);
               		 }
			;

cmdattrib	:  ID 	{
						verificaID(_input.LT(-1).getText());
						verificaAttrib(_input.LT(-1).getText());
                    	_exprID = _input.LT(-1).getText();
						_tipoVar.add(symbolTable.getTypeBy(_exprID));
                    }
               ATTR {
						_exprContent = "";
					}
               expr
               SC   {
				 		verificaCompatibilidade(_tipoVar);
               	 		CommandAtribuicao cmd = new CommandAtribuicao(_exprID, _exprContent);
						setInitialized(_exprID);
						stack.peek().add(cmd);
               		}
			;


cmdselecao  :  'se' AP
                    ID    		  {
									verificaID(_input.LT(-1).getText());
									verificaAttrib(_input.LT(-1).getText());
									_exprDecision = _input.LT(-1).getText();
									_tipoVar.add(symbolTable.getTypeBy(_input.LT(-1).getText()));
						  		  }
                    OPREL 		  { _exprDecision += _input.LT(-1).getText(); }
                    (ID | NUMBER) {
									verificaAttrib(_input.LT(-1).getText());
									if (_input.LT(-1).getText().matches("\\d+(\\.\\d+)?"))
										_tipoVar.add(IsiVariable.NUMBER);
									else {
										verificaID(_input.LT(-1).getText());
										_tipoVar.add(symbolTable.getTypeBy(_input.LT(-1).getText()));
									}
									_exprDecision += _input.LT(-1).getText();
								  }
                    FP 			  { verificaCompatibilidade(_tipoVar); }
                    ACH			  {
									curThread = new ArrayList<AbstractCommand>();
                    				stack.push(curThread);
                    			  }
                    (cmd)+

                    FCH			  { listaTrue = stack.pop(); }
                    (
					'senao'
                   	ACH
								  {
									curThread = new ArrayList<AbstractCommand>();
									stack.push(curThread);
								  }
                   	(cmd+)
                   	FCH
								  {
									listaFalse = stack.pop();
									CommandDecisao cmd = new CommandDecisao(_exprDecision, listaTrue, listaFalse);
									stack.peek().add(cmd);
								  }
                    )?
            ;

cmdenquanto  : 			  'enquanto'
						  AP

						  ID		    {
									 	  verificaID(_input.LT(-1).getText());
										  verificaAttrib(_input.LT(-1).getText());
										  _exprDecision = _input.LT(-1).getText();
										  _tipoVar.add(symbolTable.getTypeBy(_input.LT(-1).getText()));
										}
						  OPREL 		{ _exprDecision += _input.LT(-1).getText(); }
						  (ID | NUMBER)
						 				{
											verificaAttrib(_input.LT(-1).getText());
											if (_input.LT(-1).getText().matches("\\d+(\\.\\d+)?"))
												_tipoVar.add(IsiVariable.NUMBER);
											else {
												verificaID(_input.LT(-1).getText());
												_tipoVar.add(symbolTable.getTypeBy(_input.LT(-1).getText()));
											}
											_exprDecision += _input.LT(-1).getText();
										}
						  FP 			{ verificaCompatibilidade(_tipoVar); }
						  'faca'
                          ACH
                           				{
										  curThread = new ArrayList<AbstractCommand>();
                           				  stack.push(curThread);
                           				}
                          (cmd)+

                          FCH
                          				{
                            			  listaEnq = stack.pop();
                            			  CommandEnquanto cmd = new CommandEnquanto(_exprDecision, listaEnq);
                            			  stack.peek().add(cmd);
                           				}
			 ;


expr		:  (termo|funcaomat)
			   (
	           OP  { _exprContent += _input.LT(-1).getText(); }
	           (termo|funcaomat)
	           )*
		    ;

funcaomat : OPFUNCAOMAT {
						  _opfunmat = _input.LT(-1).getText();
						  if (_input.LT(-1).getText().equals("logaritmo"))
							_exprContent += String.format("(%s", _input.LT(-1).getText());
						  else
						  	_exprContent += _input.LT(-1).getText();
						}
			AP 			{
						  _exprContent += _input.LT(-1).getText();
						}
			(NUMBER|ID) {
						  if (_input.LT(-1).getText().matches("\\d+(\\.\\d+)?"))
						  	_tipoVar.add(IsiVariable.NUMBER);
						  else {
						  	verificaID(_input.LT(-1).getText());
							checkInitialized(_input.LT(-1).getText());
	               	   	  	_tipoVar.add(symbolTable.getTypeBy(_input.LT(-1).getText()));
						  }

						  _exprContent += _input.LT(-1).getText();
						}
			VIR		    {
						  if (_opfunmat.equals("logaritmo")) {
							_exprContent += ") / Math.log(";
						  }
						  else
						  	_exprContent += _input.LT(-1).getText();
						}
			(NUMBER|ID) {
						  if (_input.LT(-1).getText().matches("\\d+(\\.\\d+)?"))
						  	_tipoVar.add(IsiVariable.NUMBER);
						  else {
						  	verificaID(_input.LT(-1).getText());
							checkInitialized(_input.LT(-1).getText());
						  	_tipoVar.add(symbolTable.getTypeBy(_input.LT(-1).getText()));
						  }

						  if (_opfunmat.equals("raiz"))
							_exprContent += String.format("1/%s", _input.LT(-1).getText());
						  else
						    _exprContent += _input.LT(-1).getText();
						}
			FP 			{
						  if (_opfunmat.equals("logaritmo"))
						  	_exprContent += _input.LT(-1).getText();
						  _exprContent += _input.LT(-1).getText();
						}
			;

termo		: ID 	  {
				   	   	verificaID(_input.LT(-1).getText());
						checkInitialized(_input.LT(-1).getText());
	               	   	_tipoVar.add(symbolTable.getTypeBy(_input.LT(-1).getText()));
					   	_exprContent += _input.LT(-1).getText();
                 	  }
            | NUMBER  {
					   	_tipoVar.add(IsiVariable.NUMBER);
              		    _exprContent += _input.LT(-1).getText();
              		  }
			| CHAR    {
					    _tipoVar.add(IsiVariable.CHAR);
              		    _exprContent += _input.LT(-1).getText();
              		  }
			| TEXT    {
					    _tipoVar.add(IsiVariable.TEXT);
              		    _exprContent += _input.LT(-1).getText();
               		  }
			| BOOLEAN {
						_tipoVar.add(IsiVariable.BOOLEAN);
              			_exprContent += _input.LT(-1).getText();
               		  }
			;


AP	: '('
	;

FP	: ')'
	;

SC	: ';'
	;

OP	: '+' | '-' | '*' | '/'
	;

ATTR : '='
	 ;

VIR  : ','
     ;

ACH  : '{'
     ;

FCH  : '}'
     ;

OPREL : '>' | '<' | '>=' | '<=' | '==' | '!='
      ;

BOOLEAN : 'true'
		| 'false'
        ;

OPFUNCAOMAT : 'potencia'
			| 'logaritmo'
			| 'raiz'
		    ;

ID	: [a-z] ([a-z] | [A-Z] | [0-9])*
	;

NUMBER	: [0-9]+ ('.' [0-9]+)?
		;

TEXT : '"' ( '\\"' | . )*? '"'
	 ;

CHAR : '\'' ( '\\\'' | . ) '\''
     ;

WS	: (' ' | '\t' | '\n' | '\r') -> skip;

MLCOMMENT : ('/*' .*? '*/') -> skip;

SLCOMMENT: ('//' ~[\r\n]*)  -> skip;
