# Developed 2020-02-10 by Gabe Miller
# Installs all the requirements for PFHA System

# Download chocolatey 
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Programs
# Would be nice to try and get these to install to the d drive, but it is rather difficult
choco install 7zip -y 
choco install TotalCommander -y 
choco install git -y 
choco install TortoiseGit -y 
choco install SublimeText3 -y 
choco install sublimemerge -y
choco install PyCharm-community -y
choco install miniconda3 -y
choco install robo3t -y
choco install winscp -y
choco install vcredist2017 -y

# Fortran Compiler
Invoke-WebRequest "https://software.intel.com/sites/default/files/managed/4a/11/ww_ifort_redist_msi_2020.0.166.zip" -OutFile $env:temp\ww_ifort_redist_msi_2020.zip
Expand-Archive -LiteralPath $env:temp\ww_ifort_redist_msi_2020.zip -DestinationPath $env:temp
Start-Process -Wait $env:temp\ww_ifort_redist_intel64_2020.0.166.msi /quiet

# IIS Install
Set-ExecutionPolicy Bypass -Scope Process
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering
Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication
Enable-WindowsOptionalFeature -online -FeatureName NetFx4Extended-ASPNET45
Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CGI
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets

# Install Platmorm hanlder after IIS
choco install httpPlatformHandler -y

# Git Install
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
mkdir D:\Apps
set-location D:\Apps
$gitpass = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String('RABvAG0AaQBuAG8AMQAhAA=='))
git clone https://gamille0:$gitpass@tvaitlab.visualstudio.com/RM/_git/PFHA D:/Apps/PFHA_APP -b develop

# Setup miniconda enviornment
C:\tools\miniconda3\shell\condabin\conda-hook.ps1
conda activate 'C:\tools\miniconda3'
conda config --set ssl_verify false
conda env create -p C:\tools\miniconda3\envs\PFHA\ -f D:\Apps\PFHA_App\environment.yml
conda activate base
set-location D:\Apps\PFHA_APP
python d:\Apps\PFHA_APP\setup.py install

#Setup Website
Import-Module WebAdministration
Stop-IISSite -Name "Default Web Site" -confirm:$False
New-Website -Name "PFHA" -Port 80 -IPAddress "*" -HostHeader "" -PhysicalPath "D:\Apps\PFHA_APP\interface"
New-Item -Type Application -Path "IIS:\Sites\PFHA\API" -physicalPath "D:\Apps\PFHA_APP\framework\web_service"

# Folder permissions
$acl = Get-Acl D:\Apps
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("TVA\ITWSA-PFHA Admins","Write","Allow")
$acl.SetAccessRule($AccessRule)
$acl.SetAccessRuleProtection($false,$true)
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("TVA\FLD_RW_PFHA_ADMINS","Write","Allow")
$acl.SetAccessRule($AccessRule)
$acl | Set-Acl D:\Apps
New-SMBShare -Name Apps -Path D:\Apps -ChangeAccess 'TVA\FLD_RW_PFHA_ADMINS'

# Fix miniconda permissions
$acl = Get-Acl C:\tools
$AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("TVA\ITWSA-PFHA Admins","FullControl","Allow")
$acl.SetAccessRule($AccessRule)
$acl.SetAccessRuleProtection($false,$true)
$acl | Set-Acl C:\tools


