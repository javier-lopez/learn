#-*- mode: shell-script;-*-
# Inputs:
#   $1 -- name of the command whose arguments are being completed
#   $2 -- word being completed
#   $3 -- word preceding the word being completed
#   $COMP_LINE  -- current command line
#   $COMP_PONT  -- cursor position
#   $COMP_WORDS -- array containing individual words in the current
#                  command line
#   $COMP_CWORD -- index into ${COMP_WORDS} of the word containing the
#                  current cursor position
# Output:
#   COMPREPLY array variable contains possible completions
#
# Syntax:
#   dpatch-edit-patch [options] command dpatchname [basepatch]
#

have dpatch-edit-patch &&
_dpatch_edit_patch()
{
    local shopt_aliases_opt i cur prev mode options rootcmds patches patchlist DPEP_DO_GETOPTION
    local DPEP_SOURCEDIR DPEP_OUTDIR DPEP_TMPDIR DPEP_ROOTCMD DPEP_NEWDESC DPEP_KEEPTEMP
    local conf_sourcedir conf_outdir conf_tmpdir conf_rootcmd conf_newdesc conf_keeptemp

    case "$(shopt expand_aliases)" in
	 *on) shopt_aliases_opt="-s";;
	*off) shopt_aliases_opt="-u";;
    esac
    shopt -u expand_aliases

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    # options
    options='-s -o -r -d -k -t --sourcedir --outdir --rootcmd \
             --description --keeptemp --tmpdir'
    rootcmds='fakeroot sudo'

    # commands (added to patches)
    patches=patch
    # Read in the user's configuration file, should it exist.
    [[ -f ~/.dpatch.conf ]] && . ~/.dpatch.conf
    # default dirs
    DPEP_SOURCEDIR=${DPEP_SOURCEDIR:-${conf_sourcedir:-$(pwd)}}
    DPEP_OUTDIR=${DPEP_OUTDIR:-${conf_outdir:-$DPEP_SOURCEDIR/debian/patches}}
    # parse options
    mode=all
    for (( i=1; i < ${#COMP_WORDS[@]}; i++ )); do
        arg="${COMP_WORDS[$i]}"
        #echo "i=$i arg=\"$arg\""
        if [ -z "$arg" ]; then
            if [ -z "$DPEP_DO_GETOPTION" ]; then
                mode=all
            fi
            continue
        fi
        if [ -n "$DPEP_DO_GETOPTION" ]; then
            eval "$DPEP_DO_GETOPTION$arg"
            DPEP_DO_GETOPTION=""
            continue
        fi
        case "$arg" in
        -s|--sourcedir)
            DPEP_DO_GETOPTION="DPEP_SOURCEDIR="
            options=${options//+(-s|--sourcedir)/}
            mode=file
            ;;
        --sourcedir=*)
            DPEP_SOURCEDIR="$(printf "%s" "$arg" | cut -f2- -d= )"
            options=${options//+(-s|--sourcedir)/}
            cur=${cur/--sourcedir=/}
            mode=file
            ;;
        -o|--outdir)
            DPEP_DO_GETOPTION="DPEP_OUTDIR="
            options=${options//+(-o|--outdir)/}
            mode=file
            ;;
        --outdir=*)
            DPEP_OUTDIR="$(printf "%s" "$arg" | cut -f2- -d= )"
            options=${options//+(-o|--outdir)/}
            cur=${cur/--outdir=/}
            mode=file
            ;;
        -t|--tmpdir)
            DPEP_DO_GETOPTION="DPEP_TMPDIR="
            options=${options//+(-t|--tmpdir)/}
            mode=file
            ;;
        --tmpdir=*)
            DPEP_TMPDIR="$(printf "%s" "$arg" | cut -f2- -d= )"
            options=${options//+(-t|--tmpdir)/}
            cur=${cur/--tmpdir=/}
            mode=file
            ;;
        -r|--rootcmd)
            DPEP_DO_GETOPTION="DPEP_ROOTCMD="
            options=${options//+(-r|--rootcmd)/}
            mode=rootcmd
            ;;
        --rootcmd=*)
            DPEP_ROOTCMD="$(printf "%s" "$arg" | cut -f2- -d= )"
            options=${options//+(-r|--rootcmd)/}
            mode=all
            ;;
        -d|--description)
            DPEP_DO_GETOPTION="DPEP_NEWDESC="
            options=${options//+(-d|--description)/}
            mode=file
            ;;
        --description=*)
            DPEP_NEWDESC="$(printf "%s" "$arg" | cut -f2- -d= )"
            options=${options//+(-d|--description)/}
            mode=file
            ;;
        -*)
            mode=options
            ;;
        patch)
            mode=patch
            patches=""
            ;;
        *)
            mode=patch
            ;;
        esac
    done
    #echo "mode=$mode"
    case "$mode" in
    options)
        # standard completion on options
        COMPREPLY=( $( compgen -W "$options" -- "$cur" ) )
        ;;
    none)
        # the user has to type a text
        return 0
        ;;
    file)
        # files and directories
        _filedir
        ;;
    rootcmd)
        # a root command
        COMPREPLY=( $( compgen -W "$rootcmds" -- "$cur" ) )
        ;;
    patch|all)
        # a list of patches ("patch") or all options and patches ("all")
        if [ "$mode" = "all" ]; then
            COMPREPLY=( $( compgen -W "$options" -- "$cur" ) )
        fi
        # check for debian source dir
        if [ ! -e "$DPEP_SOURCEDIR/debian/rules" ]; then
            return 0
        fi
        # check for output dir
        if [ ! -d "$DPEP_OUTDIR" ]; then
            return 0
        fi
        # search patches
        patchlist=$(ls $DPEP_OUTDIR/00list* 2>/dev/null)
        if [ -z "$patchlist" ]; then
            return 0
        fi
        patches="$(cat $patchlist | grep -v ^\# 2>/dev/null) $patches"
        COMPREPLY=( ${COMPREPLY[@]} $( compgen -W "$patches" -- "$cur" ) )
        ;;
    esac
    shopt "$shopt_aliases_opt" expand_aliases
    return 0
}
[ "$have" ] && complete -F _dpatch_edit_patch $filenames dpatch-edit-patch

# arch-tag: 448345aa-f5c7-4e20-89d7-4f7df0288228
