#!/bin/bash

# Promjena prava korisnika i pristupa direktoriju
sudo usermod -aG sudo $USERNAME
sudo chown -R $USERNAME:$USERNAME /opt

# Ažuriranje i nadogradnja sistema
sudo apt-get update && sudo apt-get upgrade -y

# Instalacija osnovnih paketa
sudo apt-get install -y build-essential gcc make linux-headers-$(uname -r) git libproc-processtable-perl dkms patchutils dvb-apps nload htop net-tools

# Instalacija specifičnih aplikacija
sudo apt-get install -y dvblast vlc kaffeine w-scan

# Kompilacija i instalacija MumuDVB-a
git clone https://github.com/braice/MuMuDVB.git
cd MuMuDVB
autoreconf -i && ./configure && make
sudo make install
cd ..

# Dodavanje repozitorijuma i instalacija MythTV-a
sudo add-apt-repository -y ppa:mythbuntu/31
sudo apt-get update && sudo apt-get install -y mythtv

# Kompilacija i instalacija TSDuck-a
git clone https://github.com/tsduck/tsduck.git
cd tsduck
make && sudo make install
cd ..

echo "Instalacija DVB alata završena. Idemo sa driverom TBS-a"

# Instalacija TBS drivera
sudo apt-get update && sudo apt-get upgrade -y
lspci -vvv | grep tbs
mkdir tbsdriver && cd tbsdriver/
git clone https://github.com/tbsdtv/media_build.git
git clone --depth=1 https://github.com/tbsdtv/linux_media.git -b latest ./media
cd media_build/
make dir DIR=../media && make distclean && make -j4 && sudo make install
cd ../..
wget http://www.tbsdtv.com/download/document/linux/tbs-tuner-firmwares_v1.0.tar.bz2
tar jxvf tbs-tuner-firmwares_v1.0.tar.bz2 -C /lib/firmware/
sudo reboot

echo "Instalacija TBS drivera završena"

# Instalacija FFmpeg, OSCam, TVHeadend i NVIDIA drajvera
#!/bin/bash

# Instalacija FFmpeg
sudo apt-get update && sudo apt-get install -y autoconf automake build-essential libtool pkg-config texi2html zlib1g-dev yasm cmake curl mercurial git wget
git clone https://github.com/keylase/ffmpeg-build-script.git
cd ffmpeg-build-script
./build-ffmpeg --build
cd ..

# Instalacija i konfiguracija OSCam
OSCAM_DIR="/usr/local/bin/oscam"
OSCAM_Emu_DIR="/usr/local/bin/oscam-emu"
OSCAM_Emu_PATCHES_DIR="/usr/local/bin/oscam-emu-patches"
sudo apt-get install -y git build-essential
git clone https://github.com/oscam-emu/oscam-emu.git $OSCAM_Emu_DIR
cd $OSCAM_Emu_DIR
./configure --enable WITH_EMU && make
sudo cp oscam-emu /usr/local/bin/oscam
mkdir -p $OSCAM_Emu_PATCHES_DIR
cd $OSCAM_Emu_PATCHES_DIR
git clone https://github.com/oscam-emu/oscam-patched.git .
patch -p0 < oscam-patched.patch
cd $OSCAM_Emu_DIR
make clean && ./configure --enable WITH_EMU && make
sudo cp oscam-emu /usr/local/bin/oscam
cd ..

# Instalacija TVHeadend
sudo apt update && sudo apt upgrade -y
sudo apt install -y coreutils wget apt-transport-https lsb-release ca-certificates build-essential
curl -1sLf 'https://dl.cloudsmith.io/public/tvheadend/tvheadend/setup.deb.sh' | sudo -E bash
sudo sh -c 'echo "deb https://apt.tvheadend.org/stable $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/tvheadend.list'
sudo apt update && sudo apt install -y tvheadend


# ...

# Kompilacija i instalacija tsdecrypt-a
git clone https://github.com/gfto/tsdecrypt.git
cd tsdecrypt
autoreconf -i && ./configure && make
sudo make install
cd ..

# Instalacija NVIDIA drajvera i patcha
sudo apt install -y nvidia-driver-`apt search nvidia-driver | grep -oP 'nvidia-driver-\K[0-9]+' | sort -V | tail -1`
git clone https://github.com/keylase/nvidia-patch.git
cd nvidia-patch
./patch.sh
cd ..



# Provjera instalacije paketa
echo "Provjeravam instalaciju paketa..."

echo "DVBlast: " && dvblast --version || echo "Nije instaliran"
echo "VLC: " && vlc --version || echo "Nije instaliran"
echo "Kaffeine: " && kaffeine --version || echo "Nije instaliran"
echo "MumuDVB: " && mumudvb --version || echo "Nije instaliran"
echo "MythTV: " && mythbackend --version || echo "Nije instaliran"
echo "w_scan: " && w_scan -v || echo "Nije instaliran"
echo "FFmpeg: " && ffmpeg -version || echo "Nije instaliran"
echo "OSCam: " && oscam -V || echo "Nije instaliran"
echo "TVHeadend: " && systemctl status tvheadend || echo "Nije instaliran"
echo "NVIDIA: " && nvidia-smi || echo "Nije instaliran"
echo "tsdecrypt: " && tsdecrypt --help || echo "Nije instaliran"

echo "Provjeravanje instalacije završeno."

# Kraj skripte



echo "Instalacija svih komponenti završena. Pozdrav od rodicinog cmara iz Mostara!"
