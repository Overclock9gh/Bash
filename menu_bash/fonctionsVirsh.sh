# -------------------------------------------  
# Définition des fonctions en lien avec Virsh
# ------------------------------------------- 
# Fonction qui attend la touche Entrée pour continuer
sh_pause(){      
read -p "Appuyer sur la touche [Entrée] pour continuer..." sh_touche_entree  
} 

# Menu qui gére les choix de l'affichage des VM
sh_lire_options_affichage_vm(){
	local sh_choice2
	read -p "Entrez un choix [ a - d ] " sh_choice2
	case $sh_choice2 in
	a) sh_afficher_vm "--all" ""; sh_pause ;;
	b) sh_afficher_vm "" "actives"; sh_pause ;;
	c) sh_menus ;;
	d) exit ;;
	*) 
    sh_message_erreur "Erreur..." "Le choix n'est pas valide"
    sh_pause
    sh_menu_un
	esac
}

# Fonction qui affiche les VM
sh_afficher_vm(){
	clear
	echo -e "${sh_BLU}Voici la liste des VM $2 ${sh_STD2}"
    virsh list $1 | cut -c8-37 | sed '1,2d ; $d' > listeVM.txt
	if [[ -s listeVM.txt ]]; then
		cat listeVM.txt
	else
		echo "Il n'y a aucune VM active"
	fi
}

# Menu qui gére les choix de de démarrage et l’arrêt de VMs
sh_lire_options_etat_vm(){
	local sh_choice3
	read -p "Entrez un choix [ a - g ] " sh_choice3
	case $sh_choice3 in
	a) sh_demarrage_vm ;;
	b) sh_fermeture_vm ;;
	c) sh_destruction_vm ;;
	d) sh_suspension_vm ;;
	e) sh_reprise_vm ;;
	f) sh_menus ;;
	g) exit ;;
	*) 
    sh_message_erreur "Erreur..." "Le choix n'est pas valide"
    sh_pause
    sh_menu_deux 
	esac
}

# Fonction qui demande le choix d'un numéro
sh_choix_numero(){
	echo -e "${sh_BLU}Veuillez choisir un numéro${sh_STD2}"
}

# Fonction qui affiche l'état de la VM en paramètre
sh_etat_vm(){
	export sh_vm=$(virsh list $1 | cut -c8-37 | sed '1,2d')
}

sh_reseau_vm(){
	export sh_reseau_list=$(sudo virsh net-list | cut -c1-22 | sed '1,2d')
}

# Fonction qui compare l'état de la VM en paramètre à un état choisis en paramètre
sh_comparaison_vm(){
	export sh_vm=$(virsh list $1 | grep $2 -q)
}

# Fonction qui change l'état choisis en paramètre d'une VM en paranamètre
sh_changer_etat_vm(){
	export sh_vm=$(virsh $1 $2 &>/dev/null)
}

# Fonction qui questionne à l'utilisateur au sujet de la connaisance de ses VM
sh_question_vm(){
	read -p "Connaissez-vous le nom de vos VM o/n ?: " sh_question
}

# Fonction qui questionne à l'utilisateur le nom d'une VM
sh_question_vm2(){
	read -p "Veuillez écrire le nom ou faire exit pour sortir: " sh_reponse
}

# Fonction qui avertis l'utilisateur d'un avertissement spécifique
sh_message_avertissement(){
	echo -e "${sh_YEL}$1${STD}" && echo -e "${sh_YEL2}$2${sh_STD2}"
}

# Fonction qui avertis l'utilisateur d'une erreur spécifique
sh_message_erreur(){
	echo -e "${sh_RED}$1${sh_STD}" && echo -e "${sh_RED2}$2${sh_STD2}"
}

# Fonction qui demande à l'utilisateur sa volonté de continuer après un chpix
sh_question_continuer(){
    read -p "Voulez-vous continuer ou revenir au menu précédent ? (o)continuer/(n)revenir: " sh_reponse2
    if [[ "$sh_reponse2" = "o" ]]; then
		$1
	else
		$2
	fi
}

