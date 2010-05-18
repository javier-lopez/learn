# Programmable bash_completion file for the main OpenOffice.org applications
# It is based on /etc/profile.d/complete.bash from SUSE Linux 10.1

_def=; _dir=; _file=; _nosp=
if complete -o default _nullcommand &> /dev/null ; then
    _def="-o default"
    _dir="-o dirnames"
    _file="-o filenames"
fi
_minusdd="-d ${_dir}"
_minusdf="-d ${_file}"
if complete -o nospace _nullcommand &> /dev/null ; then
    _nosp="-o nospace"
    _minusdd="${_nosp} ${_dir}"
    _minusdf="${_nosp} ${_dir}"
fi
complete -r _nullcommand &> /dev/null

# General OOo expanding shell function
_ooexp_ ()
{
    # bash `complete' is broken because you can not combine
    # -d, -f, and -X pattern without missing directories.
    local c=${COMP_WORDS[COMP_CWORD]}
    local a="${COMP_LINE}"
    local e s g=0 cd dc t=""
    local IFS

    shopt -q extglob && g=1
    test $g -eq 0 && shopt -s extglob
    # Don't be fooled by the bash parser if extglob is off by default
    cd='*-?(c)d*'
    dc='*-d?(c)*'

    case "${1##*/}" in
    oobase)		e='!*.+(odb|ODB)' ;;
    oofromtemplate)		e='!*.+(stw|STW|dot|DOT|vor|VOR|stc|STC|xlt|XLT|sti|STI|pot|POT|std|STD|stw|STW|dotm|DOTM|dotx|DOTX|potm|POTM|potx|POTX|xltm|XLTM|xltx|XLTX)' ;;
    oodraw)		e='!*.+(sxd|SXD|std|STD|dxf|DXF|emf|EMF|eps|EPS|met|MET|pct|PCT|sgf|SGF|sgv|SGV|sda|SDA|sdd|SDD|vor|VOR|svm|SVM|wmf|WMF|bmp|BMP|gif|GIF|jpg|JPG|jpeg|JPEG|jfif|JFIF|fif|FIF|jpe|JPE|pcd|PCD|pcx|PCX|pgm|PGM|png|PNG|ppm|PPM|psd|PSD|ras|RAS|tga|TGA|tif|TIF|tiff|TIFF|xbm|XBM|xpm|XPM|odg|ODG|otg|OTG|fodg|FODG|odc|ODC|odi|ODI|sds|SDS|wpg|WPG|svg|SVG)' ;;
    oocalc)		e='!*.+(sxc|SXC|stc|STC|dif|DIF|dbf|DBF|xls|XLS|xlw|XLW|xlt|XLT|rtf|RTF|sdc|SDC|vor|VOR|slk|SLK|txt|TXT|htm|HTM|html|HTML|wk1|WK1|wks|WKS|123|123|xml|XML|ods|ODS|ots|OTS|fods|FODS|csv|CSV|xlsb|XLSB|xlsm|XLSM|xlsx|XLSX|xltm|XLTM|xltx|XLTX)' ;;
    oomath)		e='!*.+(sxm|SXM|smf|SMF|mml|MML|odf|ODF)' ;;
    ooweb)		e='!*.+(htm|HTM|html|HTML|stw|STW|txt|TXT|vor|VOR|oth|OTH)' ;;
    ooffice)		e='!*.+(sxd|SXD|std|STD|dxf|DXF|emf|EMF|eps|EPS|met|MET|pct|PCT|sgf|SGF|sgv|SGV|sda|SDA|sdd|SDD|vor|VOR|svm|SVM|wmf|WMF|bmp|BMP|gif|GIF|jpg|JPG|jpeg|JPEG|jfif|JFIF|fif|FIF|jpe|JPE|pcd|PCD|pcx|PCX|pgm|PGM|png|PNG|ppm|PPM|psd|PSD|ras|RAS|tga|TGA|tif|TIF|tiff|TIFF|xbm|XBM|xpm|XPM|odg|ODG|otg|OTG|fodg|FODG|odc|ODC|odi|ODI|sds|SDS|wpg|WPG|svg|SVG|doc|DOC|dot|DOT|rtf|RTF|sxw|SXW|stw|STW|sdw|SDW|vor|VOR|txt|TXT|htm?|HTM?|xml|XML|wp|WP|wpd|WPD|wps|WPS|odt|ODT|ott|OTT|fodt|FODT|docm|DOCM|docx|DOCX|dotm|DOTM|dotx|DOTX|sxm|SXM|smf|SMF|mml|MML|odf|ODF|sxi|SXI|sti|STI|ppt|PPT|pps|PPS|pot|POT|sxd|SXD|sda|SDA|sdd|SDD|sdp|SDP|vor|VOR|cgm|CGM|odp|ODP|otp|OTP|fodp|FODP|ppsm|PPSM|ppsx|PPSX|pptm|PPTM|pptx|PPTX|potm|POTM|potx|POTX|odb|ODB|sxc|SXC|stc|STC|dif|DIF|dbf|DBF|xls|XLS|xlw|XLW|xlt|XLT|rtf|RTF|sdc|SDC|vor|VOR|slk|SLK|txt|TXT|htm|HTM|html|HTML|wk1|WK1|wks|WKS|123|123|xml|XML|ods|ODS|ots|OTS|fods|FODS|csv|CSV|xlsb|XLSB|xlsm|XLSM|xlsx|XLSX|xltm|XLTM|xltx|XLTX|sxg|SXG|odm|ODM|sgl|SGL|stw|STW|dot|DOT|vor|VOR|stc|STC|xlt|XLT|sti|STI|pot|POT|std|STD|stw|STW|dotm|DOTM|dotx|DOTX|potm|POTM|potx|POTX|xltm|XLTM|xltx|XLTX|htm|HTM|html|HTML|stw|STW|txt|TXT|vor|VOR|oth|OTH)' ;;
    oowriter)		e='!*.+(doc|DOC|dot|DOT|rtf|RTF|sxw|SXW|stw|STW|sdw|SDW|vor|VOR|txt|TXT|htm?|HTM?|xml|XML|wp|WP|wpd|WPD|wps|WPS|odt|ODT|ott|OTT|fodt|FODT|docm|DOCM|docx|DOCX|dotm|DOTM|dotx|DOTX|sxg|SXG|odm|ODM|sgl|SGL)' ;;
    ooimpress)		e='!*.+(sxi|SXI|sti|STI|ppt|PPT|pps|PPS|pot|POT|sxd|SXD|sda|SDA|sdd|SDD|sdp|SDP|vor|VOR|cgm|CGM|odp|ODP|otp|OTP|fodp|FODP|ppsm|PPSM|ppsx|PPSX|pptm|PPTM|pptx|PPTX|potm|POTM|potx|POTX)' ;;
    unopkg)		e='!*.+(oxt|OXT)' ;;
    *)			e='!*'
    esac

    case "$(complete -p ${1##*/} 2> /dev/null)" in
	*-d*)	;;
	*) s="-S/"
    esac

    IFS='
