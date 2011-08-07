#!/usr/bin/env bash
#chilicuil <chilicuil@gmail.com> 2011
#rm, is a wrapper for the existing rm command compatible with nautilus trash
#management, if the user specifies the -f flag files are removed and NOT
#archived.

#Inspyred by 'Wicked Cool Shell Scripts: 101 Scripts for Linux, Mac
#OS X, and Unix Systems'

#TODO 03-01-2011 00:17 => Implement recover procedure & custom clean and list
#functions

#TODO 03-01-2011 00:29 => fix this shit
# ./rm_.sh /home/chilicuil/las_aventuras_de_nono\ \(copy\).pdf 
# ./rm_.sh: line 28: $trash_dir/info/$(basename "$arg").trashinfo: ambiguous redirect

trash_dir="$HOME/.local/share/Trash"
RM="/bin/rm"

archive ()
{
    for arg
    do
        if [ -e "$arg" ] ; then
            #TODO 02-01-2011 17:28 => check if the file already exist, add basename.+1
            #don't forget modify printf > *.trashinfo

            #TODO 03-01-2011 12:18 => find a realpath()
            newname="$trash_dir/files/$(basename "$arg")"

            mv "$arg" "$newname"
            printf "[Trash Info]\nPath=$(pwd)/$arg\nDeletionDate=$(date +%Y-%m-%dT%T)"\
            > $trash_dir/info/$(basename "$arg").trashinfo
        fi
    done
}

clean ()
{
    # list pattern
    # for delete_file_data in $data
    # do
    #    real_file=$(echo delete_file_data | cut ...)
    #    $RM -rf real_file
    #    $RM -rf real_file.info
    # done

    list
    echo -n "Empty all items from trash? (Y/n) "
    answer=y
    read answer
    if [ ! $answer == "y" ]; then
        echo "Nothing done" && exit 0
    else
        $RM -rf $trash_dir/files/*
        $RM -rf $trash_dir/info/*
    fi

}

list ()
{
    #TODO 03-01-2011 00:08 => recive pattern, save to a dictionary
    there_are_trash=($trash_dir/info/*.trashinfo)
    if [ ! -e ${there_are_trash[0]} ] ; then
        echo "$(basename $0): Nothing to list" >&2 ; exit 1
    fi

    index=1

    for delete_file_data in $(find $trash_dir/info -name "*.trashinfo" | sort | xargs grep -A 1 -Hri path \
                              | sed -e 's:^:|:g' -e 's:\.trashinfo.*=:|:g'\
                              | tr -d '\n'| sed -e 's:--:\n:g')
    do
        datetime_string=$(echo $delete_file_data | cut -d\| -f5)
        general_date=$(echo $datetime_string | cut -dT -f1)
        detail_date=$(echo $datetime_string | cut -dT -f2)
        name=$(echo $delete_file_data | cut -d\| -f3)
        real_file=$(echo $delete_file_data | cut -d\| -f2 | sed -e 's:\/info\/:\/files\/:g')
        size=$(du -sh $real_file | awk '{print $1}')

            if [ -d $real_file ] ; then
                some="$(ls $real_file | wc -l | sed 's/[^[:digit:]]//g')"
                if [ $index -gt 9 ]; then
                    echo " $index)  $name (d, $some items, $size, deleted the $general_date at $detail_date)"
                else
                    echo " $index)   $name (d, $some items, $size, deleted the $general_date at $detail_date)"
                fi
            else
                if [ $index -gt 9 ]; then
                    echo " $index)  $name (f, $size, deleted the $general_date at $detail_date)"
                else
                    echo " $index)   $name (f, $size, deleted the $general_date at $detail_date)"
                fi
            fi
            index=$(($index + 1))
    done

    return 0
    #if [ $matches -eq 0 ] ; then
        #echo "No match for \"$1\" in the deleted file archive." >&2
        #exit 1
    #fi

    #if [ $matches -gt 1 ] ; then
        #echo "More than one file or directory match in the archive:"
        #index=1
        #for name in $(ls -td *"$1")
        #do
            #datetime="$(echo $name | cut -c1-14| \
                #awk -F. '{ print $5"/"$4" at "$3":"$2":"$1 }')"
            #if [ -d $name ] ; then
                #size="$(ls $name | wc -l | sed 's/[^[:digit:]]//g')"
                #echo " $index)   $1  (contents = ${size} items, deleted = $datetime)"
            #else
                #size="$(ls -sdk1 $name | awk '{print $1}')"
                #echo " $index)   $1  (size = ${size}Kb, deleted = $datetime)"
            #fi
            #index=$(($index + 1))
        #done
        #echo ""
        #echo -n "Which version of $1 do you want to restore ('0' to quit)? [1] : "
        #read desired
        #if [ ${desired:=1} -ge $index ] ; then
            #echo "$0: Restore canceled by user: index value too big." >&2
            #exit 1
        #fi

        #if [ $desired -lt 1 ] ; then
            #echo "$0: restore canceled by user." >&2 ; exit 1
        #fi

        #restore="$(ls -td1 *"$1" | sed -n "${desired}p")"

        #if [ -e "$dest/$1" ] ; then
            #echo "\"$1\" already exists in this directory. Cannot overwrite." >&2
            #exit 1
        #fi

        #echo -n "Restoring file \"$1\" ..."
        #$move "$restore" "$dest/$1"
        #echo "done."

        #echo -n "Delete the additional copies of this file? [y] "
        #read answer

        #if [ ${answer:=y} = "y" ] ; then
            #$realrm -rf *"$1"
            #echo "deleted."
        #else
            #echo "additional copies retained."
        #fi
    #else
        #if [ -e "$dest/$1" ] ; then
            #echo "\"$1\" already exists in this directory. Cannot overwrite." >&2
            #exit 1
        #fi

        #restore="$(ls -d *"$1")"

        #echo -n "Restoring file \"$1\" ... "
        #$move "$restore" "$dest/$1"
        #echo "done."
    #fi

    #exit 0
}

recover ()
{
    # list pattern
    # for delete_file_data in $data
    # do
    #    real_file=$(echo delete_file_data | cut ...)
    #    name=$(echo delete_file_data | cut ...)
    #    $MV $real_file $name
    #    $RM -rf $real_file.info
    # done

    #list
    #echo -n "Recover all items from trash? (Y/n) "
    #answer=y
    #read answer
    #if [ ! $answer == "y" ]; then
        #echo "Nothing done" && exit 0
    #else
         # for delete_file_data in $data
         # do
         #    real_file=$(echo delete_file_data | cut ...)
         #    name=$(echo delete_file_data | cut ...)
         #    $MV $real_file $name
         #    $RM -rf $real_file.info
         # done
    #fi

    echo recover
}

if [ $# -eq 0 ] ; then # let 'rm' ouptut the usage error
    exec $RM  #our shell is replaced by /bin/rm, keeping original status
    #unmodified
fi

FLAGS=""

while getopts ":flurc" options
do
    case $options in
        f) exec $RM "$@"            ;;  # exec lets us exit this script directly.
        l) list                     ;;
        u) recover "$@"             ;;
        c) clean                    ;;
        *) exec $RM "$@"            ;;  # other flags are for 'rm', not for us
  esac
done
shift $(($OPTIND - 1))

# Make sure that the $trash_dir exists

if [ ! -d $trash_dir ] ; then
    if [ ! -w $HOME ] ; then
        echo "$0 failed: can't create $trash_dir in $HOME" >&2
        exit 1
    fi
    mkdir -p $trash_dir/{files,info}
    chmod -R 700 $trash_dir # a little bit of privacy, please
fi

archive "$@"

exit 0
