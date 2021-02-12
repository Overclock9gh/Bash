pause(){      
	read -p "Appuyer sur la touche [Enter] pour continuer..." EnterKey  
}

fonctionsOne(){
	echo "Voici la liste des VM $2"
    virsh -c qemu:///system list $1 | cut -c8-37 | sed '1,2d' > listeVM.txt
	cat listeVM.txt
	pause
}

read_options2(){
	local choice2
	read -p "Entrez un choix [ a - d ] " choice2
	case $choice2 in
	a) fonctionsOne "--all" "" ;;
	b) fonctionsOne "" "actives";;
	c) show_menus && read_options ;;
	d) exit 0;;
	*) 
	clear
	echo -e "${RED}Erreur...${STD}" && sleep 2 && echo -e "${RED2}Le choix n'est pas valide${STD2}"
	echo "Voulez-vous continuer ? o/n"
	read reponse2
	if [[ "$reponse2" = "o" ]]; then
		bash fichierOne.sh
		read_options2
	else
		show_menus
		read_options
	fi	
	esac
}

read_options3(){
	local choice3
	read -p "Entrez un choix [ a - g ] " choice3
	case $choice3 in
	a) onev3 ;;
	b) twov3 ;;
	c) threev3 ;;
	d) fourv3 ;;
	e) fivev3 ;;
	f) show_menus && read_options ;;
	g) exit 0;;
	*) 
	clear
	echo -e "${RED}Erreur...${STD}" && sleep 2 && echo -e "${RED2}Le choix n'est pas valide${STD2}"
	echo "Voulez-vous continuer ? o/n"
	read reponse2
	if [[ "$reponse2" = "o" ]]; then
		bash fichierTwo.sh
		read_options3
		else
		show_menus
		read_options
	fi		
	esac
}

VM_VIRSH_QEMU_STATE(){
	VM=$(virsh -c qemu:///system list $1 | cut -c8-37 | sed '1,2d')
}

VM_VIRSH_QEMU_COMPARAISON(){
	VM=$(virsh -c qemu:///system list $1 | grep $2 -q)
}

VM_VIRSH_QEMU_CHANGER_ETAT(){
	VM=$(virsh -c qemu:///system $1 $2 &>/dev/null)
}

QUESTION_NOM_VM(){
	echo "Connaissez-vous le nom de vos VM o/n ?" 
	read question
}

QUESTION_NOM_VM2(){
	echo "Veuillez écrire le nom ou faire exit pour sortir"
	read reponse 
}

MESSAGE_AVERTISSEMENT(){
	echo -e "${YEL}$1${STD}" && sleep 2 && echo -e "${YEL2}$2${STD2}"
}

MESSAGE_ERREUR(){
	echo -e "${RED}$1${STD}" && sleep 2 && echo -e "${RED2}$2${STD2}"
}

MENU(){
	bash fichierTwo.sh
	read_options3
}

onev3(){
	clear
	VM_VIRSH_QEMU_STATE --state-shutoff
	QUESTION_NOM_VM
	case "$question" in
		o)
		clear
		QUESTION_NOM_VM2
		if [[ "$reponse" = "exit" ]]; then
			MENU
		elif (VM_VIRSH_QEMU_COMPARAISON --state-running $reponse); then
			clear
			MESSAGE_AVERTISSEMENT "Avertissement" "La VM est déjà actif"
			sleep 2
			MENU
		elif (VM_VIRSH_QEMU_COMPARAISON --state-paused $reponse); then
			clear
			MESSAGE_AVERTISSEMENT "Avertissement" "La VM est déjà actif, mais seulement en pause"
			sleep 2
			MENU
		elif (VM_VIRSH_QEMU_COMPARAISON --all $reponse); then
			clear
			VM_VIRSH_QEMU_CHANGER_ETAT start $reponse
			sleep 2
			echo "La VM démarre"
			sleep 1
			echo "Voulez-vous continuer ? o/n"
			read reponse2
			if [[ "$reponse2" = "o" ]]; then
				onev3
			else
			MENU
			fi
		else
			clear
			MESSAGE_ERREUR "Erreur..." "La VM n'existe pas"
			sleep 2
			MENU
		fi				
		;;
		

		n)
		clear
		PS3="Votre choix :"
		echo "Veuillez choisir un numéro"
		select reponse in $VM exit
		do
			if [[ "$reponse" = "exit" ]]; then
				bash fichierTwo.sh
				read_options3
			elif [ -z "${reponse//}" ]; then
				clear
				MESSAGE_ERREUR "Erreur..." "Le numéro ne fait pas parti des choix"
				sleep 2
				MENU
			else
				clear
				VM_VIRSH_QEMU_CHANGER_ETAT start $reponse
				sleep 2
				echo "La Vm démarre"
				sleep 1
				echo "Voulez-vous continuer ? o/n"
				read reponse2
				if [[ "$reponse2" = "o" ]]; then
					onev3
				else
					MENU
				fi
			fi
		done
		exit 0  
		;;


		*)
		clear 
		MESSAGE_ERREUR "Erreur..." "Le choix n'est pas valide"
		sleep 2
		MENU
	esac
	pause
}

