package br.edu.ufabc.isilanguage.compiler.ast;

import java.util.ArrayList;

public class CommandEnquanto extends AbstractCommand{
	private String condition;
	private ArrayList<AbstractCommand> lista;
	
	public CommandEnquanto(String condition, ArrayList<AbstractCommand> comandos) {
		this.condition = condition;
		this.lista = comandos;
	}

	@Override
	public String generateJavaCode() {
        StringBuilder str = new StringBuilder();
		str.append("while ("+condition+") {\n");
		for (AbstractCommand cmd: lista) {
			str.append("\t\t\t"+cmd.generateJavaCode());
		}
		str.append("\n}\n");
        return str.toString();
    }
    @Override
    public String toString() {
        return "CommandEnquanto [condition=" + condition + ", lista=" + lista + "]";
    }

}
