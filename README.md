# QuartusInstallerUbuntu
Installer for Quartus II on Ubuntu 20.04

This installer is a Bash script which allows you to easily install Quartus II on Ubuntu 20.04. It could also work on Ubuntu 18.04, but
it was not tested. It was tested on a fresh Ubuntu 20.04 install. 

You need to download Quartus installer from Intel page, which can be found on <https://www.intel.com/content/www/us/en/programmable/downloads/download-center.html>, in which
you should select appropiate Quartus II version. This script was tested using Quartus 19.1 version. If you want to choose other version, you should modify quartus_install.sh, 
in line `QUARTUS_VER=19.1` and `QUARTUS_BUILD_VER=.0.670`. The second one can be obtained from the name of the downloaded installer, don't forget the first dot. 

By default, Quartus will be installed in /opt/altera/\<version>. If you want to change this directory, you can change line `INSTALL_DIR=/opt/altera/$QUARTUS_VER` on quartus_install.sh.

Sources of final script are in same script.
