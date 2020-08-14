# shellcheck shell=sh
getoptions() {
  URL="https://github.com/ko1nksm/getoptions"
  LICENSE="Creative Commons Zero v1.0 Universal (CC0 Public Domain)"
  _error='' _on=1 _off='' _export='' _restargs='RESTARGS'
  _plus='' _optargs='' _no='' _equal=1 indent=''

  for i in 0 1 2 3 4 5; do
    eval "_$i() { echo \"$indent\" \"\$@\"; }"
    indent="$indent  "
  done

  quote() {
    q="$2'" r=''
    while [ "$q" ]; do r="$r${q%%\'*}'\''" && q="${q#*\'}"; done
    q="'${r%????}'" && q="${q#\'\'}" && q="${q%\'\'}" && [ "$q" ] || q="''"
    eval "$1=\"\$q\""
  }

  code() {
    [ ! "${1#:}" = "$1" ] && c=4 || c=3
    eval "[ ! \${$c:+x} ] || $2 \"\$$c\""
  }

  args() {
    on=$_on off=$_off export=$_export init='@empty'
    while [ $# -gt 1 ] && [ ! "$2" = '--' ] && shift; do
      case $1 in
        --no-* | --\{no-\}*) _no=1 ;;
        +*) _plus=1 ;;
        [!-+]*) eval "${1%%:*}=\"\${1#*:}\"" ;;
      esac
    done
  }

  defvar() {
    case $init in
      @empty) code "$1" _0 "${export:+export }$1=''" ;;
      @unset) code "$1" _0 "unset $1 ||:" "unset OPTARG ||:; ${1#:}" ;;
      *)  [ _"${init#@}" = _"$init" ] || eval "init=\"=\${${init#@}}\""
          [ _"${init#=}" = _"$init" ] && _0 "$init" && return 0
          quote init "${init#=}"
          code "$1" _0 "${export:+export }$1=$init" "OPTARG=$init; ${1#:}"
    esac
  }

  optarg() {
    while [ $# -gt 1 ] && [ ! "$2" = '--' ] && shift; do
      [ "${1#-?}" ] || _optargs="${_optargs}${1#-}"
    done
  }

  setup() {
    while [ $# -gt 0 ] && i=$1 && [ ! "$1" = '--' ] && shift; do
      eval "_${i%%:*}=\"\${i#*:}\""
    done
  }
  flag() { args "$@"; defvar "$@"; }
  param() { args "$@"; defvar "$@"; optarg "$@"; }
  option() { args "$@"; defvar "$@"; optarg "$@"; }
  disp() { args "$@"; }
  msg() { args "$@"; }

  _0 "# Option parser generated by getoptions"
  _0 "# URL: $URL"
  _0 "# LICENSE: $LICENSE"
  "$@"
  _0 "$_restargs=''"

  args() {
    sw='' on="$_on" off="$_off" validate='' counter='' default=''
    while [ $# -gt 1 ] && [ ! "$2" = '--' ] && shift; do
      case $1 in
        --\{no-\}* ) sw="${sw}${sw:+ | }--${1#--?no-?} | --no-${1#--?no-?}" ;;
        [-+]? | --*) sw="${sw}${sw:+ | }$1" ;;
        *) eval "${1%%:*}=\"\${1#*:}\""
      esac
    done
  }

  setup() { :; }
  flag() {
    args "$@"
    [ "$counter" ] && on=1 off=-1
    quote on "$on"
    quote off "$off"
    _3 "$sw)"
    _4 "[ \"\${OPTARG:-}\" ] && set -- noarg \"\$1\" && break"
    _4 "eval '[ \${OPTARG+x} ] &&:' && OPTARG=$on || OPTARG=$off"
    [ "$validate" ] && _4 "{ $validate; } || return \$?"
    [ "$counter" ] && code="\$((\${$1:-0} + \$OPTARG))" || code="\$OPTARG"
    code "$1" _4 "$1=$code" "${1#:}"
    _4 ";;"
  }
  param() {
    args "$@"
    _3 "$sw)"
    _4 "[ \$# -le 1 ] && set -- required \"\$1\" && break"
    _4 "OPTARG=\$2"
    [ "$validate" ] && _4 "{ $validate; } || return \$?"
    code "$1" _4 "$1=\$OPTARG" "${1#:}"
    _4 "shift ;;"
  }
  option() {
    args "$@"
    quote default "$default"
    _3 "$sw)"
    _4 "if [ ! \"\$OPTARG\" ]; then"
    _5 "OPTARG=$default"
    _5 "eval 'shift; set -- \"'\"\$1\"'\" \"\$OPTARG\"' \${2+'\"\$@\"'}"
    _4 "fi"
    _4 "OPTARG=\$2"
    [ "$validate" ] && _4 "{ $validate; } || return \$?"
    code "$1" _4 "$1=\$OPTARG" "${1#:}"
    _4 "shift ;;"
  }
  disp() {
    args "$@"
    _3 "$sw)"
    code "$1" _4 "echo \"\$$1\"" "${1#:}"
    _4 "exit 0 ;;"
  }

  _0 "$2() {"
  _1 "OPTIND=\$((\$#+1))"
  _1 "while [ \$# -gt 0 ] && OPTARG=''; do"
  _2 "case \$1 in"
  if [ "$_equal" ]; then
    _3 "--?*=*) OPTARG=\$1; shift"
    _4 "eval 'set -- \"\${OPTARG%%\=*}\" \"\${OPTARG#*\=}\"' \${1+'\"\$@\"'}"
    _4 ";;"
  fi
  if [ "$_no" ]; then
    _3 "--no-*) unset OPTARG ;;"
  fi
  if [ "$_optargs" ]; then
    _3 "-[$_optargs]?*) OPTARG=\$1; shift"
    _4 "eval 'set -- \"\${OPTARG%\"\${OPTARG#??}\"}\" \"\${OPTARG#??}\"' \${1+'\"\$@\"'}"
    _4 ";;"
  fi
  _3 "-[!-]?*) OPTARG=\$1; shift"
  _4 "eval 'set -- \"\${OPTARG%\"\${OPTARG#??}\"}\" \"-\${OPTARG#??}\"' \${1+'\"\$@\"'}"
  _4 "OPTARG='' ;;"
  if [ "$_plus" ]; then
    _3 "+??*) OPTARG=\$1; shift"
    _4 "eval 'set -- \"\${OPTARG%\"\${OPTARG#??}\"}\" \"+\${OPTARG#??}\"' \${1+'\"\$@\"'}"
    _4 "unset OPTARG ;;"
    _3 "+*) unset OPTARG ;;"
  fi
  _2 "esac"
  _2 "case \$1 in"
  "$@"
  _3 "--)"
  _4 "while [ \$# -gt 1 ] && shift; do"
  _5 "$_restargs=\"\$$_restargs \\\"\\\${\$((\$OPTIND-\$#))}\\\"\""
  _4 "done"
  _4 "return 0 ;;"
  _3 "[-${_plus:++}]?*) set -- unknown \"\$1\" && break ;;"
  _3 "*) $_restargs=\"\$$_restargs \\\"\\\${\$((\$OPTIND-\$#))}\\\"\""
  _2 "esac"
  _2 "shift"
  _1 "done"
  _1 "[ \$# -eq 0 ] && return 0"
  if [ "$_error" ]; then
    _1 "$_error \"\$@\" && exit 1"
  fi
  _1 "case \$1 in"
  _2 "unknown) echo \"unrecognized option '\$2'\" >&2 ;;"
  _2 "noarg) echo \"option '\$2' doesn't allow an argument\" >&2 ;;"
  _2 "required) echo \"option '\$2' requires an argument\" >&2 ;;"
  _1 "esac"
  _1 "exit 1"
  _0 "}"
  _0 "# End of option parser"
}

