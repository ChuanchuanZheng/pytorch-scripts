@echo off

REM Check for necessary components

IF NOT EXIST "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" (
    echo Visual Studio 2017 C++ BuildTools is required to compile PyTorch on Windows
    exit /b 1
)

for /f "usebackq tokens=*" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -legacy -version [15^,16^) -property installationPath`) do (
    if exist "%%i" if exist "%%i\VC\Auxiliary\Build\vcvarsall.bat" (
        set VS15INSTALLDIR=%%i
        set VS15VCVARSALL=%%i\VC\Auxiliary\Build\vcvarsall.bat
        goto vswhere
    )
)

:vswhere
IF "%VS15VCVARSALL%"=="" (
    echo Visual Studio 2017 C++ BuildTools is required to compile PyTorch on Windows
    exit /b 1
)

IF NOT "%VS15VCVARSALL%"=="" IF NOT "%VS140COMNTOOLS%"=="" (
    set DISTUTILS_USE_SDK=1
)

where /q python.exe

IF ERRORLEVEL 1 (
    echo Python is required to compile PyTorch on Windows
    exit /b 1
)

for /F "usebackq delims=" %%i in (`python -c "import sys; print('{0[0]}{0[1]}'.format(sys.version_info))"`) do (
    set /a PYVER=%%i
)

if  %PYVER% LSS 35 (
    echo Python 3.5 or up is required to compile PyTorch on Windows
    echo Maybe you can create a virual environment if you have conda installed:
    echo ^> conda create -n test python=3.6 pyyaml mkl numpy
    echo ^> activate test
    exit /b 1
)