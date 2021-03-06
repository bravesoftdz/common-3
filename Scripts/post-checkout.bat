@echo off

rem **************************************************************************
rem *
rem * Copyright 2016 Tim De Baets
rem *
rem * Licensed under the Apache License, Version 2.0 (the "License");
rem * you may not use this file except in compliance with the License.
rem * You may obtain a copy of the License at
rem *
rem *     http://www.apache.org/licenses/LICENSE-2.0
rem *
rem * Unless required by applicable law or agreed to in writing, software
rem * distributed under the License is distributed on an "AS IS" BASIS,
rem * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
rem * See the License for the specific language governing permissions and
rem * limitations under the License.
rem *
rem **************************************************************************
rem *
rem * Git post-checkout hook
rem *
rem **************************************************************************

setlocal enabledelayedexpansion

set SCRIPTPATH=%~dp0

rem Strange effects can occur if this script is updated while it is being
rem executed. Therefore, we first create a temporary copy of ourselves and
rem then transfer execution to that copy.
set BATCHNAME=%~nx0
set BATCHSUFFIX=%BATCHNAME:~-8%
set BATCHTMPNAME=
if not "%BATCHSUFFIX%"==".tmp.bat" (
    set BATCHTMPNAME=%~dpn0.tmp.bat
    call "%SCRIPTPATH%\mycopy.bat" "%~f0" "!BATCHTMPNAME%!"
    if errorlevel 1 goto failed
    rem Transfer execution to temporary copy
    "!BATCHTMPNAME!" %*
    if errorlevel 1 goto failed
)

rem Run project-specific hook if it exists
if exist Hooks\post-checkout.bat (
    call .\Hooks\post-checkout.bat %*
    if errorlevel 1 goto failed
)

echo Updating submodules...

git submodule update
if errorlevel 1 goto failed

goto exit

:failed
echo *** post-checkout FAILED ***
set ERRCODE=1
if "%BATCHSUFFIX%"==".tmp.bat" (
    "%SCRIPTPATH%\deleteselfandexit.bat" "%~f0" %ERRCODE%
)
exit /b %ERRCODE%

:exit
if "%BATCHSUFFIX%"==".tmp.bat" (
    "%SCRIPTPATH%\deleteselfandexit.bat" "%~f0"
)