twov3(){
	clear
	VM_VIRSH_QEMU_STATE --state-running
	QUESTION_NOM_VM
	case "$question" in
		o)
		clear
		QUESTION_NOM_VM2
		if [[ "$reponse" = "exit" ]]; then
			bash fichierTwo.sh
			read_options3
		elif (VM_VIRSH_QEMU_COMPARAISON --state-shutoff $reponse); then
			clear
			MESSAGE_AVERTISSEMENT "Avertissement" "La VM est suspendue, veuillez la reprendre pour utiliser cette option"
			MENU
		elif (VM_VIRSH_QEMU_COMPARAISON --state-paused $reponse); then
			clear
			MESSAGE_AVERTISSEMENT "Avertissement" "La VM est déjà suspendue"
			sleep 4
			MENU
		elif (VM_VIRSH_QEMU_COMPARAISON "" $reponse); then
			clear
			VM_VIRSH_QEMU_CHANGER_ETAT shutdown $reponse
			sleep 2
			echo "La VM s'éteint"
			sleep 1
			echo "Voulez-vous continuer ? o/n"
			read reponse2
			if [[ "$reponse2" = "o" ]]; then
				twov3
			else
				MENU
			fi	
		else
			clear
			MESSAGE_ERREUR "Erreur..." "La VM n'existe pas"
			sleep 2
			MENU
		fi				
		;;
		

		n)
		clear
		PS3="Votre choix :"
		echo "Veuillez choisir un numéro"
		select reponse in $VM exit
		do
			if [[ "$reponse" = "exit" ]]; then
				bash fichierTwo.sh
				read_options3
			elif [ -z "${reponse//}" ]; then
				clear
				MESSAGE_ERREUR "Erreur..." "Le numéro ne fait pas parti des choix"
				sleep 2
				MENU
			else
				clear
				VM_VIRSH_QEMU_CHANGER_ETAT shutdown $reponse
				sleep 2
				echo "La VM s'éteint"
				sleep 1
				echo "Voulez-vous continuer ? o/n"
				read reponse2
				if [[ "$reponse2" = "o" ]]; then
					twov3
				else
					MENU
				fi
			fi
		done
		exit 0  
		;;

		*)
		clear 
		MESSAGE_ERREUR "Erreur..." "Le choix n'est pas valide"
		sleep 2
		MENU	
	esac
	pause
}

