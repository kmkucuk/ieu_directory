@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
REM 
REM Create desktop and start menu shortcut to run MATLAB
REM
 
REM Default is non-elevated interactive mode (i.e., ask user) if no arguments 
REM are given at command line. This can be changed below.
REM Run in elevated (admin) mode
REM 0=No, 1=Yes
SET elevFlag=0
REM Create desktop shortcut to MATLAB, 
REM -1=ask, 0=no, 1=yes
SET dtrun=-1
REM Create desktop shortcut to uninstall MATLAB,
REM -1=ask, 0=no, 1=yes
SET dtunin=-1
REM Create start menu items with shortcuts to run and uninstall MATLAB: 
REM -1=ask, 0=no, 1=for this user, 2=for all users (elevated mode)
SET sm=-1
 
REM Uncomment and set below, for example if you want to apply the
REM file to another release also installed on the computer or do not want the 
REM user to supply the MATLAB release number (MATLAB command "version -release")
REM and the MATLAB installation root directory (MATLAB command "matlabroot").
REM Any supplied command line arguments override the values set below.
SET matlabrelease=R2020a
SET matlabroot="C:\Program Files\MATLAB\R2020a"
REM
REM --------------------------DO NOT EDIT BELOW---------------------------------

REM Version 1.0 (7 Oct 2020), Patrik Forssén, Karlstad University

REM Administrator?
net.exe session 1>NUL 2>NUL
IF %ERRORLEVEL% EQU 0 (
  SET isadmin=1
) ELSE (
  SET isadmin=0
)

REM Check input
IF [%1]==[] (
  IF [%matlabrelease%]==[] (
     GOTO LOCALHELP)
  ) ELSE (
  SET matlabrelease=%1
)
IF [%2]==[] (
  IF [%matlabroot%]==[] (
     GOTO LOCALHELP)
  ) ELSE (
  SET matlabroot=%2
)
REM Check flags
SET hasFlags=0
IF NOT [%3]==[] (
  CALL :CHECKFLAGS %3 %isadmin% %elevFlag% 0)
IF NOT [%4]==[] (
  CALL :CHECKFLAGS %4 %isadmin% %elevFlag% 0)
IF NOT [%5]==[] (
  CALL :CHECKFLAGS %5 %isadmin% %elevFlag% 0)
IF NOT [%6]==[] (
  CALL :CHECKFLAGS %6 %isadmin% %elevFlag% 0)
IF NOT [%7]==[] (
  CALL :CHECKFLAGS %7 %isadmin% %elevFlag% 0)
IF %hasFlags%==1 (
  SET dtrun=0
  SET dtunin=0
  SET sm=0
  IF NOT [%3]==[] (
    CALL :CHECKFLAGS %3 %isadmin% %elevFlag% 1)
  IF NOT [%4]==[] (
    CALL :CHECKFLAGS %4 %isadmin% %elevFlag% 1)
  IF NOT [%5]==[] (
    CALL :CHECKFLAGS %5 %isadmin% %elevFlag% 1)
  IF NOT [%6]==[] (
    CALL :CHECKFLAGS %6 %isadmin% %elevFlag% 1)
  IF NOT [%7]==[] (
    CALL :CHECKFLAGS %7 %isadmin% %elevFlag% 1)
)

IF %elevFlag%==1 (
  IF %isadmin%==1 (
    GOTO MAIN)
) ELSE (
  GOTO MAIN
)

REM Not elevated and elevation requested, reinvoke with elevation.
REM Raises an UAC warning that must be accepted
set args=%*
if defined args set args=%args:^=^^%
if defined args set args=%args:<=^<%
if defined args set args=%args:>=^>%
if defined args set args=%args:&=^&%
if defined args set args=%args:|=^|%
if defined args set "args=%args:"=\"\"%"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  " Start-Process -Wait -Verb RunAs -FilePath cmd -ArgumentList \"/c \"\" cd /d \"\"%CD%\"\" ^&^& \"\"%~f0\"\" %args% \"\" \" "
exit /b


:MAIN
REM Check that the installation directory is valid
IF NOT EXIST %matlabroot%\* (
  ECHO The set MATLAB installation directory %matlabroot% does not exist!
  GOTO:EOF)

