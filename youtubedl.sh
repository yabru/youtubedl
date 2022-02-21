#!/bin/bash
version='4.9.5'
commit='update notificatie'
tools=(AtomicParsley curl python@3.9 ffmpeg libav exiftool gnu-sed eye-d3 coreutils youtube-dl sox imagemagick instalooter git faac lame xvid)
toolsverbeterd=`echo ${tools[*]}|tr '[:upper:]' '[:lower:]'`
tools=($toolsverbeterd)
random=`echo "$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM"`
#gshufiserniet=`gshuf --version &> /dev/null&&echo "1"`
#if  [[ $gshufiserniet == "1" ]]; then
#	entries=($(gshuf -i 0-149 -n 15 | sort -n))
#	random=`echo "${entries[@]}"|sed -e 's/ //g'`
#fi
toegang="0"
vofa=v
image="0"
verdonkeringspercentage=
if [[ $verdonkeringspercentage == "" ]]; then
	verdonkeringspercentage=40
fi
[[ $(cat $(which youtubedl)|head -2|tail -1) == $(curl -s https://raw.githubusercontent.com/yabru/youtubedl/main/youtubedl.sh|head -2|tail -1) ]]||osascript -e 'display notification "Er is een nieuwe update beschickbaar run: youtubedl -U om te updaten." with title "Youtube-dl" subtitle "Github."'
berekenmin () {
	urenvoor=`echo $datevoordl|awk 'BEGIN {FS=":"}{print $1}'`
	urenna=`echo $datenadl|awk 'BEGIN {FS=":"}{print $1}'`
	minvoor=`echo $datevoordl|awk 'BEGIN {FS=":"}{print $2}'`
	minna=`echo $datenadl|awk 'BEGIN {FS=":"}{print $2}'`
	if [[ $urenna != $urenvoor ]]; then
		if [[ $urenna -gt $urenvoor ]]; then
			minerbij=$(( urenna - urenvoor ))
			minerbij=$(( minerbij * 60 ))
			minna=$(( minna + minerbij ))
		else
			if [[ $urenna == "0"* ]]; then
				urenna=`echo "$urenna"|sed -e "s/0//"`
			fi
			urenna=$(( urenna + 24 ))
			minerbij=$(( urenna - urenvoor ))
			minerbij=$(( minerbij * 60 ))
			minna=$(( minna + minerbij ))
		fi
	fi
	berekend=$(( minna - minvoor ))
}
locatie () {
	/usr/local/bin/youtubedl -h &> /dev/null;exitcode=$?
	if [[ $exitcode != 10 ]]; then
		locatieCheck=`/bin/ls /usr/local/bin/youtubedl &> /dev/null && echo "1"`
		if [[ $locatieCheck == "1" ]]; then
			rm /usr/local/bin/youtubedl
		fi
		which brew &> /dev/null|| ls /usr/local/bin/brew &> /dev/null||brewiserniet=1
		if [[ $brewiserniet == 1 ]]; then
			echo "je hebt HomeBrew niet geinstalleerd, Dit is esentieel voor youtubedl om te functioneren."
			echo ""
			echo "je instaleerd Homebrew met:"
			echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
			exit 1
		fi
		realpath --version||coreutilsnietgevonden=1
		if [[ $coreutilsnietgevonden == 1 ]]; then
			echo "essentieel component mist: coreutils, mag deze gedownload worden? Y/n"
			while [[ $afgerond != 1 ]]; do
				read janee
				if [[ $janee == "" ]]||[[ $janee == "Y" ]]||[[ $janee == "y" ]]||[[ $janee == "yes" ]]||[[ $janee == "Yes" ]]||[[ $janee == "YES" ]]; then
					brew install coreutils
					afgerond=1
				else
					if [[ $janee == "N" ]]||[[ $janee == "n" ]]||[[ $janee == "no" ]]||[[ $janee == "No" ]]||[[ $janee == "NO" ]]; then
						exit 1
					else
						echo "geen herkend antwoord"
					fi
				fi
			done	
		fi
		echo -e "\nGeen symlink gevonden voor dit script, deze wordt voor je gemaakt,\nje kan nu het YouTube Download script runnen door youtubedl te typen\nVergeet niet om eenmalig youtubedl -i te runnen, dit instaleerd je basis\n"
		SCRIPT=`realpath $0`
		ln -s $SCRIPT /usr/local/bin/youtubedl
		exec $SHELL
		exit 0
	fi
}
cleanupfiles () {
	filenaamverbeterdrm=`echo $filenaamverbeterd|rev|sed -e "s/3pm.//"|rev`
	GLOBIGNORE=*.mp3
	rm ~/Documents/youtube-dl/file.jpg ''"$filenaamverbeterdrm"''* &> /dev/null
	unset GLOBIGNORE
	#ffmpeg -i "$filenaamverbeterd" ~/Documents/youtube-dl/file.jpg &> /dev/null||nietgelukt=1
	exiftool "$filenaamverbeterd"|grep "User Defined Text               : (URL)"&>/dev/null||nietgelukt=1
	if [[ $nietgelukt == 1 ]]; then
		rm "$filenaamverbeterd" &> /dev/null
	fi
	exit 1
}
help () {
	echo ""
	echo "youtubedl -u \"YouTube-url\" [options]"
	echo ""
	echo "youtubedl - download YouTube video's met wat extra toevoegingen op het youtube-dl commando (direct .mp3, .mp4 bestandtype en meer)"
	echo ""
	echo ""
	echo -e "\t[MEERDERE URL'S MOGELIJK: YouTubeUrl\ YouTubeUrl\ YouTubeUrl (\"\\\" moet voor de spatie)]"
	echo ""
	echo ""
	echo "NOODZAAKELIJK:"
	echo "-u	[URL]				Voor het invoegen YouTube url (heeft een URL na -u nodig)"
	echo "-F	[FILE]				sla het download aspect over met -F en geef aan welk bestand je wilt bewerken."
	echo "-y	[URL BESTAND]			(vervanning voor -u) Haalt de url uit bestanden die eerder zijn gedownload met deze tool. (pad nodig)"
	echo ""
	echo ""
	echo ""
	echo "audio	-a				Exporteer het bestand als audio met een .mp3 bestandtype en voeg uitgebreide metadata toe (standaard bestandtype is .mp4)"
	echo "-p	[PROCENT]			Zet een eigen procent van volume (kan harder of zachter zijn) Voorbeeld: -p 150"
	echo "-e	[EINDE](tijd)			geef aan wanneer je bestand moet stopen en houd alle metadata (met een \|\"seconde\" bepaal je hoelang de fadeout is standaard 3)"
	echo "-s	[SECONDE](tijd)			Download vanaf de speciafieke seconde die je hem geeft (Format: onder de min -s 34 | over de min -s 1:24)(met een \|\"seconde\" bepaal je hoelang de fadein is standaard 2)(-s c haalt stilte automatish weg)"
	echo "-t	[TWEEDELIED](tijd)		als er meerdere liedjes in 1 video zitten. Geef aan waar de wissel in de video zit"
	echo ""
	echo ""
	echo "metadata (audio)"
	echo "-m	[MANIPULATIE] 			manipuleer de titel van de titel zodat het script denkt dat je input de titel is die hij dan verwerkt (handig voor -T)"
	echo "-r	[ROTZOOI TITEL]			Voor min a, een titel zonder goede structuur"
	echo "-g	[GENRE]				Zet voor de huidge download een andere genre voor de huidige download"
	echo "-T	[THUMBNAIL] 			Genereerd zelf een thumbnail met text van een foto via een url na argument (ondersteund: youtube_link, insta_link, bestanden, andere foto link)"
	echo "	[THUMBNAIL]			(\"youtubedl -T\" (zonder argument) betekend dat hij de huidige thumbnail gebruik als foto \"youtubedl -T INSTA_URL\|boven(of onder) sneidt hij af)"
	echo ""
	echo "thumbnail extract"
	echo "-f	[FOTO DOWNLOAD]			Werkt hetzelfde als het downloaden van video en audio alleen download het sript met dit argument thumbnail's"
	echo ""
	echo "technisch:"
	echo "-U	[UPDATE]			Update dependencies als dat nodig is"
	echo "-i	[INSTALATIE]			Deze optie is wat je als allereers moet doen! met dit argument worden noodzakelijke tools geïnstaleerd, dit is eenmalig"
	echo ""
	echo "overig:"
	echo "-o	[OPEN]				Opend direct het nieuw gedownloade bestand"
	echo "-h	[HELP]				Laat een korte hulp pagina zien (Deze pagina)"
	echo "-b	[BEIDE]				Download beide video en audio in één commando (maar één link mogelijk)"
	echo "-v	[VERSIE]			laat de huidige versie van het script zien met het laatste update bericht"
	echo "-s	[SYNC]				Synced al je nummers met je iPhone"
	exit 10
}
toolscheck () {
	for t in ${tools[@]}; do
		FILE="/usr/local/Cellar/$t"
		echo `ls $FILE &> /dev/null || echo "$t"` >> ~/Documents/youtube-dl/.nietgeinstalleerd.list
	done
	installeeraplicaties=`cat ~/Documents/youtube-dl/.nietgeinstalleerd.list| sed -e "/^$/d"`
	rm ~/Documents/youtube-dl/.nietgeinstalleerd.list
	if [[ $installeeraplicaties != "" ]]; then
		installeerlijst=($installeeraplicaties)
		t=""
		hoeveelheidnieuweprogrammas=`echo "${#installeerlijst[@]}"`
		hoeveel2=0
		echo "er zijn bepaalde dependencies niet geinstalleerd, installing..."
		for t in ${installeerlijst[@]}; do
			hoeveel2=$(( hoeveel2 + 1 ))
			huidigpercentage=$(( 100 / hoeveelheidnieuweprogrammas * hoeveel2 ))
			datevoordl=`date`
			datevoordl=`echo ${datevoordl:11:5}`
			brew install $t &> /dev/null & while `ps -ef | grep br[e]w > /dev/null`;do for s in / / - - \\ \\ \|; do printf "\r$s		$t";sleep .05;done;done
			datenadl=`date`
			datenadl=`echo ${datenadl:11:5}`
			if [[ $hoeveelheidnieuweprogrammas == $hoeveel2 ]]; then
				huidigpercentage=100
			fi
			berekenmin
			echo -ne "\r$hoeveel2/$hoeveelheidnieuweprogrammas (%$huidigpercentage)	$t - $berekend\n"
		done
		echo "	"
		echo "geinstalleerde dependencies: "${installeerlijst[@]}""
		exit 0
	fi
	pip=pip
	which pip &>/dev/null||pip=pip3
	which deep-translator&>/dev/null||$pip install -U deep_translator
}
install () {
	locatie
	touch ~/Documents/youtube-dl/.black.list
	touch ~/Documents/youtube-dl/.white.list
	ls /usr/local/bin/brew &> /dev/null ||checkinstall=1
	if [[ $checkinstall == 1 ]]; then
		echo -e "je mist Homebrew, Dit is een essentieel component van deze code.."
		echo " "
		echo "je instaleerd Homebrew met:"
		echo -e '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
		exit 1
	fi
	ls ~/.config/youtube-dl.conf &> /dev/null || checkinstall=1
	if [[ $checkinstall == 1 ]]; then
		mkdir ~/.config &>/dev/null
		echo '--no-playlist --output "~/Documents/youtube-dl/%(uploader)s - %(title)s.%(ext)s"' > ~/.config/youtube-dl.conf
		echo "configuratie bestanden aangemaakt"
		checkinstall=0
		ietsgedaan=1
	fi
	ls ~/Documents/youtube-dl/ &> /dev/null ||checkinstall=1
	if [[ $checkinstall == 1 ]]; then
		mkdir -p ~/Documents/youtube-dl/
		echo "map gemaakt"
		checkinstall=0
		ietsgedaan=1
	fi
	ls ~/Documents/youtube-dl_video/ &> /dev/null ||checkinstall=1
	if [[ $checkinstall == 1 ]]; then
		mkdir -p ~/Documents/youtube-dl_video/
		echo "map gemaakt"
		checkinstall=0
		ietsgedaan=1
	fi
	for t in ${tools[@]}; do
		FILE="/usr/local/Cellar/$t"
		echo `ls $FILE &> /dev/null || echo "$t"` >> ~/Documents/youtube-dl/.nietgeinstalleerd.list
	done
	touch ~/Documents/youtube-dl/.gedaan
	sleep .2
	rm ~/Documents/youtube-dl/.gedaan
	installeeraplicaties=`cat ~/Documents/youtube-dl/.nietgeinstalleerd.list| sed -e "/^$/d"`
	rm ~/Documents/youtube-dl/.nietgeinstalleerd.list
	if [[ $installeeraplicaties != "" ]]; then
		echo "tools aan het instaleren! (dit kan LANG duren, Wees geduldig)"
		installeerlijst=($installeeraplicaties)
		t=""
		hoeveelheidnieuweprogrammas=`echo "${#installeerlijst[@]}"`
		hoeveel2=0
		for t in ${installeerlijst[@]}; do
			hoeveel2=$(( hoeveel2 + 1 ))
			huidigpercentage=$(( 100 / hoeveelheidnieuweprogrammas * hoeveel2 ))
			brew install $t &> /dev/null & while `ps -ef | grep br[e]w > /dev/null`;do for s in / / - - \\ \\ \|; do printf "\r$s		$t";sleep .05;done;done
			if [[ $hoeveelheidnieuweprogrammas == $hoeveel2 ]]; then
				huidigpercentage=100
			fi
			echo -ne "\r$hoeveel2/$hoeveelheidnieuweprogrammas (%$huidigpercentage)	$t\n"
		done
		echo ""
		echo "geinstalleerde dependencies: "${installeerlijst[@]}""
		ietsgedaan=1
	fi
	ls ~/Documents/youtube-dl/.config.yt&>/dev/null||geenconfig=1
	if [[ $geenconfig == 1 ]]; then
		echo "GENRE=" > ~/Documents/youtube-dl/.config.yt
		echo "#de waarde die je GANRE geeft zal je standaard waarde worden" >> ~/Documents/youtube-dl/.config.yt
		echo "" >> ~/Documents/youtube-dl/.config.yt
		echo "ENHANSEDAUDIO=" >> ~/Documents/youtube-dl/.config.yt
		echo "#dit zal de waarde zijn om te kijken of je enhansedaudio wilt" >> ~/Documents/youtube-dl/.config.yt
		echo "" >> ~/Documents/youtube-dl/.config.yt
		echo "IPHONESYNC=" >> ~/Documents/youtube-dl/.config.yt
		echo "IPHONENAAM=" >> ~/Documents/youtube-dl/.config.yt
		echo "#BEWERKT NOOIT DIRECT IPHONENAAM, GEBRUIK: youtubedl -i" >> ~/Documents/youtube-dl/.config.yt
		echo "#LET OP! ZORG ERVOOR DAT IPHONE NAAM GOEDSTAAT" >> ~/Documents/youtube-dl/.config.yt
		echo "#dit bepalen of je na een download gelijk je muziek wilt synchroniseren naar je iPhone" >> ~/Documents/youtube-dl/.config.yt
	fi
	if ! `cat ~/Documents/youtube-dl/.config.yt|grep -i "^IPHONESYNC=" &>/dev/null`; then
		echo "" >> ~/Documents/youtube-dl/.config.yt
		echo "IPHONESYNC=" >> ~/Documents/youtube-dl/.config.yt
		echo "IPHONENAAM=" >> ~/Documents/youtube-dl/.config.yt
		echo "#BEWERKT NOOIT DIRECT IPHONENAAM, GEBRUIK: youtubedl -i" >> ~/Documents/youtube-dl/.config.yt
		echo "#LET OP! ZORG ERVOOR DAT IPHONE NAAM GOEDSTAAT" >> ~/Documents/youtube-dl/.config.yt
		echo "#dit bepalen of je na een download gelijk je muziek wilt synchroniseren naar je iPhone" >> ~/Documents/youtube-dl/.config.yt
	fi
	genre=`cat ~/Documents/youtube-dl/.config.yt|grep -i "^GENRE="|sed -e "s/GENRE=//"`
	if [[ $genre == "" ]]; then
		echo "Naar welke genre zul je het meeste luisteren? (Dit wordt de standaard genre tenzei je een speciafieke selecteerd met argumenten)"
		read genre
		gsed -i "s/^GENRE=.*/GENRE=$genre/" ~/Documents/youtube-dl/.config.yt
	fi
	enhansedaudio=`cat ~/Documents/youtube-dl/.config.yt|grep -i "^ENHANSEDAUDIO="|sed -e "s/ENHANSEDAUDIO=//"`
	while [[ $enhansedaudio == "" ]]; do
		echo "wil je enhansed audio? (hogere bitrate) Ja (1)/Nee (2)"
		read enhansedaudio
		if [[ $enhansedaudio == 1 ]]||[[ $enhansedaudio == ja ]]||[[ $enhansedaudio == Ja ]]||[[ $enhansedaudio == JA ]]; then
			enhansedaudio="true"
		fi
		if [[ $enhansedaudio == 2 ]]||[[ $enhansedaudio == Nee ]]||[[ $enhansedaudio == nee ]]||[[ $enhansedaudio == NEE ]]; then
			enhansedaudio="false"	
		fi
		if [[ $enhansedaudio == "true" ]]||[[ $enhansedaudio == "false" ]]; then
			gsed -i "s/^ENHANSEDAUDIO=.*/ENHANSEDAUDIO=$enhansedaudio/" ~/Documents/youtube-dl/.config.yt
		else
			echo "geen geldig argument herkend, probeer opnieuw"
			enhansedaudio=""
		fi
	done
	isync=`cat ~/Documents/youtube-dl/.config.yt|grep -i "^IPHONESYNC="|sed -e "s/IPHONESYNC=//"`
	while [[ $isync == "" ]]; do
		echo "Wil je automatish je iPhone Synchroniseren aan je Mac muziek-bibliotheek? Y/n"
		read isync
		if [[ $isync == "y" ]]||[[ $isync == "Y" ]]||[[ $isync == "" ]]; then
			isync="true"
		fi
		if [[ $isync == "n" ]]||[[ $isync == "N" ]];then
			isync="false"	
		fi
		if [[ $isync == "true" ]]||[[ $isync == "false" ]]; then
			gsed -i "s/^IPHONESYNC=.*/IPHONESYNC=$isync/" ~/Documents/youtube-dl/.config.yt
			ietsgedaan=1
		else
			echo "geen geldig argument herkend, probeer opnieuw"
			isync=""
		fi
	done
	iPhonenaam=`cat ~/Documents/youtube-dl/.config.yt|grep -i "^IPHONENAAM="|sed -e "s/IPHONENAAM=//"`
	isync=`cat ~/Documents/youtube-dl/.config.yt|grep -i "^IPHONESYNC="|sed -e "s/IPHONESYNC=//"`
	if [[ $isync == "true" ]]&&[[ $iPhonenaam == "" ]];then
		gevonden=0
		read -p "Voledige naam van je iPhone: " iPhonenaam
		osascript -e 'set iPhoneName to "'"$iPhonenaam"'"
		-- Open Finder window
		tell application "Finder" to open ("/" as POSIX file)

		on isPhoneVisible(iPhoneName)
			tell application "System Events" to tell outline 1 of scroll area 1 of splitter group 1 of window 1 of application process "Finder"
				set theElements to first UI element of every row whose name is iPhoneName
				repeat with e in theElements
					try
						if name of e is iPhoneName then
							return true
						end if
					end try
				end repeat
			end tell
			return false
		end isPhoneVisible

		if not isPhoneVisible(iPhoneName) then
			-- Restart daemon that shows the iPhone in the sidebar so it is actually visible
			do shell script "pkill -9 AMPDevicesAgent AMPDeviceDiscoveryAgent"
		end if


		-- Select iPhone
		-- needs retry until the iPhone becomes visible
		tell application "System Events" to tell outline 1 of scroll area 1 of splitter group 1 of window 1 of application process "Finder"
			set hasFoundPhone to false
			set x to 0
			repeat while not hasFoundPhone 
				set theElements to first UI element of every row whose name is iPhoneName
				repeat with e in theElements
					try
						if name of e is iPhoneName then
							tell e to perform action "AXOpen"
							do shell script "touch /Users/'"$USER"'/Documents/youtube-dl/.gevonden"
							set hasFoundPhone to true

							exit repeat
						end if
					end try
				end repeat
				delay 1
				set x to x + 1
				if 15 > x then
					exit repeat
					--do shell script "pkill osascript&>/dev/null"
				end if
			end repeat
		end tell' &>/dev/null
		osascript -e 'tell application "Finder"
		close window 1
		end tell'
		ls "/Users/$USER/Documents/youtube-dl/.gevonden"&>/dev/null&&gevonden=1
		echo ""
		if [[ $gevonden == 1 ]]; then
			echo "iPhone gevonden"
			gsed -i "s/^IPHONENAAM=.*/IPHONENAAM=$iPhonenaam/" ~/Documents/youtube-dl/.config.yt
			ietsgedaan=1
		else
			echo "iPhone niet gevonden, controleer of je op hetzelfde netwerk zit & probeer het zometeen opnieuw"
			exit 1
		fi
		rm "/Users/$USER/Documents/youtube-dl/.gevonden" &>/dev/null
	fi
	# if ! `ls "/Users/$USER/Library/Workflows/Applications/Folder Actions/autoaddmusic.workflow"&>/dev/null`; then
	# 	#hij is er niet
	# 	while [[ $goedantwoord != 1 ]];do 
	# 		echo "geen music sync gevonden, wil je deze downlaoden (beste ervaring) Y/n"
	# 		read andwoord
	# 		if [[ $andwoord == "" ]]||[[ $andwoord == "y" ]]||[[ $andwoord == "Y" ]]; then
	# 			trap "rm -rf /Users/$USER/Downloads/autoaddmusic.workflow.zip /Users/$USER/Downloads/__MACOSX /Users/$USER/Downloads/autoaddmusic.workflow* &>/dev/null" SIGINT
	# 			wget -O /Users/$USER/Downloads/autoaddmusic.workflow.zip https://raw.githubusercontent.com/yabru/ytdlworkflow/main/autoaddmusic.workflow.zip
	# 			unzip /Users/$USER/Downloads/autoaddmusic.workflow.zip -d /Users/$USER/Downloads
	# 			rm -rf /Users/$USER/Downloads/autoaddmusic.workflow.zip /Users/$USER/Downloads/__MACOSX
	# 			open /Users/$USER/Downloads/autoaddmusic.workflow
	# 			goedantwoord=1
	# 			#rm -rf "/Users/$USER/Library/Workflows/Applications/Folder Actions/autoaddmusic.workflow"
	# 		else
	# 			if [[ $andwoord == "n" ]]||[[ $andwoord == "N" ]];then
	# 				goedantwoord=1
	# 			fi
	# 		fi
	# 	done
	# fi

	if [[ $ietsgedaan == 1 ]]; then
		echo ""
		echo "Je gedownloaden videos en audio bestanden worden nu opgeslagen in je Documents (Documenten) en in de nieuwe map genaamd: youtube-dl voor audio en youtube-dl_video voor je video bestanden"
	else
		echo "Alles al geinstalleerd, je config: /Users/$USER/Documents/youtube-dl/.config.yt"
	fi
	exit 0
}
update () {
	locatie
	hoeveel1=0
	hoeveel2=0
	echo "checken voor update van script."
	versievoorupdate=`head -2 ~/.github/youtubedl.sh|grep version|sed -e "s/version=//"|sed -e "s/'//g"`
	cd ~/.github
	git stash &> /dev/null
	git stash drop &> /dev/null
	git pull
	chmod 755 `realpath $0`
	versienaupdate=`head -2 ~/.github/youtubedl.sh|grep version|sed -e "s/version=//"|sed -e "s/'//g"`
	if [[ $versievoorupdate != $versienaupdate ]]; then
		echo -e "\nGeupdate naar versie: $versienaupdate\nMet Patch Bericht: `head -3 ~/.github/youtubedl.sh|tail -1|sed -e "s/commit='//"|sed -e "s/'//g"`\n"
	fi
	#brew doctor &> /dev/null & while `ps -ef | grep br[e]w > /dev/null`;do for s in . .. ...; do printf "\rChecken voor updates$s   	";sleep .5;done;done
	brew outdated|xargs> ~/Documents/youtube-dl/.outdated.txt& while `ps -ef | grep br[e]w|grep outd[a]ted &> /dev/null`;do for s in . .. ...; do printf "\rChecken voor updates$s   	";sleep .5;done;done
	brewoutdatedlist=`cat ~/Documents/youtube-dl/.outdated.txt`
	rm ~/Documents/youtube-dl/.outdated.txt
	for t in ${tools[@]}; do
		for f in ${brewoutdatedlist[@]}; do
			if [[ $t == $f ]]; then
				hoeveel1=$(( hoeveel1 + 1 ))
			fi
		done
	done
	if [[ $hoeveel1 != "0" ]]; then
		echo -e "\n"
	fi
	for t in ${tools[@]}; do
		for f in ${brewoutdatedlist[@]}; do
			if [[ $t == $f ]]; then
				hoeveel2=$(( hoeveel2 + 1 ))
				huidigpercentage=`bc <<< "scale=2; 100/$hoeveel1*$hoeveel2"|awk 'BEGIN {FS="."}{print $1}'`
				space="       "
				if [[ $hoeveel1 == $hoeveel2 ]]; then
					huidigpercentage=100
					space="      "
				fi
				brew upgrade $f &> /dev/null & while `ps -ef | grep br[e]w > /dev/null`;do for s in / / - - \\ \\ \|; do echo -ne "\r$s	$hoeveel2/$hoeveel1 $f      "; sleep .05;done;done
				echo -ne "\r√	$hoeveel2/$hoeveel1 (%$huidigpercentage)$space$t\n"
				if [[ $updatelijst == "" ]]; then
					updatelijst=$t
				else
					updatelijst=`echo "$updatelijst $t"`
				fi
				ietsgeupdate=1
			fi
		done
	done
	if [[ $ietsgeupdate == 1 ]]; then
		echo ""
		echo "Geüpdate dependencies: $updatelijst"
	else
		echo -ne "\rAlles al up to date             \n"
	fi
	exit 0
}
syncfunc () {
osascript -e 'set iPhoneName to "'"$iPhonenaam"'"
	-- Open Finder window
	tell application "Finder"
		if exists window 1 then
		else
			tell application "Finder" to open ("/" as POSIX file)
		end if
	end tell

	on isPhoneVisible(iPhoneName)
		tell application "System Events" to tell outline 1 of scroll area 1 of splitter group 1 of window 1 of application process "Finder"
			set theElements to first UI element of every row whose name is iPhoneName
			repeat with e in theElements
				try
					if name of e is iPhoneName then
						return true
					end if
				end try
			end repeat
		end tell
		return false
	end isPhoneVisible

	if not isPhoneVisible(iPhoneName) then
		-- Restart daemon that shows the iPhone in the sidebar so it is actually visible
		do shell script "pkill -9 AMPDevicesAgent AMPDeviceDiscoveryAgent"
	end if


	-- Select iPhone
	-- needs retry until the iPhone becomes visible
	tell application "System Events" to tell outline 1 of scroll area 1 of splitter group 1 of window 1 of application process "Finder"
		set hasFoundPhone to false
		set x to 0
		repeat while not hasFoundPhone
			set theElements to first UI element of every row whose name is iPhoneName
			repeat with e in theElements
				try
					if name of e is iPhoneName then
						tell e to perform action "AXOpen"
						set hasFoundPhone to true
						exit repeat
					end if
				end try
			end repeat
			set x to x + 1
			--if 10000 > x then
			--	exit repeat
				--do shell script "pkill osascript&>/dev/null"
			--end if
			delay 1
		end repeat
	end tell

	-- Start sync
	tell application "System Events" to tell application process "Finder"
		repeat until button "Sync" of splitter group 1 of splitter group 1 of window iPhoneName exists
			delay 1
		end repeat
		click button "Sync" of splitter group 1 of splitter group 1 of window iPhoneName
		set x to 0
		repeat until button "Skip Backup" of splitter group 1 of splitter group 1 of window iPhoneName exists
			delay 1
			set x to x + 1
			--if 10000 > x then
				--exit repeat
				--do shell script "pkill osascript&>/dev/null"
			--end if
		end repeat
		repeat while button "Skip Backup" of splitter group 1 of splitter group 1 of window iPhoneName exists
			click button "Skip Backup" of splitter group 1 of splitter group 1 of window iPhoneName
		end repeat
		--repeat 10 times
    	--	click button "Skip Backup" of splitter group 1 of splitter group 1 of window iPhoneName
		--end repeat
	end tell'

}
fotocrop () {
	fotopositie=`echo "$instaurl"|awk 'BEGIN {FS="|"}{print $2}'`
	if [[ $fotopositie != "" ]]; then
		if [[ $fotopositie == "boven" ]]; then
			uiteindelijkepositie="north"
		fi
		if [[ $fotopositie == "onder" ]]; then
			uiteindelijkepositie="south"
		fi
	else
		uiteindelijkepositie="center"
	fi
	convert -gravity $uiteindelijkepositie -crop 16:9 ~/Documents/youtube-dl/outfile.jpg ~/Documents/youtube-dl/outfile.jpg &> /dev/null
}
prodcleaner () {
	n=0
	while [ "$n" -lt 6 ]; do
	n=$(( n + 1 ))
	if [[ $engeneer == "."* ]]; then
		echo "er is een ."
		engeneer=`echo "$engeneer"|sed -e "s/.//"`
	fi
	if [[ $engeneer == "by"* ]]; then
		echo "er is een by"
		engeneer=`echo "$engeneer"|sed -e "s/by//"`
	fi
	if [[ $engeneer == "By"* ]]; then
		echo "er is een By"
		engeneer=`echo "$engeneer"|sed -e "s/By//"`
	fi
	if [[ $engeneer == "BY"* ]]; then
		echo "er is een BY"
		engeneer=`echo "$engeneer"|sed -e "s/BY//"`
	fi
	if [[ $engeneer == "bY"* ]]; then
		echo "er is een bY"
		engeneer=`echo "$engeneer"|sed -e "s/bY//"`
	fi
	if [[ $engeneer == " "* ]]; then
		echo "er is een spatie"
		engeneer=`echo "$engeneer"|sed -e "s/ //"`
	fi
	done
}
proddetectie () {
	if [[ $mogelijkeprod == " prod"* ]]||[[ $mogelijkeprod == "prod"* ]]; then
		prodintitel=1
		seperator="prod"
	fi
	if [[ $mogelijkeprod == " Prod"* ]]||[[ $mogelijkeprod == "Prod"* ]]; then
		prodintitel=1
		seperator="Prod"
	fi
	if [[ $mogelijkeprod == " PROD"* ]]||[[ $mogelijkeprod == "PROD"* ]]; then
		prodintitel=1
		seperator="PROD"
	fi
}
mint () {
	eval nextopt=\${$OPTIND}
	if [[ -n $nextopt && $nextopt != -* ]] ; then
		OPTIND=$((OPTIND + 1))
		instaurl=$nextopt
	else
		instaurl="vid"
	fi
}
mind () {
	ls ~/Documents/youtube-dl/.vorigegroepen.list &>/dev/null&&mindgevonden=1
	if [[ $mindgevonden == 1 ]]; then
		teverwijderengroepenarray=(`cat ~/Documents/youtube-dl/.vorigegroepen.list`)
		for g in ${teverwijderengroepenarray[@]]}; do
			sed -i '' "s/$g//" ~/Documents/youtube-dl/.black.list
			sed -i '' '/^[[:space:]]*$/d' ~/Documents/youtube-dl/.black.list
		done
		rm ~/Documents/youtube-dl/.vorigegroepen.list &>/dev/null
		if [[ ${#teverwijderengroepenarray[@]} -gt 1 ]]; then
			echo "groepen ${teverwijderengroepenarray[@]} verwijderd."
		else
			echo "groep ${teverwijderengroepenarray[@]} verwijderd."
		fi
	else
		echo -e "Vorige sessie groepen niet gevonden.\nvoor handmatige manipulatie bewerk: ~/Documents/youtube-dl/.black.list"
		exit 1
	fi
	exit 0
}
while getopts uharidfobs:e:t:UTm:g:vy:p:F:S flag;
do
	case "${flag}" in
	u)			yourl=" ";;

	h)			help;;

	a)			vofa=a;;

	d)			mind;;

	f)			image=1;;

	r)			minr=1;;

	i)			install;;

	o)			open=1;;

	b)			beide=1;;

	s)			seconde=${OPTARG};;

	e)			eindesec=${OPTARG};;

	t)			tweedelied=${OPTARG};;

	g)			genre=${OPTARG};;

	y)			algedaanvidpad=${OPTARG};;

	T)			
				eval nextopt=\${$OPTIND}
				if [[ -n $nextopt && $nextopt != -* ]] ; then
					OPTIND=$((OPTIND + 1))
					instaurl=$nextopt
				else
					instaurl="vid"
				fi
				;;
	U)			update;;

	m)			manueelinput=${OPTARG};;

	v)			versioncheck=1;;

	p)			volumepc=${OPTARG};;

	F)			anderefile=${OPTARG};;

	S)			syncactivatie=1;;

	*)			exit 0;;
	esac
