package br.edu.ufabc.isilanguage.compiler.datastructures;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

public class SymbolTable {
	
	private HashMap<String, Symbol> map;
	
	public SymbolTable() {
		map = new HashMap<String, Symbol>();
	}
	
	public void add(Symbol symbol) {
		map.put(symbol.getName(), symbol);
	}
	
	public boolean exists(String symbolName) {
		return map.get(symbolName) != null;
	}
	
	public Symbol get(String symbolName) {
		Symbol isiSymbol = map.get(symbolName);
		if (isiSymbol instanceof Variable)
			isiSymbol.setUsed();
		return isiSymbol;
	}

	public List<Symbol> getNotUsedSymbols() {
		ArrayList<Symbol> symbols = this.getAll();
		return symbols.stream()
				.filter(symbol -> !symbol.isUsed)
				.collect(Collectors.toList());
	}
	
	public int getTypeBy(String id) {
		Variable variable = (Variable) this.get(id);
		return variable.getType();
	}

	public boolean checkInitialized(String id) {
		Symbol symbol = this.get(id);
		return symbol.isInitialized();
	}

	public void setInitializedBy(String id) {
		Variable variable = (Variable) this.get(id);
		variable.setInitialized();
	}

	public ArrayList<Symbol> getAll(){
		ArrayList<Symbol> list = new ArrayList<>();
		for (Symbol symbol : map.values()) {
			list.add(symbol);
		}
		return list;
	}
}