# Fonction qui affiche le menu principal
sh_menus(){
	sh_afficher_menus
	sh_lire_options
}

# Fonction qui gére le démarrage d'une VM
sh_demarrage_vm(){
	clear
	sh_etat_vm --state-shutoff
	sh_question_vm
	case "$sh_question" in
		o)
		clear

		sh_oui_v1(){
		sh_question_vm2
		if [[ "$sh_reponse" = "exit" ]]; then
			sh_menu_deux
		elif (sh_comparaison_vm --state-running $sh_reponse); then
			sh_message_avertissement "Avertissement" "La VM est déjà actif"
			sh_pause
			clear
			sh_oui_v1
		elif (sh_comparaison_vm --state-paused $sh_reponse); then
			sh_message_avertissement "Avertissement" "La VM est déjà actif, mais seulement en sh_pause"
			sh_pause
			clear
			sh_oui_v1
		elif (sh_comparaison_vm --all $sh_reponse); then
			clear
			sh_changer_etat_vm start $sh_reponse
			sleep 2
			echo "La VM démarre"
			sleep 1
            sh_question_continuer sh_demarrage_vm sh_menu_deux
		else
			sh_message_erreur "Erreur..." "La VM n'existe pas"
			sh_pause
			clear
			sh_oui_v1
		fi	
		}	
		sh_oui_v1		
		;;
		

		n)
		clear

		sh_non_v1(){
		sh_PS3="Votre choix :"
		sh_choix_numero
		select sh_reponse in $sh_vm exit
		do
			if [[ "$sh_reponse" = "exit" ]]; then
				sh_menu_deux
			elif [ -z "${sh_reponse//}" ]; then
				sh_message_erreur "Erreur..." "Le numéro ne fait pas parti des choix"
				sh_pause
				clear
				sh_non_v1
			else
				clear
				sh_changer_etat_vm start $sh_reponse
				sleep 2
				echo "La Vm démarre"
				sleep 1
                sh_question_continuer sh_demarrage_vm sh_menu_deux
			fi
		done
		exit 0  
		}
		sh_non_v1
		;;


		*)
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
		sh_pause
		sh_demarrage_vm
	esac
	sh_pause
}

# Fonction qui gére la fermeture d'une VM
sh_fermeture_vm(){
	clear
	sh_etat_vm --state-running
	sh_question_vm
	case "$sh_question" in
		o)
		clear

		sh_oui_v2(){
		sh_question_vm2
		if [[ "$sh_reponse" = "exit" ]]; then
			sh_menu_deux
		elif (sh_comparaison_vm --state-shutoff $sh_reponse); then
			sh_message_avertissement "Avertissement" "La VM est suspendue, veuillez la reprendre pour utiliser cette option"
			sh_pause
			clear
			sh_oui_v2
		elif (sh_comparaison_vm --state-paused $sh_reponse); then
			sh_message_avertissement "Avertissement" "La VM est déjà suspendue"
			sh_pause
			clear
			sh_oui_v2
		elif (sh_comparaison_vm "" $sh_reponse); then
			clear
			sh_changer_etat_vm shutdown $sh_reponse
			sleep 2
			echo "La VM s'éteint"
			sleep 1
            sh_question_continuer sh_fermeture_vm sh_menu_deux
		else
			sh_message_erreur "Erreur..." "La VM n'existe pas"
			sh_pause
			clear
			sh_oui_v2
		fi	
		}	
		sh_oui_v2		
		;;
		

		n)
		clear

		sh_non_v2(){
		sh_PS3="Votre choix :"
		sh_choix_numero
		select sh_reponse in $sh_vm exit
		do
			if [[ "$sh_reponse" = "exit" ]]; then
				sh_menu_deux
			elif [ -z "${sh_reponse//}" ]; then
				sh_message_erreur "Erreur..." "Le numéro ne fait pas parti des choix"
				sh_pause
				clear
				sh_non_v2
			else
				clear
				sh_changer_etat_vm shutdown $sh_reponse
				sleep 2
				echo "La VM s'éteint"
				sleep 1
                sh_question_continuer sh_fermeture_vm sh_menu_deux
			fi
		done
		exit 0  
		}
		sh_non_v2
		;;

		*)
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
		sh_pause
		sh_menu_deux	
	esac
	sh_pause
}

