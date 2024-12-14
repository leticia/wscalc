const display = document.getElementById("display");
const constNames = { 'π': 'pi', 'e': 'euler' };
let dirty = false;
let stack = null;

function isNumber(value) {
    return parseFloat(value) != NaN;
}

function isVar(name) {
    return ['x', 'y', 'z'].includes(name);
}

function isConst(name) {
    return !!constNames[name];
}

function appendToDisplay(input) {
    if (!dirty && isNumber(display.value) && isNumber(input)) {
        display.value += input;
    } else {
        display.value = input;
        dirty = false;
    }
}

function clearDisplay() {
    display.value = "";
    stack = null;
    dirty = false;
}

function clearEntry() {
    if (isNumber(display.value)) {
        display.value = display.value.slice(0, -1);
    } else {
        display.value = "";
    }
}

function toggleSign() {
    if (isNumber(display.value)) {
        display.value = display.value.startsWith("-")
            ? display.value.slice(1)
            : "-" + display.value;
    }
}

function pushStack(operator, value) {
    stack = { operator, value };
    dirty = true;
}

function popStack(value) {
    if (stack) {
        return sendRequest("GET", stack.operator, stack.value, value).
            then(result => {
                stack = null;
                return result;
            });
    } else {
        return Promise.resolve(value);
    }
}

function unaryOperation(operator) {
    popStack(display.value)
        .then(result =>
            sendRequest("GET", operator, result)
                .then(result => {
                    display.value = result;
                    dirty = true;
                })
        );
}

function binaryOperation(operator) {
    popStack(display.value)
        .then(result => {
            pushStack(operator, result);
        })
}

function equal() {
    let result;

    if (stack) {
        result = popStack(display.value);
    } else if (isVar(display.value)) {
        result = sendRequest("GET", "var", display.value);
    } else if (isConst(display.value)) {
        result = sendRequest("GET", "const", display.value);
    }

    if (result) {
        result.then(value => display.value = value);
        dirty = true;
    }
}

function saveVar(name) {
    sendRequest("POST", "var", name, display.value);
    dirty = true;
}

function sendRequest(method, operator, arg1, arg2) {
    if (isConst(arg1)) arg1 = constNames[arg1];
    if (isConst(arg2)) arg2 = constNames[arg2];

    let url = `http://localhost:8080/wscalc/${operator}/${arg1}`;
    if (arg2) url += `/${arg2}`

    return fetch(url, {method})
        .then(res =>
            res.text().then(body => {
                if (res.ok) return body;
                throw new Error(body);
            })
        )
        .catch(err => {
            display.value = "Erro";
            console.error(err);
            throw err;
        });
}
