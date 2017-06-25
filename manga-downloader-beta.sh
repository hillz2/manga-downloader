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
mangareader-openwrt(){ # THIS IS FOR MY OPENWRT ROUTER
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
				echo "Error downloading chapter $chap page $startpage: $imagelink" >> ../download-error.txt
			fi
			imagename=$((imagename+1))
		done
		cd ..
	done
	echo "DOWNLOAD SELESAI"
}
# Checking the manga
if uname -a | grep AngelBeats; then
	if curl -vC - --socks5-hostname 192.168.1.1:1095 http://www.mangareader.net/$manga | grep "404 Not Found"; then
		if curl -vC - --socks5-hostname 192.168.1.1:1095 http://mangapark.me/manga/$manga | grep "Sorry, the page you have requested cannot be found"; then
			echo "Manga cannot be found"
			exit
		else
			if [ ! -d "$manga" ]; then
				mkdir "$manga"
			fi
			cd "$manga"
			echo "Downloading from mangapark.me"
			curl --socks5-hostname 192.168.1.1:1095 http://mangapark.me/manga/kuzu-no-honkai | grep -E "/manga/kuzu-no-honkai.*>all<" | cut -d '"' -f2 > chapterlist.txt
			source="mangapark.me"
		fi
	else
		if [ ! -d "$manga" ]; then
			mkdir "$manga"
		fi
		cd "$manga"
		echo "Downloading from mangareader.net"
		source="mangareader.net"
	fi
else
	if curl -vC - http://www.mangareader.net/$manga | grep "404 Not Found"; then
		if curl -vC - http://mangapark.me/manga/$manga | grep "Sorry, the page you have requested cannot be found"; then
			echo "Manga cannot be found"
			exit
		else
			if [ ! -d "$manga" ]; then
				mkdir "$manga"
			fi
			cd "$manga"
			echo "Downloading from mangapark.me"
			source="mangapark.me"
		fi
	else
		if [ ! -d "$manga" ]; then
			mkdir "$manga"
		fi
		cd "$manga"
		echo "Downloading from mangareader.net"
		source="mangareader.net"
	fi
fi
case source in
	"mangareader.net")
		if uname -a | grep AngelBeats; then
			mangareader-openwrt
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
						echo "Error downloading chapter $chap page $startpage: $imagelink" >> ../download-error.txt
					fi
					imagename=$((imagename+1))
				done
				cd ..
			done
			echo "DOWNLOAD SELESAI"
		fi
		;;
	"mangapark.me")
		for chapter in $(cat chapterlist.txt); do
			
		;;
esac