getoptions_help() {
  width=30 plus='' heredoc='GETOPTIONS_HEREDOC'

  pad() { p=$2; while [ ${#p} -lt "$3" ]; do p="$p "; done; eval "$1=\$p"; }

  args() {
    _type=$1 var=$2 sw='' hidden='' _width=$width _pre='' && shift 2
    while [ $# -gt 0 ] && i=$1 && shift && [ ! "$i" = '--' ]; do
      case $i in
        --*) pad sw "$sw${sw:+, }" $((${plus:+4} + 4)); sw="${sw}$i" ;;
        -? ) sw="${sw}${sw:+, }$i" ;;
        +? ) pad sw "$sw${sw:+, }" 4; sw="${sw}$i" ;;
          *) eval "${i%%:*}=\"\${i#*:}\"" ;;
      esac
    done
    [ "$hidden" ] && return 0

    case $_type in
      setup | msg) _pre='' _width=0 ;;
      flag | disp) pad _pre "  $sw  " "$_width" ;;
      param      ) pad _pre "  $sw $var  " "$_width" ;;
      option     ) pad _pre "  $sw [$var]  " "$_width" ;;
    esac
    [ ${#_pre} -le "$_width" ] && [ $# -gt 0 ] && _pre="${_pre}$1" && shift
    echo "$_pre"
    pad _pre '' "$_width"
    for i; do echo "${_pre}$i"; done
  }

  setup() { args 'setup' - "$@"; }
  flag() { args 'flag' "$@"; }
  param() { args 'param' "$@"; }
  option() { args 'option' "$@"; }
  disp() { args 'disp' "$@"; }
  msg() { args 'msg' - "$@"; }

  echo "$2() {"
  echo "cat<<$heredoc"
  "$@"
  echo "$heredoc"
  echo "}"
}