done
genretest=`cat ~/Documents/youtube-dl/.config.yt 2>/dev/null|grep -i "^GENRE="|sed -e "s/GENRE=//"`
if [[ $genretest == "" ]]; then
	echo "run youtubedl -i"
	exit 1
fi
enhansedaudio=`cat ~/Documents/youtube-dl/.config.yt 2>/dev/null|grep -i "^ENHANSEDAUDIO="|sed -e "s/ENHANSEDAUDIO=//"`
if [[ $enhansedaudio == "" ]]; then
	echo "run youtubedl -i"
	exit 1
fi
isync=`cat ~/Documents/youtube-dl/.config.yt|grep -i "^IPHONESYNC="|sed -e "s/IPHONESYNC=//"`
if [[ $isync == "" ]]; then
	echo "run youtubedl -i"
	exit 1
fi
iPhonenaam=`cat ~/Documents/youtube-dl/.config.yt|grep -i "^IPHONENAAM="|sed -e "s/IPHONENAAM=//"`
if [[ $isync == "true" ]]&&[[ $iPhonenaam == "" ]]; then
	echo -e "geen iphone gevonden terwijl Sync aanstaat,\nvoeg een iPhone toe: youtubedl -i\nOf zet IPHONESYNC op false in: ~/Documents/youtube-dl/.config.yt"