# Fonction qui gére la destruction d'une VM
sh_destruction_vm(){
	clear
	sh_etat_vm 
	sh_question_vm
	case "$question" in
		o)
		clear

		sh_oui_v3(){
		sh_question_vm2
		if [[ "$sh_reponse" = "exit" ]]; then
			sh_menu_deux
		elif (sh_comparaison_vm --state-shutoff $sh_reponse); then
			sh_message_avertissement "Avertissement" "La VM est déjà éteinte"
			sh_pause
			clear
			sh_oui_v3
		elif (sh_comparaison_vm "" $sh_reponse); then
			clear
			sh_changer_etat_vm destroy $sh_reponse
			sleep 2
			echo "La VM se détruit"
			sleep 1
            sh_question_continuer sh_destruction_vm sh_menu_deux
		else
			sh_message_erreur "Erreur..." "La VM n'existe pas"
			sh_pause
			clear
			sh_oui_v3
		fi			
		}	
		sh_oui_v3
		;;
		

		n)
		clear

		sh_non_v3(){
		sh_PS3="Votre choix :"
		sh_choix_numero
		select sh_reponse in $sh_vm exit
		do
			if [[ "$sh_reponse" = "exit" ]]; then
				sh_menu_deux
			elif [ -z "${sh_reponse//}" ]; then
				sh_message_erreur "Erreur..." "Le numéro ne fait pas parti des choix"
				sh_pause
				clear
				sh_non_v3
			else
				clear
				sh_changer_etat_vm destroy $sh_reponse
				sleep 2
				echo "La VM se détruit"
				sleep 1
                sh_question_continuer sh_destruction_vm sh_menu_deux
			fi
		done
		exit 0  
		}
		sh_non_v3
		;;

	
		*)
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
		sh_pause
		sh_destruction_vm
	esac
	sh_pause
}

# Fonction qui gére le suspension d'une VM
sh_suspension_vm(){
	clear
	sh_etat_vm --state-running
	sh_question_vm
	case "$sh_question" in
		o)
		clear

		sh_oui_v4(){
		sh_question_vm2
		if [[ "$sh_reponse" = "exit" ]]; then
			sh_menu_deux
		elif (sh_comparaison_vm --state-paused $sh_reponse); then
			sh_message_avertissement "Avertissement" "La VM est déjà suspendue"
			sh_pause
			clear
			sh_oui_v4
		elif (sh_comparaison_vm --state-shutoff $sh_reponse); then
			sh_message_avertissement "Avertissement" "La VM est arreté, l'option est impossible"
			sh_pause
			clear
			sh_oui_v4
		elif (sh_comparaison_vm "" $sh_reponse); then
			clear
			sh_changer_etat_vm suspend $sh_reponse
			sleep 2
			echo "La VM se met en sh_pause"
			sleep 1
            sh_question_continuer sh_suspension_vm sh_menu_deux
		else
			sh_message_erreur "Erreur..." "La VM n'existe pas"
			sh_pause
			clear
			sh_oui_v4
		fi	
		}	
		sh_oui_v4		
		;;
		

		n)
		clear

		sh_non_v4(){
		sh_PS3="Votre choix :"
		sh_choix_numero
		select sh_reponse in $sh_vm exit
		do
			if [[ "$sh_reponse" = "exit" ]]; then
				sh_menu_deux
			elif [ -z "${sh_reponse//}" ]; then
				sh_message_erreur "Erreur..." "Le numéro ne fait pas parti des choix"
				sh_pause
				clear
				sh_non_v4
			else
				clear
				sh_changer_etat_vm suspend $sh_reponse
				sleep 2
				echo "La VM se met en sh_pause"
				sleep 1
                sh_question_continuer sh_suspension_vm sh_menu_deux
			fi
		done
		exit 0  
		}
		sh_non_v4
		;;


		*)
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
		sh_pause
		sh_suspension_vm
	esac
	sh_pause
}

