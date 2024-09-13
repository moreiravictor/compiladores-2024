package br.edu.ufabc.isilanguage.server.controller;

import br.edu.ufabc.isilanguage.compiler.CompilerOutput;
import br.edu.ufabc.isilanguage.compiler.IsilangCompiler;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;

@RestController
public class Controller {
    private String decode(String value) throws UnsupportedEncodingException {
        return URLDecoder.decode(value, StandardCharsets.UTF_8.toString());
    }
    private IsilangCompiler compiler = new IsilangCompiler();
    @CrossOrigin
    @GetMapping("/exec")
    public CompilerOutput compile(
            @RequestParam(
                    value="source",
                    defaultValue = "programa\n\tnumero x;\nfimprog;"
            ) String source
    ) {
        CompilerOutput compilerOutput;
        try {
            compilerOutput = compiler.compile(decode(source));
        }
        catch (UnsupportedEncodingException ex) {
            ex.printStackTrace();
            compilerOutput = new CompilerOutput("invalid code!", ex.getMessage(), new ArrayList<>());
        }
        return compilerOutput;
    }
}
