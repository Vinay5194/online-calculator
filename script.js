const display = document.getElementById("display");
const buttons = document.querySelectorAll("button");

let expression = "";
let finished = false;

function show() {
    display.value = expression || "0";
}

function calculate() {
    try {
        if (!expression || !/^[0-9+\-*/%.() ]+$/.test(expression)) {
            throw new Error("Invalid expression");
        }

        const result = Function('"use strict"; return (' + expression + ')')();

        if (typeof result !== "number" || !Number.isFinite(result)) {
            throw new Error("Invalid result");
        }

        expression = String(Number(result.toPrecision(12)));
        finished = true;
        show();
    } catch {
        display.value = "Error";
        expression = "";
        finished = false;
    }
}

buttons.forEach(button => {
    button.addEventListener("click", () => {
        const action = button.dataset.action;
        const value = button.dataset.value;

        if (action === "clear") {
            expression = "";
            finished = false;
            show();
            return;
        }

        if (action === "delete") {
            expression = expression.slice(0, -1);
            finished = false;
            show();
            return;
        }

        if (action === "calculate") {
            calculate();
            return;
        }

        if (finished) {
            expression = "";
            finished = false;
        }

        expression += value;
        show();
    });
});
