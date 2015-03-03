#!/bin/bash
# uany.sh
# By Kxuan <xuanmgr@gmail.com>
# Unpack ANY archive! HaHa~
# This script can easily unpack a archive and try to fix the charset.
# 
declare opt_quiet=false
declare opt_createdir=true
declare opt_verbose=false

declare archive_path=
declare directory_path=
declare type=
declare charset=

usage()
{
    cat <<-USG
Usage: $0 [-q] [-r] [-v] [--] <archive> <directory>
Detect the archive type and unpack it into directory.

Support Archive Type:
    rar, zip, tar, bzip2, gzip, xz
Options:
    -q   do not prompt if the directory not empty (the script will quit)
    -r   do not create directory if not exists
    -v   verbose mode
Sample:
$0 something.tar.gz.xz target
   - Unpacket something.tar.gz.xz into target
USG
}
handle_arguments()
{
    while [ -n "$1" ]
    do
        if [[ "$1" == "-q" ]]; then
            opt_quiet=true
        elif [[ "$1" == "-r" ]]; then
            opt_createdir=false
        elif [[ "$1" == "-v" ]]; then
            opt_verbose=true
        elif [[ "$1" == "--" ]]; then
            shift
            break
        else
            break
        fi
        shift
    done

    archive_path="`readlink -f $1`"
    $opt_verbose && echo "archive path:$archive_path"
    directory_path="$2"
    $opt_verbose && echo "directory path:$directory_path"

    if [ ! -f "$archive_path" ] ; then
        echo "$archive_path is not an regular file" >&2
        return 1
    fi
    if [ -z "$directory_path" ] ; then
        return 1
    elif ! cd "$directory_path" 2>/dev/zero; then
        $opt_verbose && echo "opt_createdir: $opt_createdir"
        if $opt_createdir && mkdir -p "$directory_path" ; then
            cd "$directory_path"
        else
            echo "Can not change directory to $directory_path" >&2
            return 2
        fi
    fi
    if [ -n "`find . -mindepth 1 -print -quit`" ] ; then
        $opt_quiet && exit 10
        read -p "The directory is not empty. Do you want to use it anyway? [yN]" ans
        [[ $ans != y ]] && exit 0
    fi
    $opt_verbose && echo "current directory: $PWD"
    return 0
}
detect_type()
{
    local mime=`file --mime-type "$1"`
    mime=${mime##${1}: }
    $opt_verbose && echo "MIME-Type: $mime"
    if [[ "$mime" == "application/zip" ]] ; then
        type=zip
    elif [[ "$mime" == "application/gzip" ]] ; then
        type=gzip
    elif [[ "$mime" == "application/x-bzip2" ]] ; then
        type=bzip2
    elif [[ "$mime" == "application/x-xz" ]] ; then
        type=xz
    elif [[ "$mime" == "application/x-tar" ]] ; then
        type=tar
    elif [[ "$mime" == "application/x-rar" ]] ; then
        type=rar
    else
        type=
    fi
    $opt_verbose && echo "type: $type"
    test -n "$type"
}

# Zip File
de_zip()
{
    $opt_verbose && echo "decompress zip file: $1"
    if read -p "Please input the zip charset:" cs; then
        unzip -q -O $cs $1
    else
        unzip -q $1
    fi
}
# Gzip File
de_gzip()
{
    $opt_verbose && echo "decompress gzip file: $1"
    name=$1
    name=${name##*/}
    name=${name%.bz2}
    $opt_verbose && echo "bz file: $name"
    gzip --stdout --decompress --keep $1 > $name
}
# BZip File
de_bzip2()
{
    $opt_verbose && echo "decompress bzip file: $1"
    name=$1
    name=${name##*/}
    name=${name%.bz2}
    $opt_verbose && echo "bz file: $name"
    bzip2 --stdout --decompress --keep $1 > $name
}
# XZ File
de_xz()
{
    $opt_verbose && echo "decompress xz file: $1"
    unxz $1
}
# Tar File
de_tar()
{
    $opt_verbose && echo "decompress tar file: $1"
    tar xf $1
}
# Rar File
de_rar()
{
    $opt_verbose && echo "decompress rar file: $1"
    unrar e $1
}

extract_archive()
{
    $opt_verbose && echo "decompress function : de_$type"
    eval "de_$type '$1'" || return
    [[ "$2" == "temp" ]] && rm "$1"
    local files=(*)

#   if only one file is extracted
#   try to extract the file again
    if [ ${#files[*]} -eq 1 ]; then
        detect_type ${files[0]} && extract_archive ${files[0]} temp 
    fi
    return 0
}
detect_charset()
{    
    local cs=`find . -printf %f | chardet | head -1`
    cs=${cs##<stdin>: }
    cs=${cs%% (*}
#    read -p "the charset is $cs.[Y/n]" ans
#    if [[ $ans == "n" ]] ; then
#        read -p "please input the right charset:" cs || return 1
#    fi
    charset=$cs
    $opt_verbose && echo "charset: $charset"
    return 0
}
rename_recursive()
{
    for file in $1/*
    do
        $opt_verbose && echo "rename file: $file using iconv -f $2 <<<$file "
        if [ -d $file ]; then
            rename_recursive $file $2
        else
            f=`iconv -f $2 <<<$file `
            [[ $f != $file ]] && mv -n "$file" "$f"
        fi
    done
}
fix_charset()
{
    local sys_charset=${LANG##*.}
    $opt_verbose && echo "charset compare: ${sys_charset^^*} != ${charset^^*}"
    if [[ "${sys_charset^^*}" != "${charset^^*}" ]] ; then
        rename_recursive "$PWD" $charset
    fi
    return 0
}

if ! handle_arguments $@; then
    usage
    exit 1
fi
if ! detect_type "$archive_path"; then
    echo "Can not detect archive type" >&2
    exit 2
fi
if ! extract_archive "$archive_path"; then
    echo "Can not extract files from $archive_path" >&2
    exit 3
fi
if ! detect_charset; then
    echo "Can not detect character set. You may need to manually repair the text encoding." >&2
    exit 4
fi
if ! fix_charset "$archive_path"; then
    echo "Fail to fix character set. " >&2
    exit 5
fi
# Done
exit 0
