#!/bin/bash

if [ ! -f /usr/bin/curl ]; then
	echo "O utilitario CURL nao esta instalado."
	echo "instale-o e tente novamente."
	exit 1
fi

if [ "$1" == "" ]; then
	echo "Uma mensagem deve ser passada como parametro."
	exit 1
fi

URL=http://localhost:8080/demo/_webservices/pull.php
curl -d notification="$1" $URL 1> /dev/null 2>&1