# Fonction qui gére la reprise d'une VM
sh_reprise_vm(){
	clear

	sh_etat_vm --state-paused
	sh_question_vm
	case "$sh_question" in
		o)

		sh_oui_v5(){
		clear
		sh_question_vm2
		if [[ "$sh_reponse" = "exit" ]]; then
			sh_menu_deux
		elif (sh_comparaison_vm --state-shutoff $sh_reponse); then
			sh_message_avertissement "Avertissement" "La VM est éteinte, l'option est impossible"
			sh_pause	
			clear
			sh_oui_v5
		elif (sh_comparaison_vm --state-running $sh_reponse); then
			sh_message_avertissement "Avertissement" "La VM est déjà actif"
			sh_pause
			sh_oui_v5
		elif (sh_comparaison_vm --state-paused $sh_reponse); then
			clear
			sh_changer_etat_vm resume $sh_reponse
			sleep 2
			echo "La VM se remet en activitée"
			sleep 1
            sh_question_continuer sh_reprise_vm sh_menu_deux
		else
			sh_message_erreur "Erreur..." "La VM n'existe pas"
			sh_pause
			clear
			sh_oui_v5
		fi	
		}
		sh_oui_v5			
		;;
		

		n)
		clear

		sh_non_v5(){
		sh_PS3="Votre choix :"
		sh_choix_numero
		select sh_reponse in $sh_vm exit
		do
			if [[ "$sh_reponse" = "exit" ]]; then
				sh_menu_deux
			elif [ -z "${sh_reponse//}" ]; then
				sh_message_erreur "Erreur..." "Le numéro ne fait pas parti des choix"
				sh_pause
				clear
				sh_non_v5
			else
				clear
				sh_changer_etat_vm resume $sh_reponse
				sleep 2
				echo "La VM se remet en activitée" 
				sleep 1				
                sh_question_continuer sh_reprise_vm sh_menu_deux
			fi
		done
		exit 0  
		}
		sh_non_v5
		;;


		*)
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
		sh_pause
		sh_reprise_vm
	esac
	sh_pause
}

# Menu qui gére les choix de connexion d'une VM
sh_lire_options_connexion_vm(){
	local sh_choice4
	read -p "Entrez un choix [ a - c ] " sh_choice4
	case $sh_choice4 in
		a) sh_connexion_vm ;;
		b) sh_menus  ;;
		c) exit 0;;
		*) 
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
		sh_pause
        sh_menu_trois
	esac
}

# Fonction qui vérifie les conditions d'une connexion d'une VM
sh_connexion_vm(){
	clear
	sh_vm=$(virsh list --all | cut -c8-37 | sed '1,2d')
	sh_PS3="Votre choix :"
	sh_choix_numero
	select sh_reponse in $sh_vm exit
	do
		if [[ "$sh_reponse" = "exit" ]]; then
            sh_menu_trois
		elif [ -z "${sh_reponse//}" ]; then
			sh_message_erreur "Erreur..." "Le numéro ne fait pas parti des choix"
            sh_pause
			sh_connexion_vm
		else
			clear
			if (sh_comparaison_vm --all $sh_reponse); then
				sh_changer_etat_vm start $sh_reponse
				sh_cmd_connexion $sh_reponse
                echo "sh_cmd_connexion vers la VM $sh_reponse"
			    sleep 1
                sh_question_continuer sh_connexion_vm sh_menu_trois
			else
				sh_cmd_connexion $sh_reponse
				sleep 2
                sh_question_continuer sh_connexion_vm sh_menu_trois
			fi
		fi
	done
	exit 0  
}

