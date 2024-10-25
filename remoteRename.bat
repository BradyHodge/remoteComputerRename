@echo off
setlocal EnableDelayedExpansion

echo Rename a computer remotely and then force restart it.
echo.
echo Made by Brady Hodge
echo V 1.6.5
echo.

:getOldName
set /p oldName="Enter the current computer name: "
if "!oldName!"=="" (
    echo Computer name cannot be empty
    goto getOldName
)

:getNewName
set /p newName="Enter the new computer name: "
if "!newName!"=="" (
    echo New computer name cannot be empty
    goto getNewName
)

:getDomainAdmin
set /p domainAdmin="Enter domain admin username: "
if "!domainAdmin!"=="" (
    echo Domain admin username cannot be empty
    goto getDomainAdmin
)

echo.
echo Please confirm the following details:
echo Current Computer Name: !oldName!
echo New Computer Name: !newName!
echo Domain Admin: !domainAdmin!
echo.

:confirm
set /p confirm="Is this correct? (Y/N): "
if /i "!confirm!"=="Y" (
    goto execute
) else if /i "!confirm!"=="N" (
    echo.
    echo Let's start over.
    echo.
    goto getOldName
) else (
    echo Please enter Y or N
    goto confirm
)

:execute
powershell -Command "$securePass = Read-Host -AsSecureString 'Enter domain admin password'; $cred = New-Object System.Management.Automation.PSCredential ('!domainAdmin!', $securePass); Rename-Computer -ComputerName '!oldName!' -NewName '!newName!' -Force -PassThru -DomainCredential $cred -Restart"
if errorlevel 1 (
    echo An error occurred while executing the command.
) else (
    echo Computer rename initiated successfully.
    echo The computer will restart automatically.
)

pause