fi
#############################
#	HET BEGIN VAN DE CODE	#
#############################
if [[ $syncactivatie == 1 ]]&&[[ $yourl == "" ]]; then
	syncfunc&>/dev/null&
	exit 0
fi
for l in $@; do
	if [[ $l == "-"* ]]&&[[ $start == 1 ]]; then
		start=0
		break
	fi
	if [[ $start == 1 ]]; then
		yourl="$yourl $l"
	fi
	if [[ $l == "-"* ]]&&[[ $l == *"u"* ]]; then
		start=1
	fi
done
#yourl=`echo $yourl|sed -e "s/ //"`
rm ~/Documents/youtube-dl/.vorigegroepen.list &> /dev/null
if [[ $versioncheck == 1 ]]; then
	echo "youtubedl version $version"
	echo "laatste patch bericht: $commit"
	exit 0
fi
locatie
toolscheck
if [[ $algedaanvidpad != "" ]]; then
	ls "$algedaanvidpad" &> /dev/null && gehaald=1
	if [[ $gehaald == 1 ]]; then
		yourl=`exiftool "$algedaanvidpad"|grep '^User Defined Text               : (URL)'`
		if [[ $yourl == "" ]]; then
			echo "geen goed bestand gevonden"
			exit 1
		fi
		yourl=`echo ${yourl:40}`

	fi
fi
if [[ $anderefile == "" ]]; then
	if  [[ "$yourl" == "" ]]; then
		if [[ $instaurl == "" ]];then geengoedeurl=1 ;fi
		if [[ $instaurl == "vid" ]];then geengoedeurl=1 ;fi
		if [[ $geengoedeurl == 1 ]]||[[ $image == 0 ]]; then
				toegang="0"
				help
		fi
	fi
fi
if [[ $seconde != "" ]]; then
	seconde=`echo "$seconde"|sed -e "s/,/\./"`
	secondecijfercheck=`echo $seconde|sed -e "s/://"`
	secondecijfercheck=`echo $secondecijfercheck|sed -e "s/\.//g"`
	secondecijfercheck=`echo $secondecijfercheck|sed -e "s/|//"`
	if ! [[ "$secondecijfercheck" =~ ^[0-9]+$ ]]&&[[ "$secondecijfercheck" != "c" ]]; then
		echo "Gebruik cijfers bij -s"
		exit 1
	fi
	secondecijfercheck=""
fi
if [[ $eindesec != "" ]]; then
	eindesec=`echo "$eindesec"|sed -e "s/,/\./g"`
	secondecijfercheck=`echo $eindesec|sed -e "s/://"`
	secondecijfercheck=`echo $secondecijfercheck|sed -e "s/\.//g"`
	secondecijfercheck=`echo $secondecijfercheck|sed -e "s/|//g"`
	if ! [[ "$secondecijfercheck" =~ ^[0-9]+$ ]]; then
		echo "Gebruik cijfers bij -e"
		exit 1
	fi
fi
if [[ $tweedelied != "" ]]; then
	tweedelied=`echo "$tweedelied"|sed -e "s/,/\./"`
	tweedeliedcijfercheck=`echo $tweedelied|sed -e "s/://"`
	tweedeliedcijfercheck=`echo $tweedeliedcijfercheck|sed -e "s/\.//"`
	tweedeliedcijfercheck=`echo $tweedeliedcijfercheck|sed -e "s/|//"`
	if ! [[ "$tweedeliedcijfercheck" =~ ^[0-9]+$ ]]; then
		echo "Gebruik cijfers bij -e"
		exit 1
	fi
fi
if [[ $volumepc != "" ]]; then
	if ! [[ "$volumepc" =~ ^[0-9]+$ ]]; then
		echo "geef een percentage aan bij -p"
		echo "bvb: youtubedl -au URL -p 150 (voor 150 procent volume) (een half keer zo hard)"
		exit 1
	fi
fi
if [[ $volumepc -gt 350 ]]; then
	echo "je volume wordt nu $volumepc%, weet je zeker dat je door wilt gaan? (y/N)"
	read doorgaan
	if [[ $doorgaan == "n" ]]||[[ $doorgaan == "N" ]]||[[ $doorgaan == "" ]]||[[ $doorgaan == "no" ]]||[[ $doorgaan == "No" ]]||[[ $doorgaan == "nee" ]]||[[ $doorgaan == "Nee" ]]; then
		exit 0
	fi
fi
if [[ $beide == 1 ]]; then
	beidecheck="1"
	vofa=a
fi
yourltweedelinkcheck=`echo $yourl|awk 'BEGIN {FS=" "}{print $2}'`
if [[ $yourltweedelinkcheck != "" ]]; then
	yourltweedelinkcheck="1"
	yourleerstelink=`echo $yourl|awk 'BEGIN {FS=" "}{print $1}'`
	allelinksbehalvedeeerste=`echo "$yourl"|sed -e "s|$yourleerstelink ||"`
	yourl=`echo $yourleerstelink`
fi
if [[ $yourl == *"youtube.com/playlist"* ]]; then
	if [[ $vofa == a ]]; then
		yourl=`/usr/local/bin/youtube-dl "$yourl" --playlist-reverse --flat-playlist -i --get-filename -o "https://www.youtube.com/watch?v=%(id)s"|awk 1 ORS="\\\\\\ "`
		yourl="`echo $yourl|rev|sed -e "s/\\\\\\//"|rev`"
		echo "`which youtubedl` -au $yourl" > ~/Documents/youtube-dl/.$random-script.sh
		chmod 755 ~/Documents/youtube-dl/.$random-script.sh
		sleep 1&&rm ~/Documents/youtube-dl/.$random-script.sh&
		bash ~/Documents/youtube-dl/.$random-script.sh
		exit
	else
		command="youtubedl -u `/usr/local/bin/youtube-dl "$yourl" --flat-playlist -i --get-filename -o "https://www.youtube.com/watch?v=%(id)s"|awk 1 ORS="\\\\\\ "`"
		command=`echo $command|rev|sed -e "s/\\\\\\//"|rev`
	fi
	command="$command ; exit"
fi
if [[ $image == 1 ]]; then
	if [[ $instaurl == "" ]]; then
		filenaam=`/usr/local/bin/youtube-dl $yourl -x --get-filename 2> /dev/null |sed -e "s/ /$random/g"`
		filenaamZonderExtentie=/Users/$USER/Downloads/`basename $filenaam|rev| cut -d'.' -f 2-|rev`.jpg
		troll=`echo $filenaamZonderExtentie|sed -e "s/$random/ /g"`
		wget -O "$troll" `youtube-dl $yourl --get-thumbnail --no-check-certificate 2> /dev/null` &> /dev/null
		exit
	else
		vofa=a
	fi
fi
#defineer filenaam als de naam die het bestandje krijgt van youtube-dl
#filenaamvooracc=`/usr/local/bin/youtube-dl $yourl -x --get-filename --output "~/Documents/youtube-dl/%(uploader)s$random%(title)s.%(ext)s"`
#filenaam=`/usr/local/bin/youtube-dl $yourl -x --get-filename`
random2=`echo $random|rev`
if [[ $anderefile == "" ]]; then
	if [[ $yourl == "" ]]; then
		if [[ $manueelinput == "" ]]; then
			echo "geen een url of manueelinput -m/-u"
			exit 1
		else
			toegang=1
			specialetoegang=1
		fi
	else
		alleytinfo=`/usr/local/bin/youtube-dl $yourl --get-title --get-filename --output "~/Documents/youtube-dl/%(uploader)s$random2%(title)s.%(ext)s$random2%(upload_date)s" 2>/dev/null|awk 1 ORS="$random"`
		titel=`echo $alleytinfo|awk 'BEGIN {FS="'$random'"}{print $1}'`
		filenaamvooracc=`echo $alleytinfo|awk 'BEGIN {FS="'$random'"}{print $2}'`
		#filenaamvooracc=`echo "/Users/$USER/Documents/youtube-dl/"``echo $alleytinfo|awk 'BEGIN {FS="'/Users/$USER/Documents/youtube-dl/'"}{print $2}'`
		filenaam=`echo $filenaamvooracc|sed -e "s|$random2| - |"|awk 'BEGIN {FS="'$random2'"}{print $1}'`
		uploaddate=`echo $alleytinfo|awk 'BEGIN {FS="'$random2'"}{print $3}'|awk 'BEGIN {FS="'$random'"}{print $1}'`
		uploaddate=${uploaddate:0:4}
		filenaamExtentie=.`echo "${filenaam}"|rev|awk 'BEGIN { FS = "." } ; { print $1 }'|rev`
		if  [[ "$filenaamExtentie" == ".m4a" ]];	#hier controleer je of het filetipe een .m4a is
		then
			toegang="1"
			typ=".m4a"
			#hij vranderd hier de tekst in het argument van filenaamverbeted van $filenaam (een .m4a) naar een .mp3
		fi
		if  [[ "$filenaamExtentie" == ".opus" ]]; #hier controleer je of het filetipe een .opus is
		then
			toegang="1"
			typ=".opus"
		fi
		if	[[ "$filenaamExtentie" == ".webm" ]]; #hier controleer je of het filetipe een .webm is
		then 
			toegang="1"
			typ=".opus"

			#hier verander je de argumenten van filenaam zodat hij denkt (bij een .webm) dat het een .opus is (waar hij bij een .webm automatish naar veranderd) dit is alleen bij .webm het geval
			filenaam=`echo $filenaam|sed -e "s/\.webm*/.opus/"`
		fi
		if [[ "$filenaamExtentie" == ".mp4" ]]; #een test om te kijen of het yt url wel kopt
		then
			toegang="1"
			typ=".mp4"
		fi
		if [[ "$toegang" == "0" ]]; #als er iets mis ging met een filenaam geven dan komt dit
		then
			echo -e "\nERROR: Geen geldig YouTube URL gevonden\nVoor meer hulp, [ youtubedl -h ]\n"
			exit 1
		fi
	fi
else
	ls "$anderefile"&>/dev/null&&toegang=1
	titel=`ls "$anderefile"|sed -e "s|.*/||"`
	account="file"
