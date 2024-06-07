#
# Variaveis de ambiente
#
# "Tragara a morte para sempre, e, assim, enxugara o Senhor DEUS as lagrimas
# de todos os rostos, e tirara de toda a terra o oprobrio do seu povo,
# porque o Senhor falou. Naquele dia, se dira: Eis que este e o nosso DEUS,
# em quem esperavamos, e Ele nos salvara; este e o Senhor, a quem
# aguardavamos; na sua salvacao exultaremos e nos alegraremos." Isaias 25.8-9

# Permissao full para o grupo
umask 002

# App >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

setenv APP_NAME     'nx'
setenv APP_ROOT_DIR '/home/renault/nx'
setenv RENAULT_RISK_LOG_FILE '/nr/logs/renault_risk_access.log'
setenv RWS_LOG_FILE '/nr/logs/rws_access.log'

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


# Sessao interativa >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

if ($?prompt) then

    alias ls       'ls --color=auto \!:*'

    # Variaveis
    setenv PAGER less
    setenv LESS -r
    set rmstar
    set dunique
    set filec
    set ignoreeof

    # Definicoes especificas para o tcsh
    if ($?tcsh) then
        set notify
        set visiblebell
        set color

        # Emacs bindings
        bindkey -e
        bindkey "\e[1~" beginning-of-line # Home
	    bindkey "\e[7~" beginning-of-line # Home rxvt
	    bindkey "\e[2~" overwrite-mode    # Ins
	    bindkey "\e[3~" delete-char       # Delete
	    bindkey "\e[4~" end-of-line       # End
	    bindkey "\e[8~" end-of-line       # End rxvt

        # Auto-complete
        set autoexpand
        set autolist
        complete cd 'C/*/d/'
        complete sudo 'n/-l/u/' 'p/1/c/'
        complete set 'p/1/s/'
        complete unset 'p/1/s/'
        complete setenv 'p/1/e/'
        complete unsetenv 'p/1/e/'
        complete alias 'p/1/a/'
        complete unalias 'p/1/a/'
        complete complete 'p/1/c/'
        complete which 'p/1/c/'
        complete where 'p/1/c/'
        complete man 'p/1/c/'

    endif

endif

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# EOF
