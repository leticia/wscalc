SERVIDOR="http://localhost:8080"
TEM_FALHA=0

# Função para auxiliar na execução de cenários de teste.
function teste() {
    local nome="$1"
    local metodo="$2"
    local caminho="$3"
    local expectativa="$4"
    local resultado=""

    echo -n "TESTE: $nome. "

    resultado="$(curl -s -X"$metodo" "$SERVIDOR/$caminho")"

    if [[ "$resultado" == "$expectativa" ]]
    then
        echo "OK"
    else
        TEM_FALHA=1
        echo "FALHOU!!!"
        echo ">>> Esperava: '$expectativa', mas obteve: '$resultado'"
    fi
}

# Inicia o servidor em background e captura seu ID de processo
python3 server.py > /dev/null 2>&1 &
SERVIDOR_PID=$!

# Espera servidor iniciar (pode demorar por estar em background)
while ! curl -s -I "$SERVIDOR" > /dev/null 2>&1
do
    sleep 0.5
done

# === Cenários de teste ====

# Falta prefixo /wscalc
teste "retorna 404 para GET" "GET" "bananas" "Erro: 404. Not Found."
# teste "retorna 404 para POST" "POST" "bananas" "Erro: 404. Not Found."

# Função add
teste "add adiciona inteiros" "GET" "wscalc/add/2/1" "3"
teste "add adiciona pontos flutuantes" "GET" "wscalc/add/2.1/1" "3.1"
teste "add retorna 400 para 0 argumentos" "GET" "wscalc/add/" "Erro: 400. Bad Request."
teste "add retorna 400 para 1 argumento" "GET" "wscalc/add/2" "Erro: 400. Bad Request."
teste "add retorna 400 para 3 argumentos" "GET" "wscalc/add/2/3/4" "Erro: 400. Bad Request."
teste "add retorna 400 para argumento inválido" "GET" "wscalc/add/a/b" "Erro: 400. Bad Request."

# Função sub
teste "sub subtrai inteiros" "GET" "wscalc/sub/3/2" "1"
teste "sub subtrai pontos flutuantes" "GET" "wscalc/sub/2.1/1" "1.1"
teste "sub retorna 400 para 0 argumentos" "GET" "wscalc/sub/" "Erro: 400. Bad Request."
teste "sub retorna 400 para 1 argumento" "GET" "wscalc/sub/2" "Erro: 400. Bad Request."
teste "sub retorna 400 para 3 argumentos" "GET" "wscalc/sub/2/3/4" "Erro: 400. Bad Request."
teste "sub retorna 400 para argumento inválido" "GET" "wscalc/sub/a/b" "Erro: 400. Bad Request."

# Função mul
teste "mul multiplica inteiros" "GET" "wscalc/mul/3/2" "6"
teste "mul multiplica pontos flutuantes" "GET" "wscalc/mul/2.1/2" "4.2"
teste "mul retorna 400 para 0 argumentos" "GET" "wscalc/mul/" "Erro: 400. Bad Request."
teste "mul retorna 400 para 1 argumento" "GET" "wscalc/mul/2" "Erro: 400. Bad Request."
teste "mul retorna 400 para 3 argumentos" "GET" "wscalc/mul/2/3/4" "Erro: 400. Bad Request."
teste "mul retorna 400 para argumento inválido" "GET" "wscalc/mul/a/b" "Erro: 400. Bad Request."

# Função div
teste "div divide inteiros" "GET" "wscalc/div/10/5" "2"
teste "div divide pontos flutuantes" "GET" "wscalc/div/10.10/5" "2.02"
teste "div returna 400 para divisão por zero" "GET" "wscalc/div/10.0/0" "Erro: 400. Bad Request."
teste "div retorna 400 para 0 argumentos" "GET" "wscalc/div/" "Erro: 400. Bad Request."
teste "div retorna 400 para 1 argumento" "GET" "wscalc/div/2" "Erro: 400. Bad Request."
teste "div retorna 400 para 3 argumentos" "GET" "wscalc/div/2/3/4" "Erro: 400. Bad Request."
teste "div retorna 400 para argumento inválido" "GET" "wscalc/div/a/b" "Erro: 400. Bad Request."

