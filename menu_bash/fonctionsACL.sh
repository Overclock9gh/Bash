# -------------------------------------------  
# Définition des fonctions en lien avec ACL
# ------------------------------------------- 
# Menu qui gère les choix de gestion de système de fichier(ACL) 
sh_lire_options_acl(){
	local choice5
	read -p "Entrez un choix [ a - e ] " choice5
	case $choice5 in
		a) sh_verification sh_afficher_acl ;;
		b) sh_u="u"; sh_verification sh_modification_acl_utilisateur;;
		c) sh_u="g"; sh_verification sh_modification_acl_utilisateur_groupe ;;
		d) sh_afficher_menus  ;;
		e) exit 0;;
		*) 
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
		sh_pause
		sh_menu_quatre
	esac
}

# Fonction qui vérifie la validité d'un fichier ou répertoire 
sh_verification(){
	clear
	read -ep "Veuillez écrire le chemin d'un fichier ou exit pour sortir: " sh_fichier
	if (test -e $sh_fichier); then
		clear
		$1
		sh_question_continuer sh_afficher_acl sh_menu_quatre
	elif [[ "$sh_fichier" = "exit" ]]; then
		sh_menu_quatre
	else
		sh_message_erreur "Erreur..." "Le fichier ou répertoire n'existe pas"
		sh_pause
		sh_verification
	fi
}

# Fonction qui affiche les ACL
sh_afficher_acl(){
	getfacl $sh_fichier
}

# Fonction qui modifie les ACL d'un utilisateur
sh_modification_acl_utilisateur(){
	clear
	read -p "Veuillez écrire le nom d'un utilisateur ou faire exit pour sortir: " sh_user
	if [[ "$sh_user" = "exit" ]]; then
		sh_menu_quatre
	elif (cat /etc/passwd | cut -d ":" -f 1 | grep $sh_user  > /dev/null); then
		clear
		echo "L'utilisateur est valide"
	else
		echo "L'utilisateur $sh_user a été créé"
		adduser -m $sh_user 
	fi
	sleep 2
	PS3="Votre choix:"
	echo "Choissisez une permission à mettre"
	select sh_permission in "r--" "-w-" "--x" "rw-" "r-x" "-wx" "rwx" exit
	do
		if [[ "$sh_permission" = "exit" ]]; then
			sh_menu_quatre
		elif [ -z "${sh_permission//}" ]; then
			sh_message_erreur "Erreur..." "Le numéro ne fait pas parti des choix"
			sh_pause
			sh_modification_acl_utilisateur
		fi
		setfacl -m "$sh_u:$sh_user:$sh_permission" $sh_fichier
		echo "L'utilisateur $sh_user a eu les permission $sh_permission"
		sh_question_continuer sh_modification_acl_utilisateur sh_menu_quatre
	done
	exit 0
}

# Fonction qui modifie les ACL d'un groupe
sh_modification_acl_utilisateur_groupe(){
	sh_modification_acl_utilisateur 
}