'
    case "$c" in
    \$\(*\))	   eval COMPREPLY=\(${c}\) ;;
    \$\(*)		COMPREPLY=($(compgen -c -P '$(' -S ')'  -- ${c#??}))	;;
    \`*\`)	   eval COMPREPLY=\(${c}\) ;;
    \`*)		COMPREPLY=($(compgen -c -P '\`' -S '\`' -- ${c#?}))	;;
    \$\{*\})	   eval COMPREPLY=\(${c}\) ;;
    \$\{*)		COMPREPLY=($(compgen -v -P '${' -S '}'  -- ${c#??}))	;;
    \$*)		COMPREPLY=($(compgen -v -P '$'          -- ${c#?}))	;;
    \~*/*)		COMPREPLY=($(compgen -f -X "$e"         -- ${c}))	;;
    \~*)		COMPREPLY=($(compgen -u ${s}	 	-- ${c}))	;;
    *@*)		COMPREPLY=($(compgen -A hostname -P '@' -S ':' -- ${c#*@})) ;;
    *[*?[]*)		COMPREPLY=($(compgen -G "${c}"))			;;
    *[?*+\!@]\(*\)*)
	if test $g -eq 0 ; then
			COMPREPLY=($(compgen -f -X "$e" -- $c))
			test $g -eq 0 && shopt -u extglob
			return
	fi
			COMPREPLY=($(compgen -G "${c}"))			;;
    *)
	if test "$c" = ".." ; then
			COMPREPLY=($(compgen -d -X "$e" -S / ${_nosp} -- $c))
	else
			for s in $(compgen -f -X "$e" -- $c) ; do
			    if test -d $s ; then
				COMPREPLY=(${COMPREPLY[@]} $(compgen -f -X "$e" -S / -- $s))
			    elif test -z "$t" ; then
				COMPREPLY=(${COMPREPLY[@]} $s)
			    else
				case "$(file -b $s 2> /dev/null)" in
				$t) COMPREPLY=(${COMPREPLY[@]} $s)		;;
				esac
			    fi
			done
	fi									;;
    esac
    test $g -eq 0 && shopt -u extglob
}


complete -d -X '.[^./]*' -F _ooexp_ ${_file} \
					oobase \
					oofromtemplate \
					oodraw \
					oocalc \
					oomath \
					ooweb \
					ooffice \
					oowriter \
					ooimpress \
					unopkg

unset _def _dir _file _nosp _minusdd _minusdf
