#!/usr/bin/env perl

use User::pwent;

use strict;
use warnings;

# ABSTRACT: Cria os diretorios para os volumes e os arquivos de log
#
# Se foi executado com sudo, o owner sera definido para o $SUDO_USER.
# Caso contrario, o owner sera definido para o usuario develop.

# Diretorios
my @dirs = qw(
    /nr
    /nr/nx
    /nr/nx/logs
);

my $mode_dir = oct('2777');

my $user = $ENV{SUDO_USER};
if ( ! defined $user || $user eq '' ) {
    $user = 'root';
}
my $pw = getpwnam($user);
die "ERRO: Falhou na identificacao do usuario" unless($pw);
my $uid = $pw->uid;
my $gid = $pw->gid;

for my $dir (@dirs) {
    if (! -d $dir) {
        mkdir $dir or warn "ERRO: Nao criou $dir : $!";
        chmod($mode_dir, $dir) or warn "ERRO: Nao ajustou o modo $dir : $!";
        chown($uid, $gid, $dir) or warn "ERRO: Nao ajustou o owner $dir : $!";
    }
}

# EOF
