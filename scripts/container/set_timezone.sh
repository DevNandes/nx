#!/bin/bash

# ABSTRACT: Ajusta o timezone para America/Sao_Paulo

rm -Rf /etc/localtime
if [ "$?" == "0" ]; then
    echo "Arquivo /etc/localtime removido com sucesso"
else
    echo "ERRO: Falhou na remocao do /etc/localtime"
fi

ln -s /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
if [ "$?" == "0" ]; then
    echo "Link para o zoneinfo Sao_Paulo criado com sucesso"
else
    echo "ERRO: Falhou na criacao do link para o zoneinfo Sao_Paulo"
fi

date

# EOF
