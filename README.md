# WSCALC


# Servidor

Dependências:

1. `python >= 3`
2. `curl` (para testes)

## Como rodar

Rode o servidor com:

```sh
python server.py
```

Teste requisições via `curl`:

```sh
curl http://localhost:8080/wscalc/add/1/1
```

Pressione Ctrl-c para fechar o servidor.

## Rodar testes

Rode testes automatizados com:

```sh
bash server_test.sh
```