# Fonction qui gére la connexion vers une VM
sh_cmd_connexion(){
    virt-viewer -c qemu:///system $1 &>/dev/null &
}

# Menu qui gére les choix de la gestion des snapshots
sh_lire_options_snapshot(){
	local sh_choice6
	read -p "Entrez un choix [ a - c ] " sh_choice6
	case $sh_choice6 in
		a) sh_validite_vm sh_liste_snapshot ;;
		b) sh_validite_vm sh_creer_snapshot ;;
		c) sh_validite_vm sh_supprimer_snapshote ;;
		d) sh_validite_vm sh_revenir_snapshot ;;
		e) sh_menus ;;
		f) exit 0 ;;
		*) 
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
		sh_pause
        sh_menu_cinq
	esac
}

# Fonction qui vérifie la validité d'une VM 
sh_validite_vm(){
	clear
	sh_etat_vm --all
	
	sh_question_vm
	case "$sh_question" in
		o)
		clear
		sh_question_vm2
		if [[ "$sh_reponse" = "exit" ]]; then
			sh_menu_cinq
		elif (sh_comparaison_vm --all $sh_reponse); then
			clear
			$1
			sleep 1
            sh_question_continuer sh_validite_vm sh_menu_quatre
		else
			sh_message_erreur "Erreur..." "La VM n'existe pas"
			sh_pause
			sh_menu_cinq
		fi	
		;;
		

		n)
		clear
		sh_PS3="Votre choix :"
		sh_choix_numero
		select sh_reponse in $sh_vm exit
		do
			if [[ "$sh_reponse" = "exit" ]]; then
				sh_menu_cinq
			elif [ -z "${sh_reponse//}" ]; then
				sh_message_erreur "Erreur..." "Le numéro ne fait pas parti des choix"
				sh_pause
				sh_menu_cinq
			else
				clear
				$1
			fi
		done
		exit 0  
		;;


		*)
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
		sh_pause
		sh_menu_cinq
	esac
}	

# Fonction qui vérifie si la VM a une image de format RAW
sh_verifie_raw(){
	virsh domstats $sh_reponse > xml.txt
	image=$(cat xml.txt | grep path | cut -f2 -d"=")
	qemu-img info $image | grep raw 1>/dev/null
}

# Fonction qui liste les snapshots d'une VM
sh_liste_snapshot(){
	if (sh_verifie_raw); then
		sh_message_erreur "Erreur..." "Impossible d'avoir des snapshots pour une image de format raw"
		sh_pause
		sh_menu_cinq
	else
		echo "Voici la liste des snapshots"
		virsh snapshot-list $sh_reponse | cut -c2-22 | sed '1,2d' > listeSnapshot.txt
		if [[ -z $(cat listeSnapshot.txt) ]]; then
			sh_message_erreur "Erreur..." "Il n'y a aucun snapshot"
			sh_pause
			sh_menu_cinq
		else
   		 	cat listeSnapshot.txt
			$1
			sh_question_continuer sh_liste_snapshot sh_menu_cinq
		fi
	fi
}

# Fonction qui créé un snapshot
sh_creer_snapshot(){
	if (sh_verifie_raw); then
		sh_message_erreur "Erreur..." "Impossible d'avoir des snapshots pour une image de format raw"
		sh_pause
		sh_menu_cinq	
	else
		read -p "Choissisez un nom pour votre snapshot: " nom
		if ( cat listeSnapshot.txt | grep $nom &>/dev/null ); then
		    sh_message_erreur "Erreur..." "La snapshot existe déjà"
			sh_pause
			sh_menu_cinq
		else
		    virsh snapshot-create-as $sh_reponse $nom &>/dev/null
			sleep 1
			echo "Le snapshot $nom a été créé"
			sleep 1
    	    sh_question_continuer sh_creer_snapshot sh_menu_cinq
		fi
	fi
}

