@ECHO OFF
SETLOCAL EnableDelayedExpansion
REM
REM Starts the currently active installation of MATLAB
REM

REM Version 1.0 (7 Oct 2020), Patrik Forssén, Karlstad University

REM Get CLSID
FOR /F "tokens=2* skip=2" %%a IN ('reg query "HKCR\Matlab.Application\CLSID"') DO (
  SET clsid=%%b)

REM Get MATLAB application path
FOR /F "tokens=2* skip=2" %%a IN ('reg query "HKCR\CLSID\%clsid%\LocalServer32"') DO (
  SET mpath=%%b)

REM Remove flags
SET flagbit=%mpath:*/=%
CALL SET mapp=%%mpath:%flagbit%=%%
SET mapp=%mapp: /=%
REM ECHO [%mapp%]

REM Path to this batch file
SET mypath=%~dp0
SET mypath=%mypath:~0,-1%
REM ECHO [%mypath%]

REM Launch MATLAB
SET runStr="%mapp%" -r "disp('MATLAB installation folder:'), disp(matlabroot), disp('This is not a permanent solution, please make shortcuts to MATLAB instead.')" -sd "%mypath%"
REM ECHO [%runStr%]
REM No waiting
start "" %runStr%

EXIT