import argparse
import math
from http import HTTPStatus
from http.server import HTTPServer, BaseHTTPRequestHandler

# Porta padrão do servidor.
PORTA = 8080

# Dicionário de variáveis suportadas.
VARIAVEIS = {
    'x': 0,
    'y': 0,
    'z': 0,
}

# Dicionário de constantes suportadas.
CONSTANTES = {
    'pi': math.pi,
    'euler': math.e,
}

# Dicionário de operações servidas pelo método GET.
# Testa o número de argumentos
OPERACOES = {
    'add':   lambda args: args[0] + args[1]                        if len(args) == 2 else None,
    'sub':   lambda args: args[0] - args[1]                        if len(args) == 2 else None,
    'mul':   lambda args: args[0] * args[1]                        if len(args) == 2 else None,
    'div':   lambda args: args[0] / args[1]                        if len(args) == 2 else None,
    'pow':   lambda args: math.pow(args[0], args[1])               if len(args) == 2 else None,
    'log':   lambda args: math.log10(args[0])                      if len(args) == 1 else None,
    'ln':    lambda args: math.log(args[0])                        if len(args) == 1 else None,
    'lg':    lambda args: math.log2(args[0])                       if len(args) == 1 else None,
    'sqrt':  lambda args: math.sqrt(args[0])                       if len(args) == 1 else None,
    'sq':    lambda args: math.pow(args[0], 2)                     if len(args) == 1 else None,
    'sin':   lambda args: math.sin(args[0])                        if len(args) == 1 else None,
    'cos':   lambda args: math.cos(args[0])                        if len(args) == 1 else None,
    'tan':   lambda args: math.tan(args[0])                        if len(args) == 1 else None,
    'sec':   lambda args: 1/math.cos(args[0])                      if len(args) == 1 else None,
    'mod':   lambda args: abs(args[0])                             if len(args) == 1 else None,
    'inv':   lambda args: (1/args[0] if args[0] != 0 else args[0]) if len(args) == 1 else None,
    'fac':   lambda args: math.factorial(args[0])                  if len(args) == 1 else None,
    'var':   lambda args: args[0]                                  if len(args) == 1 else None,
    'const': lambda args: args[0]                                  if len(args) == 1 else None,
}

class ProcessadorRequisicoes(BaseHTTPRequestHandler):
    # Retorna erros em formato texto ao invés de HTML.
    error_content_type = 'text/plain'
    error_message_format = 'Erro: %(code)d. %(message)s.'

    def do_GET(self):
        (operacao, argumentos) = self._quebra_caminho()

        # Se a expressão não existe, este caminho é inválido.
        expressao = OPERACOES.get(operacao, None)
        if expressao is None:
            self.send_error(HTTPStatus.NOT_FOUND)
            return

        # Converte argumentos em ponto flutuantes.
        # Requisição é inválida caso converção falhe.
        argumentos = self._converte_numeros(argumentos)
        if argumentos is None:
            self.send_error(HTTPStatus.BAD_REQUEST)
            return

        # Tenta calcular o resultado.
        resultado = None
        try:
            resultado = expressao(argumentos)
        except (ZeroDivisionError, ValueError, TypeError):
            pass

        # Se o resultado não pode ser obtido, a requisição é inválida.
        if resultado is None:
            self.send_error(HTTPStatus.BAD_REQUEST)
            return

        self._envia_resultado(resultado)

    def do_POST(self):
        (operacao, argumentos) = self._quebra_caminho()

        # Requer operação 'var'.
        if operacao != 'var':
            self.send_error(HTTPStatus.NOT_FOUND)
            return

        # Requer 2 argumentos.
        if len(argumentos) != 2:
            self.send_error(HTTPStatus.BAD_REQUEST)
            return

        # Requer variável conhecida.
        if argumentos[0] not in VARIAVEIS:
            self.send_error(HTTPStatus.NOT_FOUND)
            return

        # Converte argumento em número.
        nums = self._converte_numeros(argumentos[1:])
        if nums is None:
            self.send_error(HTTPStatus.BAD_REQUEST)
            return

        # Define valor da variável
        VARIAVEIS[argumentos[0]] = nums[0]
        self._envia_resultado(nums[0])

    def _quebra_caminho(self):
        # Requer pelo menos 3 barras (/wscalc/sqrt/22 == ['', 'wscalc', 'sqrt', '22']).
        # Requer wscalc como prefixo das operações (partes[1] == 'wscalc').
        partes = self.path.split('/')
        if len(partes) < 4 or partes[1] != 'wscalc':
            return (None, None)

        # Separa operação de seus argumentos.
        operacao = partes[2]
        argumentos = partes[3:]
        return (operacao, argumentos)

    def _converte_numeros(self, argumentos):
        try:
            numeros = []
            for arg in argumentos:
                if arg in CONSTANTES:
                    numeros.append(CONSTANTES[arg])
                elif arg in VARIAVEIS:
                    numeros.append(VARIAVEIS[arg])
                elif '.' in arg:
                    numeros.append(float(arg))
                else:
                    numeros.append(int(arg))
            return numeros
        except ValueError:
            return None

    def _envia_resultado(self, resultado):
        # Converte resultado para inteiro se não houver parte decimal.
        if resultado % 1 == 0:
            resultado = int(resultado)

        # Converte resultado em texto.
        resposta = str(resultado)

        # Envia cabeçalho HTTP
        self.send_response(HTTPStatus.OK)
        self.send_header('Content-Type', 'text/html')
        self.send_header('Content-Length', len(resposta))
        self.send_header('Cache-Control', "no-store")
        self.end_headers()

        # Envia texto HTTP
        self.wfile.write(resposta.encode('UTF-8'))

# Ambiente de código principal
if __name__ == '__main__':
    print(
        'Iniciando servidor na porta ', PORTA, '. ',
        'Aguardando requisições...',
        sep=''
    )

    servidor = HTTPServer(
        ('0.0.0.0', PORTA),
        ProcessadorRequisicoes
    )

    # Suprime mensagens no console ao usar CTRL+C para interromper o programa
    try:
        servidor.serve_forever()
    except KeyboardInterrupt:
        pass
