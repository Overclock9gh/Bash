#!/bin/bash  
#****************************************************************
#Auteur: Saïd Hamdane
#Date: 15 décembre 2019
#
#Objectif: Le script permet d'utiliser plusieurs fonctionnalitées 
#pour la gestion de VM, ACL & service
#****************************************************************
# -------------------------------------
# Inclusion du fichier d'initialisation
# -------------------------------------
if (cat /etc/profile | grep "menu1.sh=" &>/dev/null); then
	continue
else
	echo "alias said='bash $HOME/Said_Hamdane_Menu_Bash_TP2_3B7/menu1.sh'" >> /etc/profile
fi
# ------------------------
# Définition des variables 
# ------------------------
# Variables qui gérent le début & la fin d'un texte de couleur pour des messages spécifiques
sh_RED='\033[0;41;30m'
sh_YEL='\033[0;43;30m'
sh_BLU='\e[1;34m'
sh_RED2='\033[1;31m'
sh_YEL2='\033[0;33m'
sh_STD='\033[0;0;39m'
sh_STD2='\033[0m'

# ----------------------------------------------- 
# Inclusion des autres fichiers fonctions & alias
# ----------------------------------------------- 
source ./fonctionsInclude.sh
shopt -s expand_aliases

# ------------------------------------------  
# Définition des fonctions du menu principal
# ------------------------------------------   
# Menu qui affiche les VM
sh_menu_un(){     
	bash fichierOne.sh 
	sh_lire_options_affichage_vm
}  

# Menu qui gére le démarrage et l’arrêt de VMs
sh_menu_deux(){        
	bash fichierTwo.sh
	sh_lire_options_etat_vm
}  

# Menu qui se connecte à une VM
sh_menu_trois(){  
    bash fichierThree.sh
	sh_lire_options_connexion_vm
}

# Menu qui gére le système de fichiers (ACL)
sh_menu_quatre(){  
	bash fichierFour.sh
	sh_lire_options_acl
}

# Menu qui gére les snapshots et clones
sh_menu_cinq(){
	bash fichierFive.sh
	sh_lire_options_snapshot
}
	
# Menu qui crée/supprime une machine virtuelle
sh_menu_six(){
	bash fichierSix.sh
	sh_lire_options_gestion_vm
}

# Menu qui gére les réseaux virtuels
sh_menu_sept(){
	bash fichierSeven.sh
	sh_lire_options_reseau
}

# Menu qui gére les services Linux
sh_menu_huit(){
	bash fichierEight.sh
	sh_lire_options_service	
}

# Menu qui configure le réseau
sh_menu_neuf(){
	bash fichierNine.sh
	sh_lire_options_interface_reseau
}

# Menu qui affiche le menu principal
sh_afficher_menus() {     
	clear  

	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "Bienvenu au script !, "
	echo "ce programme vous aidera à gérer beacoup de fonctionnalités sur la gestion de VM, ACL et services."
	echo "L'outil a été faite par l'étudiant Saïd Hamdane pour le cours"
	echo "3B7-Services réseaux Linux enseigné par l'enseignant Abdelhabib Yahia."
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"     
	echo " M E N U - P R I N C I P A L "     
	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"     
	echo "1. Afficher la liste des VMs"     
	echo "2. Gérer le démarrage et l’arrêt de VMs"     
	echo "3. Se connecter à une VM."
	echo "4. Gérer le système de fichiers (ACL)"
	echo "5. Gérer les snapshots et clones"
	echo "6. Créer/supprimer une machine virtuelle"
    echo "7. Gérer les réseaux virtuel"
	echo "8. Gestion de services Linux"
	echo "9. Configuration réseau"
	echo "10. Quitter le programme"  
}

# lit les entrées du clavier et passe à l'action 
# invoque la première fonction lorsque l'utilisateur sélectionne 1 dans l'option de menu. 
# invoque la deuxième fonction lorsque l'utilisateur sélectionne 1 dans l'option de menu. 
# Ainsi de suite pour chaque fonction précédemmment créé.
# Quitte lorsque l'utilisateur sélectionne 10 dans l'option de menu.

sh_lire_options(){          
	local sh_choice   
	read -p "Entrez un choix [ 1 - 10 ] " sh_choice 
	case $sh_choice in  
		1) sh_menu_un ;;  
		2) sh_menu_deux ;;
		3) sh_menu_trois ;; 
		4) sh_menu_quatre ;; 
		5) sh_menu_cinq ;;
		6) sh_menu_six ;;
		7) sh_menu_sept ;;
		8) sh_menu_huit ;;
		9) sh_menu_neuf ;;
		10) exit 0 ;;  
		*)
		sh_message_erreur "Erreur..." "Le choix n'est pas valide"
		sh_pause
		sh_afficher_menus
		sh_lire_options
	esac  
} 

# -----------------------------------------
# Une boucle infinie pour le menu principal
# ------------------------------------ ----
while true 
do 
	sh_afficher_menus 
	sh_lire_options 
done  
