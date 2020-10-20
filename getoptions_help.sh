# shellcheck shell=sh
# URL: https://github.com/ko1nksm/getoptions
# License: Creative Commons Zero v1.0 Universal
getoptions_help() {
	width=30 plus='' here='GETOPTIONS-HEREDOC'

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

	for i in 'setup :' 'flag' 'param' 'option' 'disp' 'msg :'; do
		eval "${i% *}() { args $i \"\$@\"; }"
	done

	echo "$2() {"
	echo "cat<<$here"
	"$@"
	echo "$here"
	echo "}"
}
