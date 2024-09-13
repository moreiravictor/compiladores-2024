package br.edu.ufabc.isilanguage.compiler;

import java.util.List;

public class CompilerOutput {
    private String generatedCode;
    private String errorMessage;
    private List<String> warningMessages;

    public CompilerOutput(String generatedCode, String errorMessage, List<String> warningMessages) {
        this.generatedCode = generatedCode;
        this.errorMessage = errorMessage;
        this.warningMessages = warningMessages;
    }

    public String getGeneratedCode() {
        return generatedCode;
    }

    public void setGeneratedCode(String generatedCode) {
        this.generatedCode = generatedCode;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public List<String> getWarningMessages() {
        return warningMessages;
    }

    public void setWarningMessages(List<String> warningMessages) {
        this.warningMessages = warningMessages;
    }
}
