# shell
shell tools

## uany.sh
This script can easily unpack a archive and try to fix the charset.

	Usage: uany.sh [-q] [-r] [-v] [--] <archive> <directory>
	Detect the archive type and unpack it into directory.

	Support Archive Type:
	    rar, zip, tar, bzip2, gzip, xz
	Options:
	    -q   do not prompt if the directory not empty (the script will quit)
	    -r   do not create directory if not exists
	    -v   verbose mode
	Sample:
	uany.sh something.tar.gz.xz target
	   - Unpacket something.tar.gz.xz

## xbencode.sh

