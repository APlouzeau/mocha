# Script PowerShell pour générer une clé JWT aléatoire
# Fonctionne sur Windows, Linux et macOS (avec PowerShell Core)

# Générer 32 octets aléatoires et les convertir en Base64
$bytes = New-Object byte[] 32
[System.Security.Cryptography.RandomNumberGenerator]::Fill($bytes)
$key = [Convert]::ToBase64String($bytes)

# Afficher la clé
Write-Output $key