# Função pow
teste "pow eleva inteiros" "GET" "wscalc/pow/10/2" "100"
teste "pow eleva pontos flutuantes" "GET" "wscalc/pow/10.5/2" "110.25"
teste "pow retorna 400 para 0 argumentos" "GET" "wscalc/pow/" "Erro: 400. Bad Request."
teste "pow retorna 400 para 1 argumento" "GET" "wscalc/pow/2" "Erro: 400. Bad Request."
teste "pow retorna 400 para 3 argumentos" "GET" "wscalc/pow/2/3/4" "Erro: 400. Bad Request."
teste "pow retorna 400 para argumento inválido" "GET" "wscalc/pow/a/b" "Erro: 400. Bad Request."

# Função log
teste "log de inteiro" "GET" "wscalc/log/10" "1"
teste "log de ponto flutuante" "GET" "wscalc/log/10.1" "1.0043213737826426"
teste "log retorna 400 para 0 argumentos" "GET" "wscalc/log/" "Erro: 400. Bad Request."
teste "log retorna 400 para 2 argumentos" "GET" "wscalc/log/2/2" "Erro: 400. Bad Request."
teste "log retorna 400 para argumento inválido" "GET" "wscalc/log/a" "Erro: 400. Bad Request."

# Função ln
teste "ln de inteiro" "GET" "wscalc/ln/10" "2.302585092994046"
teste "ln de ponto flutuante" "GET" "wscalc/ln/10.1" "2.312535423847214"
teste "ln retorna 400 para 0 argumentos" "GET" "wscalc/ln/" "Erro: 400. Bad Request."
teste "ln retorna 400 para 2 argumentos" "GET" "wscalc/ln/2/2" "Erro: 400. Bad Request."
teste "ln retorna 400 para argumento inválido" "GET" "wscalc/ln/a" "Erro: 400. Bad Request."

# Função lg
teste "lg de inteiro" "GET" "wscalc/lg/10" "3.321928094887362"
teste "lg de ponto flutuante" "GET" "wscalc/lg/10.1" "3.3362833878644325"
teste "lg retorna 400 para 0 argumentos" "GET" "wscalc/lg/" "Erro: 400. Bad Request."
teste "lg retorna 400 para 2 argumentos" "GET" "wscalc/lg/2/2" "Erro: 400. Bad Request."
teste "lg retorna 400 para argumento inválido" "GET" "wscalc/lg/a" "Erro: 400. Bad Request."

# Função sqrt
teste "sqrt de inteiro" "GET" "wscalc/sqrt/100" "10"
teste "sqrt de ponto flutuante" "GET" "wscalc/sqrt/100.1" "10.00499875062461"
teste "sqrt retorna 400 para 0 argumentos" "GET" "wscalc/sqrt/" "Erro: 400. Bad Request."
teste "sqrt retorna 400 para 2 argumentos" "GET" "wscalc/sqrt/2/2" "Erro: 400. Bad Request."
teste "sqrt retorna 400 para argumento inválido" "GET" "wscalc/sqrt/a" "Erro: 400. Bad Request."

# Função sq
teste "sq de inteiro" "GET" "wscalc/sq/10" "100"
teste "sq de ponto flutuante" "GET" "wscalc/sq/10.1" "102.00999999999999"
teste "sq retorna 400 para 0 argumentos" "GET" "wscalc/sq/" "Erro: 400. Bad Request."
teste "sq retorna 400 para 2 argumentos" "GET" "wscalc/sq/2/2" "Erro: 400. Bad Request."
teste "sq retorna 400 para argumento inválido" "GET" "wscalc/sq/a" "Erro: 400. Bad Request."

# Função sin
teste "sin de inteiro" "GET" "wscalc/sin/90" "0.8939966636005579"
teste "sin de ponto flutuante" "GET" "wscalc/sin/1.57079632679" "1"
teste "sin retorna 400 para 0 argumentos" "GET" "wscalc/sin/" "Erro: 400. Bad Request."
teste "sin retorna 400 para 2 argumentos" "GET" "wscalc/sin/2/2" "Erro: 400. Bad Request."
teste "sin retorna 400 para argumento inválido" "GET" "wscalc/sin/a" "Erro: 400. Bad Request."

# Função cos
teste "cos de inteiro" "GET" "wscalc/cos/10" "-0.8390715290764524"
teste "cos de ponto flutuante" "GET" "wscalc/cos/10.1" "-0.7805681801691837"
teste "cos retorna 400 para 0 argumentos" "GET" "wscalc/cos/" "Erro: 400. Bad Request."
teste "cos retorna 400 para 2 argumentos" "GET" "wscalc/cos/2/2" "Erro: 400. Bad Request."
teste "cos retorna 400 para argumento inválido" "GET" "wscalc/cos/a" "Erro: 400. Bad Request."

