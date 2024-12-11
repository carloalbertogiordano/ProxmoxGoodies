CURRDIR="$pwd"

cd $1

find . -type f -exec du -ah {} + | sort -rh

cd $CURRDIR