# Fonction qui supprime un snapshot
sh_supprimer_snapshote(){
	if (sh_verifie_raw); then
		sh_message_erreur "Erreur..." "Impossible d'avoir des snapshots pour une image de format raw"
		sh_pause
		sh_menu_cinq
	else
		sh_cmd_supprimer_snapshot(){
		read -p "Choissisez le nom de snapshot à supprimer (soyez sûr de supprimer la plus récente pour éviter une défaillance): " nom
		if ( cat listeSnapshot.txt | grep $nom &>/dev/null ); then
		    virsh snapshot-delete $sh_reponse $nom &>/dev/null
			sleep 1
			clear
			echo "Le snapshot $nom a été supprimé"
			sleep 1
    	    		sh_question_continuer sh_creer_snapshot sh_menu_cinq		
		else
		    sh_message_erreur "Erreur..." "La snapshot n'existe pas"
			sh_pause
			sh_menu_cinq
		fi
		}
		sh_liste_snapshot sh_cmd_supprimer_snapshot
	fi
}

# Fonction qui revient à un snapshot
sh_revenir_snapshot(){
	if (sh_verifie_raw); then
		sh_message_erreur "Erreur..." "Impossible d'avoir des snapshots pour une image de format raw"
		sh_pause
		sh_menu_cinq
	else
		sh_cmd_revenir_snapshot(){
		read -p "Choissisez le nom de snapshot à revenir: " nom
		if ( cat listeSnapshot.txt | grep $nom &>/dev/null ); then
		    virsh snapshot-revert $sh_reponse $nom &>/dev/null
			sleep 1
			clear
			echo "Vous êtes revenu au snapshot $nom "
			sleep 1
    	    		sh_question_continuer sh_creer_snapshot sh_menu_cinq		
		else
		   	sh_message_erreur "Erreur..." "La snapshot n'existe pas"
			sh_pause
			sh_menu_cinq
		fi
		}
		sh_liste_snapshot sh_cmd_revenir_snapshot
	fi
}

# Menu qui gére les choix de gestion de création & supression des VM
sh_lire_options_gestion_vm(){ 
	local sh_choice7
	read -p "Entrez un choix [ a - d ] " sh_choice7
	case $sh_choice7 in
		a) sh_creer_vm ;;
		b) sh_supprimer_vm ;;
		c) sh_menus  ;;
		d) exit 0;;
		*) 
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
		sh_pause
        sh_menu_six
	esac
}

# Fonction qui vérifie la validité d'un fichier
sh_verification_fichier(){
	if ( test -f $sh_fichier); then
		clear
		echo "Le fichier est valide"
	elif [[ "$sh_fichier" = "exit" ]]; then
		$1
	else
		sh_message_erreur "Erreur..." "Le fichier n'existe pas"
		sh_pause
		$1
	fi
}

# Fonction qui vérifie si il y a un nom pour la VM
sh_verification_vm(){
	clear
	read -p "Choissisez le nom de VM ou exit pour sortir: " sh_vm
	if [ -z "$sh_vm" ]; then
	    sh_message_erreur "Erreur..." "Le choix est vide"
		sh_pause
		$1
	elif [[ "$sh_vm" = "exit" ]]; then
		$1
	else
		clear
	    echo "Le choix de VM est valide"
	fi
}

# Fonction qui créé une VM
sh_creer_vm(){
	sh_verification_vm sh_menu_six

	# Chemin de l'ISO
	clear
	read -ep "Choissisez l'emplacement de l'iso ou exit pour sortir: " sh_fichier
	sh_verification_fichier sh_menu_six

	mkdir /home/VM/$sh_vm

	# installation via l'ISO
	clear
	virt-install \
	--virt-type kvm \
	--name=$sh_vm \
	--disk path=/home/VM/$sh_vm/$sh_vm.img,size=8 \
	--ram=1024 \
	--vcpus=1 \
	--os-variant=rhel7 \
	--graphics vnc \
	--console pty,target_type=serial \
	--cdrom $sh_fichier

	sh_question_continuer sh_creer_vm sh_menu_six
}

