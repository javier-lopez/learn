#!/bin/bash
# Paste at Pastebin.com using command line (browsers are slow, right?)
# coder : Anil Dewani
# date : Novemeber 7, 2010

#help function
howto()
{
    echo "\
   Pastebin.com Bash Script \
 
    Usage : $0 [ -n <paste name> ] [ -e <paste email> ] [ -t <type of code> ] [ -h ]
   
    <paste name>   Specify the name of paste to be used (optional)
    <paste email>  Specify email to be used while pasting (optional)
    <type of code> Specify code language used, use any of the following values (optional and default value is plain text)

    => Some famous [ -t <type of code> ] Values::

    php - PHP
    actionscript3 - Action Script 3
    asp - ASP
    bash - BASH script
    c - C language
    csharp - C#
    cpp - C++
    java - JAVA
    sql - SQL
    "
}


NAME=
EMAIL=
TYPE=

#getopts, config
while getopts "n:e:t:h" OPTION
do
    case $OPTION in
        n)
            NAME=$OPTARG
            ;;
        e)
            EMAIL=$OPTARG
            ;;
    t)
        TYPE=$OPTARG
        ;;
        h)
            howto
            exit
            ;;
    ?)
        howto
        exit
        ;;
    esac
done

#get data from stdin
INPUT="$(</dev/stdin)"

querystring="paste_private=0&paste_code=${INPUT}&paste_name=${NAME}&paste_email=${EMAIL}&paste_format=${TYPE}"

#post data to pastebin.com API
curl -d "${querystring}" http://pastebin.com/api_public.php

echo ""
