# ------------------------------------------------------  
# Inclusion des fichiers contenant des fonctions & alias
# ------------------------------------------------------ 
source ./fonctionsVirsh.sh
source ./fonctionsACL.sh
source ./fonctionsService.sh

alias virsh="sudo virsh -c qemu:///system"
alias listUser="cat /etc/passwd | cut -d ":" -f 1"