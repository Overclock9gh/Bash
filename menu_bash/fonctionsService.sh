# ---------------------------------------------
# Définition des fonctions en lien les services
# ---------------------------------------------
# Menu qui gére les choix de gestion de service
sh_lire_options_service(){ 
	local sh_choice9
	read -p "Entrez un choix [ a - f ] " sh_choice9
	case $sh_choice9 in
		a) sh_etat_service status sh_etat_service ;;
		b) sh_installer_service install sh_installer_service ;;
		c) sh_demarrer_service ;;
		d) sh_arreter_service ;;
		e) sh_desinstaller_service ;;
		f) sh_afficher_menus  ;;
		g) exit 0 ;;
		*) 
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
		sh_pause
        sh_menu_huit
	esac
}

# Fonction qui demande le choix du service
sh_question_service(){
	read -p "Choissisez un service: " sh_service
}

# Fonction qui vérifie l'état d'un service
sh_etat_service(){
	sh_question_service
	sudo systemctl $1 $sh_service
	sh_question_continuer $2 sh_menu_huit
}

# Fonction qui installe un service
sh_installer_service(){
	sh_question_service
	sudo yum -y $1 $sh_service
	sh_question_continuer $2 sh_menu_huit
}

# Fonction qui démarre un service
sh_demarrer_service(){
	sh_etat_service enable sh_demarrer_service
	sh_etat_service start sh_demarrer_service
}

# Fonction qui stoppe un service
sh_arreter_service(){
	sh_etat_service stop sh_arreter_service
}

# Fonction qui désinstalle un service
sh_desinstaller_service(){
	sh_installer_service remove sh_installer_service
}

# Menu qui lie les options des interfaces réseaux
sh_lire_options_interface_reseau(){ 
	local sh_choice10
	read -p "Entrez un choix [ a - f ] " sh_choice10
	case $sh_choice10 in
		a) sh_afficher_interface ;;
		b) sh_choix_interface ;;
		c) sh_redemarrer_reseau ;;
		d) sh_attribuer_addresse ;;
		e) sh_attribuer_passerelle ;;
		f) sh_ajouter_route ;;
		g) sh_afficher_table_routage ;;
		h) sh_afficher_chemin_route ;;
		i) sh_menus  ;;
		j) exit 0;;
		*) 
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
		sh_pause
        sh_menu_neuf
	esac
}

# Fonction qui affiche les interfaces
sh_afficher_interface(){
	nmcli device status
	sh_pause
	sh_menu_neuf
}

# Fonction qui gère les interfaces
sh_gestion_interface(){
	read -p "Voulez-vous activer ou désactiver l'interface a/d: " sh_reponse
	if [[ "$sh_reponse" = "a" ]]; then 
		ifup $sh_int 
	elif [[ "$sh_reponse" = "d" ]]; then
		ifdown $sh_int
	else
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
	fi 
}

# Fonction qui gère le choix des interfaces
sh_choix_interface(){
	read -ep "Veuillez écrire le nom de l'interface: " sh_int
	if (ip a | grep $sh_int &>/dev/null); then
		sh_gestion_interface
		sh_question_continuer sh_choix_interface sh_menu_neuf
	else
		sh_message_erreur "Erreur..." "L'interface n'est pas présente"
		sh_pause
		sh_menu_neuf
	fi
}

# Fonction qui redémarre le réseau
sh_redemarrer_reseau(){
	echo "Le réseau est en train de redémarrer"
	systemctl restart network
	sh_pause
	sh_menu_neuf
}

# Fonction qui attribue une adresse IP & masque de sous-réseaux
sh_attribuer_addresse(){
	read -ep "Veuillez écrire le chemin de l'interface: " sh_fichier
	sh_verification_fichier sh_menu_neuf
	sudo sed -i -e "s/^BOOTPROTO=.*$/BOOTPROTO=static/" $sh_fichier &>/dev/null
	if grep -q 'IPADDR\|NETMASK' $sh_fichier ; then
		read -p "Veuillez écrire l'adresse IP: " ip 
		sh_condition_regex $ip sh_attribuer_addresse
		sudo sed -i -e "s/^IPADDR=.*$/IPADDR=${sh_ip}/" $sh_fichier &>/dev/null
		read -p "Veuillez écrire le masque de sous réseau: " sh_mask 
		sh_condition_regex $sh_mask sh_attribuer_addresse
		sudo sed -i -e "s/^NETMASK=.*$/NETMASK=${sh_mask}/" $sh_fichier &>/dev/null
		sh_question_continuer sh_choix_interface sh_menu_neuf
	else
		read -p "Veuillez écrire l'adresse IP: " sh_ip 
		sh_condition_regex $ip sh_attribuer_addresse
		echo "IPADDR=$sh_ip" >> $sh_fichier 
		read -p "Veuillez écrire le masque de sous réseau: " sh_mask 
		sh_condition_regex $sh_mask sh_attribuer_addresse
		echo "NETMASK=$sh_mask" >> $sh_fichier 
		sh_question_continuer sh_attribuer_addresse sh_menu_neuf
	fi
}

# Fonction qui attribue une passerelle par défaut 
sh_attribuer_passerelle(){
	read -p "Veuillez écrire l'adresse de la passerelle par défaut: " sh_gateway
	sh_condition_regex $sh_gateway sh_attribuer_addresse
	if grep -q 'GATEWAY' /etc/sysconfig/network ; then
		sudo sed -i -e "s/^GATEWAY=.*$/GATEWAY=${gateway}/" /etc/sysconfig/network &>/dev/null
	else
		echo "GATEWAY=$sh_gateway" >> /etc/sysconfig/network 
	fi
	sh_question_continuer sh_attribuer_addresse sh_menu_neuf
}

# Fonction qui attribue une condition à un préfixe d'adresse IP
sh_condition_prefix(){
	if [[ $prefixe -ge 1 && $prefixe -le 32 ]]; then
		echo ""
	else
		sh_message_erreur "Erreur..." "Le préfixe n'est pas valide"
		sh_pause
		sh_ajouter_route
	fi
}

# Fonction qui ajoute une route
sh_ajouter_route(){
	read -p "Veuillez écrire l'adresse du réseau à ajouter: " reseau
	sh_condition_regex $reseau sh_ajouter_route
	read -p "Veuillez écrire le nombre du préfixe du réseau: " prefixe
	sh_condition_prefix 
	read -p "Veuillez écrire l'adresse qui mène à ce réseau: " route
	sh_condition_regex $route sh_ajouter_route
	ip route add $reseau"/"$prefixe via $route
	echo "ip route add $reseau/$prefixe via $route"
	sh_question_continuer sh_ajouter_route sh_menu_neuf
}

# Fonctionqui affiche la table de routage
sh_afficher_table_routage(){
	ip route
	sh_pause 
	sh_menu_neuf
}

# Fonction qui affiche le chemin vers un réseau
sh_afficher_chemin_route(){
	read -p "Veuillez écrire l'adresse à tracer le chemin: " adresse
	sh_condition_regex $adresse sh_afficher_chemin_route
	tracepath $adresse
	sh_pause 
	sh_menu_neuf
}