REM Check if shortcuts already exist, if so do not make any
REM Desktop...
SET LinkDest="%HOMEDRIVE%%HOMEPATH%\Desktop\MATLAB %matlabrelease%.lnk"
IF EXIST %LinkDest% (
  SET dtrun=0)
SET LinkDest="%HOMEDRIVE%%HOMEPATH%\Desktop\MATLAB %matlabrelease% - Uninstall.lnk"
IF EXIST %LinkDest% (
  SET dtunin=0)
REM Start menu...
SET smAll=0
SET LinkDest0="%ProgramData%\Microsoft\Windows\Start Menu\Programs\MATLAB %matlabrelease%"
SET LinkDest1="%ProgramData%\Microsoft\Windows\Start Menu\Programs\MATLAB %matlabrelease%\MATLAB %matlabrelease%.lnk"
SET LinkDest2="%ProgramData%\Microsoft\Windows\Start Menu\Programs\MATLAB %matlabrelease%\MATLAB %matlabrelease% - Uninstall.lnk"
IF EXIST %LinkDest0%\* (
  IF EXIST %LinkDest1% (
    IF EXIST %LinkDest2% (
       SET smAll=1)
    )
  )
)
SET smUser=0
SET LinkDest0="%AppData%\Microsoft\Windows\Start Menu\Programs\MATLAB %matlabrelease%"
SET LinkDest1="%AppData%\Microsoft\Windows\Start Menu\Programs\MATLAB %matlabrelease%\%matlabrelease%.lnk"
SET LinkDest2="%AppData%\Microsoft\Windows\Start Menu\Programs\MATLAB %matlabrelease%\%matlabrelease% - Uninstall.lnk"
IF EXIST %LinkDest0%\* (
  IF EXIST %LinkDest1% (
    IF EXIST %LinkDest2% (
       SET smUser=1)
    )
  )
)
SET /a test=%smAll%+%smUser%
IF %test% GTR 0 (
  SET sm=0)

REM Desktop run icon
IF %dtrun% EQU -1 (
  SET createFlag=Y)
IF %dtrun% EQU 0 (
  SET createFlag=N)
IF %dtrun% EQU 1 (
  SET createFlag=Y)
