rm -f main.zip
wget "https://github.com/maiconcarneiro/mcsqlkit/archive/refs/heads/main.zip"
unzip -qo main.zip
rm -rf shared
mv mcsqlkit-main/* .
rm -rf mcsqlkit-main