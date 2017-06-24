#!/bin/sh

echo "MANGA DOWNLOADER. SCRIPT TO DOWNLOAD MANGA FROM www.mangareader.net"
echo "SCRIPT WRITTEN BY GALIH (www.facebook.com/galihpa)"
echo "USAGE: ./manga-downloader.sh MANGANAME STARTCHAPTER ENDCHAPTER"
echo "EXAMPLE: ./manga-downloader.sh \"shingeki no kyojin\" 54 94"
if [[ $# -ne 3 ]]; then
	exit
fi
manga="$1"
manga=$(echo "$manga" | awk '{print tolower($0)}') # Converting it to lower case
manga=$(echo "$manga" | sed 's/ /-/g') #Removing spaces and adding '-'
chaps="$2"
chape="$3"
if [ ! -d "$manga" ]; then
	mkdir "$manga"
fi
cd "$manga"
unused(){
	for chap in $(seq $chaps $chape);
	do
		mkdir -p ${manga}-${chap}
		cd ${manga}-${chap}
		endpage=$(wget -cO - www.mangareader.net/$manga/$chap/1 | grep "<option value=\"" | tail -1 | awk -F "[><]" '{print $3}')
		imagename=1
		for startpage in $(seq 1 $endpage); do
			echo "Downloading page $startpage of $endpage chapter $chap....."
			imagelink=$(wget -cO - www.mangareader.net/$manga/$chap/$startpage | sed -n 's/.*src="\([^"]*\).*/\1/p' | grep -E "mangareader.*$manga.*jpg")
			wget -cO "${imagename}.jpg" "$imagelink"
			imagename=$((imagename+1))
		done
		cd ..
	done
}
openwrt(){ # THIS IS FOR MY OPENWRT ROUTER
	for chap in $(seq $chaps $chape);
	do
		mkdir -p ${manga}-${chap}
		cd ${manga}-${chap}
		endpage=$(curl -vC - --socks5-hostname 192.168.1.1:1095 www.mangareader.net/$manga/$chap/1 | grep "<option value=\"" | tail -1 | awk -F "[><]" '{print $3}')
		imagename=1
		for startpage in $(seq 1 $endpage); do
			echo "Downloading page $startpage of $endpage chapter $chap....."
			imagelink=$(curl -vC - --socks5-hostname 192.168.1.1:1095 www.mangareader.net/$manga/$chap/$startpage | sed -n 's/.*src="\([^"]*\).*/\1/p' | grep -E "mangareader.*$manga.*jpg")
			curl -vC - --socks5-hostname 192.168.1.1:1095 "$imagelink" > "${imagename}.jpg"
			if [[ $? != 0 ]]; then
				echo "Error downloading chapter $chap page $startpage" >> ../download-error.txt
			fi
			imagename=$((imagename+1))
		done
		cd ..
	done
	echo "DOWNLOAD SELESAI"
}
if uname -a | grep AngelBeats; then
	openwrt
else
	for chap in $(seq $chaps $chape);
	do
		mkdir -p ${manga}-${chap}
		cd ${manga}-${chap}
		endpage=$(curl -vC - www.mangareader.net/$manga/$chap/1 | grep "<option value=\"" | tail -1 | awk -F "[><]" '{print $3}')
		imagename=1
		for startpage in $(seq 1 $endpage); do
			echo "Downloading page $startpage of $endpage chapter $chap....."
			imagelink=$(curl -vC - www.mangareader.net/$manga/$chap/$startpage | sed -n 's/.*src="\([^"]*\).*/\1/p' | grep -E "mangareader.*$manga.*jpg")
			curl -vC - "$imagelink" > "${imagename}.jpg"
			if [[ $? != 0 ]]; then
				echo "Error downloading chapter $chap page $startpage" >> ../download-error.txt
			fi
			imagename=$((imagename+1))
		done
		cd ..
	done
	echo "DOWNLOAD SELESAI"
fi