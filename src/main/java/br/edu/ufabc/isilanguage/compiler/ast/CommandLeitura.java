package br.edu.ufabc.isilanguage.compiler.ast;

import br.edu.ufabc.isilanguage.compiler.datastructures.Variable;

public class CommandLeitura extends AbstractCommand {
	
	private String id;
	private Variable var;
	
	public CommandLeitura (String id, Variable var) {
		this.id = id;
		this.var = var;
	}
	@Override
	public String generateJavaCode() {
		switch (var.getType()) {
			case Variable.NUMBER:
				return id +"= _key.nextDouble();";
			case Variable.TEXT:
				return id +"= _key.nextLine();";
			case Variable.CHAR:
				return id +"= _key.next().charAt(0);";
			case Variable.BOOLEAN:
				return id +"= _key.nextBoolean();";
			default:
				return "";
		}
	}
	@Override
	public String toString() {
		return "CommandLeitura [id=" + id + "]";
	}

}
