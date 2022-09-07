#########################################################################################
#  Auteur :                  Laurent MESSIER
#  Dernière modification :   07/09/2022
#
#  Utilisation :
#
#  Renseigner la variable $output_csv pour designer le fichier de sortie de l'extraction
#  Renseigner la variable $commentaire : ex. "Veeam OnPrime"
#
#  Lancer le script depuis le serveur Veeam
#
#########################################################################################


#Emplacement de sauvegarde du CSV Final:
$output_csv = 'c:\Veeam_backup\Listing.csv'
$commentaire = "First Veeam Backup Server"


#Recuperation des backups
$backups = Get-VBRBackup

#Initialisation du tableau contenant les valeurs
$backuplist = @()

#Boucle de traitement des données pour chaque Backup
foreach ($backup in $backups) {
   
   #Listing des points de restauration
   $restorePoints = Get-VBRRestorePoint -Backup $backup
   
   #Traitement de tous les points de restauration du Backup en cours
   foreach($increment in $restorePoints) {
    #Recupération du nom du backup
    $col1 = $backup.Name

    #Recupération du nom du Serveur / VM
    $col2 = $increment.Name
    
    #Recupération de la date de Backup
    $col3 = $increment.CreationTime
    
    #Recupération du type de backup
    $col4 = $increment.Type
    
    #Statut du backup
    if ($increment.IsConsistent -eq "True")
        {
            $col5 = "OK"
        }
    else
        {
            $col5 = "KO"
        }
    
    #Ajout du commentaire
    $col6 = $commentaire

    #insertion de la ligne dans le tableau
    $backuplist += [pscustomobject]@{Backup_Job=$col1;VM_Name=$col2;CreationTime=$col3;Type=$col4;Status=$col5;Storage=$col6}
    }
}

#Export du tableau en CSV
$backuplist | Sort-Object -Property VM_Name, CreationTime | Export-Csv -Path $output_csv -NoTypeInformation -Force
