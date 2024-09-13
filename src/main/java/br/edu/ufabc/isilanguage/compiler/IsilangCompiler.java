package br.edu.ufabc.isilanguage.compiler;

import br.edu.ufabc.isilanguage.compiler.exceptions.IsiException;
import br.edu.ufabc.isilanguage.compiler.parser.IsiLangLexer;
import br.edu.ufabc.isilanguage.compiler.parser.IsiLangParser;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;

import java.util.ArrayList;

public class IsilangCompiler {
    public CompilerOutput compile(String source) {
        String content = "";
        ArrayList<String> warnings = new ArrayList<>();
        String error = "";

        try {
            IsiLangLexer lexer = new IsiLangLexer(CharStreams.fromString(source));
            CommonTokenStream tokenStream = new CommonTokenStream(lexer);
            IsiLangParser parser = new IsiLangParser(tokenStream);

            parser.prog();
            content = parser.generateCode();
            warnings = parser.getWarnings();

        } catch (IsiException ex) {
            error = "Semantic error: " + ex.getMessage();

        } catch (NullPointerException ex) {
            error = "Compilation error: Unexpected null value encountered - " + ex.getMessage();

        } catch (Exception ex) {
            error = "General error: " + ex.getMessage();
            ex.printStackTrace();
        }

        return new CompilerOutput(content, error, warnings);
    }
}
