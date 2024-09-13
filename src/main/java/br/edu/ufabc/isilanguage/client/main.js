window.addEventListener("DOMContentLoaded", () => {
    let inputEditor = CodeMirror.fromTextArea(document.getElementById("input"), {
        mode: "text/x-java",
        indentWithTabs: true,
        smartIndent: true,
        lineNumbers: true,
        lineWrapping: true,
        matchBrackets: true,
        autofocus: true,
        theme: "yeti",
    });
    let outputEditor = CodeMirror.fromTextArea(document.getElementById("output"), {
        mode: "text/x-java",
        indentWithTabs: true,
        smartIndent: true,
        lineNumbers: true,
        lineWrapping: true,
        matchBrackets: true,
        autofocus: true,
        theme: "yeti",
    });

    document.getElementById("exec").addEventListener('click', async () => {
        const baseUrl = "http://localhost:8080";
        const endpoint = "/exec";
        let userInput = inputEditor.getValue().trimEnd();
        const encodedInput = encodeURI(userInput);

        try {
            const response = await fetch(`${baseUrl}${endpoint}?source=${encodedInput}`);
            const result = await response.json();

            if (result.errorMessage) {
                document.getElementById('error').textContent = result.errorMessage;
                outputEditor.getDoc().setValue('');
            } else {
                const output = result.generatedCode;
                document.getElementById("output").value = output;
                outputEditor.getDoc().setValue(output);
                document.getElementById('error').textContent = '';
            }

            if (result.warningMessages.length > 0) {
                document.getElementById('warnings').innerHTML = result.warningMessages.join('<br />');
            } else {
                document.getElementById('warnings').textContent = '';
            }
        } catch (error) {
            console.error("An error occurred during execution:", error);
        }
    });
});