threev3(){
	clear
	VM_VIRSH_QEMU_STATE 
	QUESTION_NOM_VM
	case "$question" in
		o)
		clear
		QUESTION_NOM_VM2
		if [[ "$reponse" = "exit" ]]; then
			MENU
		elif (VM_VIRSH_QEMU_COMPARAISON --state-shutoff $reponse); then
			clear
			MESSAGE_AVERTISSEMENT "Avertissement" "La VM est déjà éteinte"
			echo "Voulez-vous continuer ? o/n"
			read reponse2
			if [[ "$reponse2" = "o" ]]; then
				threev3
			else
				MENU
			fi
		elif (VM_VIRSH_QEMU_COMPARAISON "" $reponse); then
			clear
			VM_VIRSH_QEMU_CHANGER_ETAT destroy $reponse
			sleep 2
			echo "La VM se détruit"
			sleep 1
			echo "Voulez-vous continuer ? o/n"
			read reponse2
			if [[ "$reponse2" = "o" ]]; then
				threev3
			else
				MENU
			fi
		else
			clear
			MESSAGE_ERREUR "Erreur..." "La VM n'existe pas"
			sleep 2
			MENU
		fi				
		;;
		

		n)
		clear
		PS3="Votre choix :"
		echo "Veuillez choisir un numéro"
		select reponse in $VM exit
		do
			if [[ "$reponse" = "exit" ]]; then
				bash fichierTwo.sh
				read_options3
			elif [ -z "${reponse//}" ]; then
				clear
				MESSAGE_ERREUR "Erreur..." "Le numéro ne fait pas parti des choix"
				sleep 2
				MENU
			else
				clear
				VM_VIRSH_QEMU_CHANGER_ETAT destroy $reponse
				sleep 2
				echo "La VM se détruit"
				sleep 1
				echo "Voulez-vous continuer ? o/n"
				read reponse2
				if [[ "$reponse2" = "o" ]]; then
					fourv3
				else
					MENU
				fi
			fi
		done
		exit 0  
		;;

	
		*)
		clear 
		MESSAGE_ERREUR "Erreur..." "Le choix n'est pas valide"
		sleep 2
		MENU
	esac
	pause
}

fourv3(){
	clear
	VM_VIRSH_QEMU_STATE --state-running
	QUESTION_NOM_VM
	case "$question" in
		o)
		clear
		QUESTION_NOM_VM2
		if [[ "$reponse" = "exit" ]]; then
			MENU
		elif (virsh -c qemu:///system list --state-paused | grep $reponse -q); then
			clear
			MESSAGE_AVERTISSEMENT "Avertissement" "La VM est déjà suspendue"
			MENU
		elif (virsh -c qemu:///system list | grep $reponse -q); then
			clear
			VM_VIRSH_QEMU_CHANGER_ETAT suspend $reponse
			sleep 2
			echo "La VM se met en pause"
			sleep 1
			echo "Voulez-vous continuer ? o/n"
			read reponse2
			if [[ "$reponse2" = "o" ]]; then
				fourv3
			else
				MENU
			fi
		else
			clear
			MESSAGE_ERREUR "Erreur..." "La VM n'existe pas"
			sleep 2
			MENU
		fi				
		;;
		

		n)
		clear
		PS3="Votre choix :"
		echo "Veuillez choisir un numéro"
		select reponse in $VM exit
		do
			if [[ "$reponse" = "exit" ]]; then
				MENU
			elif [ -z "${reponse//}" ]; then
				clear
				MESSAGE_ERREUR "Erreur..." "Le numéro ne fait pas parti des choix"
				sleep 2
				MENU
			else
				clear
				VM_VIRSH_QEMU_CHANGER_ETAT suspend $reponse
				sleep 2
				echo "La VM se met en pause"
				sleep 1
				echo "Voulez-vous continuer ? o/n"
				read reponse2
				if [[ "$reponse2" = "o" ]]; then
					fourv3
				else
					MENU
				fi
			fi
		done
		exit 0  
		;;


		*)
		clear 
		MESSAGE_ERREUR "Erreur..." "Le choix n'est pas valide"
		sleep 2
		MENU
	esac
	pause
}

