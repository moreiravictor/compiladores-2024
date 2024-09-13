package br.edu.ufabc.isilanguage.compiler.ast;

import java.util.ArrayList;

import br.edu.ufabc.isilanguage.compiler.datastructures.Symbol;
import br.edu.ufabc.isilanguage.compiler.datastructures.SymbolTable;

public class IsiProgram {
	private SymbolTable varTable;
	private ArrayList<AbstractCommand> comandos;
	private String programName;

	public String generateTarget() {
		StringBuilder str = new StringBuilder();
		str.append("import java.util.Scanner;\n");
		str.append("public class MainClass { \n");
		str.append("\tpublic static void main(String args[]){\n ");
		str.append("\t\tScanner _key = new Scanner(System.in);\n");
		for (Symbol symbol: varTable.getAll()) {
			str.append("\t\t"+symbol.generateJavaCode()+"\n");
		}
		for (AbstractCommand command: comandos) {
			str.append("\t\t"+command.generateJavaCode()+"\n");
		}
		str.append("\t}\n");
		str.append("}");

		return str.toString();
	}

	public SymbolTable getVarTable() {
		return varTable;
	}

	public void setVarTable(SymbolTable varTable) {
		this.varTable = varTable;
	}

	public ArrayList<AbstractCommand> getComandos() {
		return comandos;
	}

	public void setComandos(ArrayList<AbstractCommand> comandos) {
		this.comandos = comandos;
	}

	public String getProgramName() {
		return programName;
	}

	public void setProgramName(String programName) {
		this.programName = programName;
	}

}
