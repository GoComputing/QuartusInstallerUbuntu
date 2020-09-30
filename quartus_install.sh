#!/bin/bash

QUARTUS_VER=19.1
QUARTUS_BUILD_VER=.0.670
INSTALL_DIR=/opt/altera/$QUARTUS_VER
QUARTUS_COMPLETE_VER=${QUARTUS_VER}${QUARTUS_BUILD_VER}

# Assert folder doesn't exists
if [ -e "$INSTALL_DIR" ]; then
	echo "$INSTALL_DIR already exists. Aborting"
	exit -1
fi




# Assert that this script is executed as root
if [[ $UID != 0 ]]; then
	echo "This script should be executed as root"
	exit -1
fi




# Install Quartus II and ModelSim
echo "Decompressing Quartus II and Modelsim-Altera"
mkdir -p build/quartus
tar -xvf Quartus-lite-$QUARTUS_COMPLETE_VER-linux.tar -C build/quartus
pushd build/quartus/components

echo "Installing Quartus II"
DISPLAY="" ./QuartusLiteSetup-$QUARTUS_COMPLETE_VER-linux.run \
        --disable-components quartus_help,modelsim_ase,modelsim_ae \
        --mode unattended \
        --unattendedmodeui none \
        --accept_eula 1 \
        --installdir "$INSTALL_DIR"

echo "Installing Modelsim-Altera"
DISPLAY="" ./ModelSimSetup-$QUARTUS_COMPLETE_VER-linux.run \
        --modelsim_edition modelsim_ase \
        --mode unattended \
        --unattendedmodeui none \
        --accept_eula 1 \
        --installdir $INSTALL_DIR

popd




# Add and update udev rules to allow non-root users program using USB Blaster
cp files/51-usbblaster.rules /etc/udev/rules.d/
udevadm control --reload-rules
udevadm trigger




# Update package list
dpkg --add-architecture i386
apt-get update -y




# Install libusb (https://electronics.stackexchange.com/questions/239882/altera-cyclone-ii-jtag-after-as-programming)
apt-get install -y libudev1:i386
ln -sf /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so.0




# Install dependencies (https://askubuntu.com/questions/602725/trouble-running-modelsim-on-ubuntu)
apt-get install -y zlib1g-dev:i386 build-essential gcc-multilib g++-multilib \
	lib32z1 lib32stdc++6 lib32gcc1 \
	expat:i386 fontconfig:i386 libfreetype6:i386 libexpat1:i386 libc6:i386 libgtk-3-0:i386 \
	libcanberra0:i386 libice6:i386 libsm6:i386 libncurses5:i386 zlib1g:i386 \
	libx11-6:i386 libxau6:i386 libxdmcp6:i386 libxext6:i386 libxft2:i386 libxrender1:i386 \
	libxt6:i386 libxtst6:i386




# Configure Modelsim-Altera
mkdir $INSTALL_DIR/modelsim_ase/lib32
mv $INSTALL_DIR/modelsim_ase/linuxaloem $INSTALL_DIR/modelsim_ase/linuxaloem_orig
mkdir $INSTALL_DIR/modelsim_ase/linuxaloem
ln -s $INSTALL_DIR/modelsim_ase/linuxaloem_orig/* $INSTALL_DIR/modelsim_ase/linuxaloem
rm $INSTALL_DIR/modelsim_ase/linuxaloem/vsim
printf "#!/bin/sh\nLD_LIBRARY_PATH=%s %s \"\$@\"\nexit \$?\n" "$INSTALL_DIR/modelsim_ase/lib32" "$INSTALL_DIR/modelsim_ase/linuxaloem_orig/vsim" > $INSTALL_DIR/modelsim_ase/linuxaloem/vsim
chmod a+x $INSTALL_DIR/modelsim_ase/linuxaloem/vsim




# Install freetype on modelsim
pushd build
wget http://download.savannah.gnu.org/releases/freetype/freetype-2.4.12.tar.bz2
tar -xvf freetype-2.4.12.tar.bz2
pushd freetype-2.4.12
./configure --build=i686-pc-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32"
make -j4
mv objs/.libs/*.so* $INSTALL_DIR/modelsim_ase/lib32
popd
popd




# Install libpng12 on modelsim
pushd build
wget https://sourceforge.net/projects/libpng/files/libpng12/1.2.59/libpng-1.2.59.tar.xz
tar -xvf libpng-1.2.59.tar.xz
pushd libpng-1.2.59
./configure --build=i686-pc-linux-gnu "CFLAGS=-m32" "CXXFLAGS=-m32" "LDFLAGS=-m32"
make -j4
mv .libs/*.so* $INSTALL_DIR/modelsim_ase/lib32
popd
popd




# Update path
echo "export PATH=\$PATH:$INSTALL_DIR/quartus/bin" >> /etc/profile
echo "export PATH=\$PATH:$INSTALL_DIR/modelsim_ase/linuxaloem" >> /etc/profile