# Fonction qui supprime une VM
sh_supprimer_vm(){
	sh_verification_vm sh_menu_six

	# Stopper & supprimer la VM
	/bin/virsh destroy $sh_vm; /bin/virsh undefine $sh_vm --remove-all-storage

	sh_question_continuer sh_supprimer_vm sh_menu_six
}

# Menu qui gére les choix de gestion de réseaux
sh_lire_options_reseau(){ 
	local sh_choice8
	read -p "Entrez un choix [ a - f ] " sh_choice8
	case $sh_choice8 in
		a) sh_menus_A ;;
		b) sh_choix_vm sh_attacher_reseau;;
		c) sh_detacher_reseau;;
		d) sh_supprimer_reseau ;;
		e) sh_menus  ;;
		f) exit 0;;
		*) 
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
		sh_pause
        sh_menu_sept
	esac
}

# Menu qui gére les réseaux virtuels
sh_menus_A(){
	bash fichierA.sh
	sh_choix
}

# Menu qui gére les choix des réseaux
sh_choix(){
	local sh_choice_A  
	read -p "Entrez un choix [ a - d ] " sh_choice_A
	case $sh_choice_A in 
		a) sh_nat ;;
		b) sh_routed ;;
		c) sh_isole ;;
		d) sh_menu_sept ;;
		*)
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
		sh_pause
        sh_menu_sept
	esac	
}

# Fonction qui définis une expression régulière
sh_condition_regex(){
	# Expression régulière qui valide un format IP raisonnable et standard (ex: 192.168.206.5)
	regex='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
	if [[ $1 =~ $regex ]]; then
		sed -i -e "s/IP/${1}/g" $1.xml &>/dev/null
	else
		sh_message_erreur "Erreur..." "L'adresse ne fait pas parti des critères"
		sh_pause
		$2
	fi
}

# Fonction qui définis une condition d'un réseau
sh_condition_definir(){
	if (virsh net-list --all| grep $nom &>/dev/null); then
		echo "Le réseau n'est pas valide"
	else 
		echo "Le réseau est valide"
		sh_condition_interface
		$1
	fi
}

# Fonction qui définis une condition d'une interface
sh_condition_interface(){
	if (ip a | grep $int &>/dev/null); then
		echo "L'interface n'est pas valide"
	else 
		echo "L'interface est valide"
		$1
	fi
}

# Fonction qui gére le réseau NAT
sh_nat(){
	read -p "Veuillez choisir le nom de votre réseau : " nom
	cp NAT.xml $nom.xml
	sed -i -e "s/sh_nat/${nom}/g" $nom.xml &>/dev/null

	read -p "Veuillez écrire le type de réseau: " type 
	sed -i -e "s/TYPE/${type}/g" $nom.xml &>/dev/null

	read -p "Veuillez écrire l'interface utilisé: " int 
	sed -i -e "s/VIRBR/${int}/g" $nom.xml &>/dev/null

	read -p "Veuillez écrire l'adresse IP: " ip
	sh_condition_regex $ip sh_menus_A
	sed -i -e "s/IP/${ip}/g" $nom.xml &>/dev/null

	read -p "Veuillez écrire le masque de sous réseau: " masque
	sh_condition_regex $masque sh_menus_A
	sed -i -e "s/MASK/${masque}/g" $nom.xml &>/dev/null

	sh_condition_definir "virsh net-define $nom.xml "

	virsh net-start $nom &>/dev/null

	virsh net-autostart $nom &>/dev/null
	
	sh_question_continuer $2 sh_menu_sept
}