fi
if [[ "$toegang" == "1" ]]; then #hier controleer je of hij uberhoubt goed een filenaam gekregen heeft
	#titel=`basename "$filenaamvooracc"|rev| cut -d'.' -f 2-|rev| awk 'BEGIN {FS="'$random'"}{print $2}'` # sed -e "s/ - /$random/"|
	if [[ $anderefile == "" ]]; then
		account=`basename "$filenaamvooracc"|rev| cut -d'.' -f 2-|rev| awk 'BEGIN {FS="'$random2'"}{print $1}'`
	fi
	if [[ $specialetoegang != 1 ]]; then
		echo -e "\n\nTitel:		$titel" 
		echo " "
		echo -e "Account:	$account\n\n"
	fi
	if [[ "$vofa" == "a" ]]; then
		if [[ $anderefile == "" ]]; then
			if [[ $image == 0 ]]; then	
				filenaamverbeterd=`echo $filenaam|rev|sed -e "s/$(echo $typ|rev)/3pm./"|rev`
				yourlid=$(echo $yourl|sed -e "s|.*youtu.be/||")
				yourlid=$(echo $yourlid|sed -e "s|.*/watch?v=||")
				yourlid=$(echo $yourlid|sed -e "s|?list=.*||")
				yourlid=$(echo $yourlid|sed -e "s|&list=.*||")
				#thumbnailbestemming="/Users/$USER/Documents/youtube-dl/$yourlid.jpg"
				thumbnailbestemming="/Users/$USER/Documents/youtube-dl/outfile.jpg"
				wget -O ~/Documents/youtube-dl/outfile.jpg https://img.youtube.com/vi/$yourlid/maxresdefault.jpg &>/dev/null||wgetgingfout=1
				if [[ $wgetgingfout == 1 ]]; then
					echo MAX kwaliteit Thumbnail Downloaden ging mis, Naitive tool gebruiken...
					rm ~/Documents/youtube-dl/outfile.jpg
				fi
				while true; do
					trap - SIGINT
					trap
					#--embed-thumbnail
					if [[ $wgetgingfout == 1 ]]; then
						/usr/local/bin/youtube-dl $yourl -x --audio-format mp3 --embed-thumbnail --audio-quality 0 --output "$filenaam" -f bestaudio&&goedgegaan=1
					else
						/usr/local/bin/youtube-dl $yourl -x --audio-format mp3 --audio-quality 0 --output "$filenaam" -f bestaudio&&goedgegaan=1
						eyeD3 --add-image "/Users/$USER/Documents/youtube-dl/outfile.jpg:FRONT_COVER" "$filenaamverbeterd" &>/dev/null
						rm ~/Documents/youtube-dl/outfile.jpg
					fi
					if [[ $goedgegaan == 1 ]]; then
						break
					else
						echo "opniew proberen? (Y/n)"
						trap cleanupfiles SIGINT
						read opniewproberen
						if [[ $opniewproberen != "" ]]&&[[ $opniewproberen != "y" ]]&&[[ $opniewproberen != "Y" ]]; then	
							cleanupfiles
						fi
					fi
				done
			fi
		else
			ls ~/Documents/youtube-dl/"`basename "$anderefile"`"&>/dev/null||mv "$anderefile" ~/Documents/youtube-dl/"`basename "$anderefile"`"
			filenaam="/Users/$USER/Documents/youtube-dl/"`basename "$anderefile"`""
			echo $filenaam
			filenaamverbeterd=$filenaam
		fi
		#/usr/local/bin/youtube-dl $yourl -x --audio-format mp3 --embed-thumbnail --audio-quality 0 --output "$filenaam" -f bestaudio||echo "opniew proberen? (Y/n)"; read opniewproberen; if [[ $opniewproberen == "" ]]||[[ $opniewproberen == "y" ]]||[[ $opniewproberen == "Y" ]]; then youtubedl "$@";else exit; fi #&sleep 2;echo -ne "\r"`du -s "$filenaam.part"|awk 'BEGIN {FS="	"}{print $1}'`;echo -ne "\r"; exit #||youtube-dl --rm-cache-dir
		trap exit SIGINT
		if [[ $manueelinput != "" ]]; then
			titel=$manueelinput
		fi
		if [[ $titel == *" - "* ]]; then
			liedseperator=" - "
		fi
		if [[ $liedseperator == "" ]]&&[[ $titel == *"- "* ]]; then
			liedseperator="- "
		fi
		if [[ $liedseperator == "" ]]&&[[ $titel == *" -"* ]]; then
			liedseperator=" -"
		fi
		if [[ $liedseperator == "" ]]&&[[ $titel == *"-"* ]]; then
			liedseperator="-"
		fi
		if [[ $liedseperator == "" ]]; then
			liedseperatornietgevonden=1
		else
			artiestnaam=`echo "$titel"|awk 'BEGIN {FS="'"$liedseperator"'"}{print $1}'`
			artiestnaam=`echo "$artiestnaam"|sed -e "s/ / /g"`
			if [[ $manueelinput == "" ]]; then
				artiestnaam=`echo "$artiestnaam"|iconv -c -f utf8 -t ascii`
			fi
			liedtitel=`echo "$titel"|awk 'BEGIN {FS="'"$liedseperator"'"}{print $2}'`
		fi
		if [[ `echo "$artiestnaam"|wc -c` == `echo "$titel"|wc -c` ]]; then
			artiestnaam=`echo "$titel"|awk 'BEGIN {FS=" – "}{print $1}'`
		fi
		if [[ $hoeveeldrafmoet == "" ]]; then
			hoeveeldrafmoet=0
		fi
		if [[ $liedseperatornietgevonden == 1 ]]; then
			if [[ $titel == *" | "* ]]; then
				artiestnaammisschien=`echo "$titel"|awk 'BEGIN {FS="|"}{print $1}'`
				woordtellerlied=`echo "$artiestnaammisschien" |wc -c|tr  -d '[:blank:]'`
				woordtellerlied=$(( woordtellerlied + 1 ))
				liedtitelmisschien=`echo ${titel:woordtellerlied}`
				echo -e "\n\nArtiest:		$artiestnaammisschien" 
				echo " "
				echo -e "Tietel van lied:	$liedtitelmisschien\n\n"
				echo "klopt wat hierboven staat? (1) Ja, (2) Nee. (1/2)"
				read liedkeuze
				if [[ $liedkeuze == 1 ]]; then
					artiestnaam="$artiestnaammisschien"
					liedtitel="$liedtitelmisschien"
				else
					if [[ $liedkeuze != 2 ]]; then
						echo "Geen geldig teken herkend, ga uit van (2) Nee"
					fi
				fi
			fi	
		fi
		if [[ $liedtitel == "("* ]]; then
			liedtitel=`echo $liedtitel|sed -e "s/(//"|sed -e "s/)//"`
		fi
		artiestnaam=`echo "$artiestnaam"|sed -e "s/|/ /g"`
		artiestnaamtest=`echo "$artiestnaam"|sed -e "s/#[^ ]*/$random/g"`
		if [[ $artiestnaamtest == "$random x $random"* ]]; then
			artiestnaam=`echo "$artiestnaam"|sed -e "s/x/ /"`
		fi
		hoeveelxtussenhaakjes=$((`echo "$liedtitel"| awk -F"(" '{print NF-1}'` + 2 ))
		n=1
		while [ "$n" -lt $hoeveelxtussenhaakjes ]; do
			n=$(( n + 1 ))
			mogelijkeprod=`echo $liedtitel|awk 'BEGIN {FS="("}{print $"'$n'"}'|awk 'BEGIN {FS="|"}{print $1}'|awk 'BEGIN {FS="("}{print $1}'|awk 'BEGIN {FS="["}{print $1}'|awk 'BEGIN {FS="]"}{print $1}'|awk 'BEGIN {FS="{"}{print $1}'|awk 'BEGIN {FS="}"}{print $1}'|awk 'BEGIN {FS=")"}{print $1}'`
			proddetectie
			if [[ $prodintitel == "1" ]]; then
				engeneer=`echo $mogelijkeprod|awk 'BEGIN {FS="'$seperator'"}{print $2}'`
				prodcleaner
			fi
			if [[ $seperator != "" ]]; then
				n=$(( hoeveelxtussenhaakjes + 1 ))
			fi
		done
		if [[ $seperator == "" ]]; then
			n=1
			hoeveelxtussenhaakjes=$((`echo "$liedtitel"| awk -F"[" '{print NF-1}'` + 2 ))
			while [ "$n" -lt $hoeveelxtussenhaakjes ]; do
				n=$(( n + 1 ))
				prodintitel=0
				mogelijkeprod=`echo $liedtitel|awk 'BEGIN {FS="["}{print $"'$n'"}'|awk 'BEGIN {FS="|"}{print $1}'|awk 'BEGIN {FS="("}{print $1}'|awk 'BEGIN {FS="["}{print $1}'|awk 'BEGIN {FS="]"}{print $1}'|awk 'BEGIN {FS="{"}{print $1}'|awk 'BEGIN {FS="}"}{print $1}'|awk 'BEGIN {FS=")"}{print $1}'`
				proddetectie
				if [[ $prodintitel == "1" ]]; then
					engeneer=`echo $mogelijkeprod|awk 'BEGIN {FS="'$seperator'"}{print $2}'`
					prodcleaner
				fi
				if [[ $seperator != "" ]]; then
					n=$(( hoeveelxtussenhaakjes + 1 ))
				fi
			done
		fi
		if [[ $seperator == "" ]]; then
			n=1
			hoeveelxtussenhaakjes=$((`echo "$liedtitel"| awk -F"{" '{print NF-1}'` + 2 ))
			while [ "$n" -lt $hoeveelxtussenhaakjes ]; do
				n=$(( n + 1 ))
				prodintitel=0
				mogelijkeprod=`echo $liedtitel|awk 'BEGIN {FS="{"}{print $"'$n'"}'|awk 'BEGIN {FS="|"}{print $1}'|awk 'BEGIN {FS="("}{print $1}'|awk 'BEGIN {FS="["}{print $1}'|awk 'BEGIN {FS="]"}{print $1}'|awk 'BEGIN {FS="{"}{print $1}'|awk 'BEGIN {FS="}"}{print $1}'|awk 'BEGIN {FS=")"}{print $1}'`
				proddetectie
				if [[ $prodintitel == "1" ]]; then
					engeneer=`echo $mogelijkeprod|awk 'BEGIN {FS="'$seperator'"}{print $2}'`
					prodcleaner
				fi
				if [[ $seperator != "" ]]; then
					n=$(( hoeveelxtussenhaakjes + 1 ))
				fi
			done
		fi
		if [[ $seperator == "" ]]; then
			n=1
			hoeveelxtussenhaakjes=$((`echo "$liedtitel"| awk -F"|" '{print NF-1}'` + 2 ))
			while [ "$n" -lt $hoeveelxtussenhaakjes ]; do
				n=$(( n + 1 ))
				prodintitel=0
				mogelijkeprod=`echo $liedtitel|awk 'BEGIN {FS="|"}{print $"'$n'"}'|awk 'BEGIN {FS="|"}{print $1}'|awk 'BEGIN {FS="("}{print $1}'|awk 'BEGIN {FS="["}{print $1}'|awk 'BEGIN {FS="]"}{print $1}'|awk 'BEGIN {FS="{"}{print $1}'|awk 'BEGIN {FS="}"}{print $1}'|awk 'BEGIN {FS=")"}{print $1}'`
				proddetectie
				if [[ $prodintitel == "1" ]]; then
					engeneer=`echo $mogelijkeprod|awk 'BEGIN {FS="'$seperator'"}{print $2}'`
					prodcleaner
				fi
				if [[ $seperator != "" ]]; then
					n=$(( hoeveelxtussenhaakjes + 1 ))
				fi
			done
		fi
		if [[ $seperator == "" ]]; then
			n=1
			hoeveelxtussenhaakjes=$((`echo "$liedtitel"| awk -F")" '{print NF-1}'` + 2 ))
			while [ "$n" -lt $hoeveelxtussenhaakjes ]; do
				n=$(( n + 1 ))
				prodintitel=0
				mogelijkeprod=`echo $liedtitel|awk 'BEGIN {FS=")"}{print $"'$n'"}'|awk 'BEGIN {FS="|"}{print $1}'|awk 'BEGIN {FS="("}{print $1}'|awk 'BEGIN {FS="["}{print $1}'|awk 'BEGIN {FS="]"}{print $1}'|awk 'BEGIN {FS="{"}{print $1}'|awk 'BEGIN {FS="}"}{print $1}'|awk 'BEGIN {FS=")"}{print $1}'`
				proddetectie
				if [[ $prodintitel == "1" ]]; then
					engeneer=`echo $mogelijkeprod|awk 'BEGIN {FS="'$seperator'"}{print $2}'`
					prodcleaner
				fi
				if [[ $seperator != "" ]]; then
					n=$(( hoeveelxtussenhaakjes + 1 ))
				fi
			done
		fi
		if [[ $seperator == "" ]]; then
			n=1
			hoeveelxtussenhaakjes=$((`echo "$liedtitel"| awk -F"]" '{print NF-1}'` + 2 ))
			while [ "$n" -lt $hoeveelxtussenhaakjes ]; do
				n=$(( n + 1 ))
				prodintitel=0
				mogelijkeprod=`echo $liedtitel|awk 'BEGIN {FS="]"}{print $"'$n'"}'|awk 'BEGIN {FS="|"}{print $1}'|awk 'BEGIN {FS="("}{print $1}'|awk 'BEGIN {FS="["}{print $1}'|awk 'BEGIN {FS="]"}{print $1}'|awk 'BEGIN {FS="{"}{print $1}'|awk 'BEGIN {FS="}"}{print $1}'|awk 'BEGIN {FS=")"}{print $1}'`
				proddetectie
				if [[ $prodintitel == "1" ]]; then
					engeneer=`echo $mogelijkeprod|awk 'BEGIN {FS="'$seperator'"}{print $2}'`
					prodcleaner
				fi
				if [[ $seperator != "" ]]; then
					n=$(( hoeveelxtussenhaakjes + 1 ))
				fi
			done
		fi
		if [[ $seperator == "" ]]; then
			n=1
			hoeveelxtussenhaakjes=$((`echo "$liedtitel"| awk -F" " '{print NF-1}'` + 2 ))
			while [ "$n" -lt $hoeveelxtussenhaakjes ]; do
				n=$(( n + 1 ))
				prodintitel=0
				mogelijkeprod=`echo $liedtitel|awk 'BEGIN {FS=" "}{print $"'$n'"}'|awk 'BEGIN {FS="|"}{print $1}'|awk 'BEGIN {FS="("}{print $1}'|awk 'BEGIN {FS="["}{print $1}'|awk 'BEGIN {FS="]"}{print $1}'|awk 'BEGIN {FS="{"}{print $1}'|awk 'BEGIN {FS="}"}{print $1}'|awk 'BEGIN {FS=")"}{print $1}'`
				proddetectie
				if [[ $prodintitel == "1" ]]; then
					engeneer=`echo $mogelijkeprod|awk 'BEGIN {FS="'$seperator'"}{print $2}'`
					prodcleaner
				fi
				if [[ $seperator != "" ]]; then
					n=$(( hoeveelxtussenhaakjes + 1 ))
				fi
			done
		fi
		liedtitelzonderprod=$liedtitel
		if [[ $liedtitelzonderprod == *"FT "* ]]; then
			ftseperator="FT "
			featuredawknietaf=`echo "$liedtitelzonderprod"|awk 'BEGIN {FS="FT "}{print $1}'`
		fi
		if [[ $liedtitelzonderprod == *"FT. "* ]]; then
			ftseperator="FT. "
			featuredawknietaf=`echo "$liedtitelzonderprod"|awk 'BEGIN {FS="FT. "}{print $1}'`
		fi
		if [[ $liedtitelzonderprod == *"Ft "* ]]; then
			ftseperator="Ft "
			featuredawknietaf=`echo "$liedtitelzonderprod"|awk 'BEGIN {FS="Ft "}{print $1}'`
		fi
		if [[ $liedtitelzonderprod == *"Ft. "* ]]; then
			ftseperator="Ft. "
			featuredawknietaf=`echo "$liedtitelzonderprod"|awk 'BEGIN {FS="Ft. "}{print $1}'`
		fi
		if [[ $liedtitelzonderprod == *"ft "* ]]; then
			ftseperator="ft "
			featuredawknietaf=`echo "$liedtitelzonderprod"|awk 'BEGIN {FS="ft "}{print $1}'`
		fi
		if [[ $liedtitelzonderprod == *"ft. "* ]]; then
			ftseperator="ft. "
			featuredawknietaf=`echo "$liedtitelzonderprod"|awk 'BEGIN {FS="ft. "}{print $1}'`
		fi
		if [[ $liedtitelzonderprod == *"feat "* ]]; then
			ftseperator="feat "
			featuredawknietaf=`echo "$liedtitelzonderprod"|awk 'BEGIN {FS="feat "}{print $1}'`
		fi
		if [[ $liedtitelzonderprod == *"feat. "* ]]; then
			ftseperator="feat. "
			featuredawknietaf=`echo "$liedtitelzonderprod"|awk 'BEGIN {FS="feat. "}{print $1}'`
		fi
		if [[ $liedtitelzonderprod == *"Feat "* ]]; then
			ftseperator="Feat "
			featuredawknietaf=`echo "$liedtitelzonderprod"|awk 'BEGIN {FS="Feat "}{print $1}'`
		fi
		if [[ $liedtitelzonderprod == *"Feat. "* ]]; then
			ftseperator="Feat. "
			featuredawknietaf=`echo "$liedtitelzonderprod"|awk 'BEGIN {FS="Feat. "}{print $1}'`
		fi
		if [[ $ftseperator != "" ]]; then
			liedtitelzonderprodvoorzo="$featuredawknietaf"
			featuredawknietaf=`echo "$liedtitelzonderprod"|sed -e "s/$featuredawknietaf//"`
			featured=`echo $featuredawknietaf|awk 'BEGIN {FS="@"}{print $1}'|awk 'BEGIN {FS="|"}{print $1}'|awk 'BEGIN {FS="-"}{print $1}'|awk 'BEGIN {FS=")"}{print $1}'|awk 'BEGIN {FS="("}{print $1}'|awk 'BEGIN {FS="["}{print $1}'|awk 'BEGIN {FS="]"}{print $1}'`
			artiestnaam=`echo "$artiestnaam $featured"`
			liedtitelzonderprod="$liedtitelzonderprodvoorzo"
		fi
		wnrhaakjesspatie=1
		if [[ $artiestnaam == *"(FT"* ]]; then
			wnrhaakjesspatie=`echo $artiestnaam|awk 'END{print index($0,"(FT")}'`
		fi
		if [[ $artiestnaam == *"(Ft"* ]]; then
			wnrhaakjesspatie=`echo $artiestnaam|awk 'END{print index($0,"(Ft")}'`
		fi
		if [[ $artiestnaam == *"(ft"* ]]; then
			wnrhaakjesspatie=`echo $artiestnaam|awk 'END{print index($0,"(ft")}'`
		fi
		if [[ wnrhaakjesspatie -gt 1 ]]; then
			restvandefeat=`echo ${artiestnaam:wnrhaakjesspatie}`
			anderehaakje=$((`echo $restvandefeat|awk 'END{print index($0,")")}'` + wnrhaakjesspatie ))
			anderehaakjeplus1=$(( anderehaakje + 1 ))
			artiestnaam=`echo ${artiestnaam:0:anderehaakje-1}${artiestnaam:anderehaakje}`
			artiestnaam=`echo ${artiestnaam:0:wnrhaakjesspatie-1}${artiestnaam:wnrhaakjesspatie}`
		fi
		if [[ $artiestnaam == *"FT "* ]]; then
			ftseperator="FT "
		fi
		if [[ $artiestnaam == *"FT. "* ]]; then
			ftseperator="FT. "
		fi
		if [[ $artiestnaam == *"Ft "* ]]; then
			ftseperator="Ft "
		fi
		if [[ $artiestnaam == *"Ft. "* ]]; then
			ftseperator="Ft. "
		fi
		if [[ $artiestnaam == *"ft "* ]]; then
			ftseperator="ft "
		fi
		if [[ $artiestnaam == *"ft. "* ]]; then
			ftseperator="ft. "
		fi
		if [[ $artiestnaam == *"feat "* ]]; then
			ftseperator="feat "
		fi
		if [[ $artiestnaam == *"feat. "* ]]; then
			ftseperator="feat. "
		fi
		if [[ $artiestnaam == *"Feat "* ]]; then
			ftseperator="Feat "
		fi
		if [[ $artiestnaam == *"Feat. "* ]]; then
			ftseperator="Feat. "
		fi
		if [[ $ftseperator != "" ]]; then
			artiestnaam=`echo "$artiestnaam"|sed -e "s/$ftseperator/x /g"`
		fi
		artiestnaam=`echo $artiestnaam|sed -e "s/, / x /g"|sed -e "s/ & / x /g"`
		liedtitelzonderprod=`echo $liedtitelzonderprod|awk 'BEGIN {FS="@"}{print $1}'`
		liedtitelzonderprod=`echo $liedtitelzonderprod|awk 'BEGIN {FS="|"}{print $1}'`
		liedtitelzonderprod=`echo $liedtitelzonderprod|awk 'BEGIN {FS="("}{print $1}'`
		liedtitelzonderprod=`echo $liedtitelzonderprod|awk 'BEGIN {FS="["}{print $1}'`
		liedtitelzonderprod=`echo $liedtitelzonderprod|awk 'BEGIN {FS="{"}{print $1}'`
		if [[ $seperator != "" ]]; then
			liedtitelzonderprod=`echo $liedtitelzonderprod|awk 'BEGIN {FS="'$seperator'"}{print $1}'`
		fi
		if [[ $liedtitelzonderprod == "#"* ]]; then
			hoeveelx=`echo $liedtitelzonderprod| awk -F"#" '{print NF-1}'`
			liedtitelzonderprod=`echo "$liedtitelzonderprod"|rev|awk 'BEGIN {FS="#"}{print $"'$hoeveelx'"}'|rev` #voor als iemand ook nog een ander hekje heeft die we niet moeten hebben
			liedtitelzonderprod=`echo "#$liedtitelzonderprod"`
		fi
		if [[ $liedtitelzonderprod == "\""* ]]; then
			dubbelequotatiecheck=1
			revliedtitelzonderprod=`echo $liedtitelzonderprod|rev`
			if [[ $revliedtitelzonderprod == "\""* ]]; then
				dubbelequotatiecheck=$(( dubbelequotatiecheck + 1 ))
			fi
		fi
		if [[ $liedtitelzonderprod == "\'"* ]]; then
			enklelequotatiecheck=1
			revliedtitelzonderprod=`echo $liedtitelzonderprod|rev`
			if [[ $revliedtitelzonderprod == "\'"* ]]; then
				enklelequotatiecheck=$(( enklelequotatiecheck + 1 ))
			fi
		fi

		if [[ $dubbelequotatiecheck == 2 ]]; then
			liedtitelzonderprod=`echo $liedtitelzonderprod|sed -e "s/\"//"`
			liedtitelzonderprod=`echo $liedtitelzonderprod|sed -e "s/\"//"`
		fi
		if [[ $enklelequotatiecheck == 2 ]]; then
			liedtitelzonderprod=`echo $liedtitelzonderprod|sed -e "s/\'//"`
			liedtitelzonderprod=`echo $liedtitelzonderprod|sed -e "s/\'//"`
		fi

		liedtitelzonderprod=`echo $liedtitelzonderprod|rev`
		if [[ $liedtitelzonderprod == " "* ]]; then
			liedtitelzonderprod=`echo $liedtitelzonderprod|sed -e "s/ //"`
		fi
		liedtitelzonderprod=`echo $liedtitelzonderprod|rev`
		meerderenartiestentussenhaakjescheck=`echo $artiestnaam|awk 'BEGIN {FS="("}{print $2}'|awk 'BEGIN {FS=")"}{print $1}'`
		if [[ $meerderenartiestentussenhaakjescheck == *" x "* ]] || [[ $meerderenartiestentussenhaakjescheck == *" X "* ]]; then
			verbeterdartiest=`echo $artiestnaam|rev|sed -e "s/)//g"|sed -e "s/(//g"|rev`
		else
			if [[ $meerderenartiestentussenhaakjescheck == *" "* ]]; then #hij gebruikt hem als groepcheck
				groepmethoofdletter=`echo "$meerderenartiestentussenhaakjescheck"|tr '[:upper:]' '[:lower:]'|awk '{for (i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1'|sed -e "s/ //g"`
				groepklaar=`echo "($groepmethoofdletter)"`
				groeptussenhaakjes="($meerderenartiestentussenhaakjescheck)"
				groeptussenhaakjesomgekeerd=`echo $groeptussenhaakjes|rev`
				artiestnaam=`echo "$groepklaar "``echo $artiestnaam|rev|sed -e "s/$groeptussenhaakjesomgekeerd//"|rev`
			fi
			verbeterdartiest=`echo $artiestnaam|rev|sed -e "s/)//g"|sed -e "s/(/#/g"|rev`
		fi
		ls ~/Documents/youtube-dl/.blocklist &> /dev/null && blocked=`cat ~/Documents/youtube-dl/.blocklist`
		if [[ $blocked != "" ]]; then
			if [[ $verbeterdartiest == *"$blocked"* ]]; then
				verbeterdartiest=`echo $verbeterdartiest|sed -e "s/$blocked //g"`
			fi
		fi
		verbeterdartiest=`echo "$verbeterdartiest"|sed -e "s/ X / x /g"`
		hoeveelx=`echo "$verbeterdartiest"| awk -F" x " '{print NF-1}'`
		totaalhoeveel=$(( hoeveelx + 1))
		n=0
		while [ "$n" -lt $totaalhoeveel ]; do
			allerlaatstewoord=""
			n=$(( n + 1 ))
			persoon=`echo $verbeterdartiest|awk 'BEGIN {FS=" x "}{print $"'$n'"}'`
			hoeveelxspatie=`echo "$persoon"| awk -F" " '{print NF-1}'`
			hoeveelxspatieplus1=$(( hoeveelxspatie + 1 ))
			allerlaatstewoord=`echo $persoon|rev|awk 'BEGIN {FS=" "}{print $1}'|rev`
			if [[ $hoeveelxspatieplus1 -gt 1 ]]; then
				laatstewoord=`echo $persoon|awk 'BEGIN {FS=" "}{print $"'$hoeveelxspatieplus1'"}'`
				if [[ $laatstewoord == "#"* ]]; then
					if [[ $persoon == "#"* ]]; then
						eerstewoorddoorhekje=`echo $persoon|awk 'BEGIN {FS=" "}{print $1}'`
						persoon=`echo "$persoon"|sed -e "s/$eerstewoorddoorhekje //"`
						hekjetoegang=1
					fi
					revlaatstewoord=`echo $laatstewoord|rev`
					persoon=`echo "$persoon"|rev|sed -e "s/$revlaatstewoord//"|rev`
					persoon=`echo "$laatstewoord $persoon"`
					if [[ $hekjetoegang == 1 ]]; then
						persoon=`echo "$eerstewoorddoorhekje $persoon"`
					fi
				fi
			fi
			if [[ $persoon == "" ]]; then
				persoonlijst=`echo "$persoonlijst`
			else
				persoonlijst=`echo "$persoonlijst x $persoon"`
			fi
		done
		revpersoonlijst=`echo $persoonlijst|rev`
		if [[ $revpersoonlijst == "x "* ]]; then
			persoonlijst=`echo $revpersoonlijst|sed -e "s/x //"|rev`
			woordtellerzonderprod=`echo "$liedtitelzonderprod" |wc -c|tr  -d '[:blank:]'`
			woordtellerzonderprod=$(( woordtellerzonderprod + 2 ))
			if [[ $titel != *"- "* ]]; then #dus hij is artiest -lied of hij is artiest-lied
				if [[ $titel != *" -"* ]]; then #dus hij is artiest-lied
					titelgefixt=`echo "$titel"|awk 'BEGIN {FS="-"}{print $2}'`
				else #dus hij is artiest -lied
					titelgefixt=`echo "$titel"|awk 'BEGIN {FS=" -"}{print $2}'`
				fi
			fi
			if [[ $titelgefixt == "" ]]; then
				titelgefixt=`echo "$titel"|awk 'BEGIN {FS="- "}{print $2}'`
			fi
			if [[ $titelgefixt == "" ]]; then
				titelgefixt=`echo "$titel"|awk 'BEGIN {FS=" - "}{print $2}'`
			fi
			liedtitelzonderprodsed=`echo ${titelgefixt:woordtellerzonderprod}`
			liedtitelzonderprod=`echo $titelgefixt|sed -e "s/$liedtitelzonderprodsed//"`
		fi

		persoonlijst=`echo $persoonlijst|sed -e "s/x //"`
		if [[ $allerlaatstewoord == "#"* ]]; then
			if [[ $persoonlijst == *" x "* ]]; then
				persoonlijstrev=`echo $persoonlijst|rev`
				allerlaatstewoordrev=`echo $allerlaatstewoord|rev`
				groepnaamzonderlaatsehekje=`echo $persoonlijstrev|sed -e "s/$allerlaatstewoordrev //"|rev`
				if [[ $groepnaamzonderlaatsehekje == "#"* ]]; then
					eerstewoordhekje=`echo "$groepnaamzonderlaatsehekje"|awk 'BEGIN {FS=" "}{print $1}'`
					groepzondereersteenlaatstehekje=`echo "$groepnaamzonderlaatsehekje"|sed -e "s/$eerstewoordhekje //"`
					verbeterdartiest=`echo "$eerstewoordhekje $allerlaatstewoord $groepzondereersteenlaatstehekje"`
					echo $verbeterdartiest
				fi
			else
				verbeterdartiest=$persoonlijst	
			fi
		else
			verbeterdartiest=$persoonlijst
		fi
		eerstewoord=`echo $verbeterdartiest|awk 'BEGIN {FS=" "}{print $1}'`
		tweedewoord=`echo $verbeterdartiest|awk 'BEGIN {FS=" "}{print $2}'`
		derdewoord=`echo $verbeterdartiest|awk 'BEGIN {FS=" "}{print $3}'`
		if [[ $derdewoord == "" ]]; then
			if [[ $tweedewoord == "#"* ]]; then
				tijdelijkwoord=$tweedewoord
				tweedewoord=$eerstewoord
				eerstewoord=$tijdelijkwoord
				verbeterdartiest=`echo "$eerstewoord $tweedewoord"`
			fi
		fi
		if [[ $tweedewoord == "" ]]; then
			eerstetweewoorden=`echo $eerstewoord`
		else
			eerstetweewoorden=`echo "$eerstewoord $tweedewoord"`
		fi
		if [[ $eerstewoord != "#"* ]]; then
			getalhoelangtweedewoord=`echo $tweedewoord|wc -c|sed -e "s/ //g"`
			getalhoelangtweedewoord=$(( getalhoelangtweedewoord - 1 ))
			if [[ $getalhoelangtweedewoord != 1 ]]; then
				getalhoelangeerstewoord=`echo $eerstewoord|wc -c|sed -e "s/ //g"`
				getalhoelangeerstewoord=$(( getalhoelangeerstewoord - 1 ))
				if [[ $getalhoelangeerstewoord == 1 ]]; then
					gedetecteerdewhitelistartist=1
				else
					blacklistaf=`cat ~/Documents/youtube-dl/.black.list|sed -e "s|'|\\\\\'|"|xargs`
					blacklist=($blacklistaf)
					artistlowercap=`echo $verbeterdartiest|tr '[:upper:]' '[:lower:]'`
					for t in ${blacklist[@]}; do
						if [[ $gedetecteerdeblacklistartist != 1 ]]; then
							if [[ "$artistlowercap" == "$t"* ]]; then
								gedetecteerdeblacklistartist=1
							fi
						fi
					done
					if [[ $gedetecteerdeblacklistartist != 1 ]]; then
						whitelistaf=`cat ~/Documents/youtube-dl/.white.list|sed -e "s|'|\\\\\'|"|xargs`
						whitelist=($whitelistaf)
						artistlowercap=`echo $verbeterdartiest|tr '[:upper:]' '[:lower:]'`
						for t in ${whitelist[@]}; do
							if [[ $gedetecteerdewhitelistartist != 1 ]]; then
								whitelistartiest=`echo $t|sed -e "s/_/ /"`
								if [[ "$artistlowercap" == "$whitelistartiest"* ]]; then
									gedetecteerdewhitelistartist=1
								fi
							fi
						done
					fi
					if [[ $minr == 1 ]]; then	
						gedetecteerdewhitelistartist=1
					else
						if [[ $tweedewoord == "x" ]]||[[ $tweedewoord == "X"* ]]; then
						gedetecteerdewhitelistartist=1
						fi
						if [[ $gedetecteerdewhitelistartist != 1 ]];then 
							if [[ $gedetecteerdeblacklistartist != 1 ]]; then
								artistspatiecheck=`echo $eerstetweewoorden|rev`

								if [[ $tweedewoord == "" ]]; then
									gedetecteerdewhitelistartist=1
								else
									echo -e "\nis \"$eerstetweewoorden\" een persoon (1) of een groep met een persoon er achter (2)? of is de titel gewoon fucked? (3) | (1/2/3)"
									read persoonofgroep
									if [[ $persoonofgroep == 1 ]]; then
										#een persoon
										echo $eerstetweewoorden|sed -e "s/ /_/"|tr '[:upper:]' '[:lower:]' >> ~/Documents/youtube-dl/.white.list
										gedetecteerdewhitelistartist=1
									fi
									if [[ $persoonofgroep == 2 ]]; then
										#een groep
										echo $eerstewoord|tr '[:upper:]' '[:lower:]' >> ~/Documents/youtube-dl/.black.list
										gedetecteerdeblacklistartist=1
									fi
									if [[ $persoonofgroep == 3 ]]; then
										gedetecteerdewhitelistartist=1
									fi
								fi
							fi
						fi
					fi
				fi
				if [[ $gedetecteerdeblacklistartist == 1 ]]; then
					allesbehalveeerstewoord=`echo $verbeterdartiest|sed -e "s/$eerstewoord//"`
					verbeterdartiest=`echo "#$verbeterdartiest"`
				fi
			fi
		fi
		hoeveelgroepen=$((`echo "$verbeterdartiest"| awk -F"#" '{print NF-1}'`))
		n=0
		while [ "$n" -lt $hoeveelgroepen ]; do
			groepnognietgevonden=0
			n=$(( n + 1 ))
			nt=$(( n + 1 ))
			huidigegroep=`echo "$verbeterdartiest"|awk 'BEGIN {FS="#"}{print $"'$nt'"}'|awk 'BEGIN {FS=" "}{print $1}'`
			cat ~/Documents/youtube-dl/.black.list |grep -i "$huidigegroep" &>/dev/null||groepnognietgevonden=1
			if [[ $groepnognietgevonden == 1 ]]; then
				if [[ $lijstvoorshow == "" ]]; then
					echo -e ""
				fi
				echo $huidigegroep|tr [:upper:] [:lower:] >> ~/Documents/youtube-dl/.black.list
				echo "Groep aan lijst toegevoegd: $huidigegroep "
				lijstvoorshow=`echo "$lijstvoorshow $huidigegroep"`
			fi
		done
		if [[ $lijstvoorshow != "" ]]; then
			lijstvoorshow=`echo "$lijstvoorshow"|sed -e "s/ //"`
			echo $lijstvoorshow|tr [:upper:] [:lower:] > ~/Documents/youtube-dl/.vorigegroepen.list
			echo -e "\nals je deze groepen weer wilt verwijderen doe dan youtubedl -d"
		fi
		artiestarray=($verbeterdartiest)
		for i in  ${artiestarray[@]}; do
			while [[ $i == *"#"* ]]; do
				i=`echo $i|sed -e "s/#//"`
			done
			ilowercase=`echo $i|tr [:upper:] [:lower:]`
			grep -Rn "^$ilowercase$" ~/Documents/youtube-dl/.black.list &> /dev/null && igedetecteerd=1
			if [[ $igedetecteerd == 1 ]]; then
				echo $verbeterdartiest|grep "^$i" &>/dev/null&&begintmeti=1
				if [[ $begintmeti == 1 ]]; then
					verbeterdartiest=`echo $verbeterdartiest|sed -e "s|^$i|^#$i|g"`
				else
					verbeterdartiest=`echo $verbeterdartiest|sed -e "s| $i| #$i|g"`
				fi
				igedetecteerd=0
				begintmeti=0
			fi
		done
		laatstewoordvanartiest=`echo $verbeterdartiest|rev|awk 'BEGIN {FS=" "}{print $1}'|rev`
		laatstewoordvanartiestrev=`echo $verbeterdartiest|rev|awk 'BEGIN {FS=" "}{print $1}'`
		if [[ $liedtitel == "" ]]; then
			liedtitelzonderprod=`echo $titel`
			artiestnaam=`echo $account|awk 'BEGIN{FS=" - "}{print $1}'`
		fi
		if [[ $minr == 1 ]]; then
			liedtitelzonderprod=$titel
			verbeterdartiest=`echo $account|awk 'BEGIN {FS=" - "}{print $1}'`
		fi
		mv "$filenaamverbeterd" ~/Documents/youtube-dl/.tijdelijk.mp3 &> /dev/null
		if [[ $genre == "" ]]; then
			genre=`cat ~/Documents/youtube-dl/.config.yt|grep -i "^GENRE"|sed -e "s/GENRE=//"`
		fi
		# if [[ $genre == "" ]]; then		
		# 	ls ~/Documents/youtube-dl/.genre  &> /dev/null || noggeengenre=1
		# 	if [[ $noggeengenre == 1 ]]; then
		# 		echo "Naar welke genre zul je het meeste luisteren? (Dit wordt de standaard genre tenzei je een speciafieke selecteerd met argumenten)"
		# 		read genre
		# 		if [[ $? == 130 ]]; then
		# 			genre="-Onbekend-"
		# 		fi
		# 		echo "$genre" > ~/Documents/youtube-dl/.genre
		# 	fi
		# 	if [[ $genre != "-Onbekend-" ]]; then
		# 		genre=`cat ~/Documents/youtube-dl/.genre`	
		# 	fi
		# fi
		while [[ $verbeterdartiest == *"##"* ]]; do
			verbeterdartiest=`echo $verbeterdartiest|sed -e "s/##/#/"`
		done
		while [[ $verbeterdartiest == *"  "* ]]; do
			verbeterdartiest=`echo "$verbeterdartiest"|sed -e "s/  / /g"`
		done
		if [[ $image == 0 ]]; then
			if [[ $prodintitel == "1" ]]; then
				engeneer=`echo $engeneer|sed -e "s/^@//"`
				engeneer=`echo "$engeneer"|sed -e "s/, / x /g"`
				avconv -i ~/Documents/youtube-dl/.tijdelijk.mp3 -metadata album="$account" -metadata TDRC="$uploaddate" -metadata genre="$genre" -metadata URL="$yourl" -metadata title="$liedtitelzonderprod" -metadata artist="$verbeterdartiest" -metadata composer="$engeneer" -c copy "$filenaamverbeterd" &>/dev/null
				rm ~/Documents/youtube-dl/.tijdelijk.mp3 ~/Documents/youtube-dl/file.jpg &> /dev/null		
			else
				avconv -i ~/Documents/youtube-dl/.tijdelijk.mp3 -metadata album="$account" -metadata TDRC="$uploaddate" -metadata genre="$genre" -metadata URL="$yourl" -metadata title="$liedtitelzonderprod" -metadata artist="$verbeterdartiest" -metadata composer="-Onbekend-" -c copy "$filenaamverbeterd" &>/dev/null
				rm ~/Documents/youtube-dl/.tijdelijk.mp3 ~/Documents/youtube-dl/file.jpg &> /dev/null
			fi
		fi
		#url='https://www.youtube.com/watch?v=TANqz4RE3iM'
		#url=https://www.youtube.com/watch\?v\=PymeZOTSt7Q\&list\=LL\&index\=1
		if [[ $instaurl != "" ]]; then
			if [[ $image == 0 ]]; then	
				if [[ $instaurl == "vid" ]]; then
					wget -O ~/Documents/youtube-dl/outfile.jpg `youtube-dl --get-thumbnail $yourl` &> /dev/null
				else
					typeurl=`echo $instaurl|sed -e "s|https://||"`
					if [[ $typeurl == "youtu.be"* ]]||[[ $typeurl == "www.youtube.com"* ]]; then
						wget -O ~/Documents/youtube-dl/outfile.jpg `youtube-dl --get-thumbnail $instaurl` &> /dev/null
					else
						if [[ $typeurl == "www.instagram.com"* ]]; then
							instalooter -T outfile post $instaurl ~/Documents/youtube-dl&>/dev/null
							#Download only selected images of a sidecar. You can select single images using their index in the sidecar starting with the leftmost or you can specify a range of images with the following syntax: start_index-end_index. Example: --slide 1 will select only the first image, --slide last only the last one and --slide 1-3 will select only the first three images.
							fotocrop
							rm ~/Documents/youtube-dl/thumbnailbestand.jpg &> /dev/null
						else
							if [[ -f `echo $instaurl|sed -e "s/|.*//"` ]]; then
								instaurlextentie=`echo $instaurl|sed -e "s/|.*//"|rev|awk 'BEGIN {FS="."}{print $1}'|rev`
								if [[ $instaurlextentie == "jpg" ]]||[[ $instaurlextentie == "JPG" ]]||[[ $instaurlextentie == "jpeg" ]]||[[ $instaurlextentie == "JPEG" ]]||[[ $instaurlextentie == "png" ]]||[[ $instaurlextentie == "PNG" ]]; then
									cp "`echo "$instaurl"|sed -e "s/|.*//"`" ~/Documents/youtube-dl/outfile.jpg
									fotocrop
								else
									if [[ $yourl != "" ]]; then
										echo "File type niet ondersteund, eigen video wordt gebruikt"
										wget -O ~/Documents/youtube-dl/outfile.jpg `youtube-dl --get-thumbnail $yourl` &> /dev/null
									else
										exit 1
									fi
								fi 
							else
								if [[ $yourl == "" ]]; then
									echo "iets ging fout met je -T bestand/url"
								else
									echo "Geen standaard ondersteunde link herkend, huidige link proberen te downloaden"
								fi
								fotokeuze=1
								if [[ $fotokeuze == 1 ]]; then
									instaurlzonderpipe=`echo "$instaurl"|sed -e "s/|.*//"`
									wget -O ~/Documents/youtube-dl/outfile.jpg "$instaurlzonderpipe" &> /dev/null||fotokeuze=2
									if [[ $fotokeuze != 2 ]]; then
										fotocrop
									fi		
								fi
								if [[ $fotokeuze == 2 ]]; then
									if [[ $yourl != "" ]]; then
										echo "er ging iets mis met het downloaden van de foto, eigen thumbnail wordt gebruikt"
										wget -O ~/Documents/youtube-dl/outfile.jpg `youtube-dl --get-thumbnail $yourl` &> /dev/null
									fi		
								fi
							fi
						fi
					fi
				fi
				hoeveelgroepen=$((`echo "$verbeterdartiest"| awk -F"#" '{print NF-1}'`))
				n=0
				while [ "$n" -lt $hoeveelgroepen ]; do
					n=$(( n + 1 ))
					nt=$(( n + 1 ))
					huidigegroep=`echo "$verbeterdartiest"|awk 'BEGIN {FS="#"}{print $"'$nt'"}'|awk 'BEGIN {FS=" "}{print $1}'`
					lijst=`echo "$lijst $huidigegroep"` 
				done
				lijst=`echo "$lijst"|sed -e "s% %%"`
				lijst2=`echo "#$lijst"|sed -e "s% % #%g"`
				artiesttitelzondergroep=`echo $verbeterdartiest`
				for f in ${lijst2[@]}; do
					artiesttitelzondergroep=`echo $artiesttitelzondergroep|sed -e "s%$f % %"`
				done
				if [[ $manueelinput == "" ]]; then
					liedtitelzonderprodh=`echo "$liedtitelzonderprod"|iconv -c -f utf8 -t ascii|tr '[:lower:]' '[:upper:]'|sed -e "s%\'%\\\\\\\'%g"`
					verbeterdartiesth=`echo "$artiesttitelzondergroep"|iconv -c -f utf8 -t ascii|tr '[:lower:]' '[:upper:]'|sed -e "s%\'%\\\\\\\'%g"`
				else
					liedtitelzonderprodh=`echo "$liedtitelzonderprod"|tr '[:lower:]' '[:upper:]'|sed -e "s%\'%\\\\\\\'%g"`
					verbeterdartiesth=`echo "$artiesttitelzondergroep"|tr '[:lower:]' '[:upper:]'|sed -e "s%\'%\\\\\\\'%g"`
				fi
				if [[ $manueelinput == *"|||*" ]]; then
					verbeterdartiesth=`echo "$titel"|awk 'BEGIN {FS="'"$liedseperator"'"}{print $1}'`
					liedtitelzonderprodh=`echo "$titel"|awk 'BEGIN {FS="'"$liedseperator"'"}{print $2}'|rev|sed -e 's/*|||//'|rev`
				fi
				echtgedaan=0
				while [ $echtgedaan -lt 1 ]; do for s in / / - - \\ \\ \|; do echo -ne "\r$s		thumbnail aan het genereren      "; sleep .05;if [[ -f ~/Documents/youtube-dl/.gedaan ]]; then echtgedaan=1; fi; done;done&
					convert -density 72 -units PixelsPerInch ~/Documents/youtube-dl/outfile.jpg -resize 1920x1080 ~/Documents/youtube-dl/outfile.jpg
					#1280x720
					caractertitel=`echo $liedtitelzonderprod|iconv -c -f utf8 -t ascii|wc -c|tr -d [:blank:]`
					if [[ $caractertitel -gt 17 ]]; then
						huidigantwoord=`bc <<< "scale=2; 100/$caractertitel*17"`
						titelvergrotingsfactor=`bc <<< "scale=2; $huidigantwoord/100*240"`
					else
						titelvergrotingsfactor=235
					fi
					convert -font Impact -paint 1 -fill black -colorize $verdonkeringspercentage% -blur 0x8 -fill white -pointsize $titelvergrotingsfactor -gravity center -draw "text 0,-70 '$liedtitelzonderprodh'" -pointsize 98 -gravity center -draw "text 0,80 '$verbeterdartiesth'" ~/Documents/youtube-dl/outfile.jpg ~/Documents/youtube-dl/file.jpg &> /dev/null
					#echo -ne "\r"
					rm ~/Documents/youtube-dl/outfile.jpg &> /dev/null
					eyeD3 --remove-all-images "$filenaamverbeterd" &> /dev/null
					eyeD3 --add-image="/Users/$USER/Documents/youtube-dl/file.jpg":FRONT_COVER "$filenaamverbeterd" &> /dev/null
					rm ~/Documents/youtube-dl/file.jpg &> /dev/null
				touch ~/Documents/youtube-dl/.gedaan
				sleep .2
				rm ~/Documents/youtube-dl/.gedaan
				echo -ne "\rThumbnail gegenereerd.                                            "
				eenwhileloopgebeurt=1
			else
				#########################
				if [[ $instaurl == "vid" ]]; then
					wget -O ~/Documents/youtube-dl/outfile.jpg `youtube-dl --get-thumbnail $yourl 2>/dev/null` &> /dev/null
				else
					typeurl=`echo $instaurl|sed -e "s|https://||"`
					if [[ $typeurl == "youtu.be"* ]]||[[ $typeurl == "www.youtube.com"* ]]; then
						wget -O ~/Documents/youtube-dl/outfile.jpg `youtube-dl --get-thumbnail $instaurl` &> /dev/null
					else
						if [[ $typeurl == "www.instagram.com"* ]]; then
							instalooter -T outfile post $instaurl ~/Documents/youtube-dl&>/dev/null
							#Download only selected images of a sidecar. You can select single images using their index in the sidecar starting with the leftmost or you can specify a range of images with the following syntax: start_index-end_index. Example: --slide 1 will select only the first image, --slide last only the last one and --slide 1-3 will select only the first three images.
							fotocrop
							rm ~/Documents/youtube-dl/thumbnailbestand.jpg &> /dev/null
						else
							if [[ -f `echo $instaurl|sed -e "s/|.*//"` ]]; then
								instaurlextentie=`echo $instaurl|sed -e "s/|.*//"|rev|awk 'BEGIN {FS="."}{print $1}'|rev`
								if [[ $instaurlextentie == "jpg" ]]||[[ $instaurlextentie == "JPG" ]]||[[ $instaurlextentie == "jpeg" ]]||[[ $instaurlextentie == "JPEG" ]]||[[ $instaurlextentie == "png" ]]||[[ $instaurlextentie == "PNG" ]]; then
									cp "`echo "$instaurl"|sed -e "s/|.*//"`" ~/Documents/youtube-dl/outfile.jpg
									fotocrop
								else
									if [[ $yourl != "" ]]; then
										echo "File type niet ondersteund, eigen video wordt gebruikt"
										wget -O ~/Documents/youtube-dl/outfile.jpg `youtube-dl --get-thumbnail $yourl` &> /dev/null
									else
										exit 1
									fi
								fi 
							else
								if [[ $yourl == "" ]]; then
									echo "iets ging fout met je -T bestand/url"
								else
									echo "Geen standaard ondersteunde link herkend, huidige link proberen te downloaden"
								fi
								fotokeuze=1
								if [[ $fotokeuze == 1 ]]; then
									instaurlzonderpipe=`echo "$instaurl"|sed -e "s/|.*//"`
									wget -O ~/Documents/youtube-dl/outfile.jpg "$instaurlzonderpipe" &> /dev/null||fotokeuze=2
									if [[ $fotokeuze != 2 ]]; then
										fotocrop
									fi
								fi
								if [[ $fotokeuze == 2 ]]; then
									if [[ $yourl != "" ]]; then
										echo "er ging iets mis met het downloaden van de foto, eigen thumbnail wordt gebruikt"
										wget -O ~/Documents/youtube-dl/outfile.jpg `youtube-dl --get-thumbnail $yourl` &> /dev/null
									else
										exit 1
									fi
								fi
							fi
						fi
					fi
				fi
				hoeveelgroepen=$((`echo "$verbeterdartiest"| awk -F"#" '{print NF-1}'`))
				n=0
				while [ "$n" -lt $hoeveelgroepen ]; do
					n=$(( n + 1 ))
					nt=$(( n + 1 ))
					huidigegroep=`echo "$verbeterdartiest"|awk 'BEGIN {FS="#"}{print $"'$nt'"}'|awk 'BEGIN {FS=" "}{print $1}'`
					lijst=`echo "$lijst $huidigegroep"` 
				done
				lijst=`echo "$lijst"|sed -e "s% %%"`
				lijst2=`echo "#$lijst"|sed -e "s% % #%g"`
				artiesttitelzondergroep=`echo $verbeterdartiest`
				for f in ${lijst2[@]}; do
					artiesttitelzondergroep=`echo $artiesttitelzondergroep|sed -e "s%$f % %"`
				done
				if [[ $manueelinput == "" ]]; then
					liedtitelzonderprodh=`echo "$liedtitelzonderprod"|iconv -c -f utf8 -t ascii|tr '[:lower:]' '[:upper:]'|sed -e "s%\'%\\\\\\\'%g"`
					verbeterdartiesth=`echo "$artiesttitelzondergroep"|iconv -c -f utf8 -t ascii|tr '[:lower:]' '[:upper:]'|sed -e "s%\'%\\\\\\\'%g"`
				else
					liedtitelzonderprodh=`echo "$liedtitelzonderprod"|tr '[:lower:]' '[:upper:]'|sed -e "s%\'%\\\\\\\'%g"`
					verbeterdartiesth=`echo "$artiesttitelzondergroep"|tr '[:lower:]' '[:upper:]'|sed -e "s%\'%\\\\\\\'%g"`
				fi
				if [[ $manueelinput == *"|||*" ]]; then
					verbeterdartiesth=`echo "$titel"|awk 'BEGIN {FS="'"$liedseperator"'"}{print $1}'|tr [:lower:] [:upper:]`
					liedtitelzonderprodh=`echo "$titel"|awk 'BEGIN {FS="'"$liedseperator"'"}{print $2}'|rev|sed -e 's/*|||//'|rev|tr [:lower:] [:upper:]`
				fi
				echtgedaan=0
				while [ $echtgedaan -lt 1 ]; do for s in / / - - \\ \\ \|; do echo -ne "\r$s		thumbnail aan het genereren      "; sleep .05;if [[ -f ~/Documents/youtube-dl/.gedaan ]]; then echtgedaan=1; fi; done;done&
					convert -density 72 -units PixelsPerInch ~/Documents/youtube-dl/outfile.jpg -resize 1920x1080 ~/Documents/youtube-dl/outfile.jpg
					caractertitel=`echo $liedtitelzonderprod|iconv -c -f utf8 -t ascii|wc -c|tr -d [:blank:]`
					if [[ $caractertitel -gt 17 ]]; then
						huidigantwoord=`bc <<< "scale=2; 100/$caractertitel*17"`
						titelvergrotingsfactor=`bc <<< "scale=2; $huidigantwoord/100*240"`
					else
						titelvergrotingsfactor=235
					fi
					convert -font Impact -paint 1 -fill black -colorize $verdonkeringspercentage% -blur 0x12 -fill white -pointsize $titelvergrotingsfactor -gravity center -draw "text 0,-70 '$liedtitelzonderprodh'" -pointsize 98 -gravity center -draw "text 0,80 '$verbeterdartiesth'" ~/Documents/youtube-dl/outfile.jpg /Users/$USER/Downloads/outfile.jpg &> /dev/null
					#echo -ne "\r"
					rm ~/Documents/youtube-dl/outfile.jpg &> /dev/null
				touch ~/Documents/youtube-dl/.gedaan
				sleep .2
				rm ~/Documents/youtube-dl/.gedaan
				echo -ne "\rThumbnail gegenereerd.                                            "
				echo gedaan
				exit
				#########################
			fi
		fi
		if [[ $enhansedaudio == "true" ]]; then
			echtgedaan=0
			while [ $echtgedaan -lt 1 ]; do for s in / / - - \\ \\ \|; do echo -ne "\r$s		Audio aan het Enhansen      "; sleep .05;if [[ -f ~/Documents/youtube-dl/.gedaan ]]; then echtgedaan=1; fi; done;done&
				#huidigdb=`ffmpeg -i "$filenaamverbeterd" -af "volumedetect" -vn -sn -dn -f null /dev/null &>tijdelijk.txt;cat tijdelijk.txt|tail -3|head -1|awk 'BEGIN {FS="mean_volume: "}{print $2}'|sed -e "s/-//";rm tijdelijk.txt`;huidigdb=`echo ${huidigdb:0:2}`
				if [[ $volumepc != "" ]]; then
					volumepc=`bc <<< "scale=2; $volumepc/100"`
					mv "$filenaamverbeterd" ~/Documents/youtube-dl/outfile.mp3 &> /dev/null
					ffmpeg -i ~/Documents/youtube-dl/outfile.mp3 -filter:a "volume=$volumepc" -b:a 320k "$filenaamverbeterd" &>/dev/null
					rm ~/Documents/youtube-dl/outfile.mp3 &>/dev/null
				else
					mv "$filenaamverbeterd" ~/Documents/youtube-dl/outfile.mp3 &> /dev/null
					ffmpeg -i ~/Documents/youtube-dl/outfile.mp3 -b:a 320k "$filenaamverbeterd"	&>/dev/null
					rm ~/Documents/youtube-dl/outfile.mp3 &>/dev/null
				fi
				#ffmpeg -i ~/Documents/youtube-dl/outfile.mp3 -af "volume=9dB" -ab 320k "$filenaamverbeterd" &>/dev/null
				#ffmpeg -i ~/Documents/youtube-dl/outfile.mp3 -filter:a loudnorm -ab 320k "$filenaamverbeterd" &>/dev/null
			touch ~/Documents/youtube-dl/.gedaan
			sleep .2
			rm ~/Documents/youtube-dl/.gedaan
			echo -ne "\rAudio enhansed.                                            "
			eenwhileloopgebeurt=1
		else
			if [[ $volumepc != "" ]]; then
				volumepc=`bc <<< "scale=2; $volumepc/100"`
				mv "$filenaamverbeterd" ~/Documents/youtube-dl/outfile.mp3 &> /dev/null
				ffmpeg -i ~/Documents/youtube-dl/outfile.mp3 -filter:a "volume=$volumepc" "$filenaamverbeterd"
			fi
		fi
		genre=`cat ~/Documents/youtube-dl/.config.yt|grep -i "^GANRE"`
		if [[ $eindesec != "" ]]; then
			if [[ $eindesec == *":"* ]]; then
				fadeoutsec=`echo $eindesec|awk 'BEGIN {FS="|"}{print $2}'`
				eindesec=`echo $eindesec|awk 'BEGIN {FS="|"}{print $1}'`
				eindemin=`echo $eindesec|awk 'BEGIN {FS=":"}{print $1}'`
				eindesec=`echo $eindesec|awk 'BEGIN {FS=":"}{print $2}'`
				if [[ $fadeoutsec == "" ]]; then
					fadeoutsec=3
				fi
				if [[ $eindesec == "0"* ]]; then
					eindesec=`echo $eindesec|sed -e "s/0//"`
				fi
				eindesec=$(( eindemin * 60 + eindesec ))
			fi
			echtgedaan=0
			echo ""
			while [ $echtgedaan -lt 1 ]; do for s in / / - - \\ \\ \|; do echo -ne "\r$s		audio aan het bijsnijden   "; sleep .05;if [[ -f ~/Documents/youtube-dl/.gedaan ]]; then echtgedaan=1; fi; done;done&
				mv "$filenaamverbeterd" ~/Documents/youtube-dl/outfile.mp3 &> /dev/null
				avconv -i ~/Documents/youtube-dl/outfile.mp3 -t "$eindesec" -c copy "$filenaamverbeterd" &> /dev/null
				
				if [[ $fadeoutsec != 0 ]]; then
					ffmpeg -i "$filenaamverbeterd" ~/Documents/youtube-dl/file.jpg &> /dev/null
					sox "$filenaamverbeterd" ~/Documents/youtube-dl/outputfade.mp3 fade h 0 -0 "$fadeoutsec" &> /dev/null 
					ffmpeg -i "$filenaamverbeterd" -i ~/Documents/youtube-dl/outputfade.mp3 -map 1 -map_metadata 0 -c copy -movflags use_metadata_tags ~/Documents/youtube-dl/tijdelijk.mp3  &> /dev/null
					rm "$filenaamverbeterd" &> /dev/null
					mv ~/Documents/youtube-dl/tijdelijk.mp3 "$filenaamverbeterd" &> /dev/null
					eyeD3 --add-image="/Users/$USER/Documents/youtube-dl/file.jpg":FRONT_COVER "$filenaamverbeterd" &> /dev/null	
				fi
				rm ~/Documents/youtube-dl/outfile.mp3 ~/Documents/youtube-dl/file.jpg ~/Documents/youtube-dl/outputfade.mp3 &> /dev/null
			touch ~/Documents/youtube-dl/.gedaan
			sleep .2
			rm ~/Documents/youtube-dl/.gedaan
			echo -ne "\rAudio bijgesneden                                            "
			eenwhileloopgebeurt=1
		fi
		minuut=0
		sec=0
		secondenadubbelepunt=0
		if [[ $tweedelied != "" ]]; then
			if [[ $tweedelied == *" "* ]]; then
				begintweedelied=`echo $tweedelied|awk 'BEGIN {FS=" "}{print $2}'`
				tweedelied=`echo $tweedelied|awk 'BEGIN {FS=" "}{print $1}'`
			fi
			if [[ $tweedelied == *":"* ]]; then
				minuut=`echo $tweedelied|awk 'BEGIN {FS=":"}{print $1}'`
				secondenadubbelepunt=`echo $tweedelied|awk 'BEGIN {FS=":"}{print $2}'`
				if [[ $secondenadubbelepunt == "0"* ]]; then
					secondenadubbelepunt=`echo $secondenadubbelepunt|sed -e "s/0//"`
				fi
				minuutinsec=$(( minuut * 60 ))
				sec=$(( secondenadubbelepunt + minuutinsec ))
			else
				sec=$tweedelied
			fi
			titelpt1=`echo "$liedtitelzonderprod PT: 1"`
			titelpt2=`echo "$liedtitelzonderprod PT: 2"`
			if [[ $engeneer != "" ]]; then
				if [[ $engeneer == *" & "* ]]; then
					engeneer1=`echo "$engeneer"|awk 'BEGIN {FS=" & "}{print $1}'`
					engeneer2=`echo "$engeneer"|awk 'BEGIN {FS=" & "}{print $2}'`
				else
					engeneer1=$engeneer
					engeneer2=$engeneer
				fi
			else
				engeneer1="-Onbekend-"
				engeneer2="-Onbekend-"
			fi
			filenaamverbeterdpt1=`echo $filenaamverbeterd|rev|sed -e "s|3pm.|3pm.1 -TP |"|rev`
			filenaamverbeterdpt2=`echo $filenaamverbeterd|rev|sed -e "s|3pm.|3pm.2 -TP |"|rev`
			if [[ $begintweedelied != "" ]]; then
				if [[ $begintweedelied == *":"* ]]; then
					minuut=`echo $begintweedelied|awk 'BEGIN {FS=":"}{print $1}'`
					secondenadubbelepunt=`echo $begintweedelied|awk 'BEGIN {FS=":"}{print $2}'`
					if [[ $secondenadubbelepunt == "0"* ]]; then
						secondenadubbelepunt=`echo $secondenadubbelepunt|sed -e "s/0//"`
					fi
					minuutinsec=$(( minuut * 60 ))
					sectwee=$(( secondenadubbelepunt + minuutinsec ))
				else
					sectwee=$tweedelied
				fi	
			else
				sectwee="$sec"
			fi
			echtgedaan=0
			echo ""
			while [ $echtgedaan -lt 1 ]; do for s in / / - - \\ \\ \|; do echo -ne "\r$s		audio aan het splitten     "; sleep .05;if [[ -f ~/Documents/youtube-dl/.gedaan ]]; then echtgedaan=1; fi; done;done&
				/bin/ls "$filenaamverbeterdpt1" &> /dev/null && rm "$filenaamverbeterdpt1" &> /dev/null
				/bin/ls "$filenaamverbeterdpt2" &> /dev/null && rm "$filenaamverbeterdpt2" &> /dev/null
				avconv -i "$filenaamverbeterd" -t $sec -metadata title="$titelpt1" -c copy "$filenaamverbeterdpt1" &> /dev/null
				avconv -i "$filenaamverbeterd" -ss $sectwee -metadata title="$titelpt2" -c copy "$filenaamverbeterdpt2" &> /dev/null
				sox "$filenaamverbeterdpt2" ~/Documents/youtube-dl/outputfade2.mp3 fade h 3 -0 0 &> /dev/null
				rm "$filenaamverbeterdpt2" &> /dev/null
				ffmpeg -i "$filenaamverbeterdpt1" -i ~/Documents/youtube-dl/outputfade2.mp3 -map 1 -map_metadata 0 -metadata title="$titelpt2" -metadata composer="$engeneer2" -c copy -movflags use_metadata_tags "$filenaamverbeterdpt2" &> /dev/null
				ffmpeg -i "$filenaamverbeterd" ~/Documents/youtube-dl/file.jpg &> /dev/null
				eyeD3 --add-image="/Users/$USER/Documents/youtube-dl/file.jpg":FRONT_COVER "$filenaamverbeterdpt2" &> /dev/null
				sox "$filenaamverbeterdpt1" ~/Documents/youtube-dl/outputfade1.mp3 fade h 0 -0 3 &> /dev/null
				rm "$filenaamverbeterdpt1" &> /dev/null
				ffmpeg -i "$filenaamverbeterdpt2" -i ~/Documents/youtube-dl/outputfade1.mp3 -map 1 -map_metadata 0 -metadata title="$titelpt1" -metadata composer="$engeneer1" -c copy -movflags use_metadata_tags "$filenaamverbeterdpt1" &> /dev/null
				eyeD3 --add-image="/Users/$USER/Documents/youtube-dl/file.jpg":FRONT_COVER "$filenaamverbeterdpt1" &> /dev/null
				rm ~/Documents/youtube-dl/file.jpg "$filenaamverbeterd" &> /dev/null
				rm ~/Documents/youtube-dl/outputfade1.mp3 ~/Documents/youtube-dl/outputfade2.mp3 &> /dev/null
				tweedeliedcheck=1
			touch ~/Documents/youtube-dl/.gedaan
			sleep .2
			rm ~/Documents/youtube-dl/.gedaan
			echo -ne "\rSplitten gedaan                                            "
			eenwhileloopgebeurt=1
		fi
		minuut=0
		sec=""
		secondenadubbelepunt=0
		if [[ $seconde != "" ]]; then
			if [[ $seconde != "c" ]]; then
				if [[ $seconde == *":"* ]]; then
					minuut=`echo $seconde|awk 'BEGIN {FS=":"}{print $1}'`
					secondenadubbelepunt=`echo $seconde|awk 'BEGIN {FS=":"}{print $2}'`
					if [[ $secondenadubbelepunt == "0"* ]]; then
						secondenadubbelepunt=`echo $secondenadubbelepunt|sed -e "s/0//"`
					fi
					minuutinsec=$(( minuut * 60 ))
					seconde=$(( secondenadubbelepunt + minuutinsec ))
				fi
				fadeinsec=`echo $seconde|awk 'BEGIN {FS="|"}{print $2}'`
				if [[ $fadeinsec == "" ]]; then
					fadeinsec=2
				fi
			else
				fadeinsec=0
			fi
			echtgedaan=0
			echo ""
			while [ $echtgedaan -lt 1 ]; do for s in / / - - \\ \\ \|; do echo -ne "\r$s		audio aan het bijsnijden   "; sleep .05;if [[ -f ~/Documents/youtube-dl/.gedaan ]]; then echtgedaan=1; fi; done;done&
				if [[ $tweedelied != "" ]]; then
					ffmpeg -i "$filenaamverbeterdpt1" ~/Documents/youtube-dl/file.jpg &> /dev/null
					if [[ $seconde == "c" ]]; then
						ffmpeg -i "$filenaamverbeterdpt1" -af silenceremove=1:0:-10dB ~/Documents/youtube-dl/outfile.mp3 &> /dev/null
					else
						avconv -i "$filenaamverbeterdpt1" -ss $seconde ~/Documents/youtube-dl/outfile.mp3 &> /dev/null
					fi
					eyeD3 --add-image="/Users/$USER/Documents/youtube-dl/file.jpg":FRONT_COVER "/Users/$USER/Documents/youtube-dl/outfile.mp3" &> /dev/null
					rm "$filenaamverbeterdpt1" &> /dev/null
					rm ~/Documents/youtube-dl/file.jpg &> /dev/null
					avconv -i ~/Documents/youtube-dl/outfile.mp3 -c copy "$filenaamverbeterdpt1" &> /dev/null						
					if [[ $fadeinsec != 0 ]]; then
						if [[ $fadeinsec == "c" ]]; then
							ffmpeg -i "$filenaamverbeterdpt1" -af silenceremove=1:0:-10dB ~/Documents/youtube-dl/outfile.mp3 &> /dev/null
							mv ~/Documents/youtube-dl/tijdelijk.mp3 "$filenaamverbeterdpt1"  &> /dev/null
						else
							ffmpeg -i "$filenaamverbeterdpt1" ~/Documents/youtube-dl/file.jpg &> /dev/null
							sox "$filenaamverbeterdpt1" ~/Documents/youtube-dl/outputfade.mp3 fade h $fadeinsec -0 0 &> /dev/null
							ffmpeg -i "$filenaamverbeterdpt1" -i ~/Documents/youtube-dl/outputfade.mp3 -map 1 -map_metadata 0 -c copy -movflags use_metadata_tags ~/Documents/youtube-dl/tijdelijk.mp3  &> /dev/null
							rm "$filenaamverbeterdpt1" &> /dev/null
							mv ~/Documents/youtube-dl/tijdelijk.mp3 "$filenaamverbeterdpt1"  &> /dev/null
							eyeD3 --add-image="/Users/$USER/Documents/youtube-dl/file.jpg":FRONT_COVER "$filenaamverbeterdpt1" &> /dev/null
						fi
					fi 
					rm ~/Documents/youtube-dl/outfile.mp3 ~/Documents/youtube-dl/file.jpg ~/Documents/youtube-dl/outputfade.mp3 &> /dev/null
				else
					ffmpeg -i "$filenaamverbeterd" ~/Documents/youtube-dl/file.jpg &> /dev/null
					if [[ $seconde == "c" ]]; then
						#ffmpeg -i "$filenaamverbeterd" -af silenceremove=1:0:-10dB ~/Documents/youtube-dl/outfile.mp3 &> /dev/null
						ffmpeg -i "$filenaamverbeterd" -af silenceremove=start_periods=1:start_silence=0.1:start_threshold=-50dB,areverse,silenceremove=start_periods=1:start_silence=0.1:start_threshold=-50dB,areverse ~/Documents/youtube-dl/outfile.mp3 &> /dev/null
					else
						avconv -i "$filenaamverbeterd" -ss $seconde ~/Documents/youtube-dl/outfile.mp3 &> /dev/null
					fi
					eyeD3 --add-image="/Users/$USER/Documents/youtube-dl/file.jpg":FRONT_COVER "/Users/$USER/Documents/youtube-dl/outfile.mp3" &> /dev/null
					rm "$filenaamverbeterd" &> /dev/null
					rm ~/Documents/youtube-dl/file.jpg &> /dev/null
					avconv -i ~/Documents/youtube-dl/outfile.mp3 -c copy "$filenaamverbeterd" &> /dev/null
					if [[ $fadeinsec != 0 ]]; then
						if [[ $fadeinsec == "c" ]]; then
							#ffmpeg -i "$filenaamverbeterd" -af silenceremove=1:0:-10dB ~/Documents/youtube-dl/outfile.mp3 &> /dev/null
							ffmpeg -i "$filenaamverbeterd" -af silenceremove=start_periods=1:start_silence=0.1:start_threshold=-50dB,areverse,silenceremove=start_periods=1:start_silence=0.1:start_threshold=-50dB,areverse ~/Documents/youtube-dl/outfile.mp3 &> /dev/null
							mv ~/Documents/youtube-dl/tijdelijk.mp3 "$filenaamverbeterd"  &> /dev/null
						else
							ffmpeg -i "$filenaamverbeterd" ~/Documents/youtube-dl/file.jpg &> /dev/null
							sox "$filenaamverbeterd" ~/Documents/youtube-dl/outputfade.mp3 fade h $fadeinsec -0 0 &> /dev/null
							ffmpeg -i "$filenaamverbeterd" -i ~/Documents/youtube-dl/outputfade.mp3 -map 1 -map_metadata 0 -c copy -movflags use_metadata_tags ~/Documents/youtube-dl/tijdelijk.mp3  &> /dev/null
							rm "$filenaamverbeterd" &> /dev/null
							mv ~/Documents/youtube-dl/tijdelijk.mp3 "$filenaamverbeterd"  &> /dev/null
							eyeD3 --add-image="/Users/$USER/Documents/youtube-dl/file.jpg":FRONT_COVER "$filenaamverbeterd" &> /dev/null
						fi
					fi
					rm ~/Documents/youtube-dl/outfile.mp3 ~/Documents/youtube-dl/file.jpg ~/Documents/youtube-dl/outputfade.mp3 &> /dev/null
				fi
			touch ~/Documents/youtube-dl/.gedaan
			sleep .3
			rm ~/Documents/youtube-dl/.gedaan
			echo -ne "\rAudio bijgesneden                                            "
			eenwhileloopgebeurt=1
		fi
		if [[ $eenwhileloopgebeurt == 1 ]]; then
			sleep .2
			echo ""
			echo -ne "\r"
		fi
		youtube-dl $yourl --write-sub --convert-subs srt --skip-download -o $random &>/dev/null
		ls "$random"* &>/dev/null&&subsgeslaagd=1
		if [[ $subsgeslaagd == 1 ]]; then
			mv "$random"* ~/Documents/youtube-dl/lyrics.txt
			gsed -i "s/.* --> .*//g" ~/Documents/youtube-dl/lyrics.txt
			gsed -i '/^[[:space:]]*$/d' ~/Documents/youtube-dl/lyrics.txt
			gsed -i '1d' ~/Documents/youtube-dl/lyrics.txt
			gsed -i '1d' ~/Documents/youtube-dl/lyrics.txt
			gsed -i '1d' ~/Documents/youtube-dl/lyrics.txt
			gsed -i "s/^.*$/&\n/" ~/Documents/youtube-dl/lyrics.txt
			if [[ `cat ~/Documents/youtube-dl/lyrics.txt|wc -c|tr -d [:space:]` -lt 5000 ]];then
				echo "wil je vertalen?"
				read vertalen
				if [[ $vertalen == "y" ]]||[[ $vertalen == "Y" ]]||[[ $vertalen == "" ]]; then
					#trans :nl file://~/Documents/youtube-dl/lyrics.txt -o nltrans.txt -no-auto
					text=`cat ~/Documents/youtube-dl/lyrics.txt`;deep-translator translate -src en -tgt nl -txt "$text"|tail -n +3|sed -e "s/^ //" > nltrans.txt
					rm ~/Documents/youtube-dl/lyrics.txt
					mv nltrans.txt ~/Documents/youtube-dl/lyrics.txt	
				fi
				#eyeD3 --encoding utf8 --add-lyrics ~/Documents/youtube-dl/lyrics.txt "$filenaamverbeterd" &>/dev/null
			fi
			eyeD3 --encoding "utf8" --add-lyrics "/Users/$USER/Documents/youtube-dl/lyrics.txt" "$filenaamverbeterd" 1>/dev/null
			rm ~/Documents/youtube-dl/lyrics.txt
		else
			echo "subs niet beschikbaar"
		fi
		#for f in `ls -art /Users/$USER/Documents/youtube-dl|tail -3 |sed -e "s/ /347345749756/g"|awk 1 ORS=" "`;do if [[ $f != "."* ]]; then f=`echo $f|sed -e "s/347345749756/ /g"`; osascript -e 'tell application "Music"
		#	set newFile to "'"/Users/$USER/Documents/youtube-dl/$f"'"
		#	set toPlaylist to "Library"
		#	add newFile to playlist toPlaylist
		#	end tell'&>/dev/null;fi #;echo "/Users/"$USER"/Documents/youtube-dl/$f"
		#done
		osascript -e 'tell application "Music"
		set newFile to "'"/Users/$USER/Documents/youtube-dl/`ls -t Documents/youtube-dl/|head -1`"'"
		set toPlaylist to "Library"
		add newFile to playlist toPlaylist
		end tell'&>/dev/null
	fi
	if [[ "$vofa" == "v" ]]; then
		filenaamverbeterd=`echo "$filenaam"|sed -e "s/$typ*//"`
		filenaamverbeterd=`echo "$filenaamverbeterd"|sed -e "s|/Documents/youtube-dl/|/Documents/youtube-dl_video/|"`
		if [[ $typ == ".mp4" ]]; then
			filenaamverbeterd=`echo "$filenaamverbeterd"|rev|sed -e "s/4pm.//"|rev`
		fi
		trap - SIGINT
		trap
		trap exit 1 SIGINT
		while [[ $gehaald != 1 ]];do
			/usr/local/bin/youtube-dl $yourl --output "$filenaamverbeterd" --merge-output-format mp4 --embed-thumbnail --all-subs --embed-subs -f bestvideo[ext=mp4]+bestaudio[ext=m4a]/mp4 --add-metadata --metadata-from-title "(?P<artist>.+?) - (?P<title>.+)"&&gehaald=1
			if [[ $gehaald != 1 ]]; then
				youtube-dl --rm-cache-dir #/usr/local/bin/youtube-dl $yourl --output "$filenaamverbeterd" --merge-output-format mp4 --embed-thumbnail --all-subs --embed-subs -f bestvideo+bestaudio --add-metadata --metadata-from-title "(?P<artist>.+?) - (?P<title>.+)"	
			fi
		done
		#if [[ $filenaamverbeterd != *".mp4" ]]; then
		#	filenaamverbeterd=`echo "$filenaamverbeterd.mp4"`
		#fi
		#ffmpeg -i "/Users/$USER/Documents/youtube-dl_video/file.jpg" ~/Documents/youtube-dl_video/file.jpg &> /dev/null
		#rm "$filenaamverbeterd"
		#ffmpeg -i ~/Documents/youtube-dl_video/outfile.mp4 -metadata URL="$yourl" -c copy "$filenaamverbeterd"
		#eyeD3 --add-image="/Users/$USER/Documents/youtube-dl_video/file.jpg":FRONT_COVER "$filenaamverbeterd" &> /dev/null
		#rm ~/Documents/youtube-dl_video/outfile.mp4
		#avconv -i ~/Documents/youtube-dl/outfile.mp3 -c copy "$filenaamverbeterd"
	fi
