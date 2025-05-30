CLIENT_CMD := python3 main.py
SERVER_CMD := docker-compose up --build

.PHONY: all server client help

all: help

help:
	@echo "make server → Inicia o servidor web e base de dados"
	@echo "make client → Executa o cliente"
	@echo "make clean  → Desliga os containers Docker"

server:
	@echo "A iniciar o servidor e base de dados via Docker..."
	cd api && $(SERVER_CMD)

client:
	@echo "A instalar dependências..."
	cd cliente && pip install -r requirements.txt

	@echo "A executar o cliente..."
	$(CLIENT_CMD)

clean:
	@echo "A desligar os containers Docker..."
	cd api && docker-compose down -v
