echo -e "\e[1;34m"
# Using ascii art font speed (see http://patorjk.com/software/taag/#p=display&f=Speed&t=VRE)
cat<<'LOGO'
___  ____/_  __ \    ___    |__  __/_________(_)___________ _
__  __/  _  / / /    __  /| |_  /_ __  ___/_  /_  ___/  __ `/
_  /___  / /_/ /     _  ___ |  __/ _  /   _  / / /__ / /_/ / 
/_____/  \____/      /_/  |_/_/    /_/    /_/  \___/ \__,_/  

LOGO
echo -e "\e[0;33m"

cat<<MSG
Welcome to the Virtual Research Environment!

MSG

# Turn off colors
echo -e "\e[m"

# Change to home directory when terminal is opened from virtual desktop
if [ "$PWD" == "/opt/noVNC-1.2.0" ]; then cd; fi
