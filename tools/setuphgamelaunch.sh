#!/bin/sh

if [ -z "$1" ]
    then
    echo "No argument supplied"
    echo "Please provide the full path to the destination directory as an argument"
    exit 1
fi

if (pwd | grep "Cataclysm-TLG/tools")
then
cd ..
else
if (ls Cataclysm-TLG)
then
echo "Cataclysm-TLG already exists"
else
echo "Cloning Cataclysm-TLG"
git clone https://github.com/fairyarmadillo/Cataclysm-TLG
fi
cd Cataclysm-TLG
fi

make

cd ..

if (ls Hgamelaunch)
then
echo "Hgamelaunch already exists"
else
echo "Cloning Hgamelaunch"
git clone https://github.com/C0DEHERO/Hgamelaunch
fi
cd Hgamelaunch

echo "Building Hgamelaunch"
cabal sandbox init
cabal install --only-dependencies
cabal configure
cabal build

# Setup folder structure
#ROOTDIR = $1
mkdir -p $1
echo "Copying bin to $1"
cp ./dist/build/Hgamelaunch/Hgamelaunch $1
echo "Copying config dir to $1/config"
cp -rn ./config $1
cp -r ./config/examples $1
echo "Copying license to $1"
cp ./LICENSE.md $1
echo "Copying readme to $1"
cp ./README.md $1

# Copying game files
cd ../Cataclysm-TLG
mkdir -p $1/ctlg
cp ./cataclysm $1/ctlg/
mkdir -p $1/share/cataclysm-tlg
mkdir -p $1/share/save
mkdir -p $1/share/memorial
cp -r ./data/. $1/share/cataclysm-tlg
cp -r ./gfx $1/share/cataclysm-tlg
cp -r ./lang $1/share/cataclysm-tlg

# Copying games.json
cd $1
ROOTPATH=$(echo "$1/" | sed -e 's/[\/&]/\\&/g')
echo "Copying games.json"
if (ls ./config/games.json)
then
cp ./config/examples/Cataclysm-TLG/games.json ./config/games.json.new
sed -i "s/!rootpath/$ROOTPATH/g" ./config/games.json.new
echo "New config has been copied to $1/config/games.json.new"
else
cp ./config/examples/Cataclysm-TLG/games.json ./config/
sed -i "s/!rootpath/$ROOTPATH/g" ./config/games.json
fi

# Making admin userdir
mkdir -p $1/userdata/ctlg/admin/
mkdir -p $1/userdata/ctlg/admin/ttyrec

# Creating the directories for ttrecs in progress
mkdir -p $1/ctlg-inprogress/
mkdir -p $1/ctlg-shared-inprogress/

echo "FINISHED! Hgamelaunch was installed into $1"
echo "The admin login is:"
echo "username: admin"
echo "password: admin"
echo "Please make sure to change the password before opening the server to the public!"
echo "You can also add, remove, or configure game launchers in config/games.json"
echo "Make sure to stick to the format, otherwise it won't be read"
echo "You might also want to change the banners located in config/banners"
echo "After you configured Hgamelaunch you need to set up an ssh server."
echo "I assume that you know how to do that."
