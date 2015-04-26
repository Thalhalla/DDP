#/bin/sh
# make an ascii art logo from DDD.jpg
jp2a --color --background=dark --chars='  DDddPPpp' -b --height=20 DDP.jpg | tee DDP.txt
echo 'https://github.com/joshuacox/DDP'>> DDP.txt
