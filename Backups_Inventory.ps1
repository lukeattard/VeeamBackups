#########################################################################################
#  Author: Laurent MESSIER
# Last modification: 07/09/2022
#
#  Use :
#
# Enter the $output_csv variable to designate the extraction output file
# Enter the $comment variable: ex. “Veeam OnPrime”
#
# Run the script from the Veeam server
#
#########################################################################################

Param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]$Output_Csv

	)

$comment = "Veeam Azure"


#language recovery
$culture = Get-Culture

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
    
    #Traitement si dates US en format d'heure AM/PM

        #Convertion de la valeur en String
        $date_us = $increment.CreationTime
        $date_us = $date_us.ToString()
        
        #Decoupage avec le delimiteur " "
        $split_result = $date_us.Split(" ")


    #Test si format US
    if ($split_result[2] -like "AM" -or $split_result[2] -like "PM") {
        #Convertion de la valeur en String
        $date_us = $increment.CreationTime
        $date_us = $date_us.ToString()
        
        #Decoupage avec le delimiteur " "
        $split_result = $date_us.Split(" ")
        
        #Tranformation de l'heure en format classique (sans AM ou PM)
        $time =  $split_result[1] + " " + $split_result[2]
        $time = ([dateTime]$time.Split('-')[0]).ToString('HH:mm:ss')

        #Transformation de la date en format FR
        $date_fr = ([dateTime]$split_result[0]).ToString('dd/MM/yyyy')
        
        #Nouvelle date en format FR et 24H
        $new_date = $date_fr + " " + $time
    
    #Date convertie en format 24H
    $col3=$new_date
    }
    else {
        #Recupération de la date de Backup
        $col3 = $increment.CreationTime
    }
    
    
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
    
    #Added comment
    $col6 = $comment

    #insertion de la ligne dans le tableau
    $backuplist += [pscustomobject]@{Backup_Job=$col1;VM_Name=$col2;CreationTime=$col3;Type=$col4;Status=$col5;Storage=$col6}
    }
}

English

#Export of the table in CSV
$backuplist | Sort-Object -Property VM_Name, CreationTime | Export-Csv -Path $output_csv -NoTypeInformation -Force