# Fonction qui gére le réseau ROUTED
sh_routed(){
	sh_nat sh_routed 
}
# Fonction qui gére le réseau ISOLE
sh_isole(){
	read -p "Veuillez choisir le nom de votre réseau : " nom
	cp ISOLE.xml $nom.xml
	sed -i -e "s/ISOLE/${nom}/g" $nom.xml &>/dev/null

	read -p "Veuillez écrire l'interface utilisé: " int 
	sed -i -e "s/VIRBR/${int}/g" $nom.xml &>/dev/null

	read -p "Veuillez écrire l'adresse IP: " ip
	sh_condition_regex $ip sh_menus_A
	sed -i -e "s/IP/${ip}/g" $nom.xml &>/dev/null

	read -p "Veuillez écrire le masque de sous réseau: " masque
	sh_condition_regex $masque sh_menus_A
	sed -i -e "s/MASK/${masque}/g" $nom.xml &>/dev/null

	sh_condition_definir "virsh net-define $nom.xml "

	virsh net-start $nom &>/dev/null

	virsh net-autostart $nom &>/dev/null
	
	sh_question_continuer sh_isole sh_menu_sept
}

# Fonction qui gère les choix d'une VM
sh_choix_vm(){
	sh_etat_vm --all
	sh_PS3="Votre choix :"
	sh_choix_numero
	select sh_reponse in $sh_vm exit
	do
		if [[ "$sh_reponse" = "exit" ]]; then
			sh_menu_sept
		elif [ -z "${sh_reponse//}" ]; then
			sh_message_erreur "Erreur..." "Le numéro ne fait pas parti des choix"
				sh_pause
				onev9
		else
			clear
			$1
		fi
	done
	exit 0
}

# Fonction qui attache un réseau
sh_attacher_reseau(){
	clear
	sh_reseau_vm
	sh_PS3="Votre choix : "
	sh_choix_numero
	select sh_reponse2 in $sh_reseau_list exit
	do
		if [[ "$sh_reponse2" = "exit" ]]; then
			sh_menu_sept
		elif [ -z "${sh_reponse2//}" ]; then
			sh_message_erreur "Erreur..." "Le numéro ne fait pas parti des choix"
			sh_pause
			sh_choix_vm
		else
			virsh attach-interface $sh_reponse network $sh_reponse2 --model virtio --config
			sleep 1
            sh_question_continuer sh_pause sh_menu_sept
		fi
	done
}

# Fonction qui détache un réseau
sh_detacher_reseau(){
	clear
	sh_etat_vm --all
	echo "Veuillez choisir la VM" 
	select sh_reponse in $sh_vm
		do
		sh_reseau=$(virsh domiflist $sh_reponse | sed 1d | awk '{print $3}' | sed '1d ; $d')
		echo "Veuillez choisir le réseau" 
		select sh_reponse2 in $sh_reseau
		do
			sh_mac=$(virsh domiflist $sh_reponse | grep $sh_reponse2 | awk '{print $5}')
			virsh detach-interface $sh_reponse network --mac $sh_mac --config
			sh_question_continuer sh_detacher_reseau sh_menu_sept
		done 
	done
}

# Fonction qui supprime un réseau
sh_supprimer_reseau(){
	clear
	sh_reseau_vm
	sh_PS3="Votre choix :"
	sh_choix_numero
	select sh_reponse in $sh_reseau exit
	do
	if [[ "$sh_reponse" = "exit" ]]; then
		sh_menu_sept
	elif [ -z "${sh_reponse//}" ]; then
		sh_message_erreur "Erreur..." "Le numéro ne fait pas parti des choix"
		sh_pause
		sh_choix_vm
	else
		virsh net-destroy $sh_reponse
		sleep 1
		virsh net-undefine $sh_reponse
		sleep 1
        sh_question_continuer sh_choix_vm sh_menu_sept
	fi
	done
}