IF %dtrun% EQU -1 (
  ECHO[
  SET /P createFlag="Create MATLAB desktop shortcut (Y)/N? ")
IF %createFlag:~0,1%==N (
  SET dtrun=0
) ELSE (
  SET dtrun=1)

REM Desktop uninstall icon
IF %dtunin% EQU -1 (
  SET createFlag=N)
IF %dtunin% EQU 0 (
  SET createFlag=N)
IF %dtunin% EQU 1 (
  SET createFlag=Y)
IF %dtunin% EQU -1 (
  ECHO[
  SET /P createFlag="Create MATLAB uninstall desktop shortcut Y/(N)? ")
IF %createFlag:~0,1%==Y (
  SET dtunin=1
) ELSE (
  SET dtunin=0)

REM Start menu items
IF %sm% EQU -1 (
  IF %isadmin%==1 (
    SET createFlag=A
  ) ELSE (
    SET createFlag=U)
)
IF %sm% EQU 0 (
  SET createFlag=N)
IF %sm% EQU 1 (
  SET createFlag=U)
IF %sm% EQU 2 (
  SET createFlag=A)
IF %sm% EQU -1 (
  IF %isadmin%==1 (
     ECHO[
     ECHO Create MATLAB start menu items for current or all users?
     SET /P createFlag="(All)/User/No? "
) ELSE (
    ECHO[
    ECHO Create MATLAB start menu items for current user?
    ECHO Note that you must run the .bat-file as administrator in order to create start menu items for all user, right click on the file and select "Run as administrator". Can only create for the current user now^^!
    SET /P createFlag="(Y)/N/Exit? ")
  )
)
IF %createFlag:~0,1%==N (
  SET sm=0)
IF %isadmin%==1 (
  IF %createFlag:~0,1%==U (
    SET sm=1)
)
IF %isadmin%==1 (
  IF %sm% EQU -1 (
    SET sm=2)
)
IF %isadmin%==0 (
  IF %createFlag:~0,1%==E (
    GOTO:EOF)
)
IF %isadmin%==0 (
  IF %sm% EQU -1 (
    SET sm=1)
)

REM Check
IF %isadmin%==0 (
  IF %sm%==2 (
    ECHO[
    ECHO Creating start menu items for all users requires that the .bat file is run as administrator^^!
    SET sm=0
  )
)

REM Call routines that sets the shortcuts
IF %dtrun%==1 (
  CALL :MAKEDTRUNSC %matlabrelease% %matlabroot%)
IF %dtunin%==1 (
  CALL :MAKEDTUNINSC %matlabrelease% %matlabroot%)
IF %sm% GEQ 1 (
  CALL :MAKEDSMSC %matlabrelease% %matlabroot% %sm%)

PAUSE
GOTO:EOF



:CHECKFLAGS
IF %1==/E (
  SET elevFlag=1)
IF %1==/R (
  IF %4==0 (
    SET hasFlags=1
  ) ELSE (
    SET dtrun=1)
)
IF %1==/U (
  IF %4==0 (
    SET hasFlags=1
  ) ELSE (
    SET dtunin=1)
)
IF %1==/S (
  IF %4==0 (
    SET hasFlags=1
  ) ELSE (
    SET sm=1)
)
IF %1==/A (
  IF %4==0 (
    SET hasFlags=1
  ) ELSE (
    IF %2==0 (
      IF %3==0 (
        ECHO[
        ECHO Option /A requires administrator priveligies^^!
        SET sm=0
      ) ELSE (
        SET sm=2)
    ) ELSE (
      SET sm=2)
  )
)
EXIT /B



:MAKEDTRUNSC
SET LinkName=MATLAB %~1
SET LinkDest="%HOMEDRIVE%%HOMEPATH%\Desktop\%LinkName%.lnk"
SET Esc_LinkDest=%%HOMEDRIVE%%%%HOMEPATH%%\Desktop\!LinkName!.lnk
SET Esc_LinkTarget=""
SET Esc_LinkTarget0="%~2\bin\matlab.exe"
SET Esc_LinkTarget1="%~2\bin\win64\MATLAB.exe"
SET Esc_LinkTarget2="%~2\bin\win32\MATLAB.exe"
IF EXIST %Esc_LinkTarget0% (
  SET Esc_LinkTarget=%Esc_LinkTarget0%
  ) ELSE (
  IF EXIST %Esc_LinkTarget1% (
    SET Esc_LinkTarget=%Esc_LinkTarget1%
    ) ELSE (
    IF EXIST %Esc_LinkTarget2% (
      SET Esc_LinkTarget=%Esc_LinkTarget2%
    )
  )
)
IF %Esc_LinkTarget%=="" (
  ECHO[
  ECHO MATLAB.EXE not found^^! Failed to create desktop MATLAB shortcut
  EXIT /B)
SET Esc_LinkTarget=%Esc_LinkTarget:"=%

SET cSctVBS=CreateShortcut.vbs
SET LOG=".\%~N0_runtime.log"
((
  echo Set oWS = WScript.CreateObject^("WScript.Shell"^)
  echo sLinkFile = oWS.ExpandEnvironmentStrings^("!Esc_LinkDest!"^)
  echo Set oLink = oWS.CreateShortcut^(sLinkFile^)
  echo oLink.TargetPath = oWS.ExpandEnvironmentStrings^("!Esc_LinkTarget!"^)
  echo oLink.Save
)1>!cSctVBS!
cscript //nologo .\!cSctVBS!
DEL !cSctVBS! /f /q
)1>>!LOG! 2>>&1

ECHO[ 
IF EXIST %LinkDest% (
  ECHO Desktop MATLAB shortcut created
) ELSE (
  ECHO Failed to create desktop MATLAB shortcut^^!
) 
EXIT /B



:MAKEDTUNINSC
SET LinkName=MATLAB %~1 - Uninstall
SET LinkDest="%HOMEDRIVE%%HOMEPATH%\Desktop\%LinkName%.lnk"
SET Esc_LinkDest=%%HOMEDRIVE%%%%HOMEPATH%%\Desktop\!LinkName!.lnk
SET Esc_LinkTarget=""
SET Esc_LinkTarget0="%~2\uninstall\bin\win64\uninstall.exe"
SET Esc_LinkTarget1="%~2\uninstall\bin\win64\uninstall.exe"
IF EXIST %Esc_LinkTarget0% (
  SET Esc_LinkTarget=%Esc_LinkTarget0%
  ) ELSE (
  IF EXIST %Esc_LinkTarget1% (
    SET Esc_LinkTarget=%Esc_LinkTarget1%
  )
)
IF %Esc_LinkTarget%=="" (
  ECHO[
  ECHO UNINSTALL.EXE not found^^! Failed to create desktop uninstall MATLAB shortcut
  EXIT /B)
SET Esc_LinkTarget=%Esc_LinkTarget:"=%

SET cSctVBS=CreateShortcut.vbs
SET LOG=".\%~N0_runtime.log"
((
  echo Set oWS = WScript.CreateObject^("WScript.Shell"^)
  echo sLinkFile = oWS.ExpandEnvironmentStrings^("!Esc_LinkDest!"^)
  echo Set oLink = oWS.CreateShortcut^(sLinkFile^)
  echo oLink.TargetPath = oWS.ExpandEnvironmentStrings^("!Esc_LinkTarget!"^)
  echo oLink.Save
)1>!cSctVBS!
cscript //nologo .\!cSctVBS!
DEL !cSctVBS! /f /q
)1>>!LOG! 2>>&1

ECHO[
IF EXIST %LinkDest% (
  ECHO Desktop uninstall MATLAB shortcut created
) ELSE (
  ECHO Failed to create desktop uninstall MATLAB shortcut^^!
) 
EXIT /B



:MAKEDSMSC
REM Make folder
IF %3==1 (
  SET smDir="%AppData%\Microsoft\Windows\Start Menu\Programs\MATLAB %~1"
) ELSE (
  SET smDir="%ProgramData%\Microsoft\Windows\Start Menu\Programs\MATLAB %~1"
)
SET makeSMDir=0
IF NOT EXIST %smDir%\* (
  mkdir %smDir%
  SET makeSMDir=1)
ECHO[
IF %makeSMDir%==1 (
  IF NOT EXIST %smDir%\* (
    ECHO Failed to create start menu MATLAB folder^^!
    EXIT /B
  ) ELSE (
    ECHO Start menu MATLAB folder created
  )
)

REM Make run shortcut
SET LinkName=MATLAB %~1
IF %3==1 (
  SET LinkDest="%AppData%\Microsoft\Windows\Start Menu\Programs\MATLAB %~1\%LinkName%.lnk"
  SET Esc_LinkDest=%%AppData%%\Microsoft\Windows\Start Menu\Programs\MATLAB %~1\%LinkName%.lnk
) ELSE (
  SET LinkDest="%ProgramData%\Microsoft\Windows\Start Menu\Programs\MATLAB %~1\%LinkName%.lnk"
  SET Esc_LinkDest=%%ProgramData%%\Microsoft\Windows\Start Menu\Programs\MATLAB %~1\%LinkName%.lnk
)
IF EXIST %LinkDest% (
  GOTO SMUNINSC)
SET Esc_LinkTarget=""
SET Esc_LinkTarget0="%~2\bin\matlab.exe"
SET Esc_LinkTarget1="%~2\bin\win64\MATLAB.exe"
SET Esc_LinkTarget2="%~2\bin\win32\MATLAB.exe"
IF EXIST %Esc_LinkTarget0% (
  SET Esc_LinkTarget=%Esc_LinkTarget0%
  ) ELSE (
  IF EXIST %Esc_LinkTarget1% (
    SET Esc_LinkTarget=%Esc_LinkTarget1%
    ) ELSE (
    IF EXIST %Esc_LinkTarget2% (
      SET Esc_LinkTarget=%Esc_LinkTarget2%
    )
  )
)
IF %Esc_LinkTarget%=="" (
  ECHO MATLAB.EXE not found^^! Failed to create start menu MATLAB shortcut
  GOTO SMUNINSC)
SET Esc_LinkTarget=%Esc_LinkTarget:"=%

SET cSctVBS=CreateShortcut.vbs
SET LOG=".\%~N0_runtime.log"
((
  echo Set oWS = WScript.CreateObject^("WScript.Shell"^)
  echo sLinkFile = oWS.ExpandEnvironmentStrings^("!Esc_LinkDest!"^)
  echo Set oLink = oWS.CreateShortcut^(sLinkFile^)
  echo oLink.TargetPath = oWS.ExpandEnvironmentStrings^("!Esc_LinkTarget!"^)
  echo oLink.Save
)1>!cSctVBS!
cscript //nologo .\!cSctVBS!
DEL !cSctVBS! /f /q
)1>>!LOG! 2>>&1

IF EXIST %LinkDest% (
  ECHO Start menu MATLAB shortcut created
) ELSE (
  ECHO Failed to create start menu MATLAB shortcut^^!
) 


:SMUNINSC
SET LinkName=MATLAB %~1 - Uninstall
IF %3==1 (
  SET LinkDest="%AppData%\Microsoft\Windows\Start Menu\Programs\MATLAB %~1\%LinkName%.lnk"
  SET Esc_LinkDest=%%AppData%%\Microsoft\Windows\Start Menu\Programs\MATLAB %~1\%LinkName%.lnk
) ELSE (
  SET LinkDest="%ProgramData%\Microsoft\Windows\Start Menu\Programs\MATLAB %~1\%LinkName%.lnk"
  SET Esc_LinkDest=%%ProgramData%%\Microsoft\Windows\Start Menu\Programs\MATLAB %~1\%LinkName%.lnk
)
IF EXIST %LinkDest% (
  EXIT /B)
SET Esc_LinkTarget=""
SET Esc_LinkTarget0="%~2\uninstall\bin\win64\uninstall.exe"
SET Esc_LinkTarget1="%~2\uninstall\bin\win64\uninstall.exe"
IF EXIST %Esc_LinkTarget0% (
  SET Esc_LinkTarget=%Esc_LinkTarget0%
  ) ELSE (
  IF EXIST %Esc_LinkTarget1% (
    SET Esc_LinkTarget=%Esc_LinkTarget1%
  )
)
IF %Esc_LinkTarget%=="" (
  ECHO UNINSTALL.EXE not found^^! Failed to create start menu uninstall MATLAB shortcut
  EXIT /B)
SET Esc_LinkTarget=%Esc_LinkTarget:"=%

SET cSctVBS=CreateShortcut.vbs
SET LOG=".\%~N0_runtime.log"
((
  echo Set oWS = WScript.CreateObject^("WScript.Shell"^)
  echo sLinkFile = oWS.ExpandEnvironmentStrings^("!Esc_LinkDest!"^)
  echo Set oLink = oWS.CreateShortcut^(sLinkFile^)
  echo oLink.TargetPath = oWS.ExpandEnvironmentStrings^("!Esc_LinkTarget!"^)
  echo oLink.Save
)1>!cSctVBS!
cscript //nologo .\!cSctVBS!
DEL !cSctVBS! /f /q
)1>>!LOG! 2>>&1

IF EXIST %LinkDest% (
  ECHO Start menu uninstall MATLAB shortcut created
) ELSE (
  ECHO Failed to create start menu uninstall MATLAB shortcut
) 
EXIT /B



:LOCALHELP
ECHO MATLABSHORTCUTS release root [/E] [/R] [/U] [/S] [/A]
ECHO[
ECHO  release  MATLAB release number, for example R2020a
ECHO  root     MATLAB installation root directory, enclose using double quotes if it contains spaces, for example "C:\Program Files\MATLAB\R2020a"
ECHO  /E       Run in elavated mode, should be placed before other flags
ECHO  /R       Makes a desktop shortcut to MATLAB
ECHO  /U       Makes a desktop shortcut for uninstallation of MATLAB
ECHO  /S       Makes start menu items for MATLAB for current user, use either /S or /A
ECHO  /A       Makes start menu items for MATLAB for all users, requires administrator priveligies
ECHO If not /R, /U, /S or /A are present the program will interactively ask for them
PAUSE