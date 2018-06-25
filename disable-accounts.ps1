<#
.SYNOPSIS

Opkuisen van Active Directory

.DESCRIPTION

Kijkt in bepaalde OU's voor niet gebruikte accounts (60 dagen users en 90 dagen computers) en disabled deze

Belangrijk: accounts eindigend op "cursist" worden niet meegerekend, zoals template users. Alsook zij die geen logondate hebben (nog niet aangemeld)


.EXAMPLE

C:\PS> disable-useraccounts.ps1

Kijkt automatisch in de desbetreffende OU's. Aanpassingen moeten in het script zelf gebruiken.

.LINK

kenvdb@gmail.com

#>

# OU's waar hij gaat kijken in deze arrays

$UserArray=@("ou=members, ou=users, ou=OurOffice, dc=labo, dc=test","ou=other, ou=users, ou=OurOffice, dc=labo, dc=test")
$ComputerArray=@("ou=members, ou=computers, ou=OurOffice, dc=labo, dc=test", "ou=other, ou=computers, ou=OurOffice, dc=labo, dc=test")

#Ou's waarnaar verplaatst wordt na het disablen.

$UserTargetPath="ou=disabled, ou=users, ou=OurOffice, dc=labo, dc=test"
$ComputerTargetPath="ou=disabled, ou=computers, ou=OurOffice, dc=labo, dc=test"

# 2 loops: 1 voor useraccounts en 1 voor computers. Alles wordt in 1 lijn gedaan.

    ForEach($User in $UserArray)
    {
       $log = Search-ADAccount -AccountInactive -TimeSpan 60.00:00:00 -SearchBase $User | where{$_.name -notlike "*cursist" -and $_.lastLogonDate -ne $null}| Disable-ADAccount -PassThru | ForEach-Object {Move-ADObject -Identity $_.DistinguishedName  -TargetPath $UserTargetPath -PassThru} | select name,objectclass
       $log  | export-csv F:\DisabledAccountslogs\DisabledUserAccounts.csv -Append -NoTypeInformation
    }

    ForEach($Computer in $ComputerArray)
    {
       $log = Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00 -SearchBase $Computer | Disable-ADAccount -PassThru | ForEach-Object {Move-ADObject -Identity $_.DistinguishedName  -TargetPath $ComputerTargetPath -PassThru} | select name,objectclass
       $log  | export-csv F:\DisabledAccountslogs\DisabledComputerAccounts.csv -Append -NoTypeInformation
    }