fivev3(){
	clear
	VM_VIRSH_QEMU_STATE --state-paused
	QUESTION_NOM_VM
	case "$question" in
		o)
		clear
			QUESTION_NOM_VM2
		if [[ "$reponse" = "exit" ]]; then
			MENU
		elif (virsh -c qemu:///system list --state-shutoff | grep $reponse -q); then
			clear
			MESSAGE_AVERTISSEMENT "Avertissement" "La VM est éteinte, l'option est impossible"
			sleep 2	
			MENU
		elif (virsh -c qemu:///system list --state-running | grep $reponse -q); then
			clear
			MESSAGE_AVERTISSEMENT "Avertissement" "La VM est déjà actif"
			sleep 2
			MENU
		elif (virsh -c qemu:///system list | grep $reponse -q); then
			clear
			VM_VIRSH_QEMU_CHANGER_ETAT resume $reponse
			sleep 2
			echo "La VM se remet en activitée"
			sleep 1
			echo "Voulez-vous continuer ? o/n"
			read reponse2
			if [[ "$reponse2" = "o" ]]; then
				fivev3
			else
				MENU
			fi
		else
			clear
			MESSAGE_ERREUR "Erreur..." "La VM n'existe pas"
			sleep 2
			MENU
		fi				
		;;
		

		n)
		clear
		PS3="Votre choix :"
		echo "Veuillez choisir un numéro"
		select reponse in $VM exit
		do
			if [[ "$reponse" = "exit" ]]; then
				MENU
			elif [ -z "${reponse//}" ]; then
				clear
				MESSAGE_ERREUR "Erreur..." "Le numéro ne fait pas parti des choix"
				sleep 2
				MENU
			else
				clear
				VM_VIRSH_QEMU_CHANGER_ETAT resume $reponse
				sleep 2
				echo "La VM se remet en activitée"
				sleep 1				
				echo "Voulez-vous continuer ? o/n"
				read reponse2
				if [[ "$reponse2" = "o" ]]; then
					fivev3
				else
					MENU
				fi
			fi
		done
		exit 0  
		;;


		*)
		clear 
		MESSAGE_ERREUR "Erreur..." "Le choix n'est pas valide"
		sleep 2
		MENU
	esac
	pause
}

read_options4(){
	local choice4
	read -p "Entrez un choix [ a - c ] " choice4
	case $choice4 in
		a) onev4 ;;
		b) show_menus && read_options  ;;
		c) exit 0;;
		*) 
		clear
		MESSAGE_ERREUR "Erreur..." "Le choix n'est pas valide"
		sleep 2
		show_menus
		read_options
	esac
}

onev4(){
	clear
	VM=$(virsh -c qemu:///system list --all | cut -c8-37 | sed '1,2d')
	PS3="Votre choix :"
	echo "Veuillez choisir un numéro"
	select reponse in $VM exit
	do
		if [[ "$reponse" = "exit" ]]; then
			bash fichierThree.sh
			read_options4
		elif [ -z "${reponse//}" ]; then
			clear
			MESSAGE_AVERTISSEMENT_AVERTISSEMENT_CHOIX
			echo "Voulez-vous continuer ? o/n"
			read reponse2
			if [[ "$reponse2" = "o" ]]; then
				onev4
			else
				bash fichierThree.sh
				read_options4
			fi
		else
			clear
			if (virsh -c qemu:///system list --state-shutoff | grep $reponse -q); then
				virsh -c qemu:///system start $reponse &>/dev/null &
				virt-viewer -c qemu:///system $reponse &>/dev/null &
				echo "Voulez-vous continuer ? o/n"
				read reponse2
				if [[ "$reponse2" = "o" ]]; then
					onev4
				else
					bash fichierThree.sh
					read_options4
				fi
			else
				virt-viewer -c qemu:///system $reponse 2>/dev/null
				sleep 2
				echo "Voulez-vous continuer ? o/n"
				read reponse2
				if [[ "$reponse2" = "o" ]]; then
					onev4
				else
					bash fichierThree.sh
					read_options4
				fi
			fi
		fi
	done
	exit 0  
}