fi
# osascript -e 'tell application "Music"
# 	set newFile to "'"$filenaamverbeterd"'"
# 	set toPlaylist to "Library"
# 	add newFile to playlist toPlaylist
# end tell'
if [[ $open == 1 ]]; then
	if [[ $tweedeliedcheck == 1 ]]; then
		open "$filenaamverbeterdpt1" "$filenaamverbeterdpt2"
	else
		if [[ $vofa == "v" ]]; then
			echo "$filenaamverbeterd.mp4"|sed -e "s| |˚|g" >> ~/Documents/youtube-dl/.open.list
		else
			echo "$filenaamverbeterd"|sed -e "s| |˚|g" >> ~/Documents/youtube-dl/.open.list
		fi
		if [[ $yourltweedelinkcheck != "1" ]]; then
			openstringbijnaaf=`cat ~/Documents/youtube-dl/.open.list|sed -e "s|'|\\\\\\'\\\\\\\"\"\\\\\\\\\\'\\\\\\\"\"\\\\\\'|g"|xargs`
			openstringbijnaaf=`echo "$openstringbijnaaf"|sed -e "s| |' '|g"|sed -e "s|˚| |g"`
			openstringaf=`echo "'$openstringbijnaaf'"`
			echo "open $openstringaf" > ~/Documents/youtube-dl/.klaaromteopenen.sh
			chmod 755 ~/Documents/youtube-dl/.klaaromteopenen.sh
			bash ~/Documents/youtube-dl/.klaaromteopenen.sh
			rm ~/Documents/youtube-dl/.open.list
			rm ~/Documents/youtube-dl/.klaaromteopenen.sh
		fi
	fi