# Função tan
teste "tan de inteiro" "GET" "wscalc/tan/10" "0.6483608274590867"
teste "tan de ponto flutuante" "GET" "wscalc/tan/10.1" "0.8007893029375109"
teste "tan retorna 400 para 0 argumentos" "GET" "wscalc/tan/" "Erro: 400. Bad Request."
teste "tan retorna 400 para 2 argumentos" "GET" "wscalc/tan/2/2" "Erro: 400. Bad Request."
teste "tan retorna 400 para argumento inválido" "GET" "wscalc/tan/a" "Erro: 400. Bad Request."

# Função sec
teste "sec de inteiro" "GET" "wscalc/sec/10" "-1.1917935066878957"
teste "sec de ponto flutuante" "GET" "wscalc/sec/10.1" "-1.2811180693828126"
teste "sec retorna 400 para 0 argumentos" "GET" "wscalc/sec/" "Erro: 400. Bad Request."
teste "sec retorna 400 para 2 argumentos" "GET" "wscalc/sec/2/2" "Erro: 400. Bad Request."
teste "sec retorna 400 para argumento inválido" "GET" "wscalc/sec/a" "Erro: 400. Bad Request."

# Função mod
teste "mod de inteiro" "GET" "wscalc/mod/-10" "10"
teste "mod de ponto flutuante" "GET" "wscalc/mod/-10.2" "10.2"
teste "mod retorna 400 para 0 argumentos" "GET" "wscalc/mod/" "Erro: 400. Bad Request."
teste "mod retorna 400 para 2 argumentos" "GET" "wscalc/mod/2/2" "Erro: 400. Bad Request."
teste "mod retorna 400 para argumento inválido" "GET" "wscalc/mod/a" "Erro: 400. Bad Request."

# Função inv
teste "inv de zero" "GET" "wscalc/inv/0" "0"
teste "inv de inteiro" "GET" "wscalc/inv/2" "0.5"
teste "inv de ponto flutuante" "GET" "wscalc/inv/2.2" "0.45454545454545453"
teste "inv retorna 400 para 0 argumentos" "GET" "wscalc/inv/" "Erro: 400. Bad Request."
teste "inv retorna 400 para 2 argumentos" "GET" "wscalc/inv/2/2" "Erro: 400. Bad Request."
teste "inv retorna 400 para argumento inválido" "GET" "wscalc/inv/a" "Erro: 400. Bad Request."

# Função fac
teste "fac de inteiro" "GET" "wscalc/fac/5" "120"
teste "fac retorna 400 para flutuante" "GET" "wscalc/fac/5.2" "Erro: 400. Bad Request."
teste "fac retorna 400 para 0 argumentos" "GET" "wscalc/fac/" "Erro: 400. Bad Request."
teste "fac retorna 400 para 2 argumentos" "GET" "wscalc/fac/2/2" "Erro: 400. Bad Request."
teste "fac retorna 400 para argumento facálido" "GET" "wscalc/fac/a" "Erro: 400. Bad Request."

# Constantes
teste "const retorna pi" "GET" "wscalc/const/pi" "3.141592653589793"
teste "const retorna euler" "GET" "wscalc/const/euler" "2.718281828459045"
teste "constantes são números" "GET" "wscalc/add/pi/euler" "5.859874482048838"
teste "const retorna 400 constante desconhecida" "GET" "wscalc/const/xxx" "Erro: 400. Bad Request."
teste "const retorna 400 para 2 argumentos" "GET" "wscalc/const/pi/1" "Erro: 400. Bad Request."

# Variáveis
teste "var define x" "POST" "wscalc/var/x/1" "1"
teste "var retorna x" "GET" "wscalc/var/x" "1"
teste "var define y" "POST" "wscalc/var/y/2" "2"
teste "var retorna y" "GET" "wscalc/var/y" "2"
teste "var define z" "POST" "wscalc/var/z/3" "3"
teste "var retorna z" "GET" "wscalc/var/z" "3"
teste "variáveis são números: x+y" "GET" "wscalc/add/x/y" "3"
teste "variáveis são números: x+z" "GET" "wscalc/add/x/z" "4"
teste "var retorna 400 constante desconhecida" "GET" "wscalc/const/xxx" "Erro: 400. Bad Request."
teste "var retorna 400 para 2 argumentos" "GET" "wscalc/const/x/1" "Erro: 400. Bad Request."

# Finaliza o servidor em background
kill -9 "$SERVIDOR_PID"

if [[ "$TEM_FALHA" -gt 0 ]]
then
    exit 1
fi

exit 0
