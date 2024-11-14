@echo off
setlocal EnableDelayedExpansion
:start
echo.
echo ==============================================
echo Rename a computer remotely and force restart
echo Brady Hodge
echo V 1.8.2
echo ==============================================
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
set /p guruUser="Enter your guru username: "
if "!guruUser!"=="" (
    echo Domain admin username cannot be empty
    goto getDomainAdmin
)
set domain=byui
set domainAdmin=!domain!\!guruUser!

:confirmComputerInfo
echo.
echo Please confirm the following details:
echo Current Computer Name: !oldName!
echo New Computer Name: !newName!
echo Domain Admin: !domainAdmin!
echo.
set /p confirm="Is this correct? (Y/N): "
if /i "!confirm!"=="Y" (
    goto checkName
) else if /i "!confirm!"=="N" (
    goto start
) else (
    echo Please enter Y or N
    goto confirmComputerInfo
)

:checkName
where dsquery >nul 2>&1
if %errorlevel% NEQ 0 (
    echo RSAT is not installed on this computer.
    echo Make sure to manually check that the name !newName! is not already in use.
    goto checkHost
)

for /f "tokens=*" %%A in ('dsquery computer -name "!newName!" 2^>nul') do (
    set "adResult=%%A"
)

if defined adResult (
    echo The computer "!newName!" is already in active directory.
    :askIgnoreADCheck
    set /p ignoreADCheck="Would you like to continue anyway? (Y/N): "
    if /i "!ignoreADCheck!" == "N" (
        goto confirmComputerInfo
    ) else if /i "!ignoreADCheck!" == "Y" (
        goto checkHost
    ) else (
        echo Please enter Y or N
        goto askIgnoreADCheck
    )
) else (
    goto checkHost
)


:checkHost
ping -n 1 !oldName! >nul
if not !errorlevel! EQU 0 (
    echo Remote computer is not responding.
    :askIgnorePing
    set /p ignorePing="Would you like to continue anyway? (Y/N): "
    if /i "!ignorePing!" == "N" (
        goto confirmComputerInfo
    ) else if /i "!ignorePing!" == "Y" (
        goto execute
    ) else (
        echo Please enter Y or N
        goto askIgnorePing
    )
)

:execute
powershell -Command "$securePass = Read-Host -AsSecureString 'Enter domain admin password'; $cred = New-Object System.Management.Automation.PSCredential ('!domainAdmin!', $securePass); Rename-Computer -ComputerName '!oldName!' -NewName '!newName!' -Force -PassThru -DomainCredential $cred -Restart"
if errorlevel 1 (
    echo An error occurred while executing the command.
) else (
    echo Computer rename initiated successfully.
    echo The computer will restart automatically.
)

:askExit
    set /p exit="Would you like to exit the program? (Y/N): "
    if /i "!exit!" == "N" (
        goto start
    ) else if /i "!exit!" == "Y" (
        goto end
    ) else (
        echo Please enter Y or N
        goto askExit
    )
:end
endlocal