fi
#mkdir ~/tijdelijk;mv "$filenaamverbeterd" ~/tijdelijk;sleep 1;mv ~/tijdelijk/* "$filenaamverbeterd";rm -rf ~/tijdelijk/&
if [[ $beidecheck == "1" ]]; then
	vofa=v
	allelinksbehalvedeeerste=$yourl
	yourltweedelinkcheck="1"
fi
if [[ $yourltweedelinkcheck == "1" ]]; then
	if [[ $minr == 1 ]]; then
		if [[ $open == 1 ]]; then
			if [[ $vofa == "v" ]]; then
				/usr/local/bin/youtubedl -rou "$allelinksbehalvedeeerste"
			else
				/usr/local/bin/youtubedl -raou "$allelinksbehalvedeeerste"
			fi
		else
			if [[ $vofa == "v" ]]; then
				/usr/local/bin/youtubedl -ru "$allelinksbehalvedeeerste"
			else
				/usr/local/bin/youtubedl -rau "$allelinksbehalvedeeerste"
			fi
		fi
	else
		if [[ $open == 1 ]]; then
			if [[ $vofa == "v" ]]; then
				/usr/local/bin/youtubedl -ou "$allelinksbehalvedeeerste"
			else
				/usr/local/bin/youtubedl -aou "$allelinksbehalvedeeerste"
			fi
		else
			if [[ $vofa == "v" ]]; then
				/usr/local/bin/youtubedl -u "$allelinksbehalvedeeerste"
			else
				/usr/local/bin/youtubedl -au "$allelinksbehalvedeeerste"
			fi
		fi
	fi
fi
if [[ $isync == "true" ]]||[[ $syncactivatie == 1 ]]; then
	echo isync poging
	syncfunc&
fi