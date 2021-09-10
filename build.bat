::prepare build env
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" (
    :: Visual Studio 2019
    call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat" (
    :: Visual Studio 2017
    call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"
) else if exist "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" (
    :: Visual Studio 2015
    call "C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\SetEnv.cmd" /x64
) else (
    echo "build env not found!"
    exit
)

set PLATFORM=x64
set BUILDER=CMake
set GENERATOR=NMake Makefiles
set APPVEYOR_BUILD_WORKER_IMAGE=Visual Studio 2019
set MSVC_NAME=vs2019
set CONFIGURATION=Release
set APPVEYOR_BUILD_FOLDER=%cd%

set BUILD_DIR=%APPVEYOR_BUILD_FOLDER%\build
set INSTALL_DIR=%APPVEYOR_BUILD_FOLDER%\install


::build pcre2
set PCRE2_ROOT=%APPVEYOR_BUILD_FOLDER%\pcre2
set PCRE2_BUILD_DIR=%PCRE2_ROOT%\build
set PCRE2_INSTALL_DIR=%PCRE2_ROOT%\install_dir

cd %APPVEYOR_BUILD_FOLDER%

if not exist %BUILD_DIR% (
    mkdir %BUILD_DIR%
)
if not exist %PCRE2_BUILD_DIR% (
    mkdir %PCRE2_BUILD_DIR%
)

cd %PCRE2_BUILD_DIR%
cmake.exe -G "%GENERATOR%" -DCMAKE_BUILD_TYPE=%CONFIGURATION% -DCMAKE_INSTALL_PREFIX="%PCRE2_INSTALL_DIR%" "%PCRE2_ROOT%"
cmake --build . --config %CONFIGURATION%
cmake --install . --config %CONFIGURATION%

cd %BUILD_DIR%
echo %APPVEYOR_BUILD_FOLDER%\cmake
cmake.exe -G "%GENERATOR%" -DCMAKE_BUILD_TYPE=%CONFIGURATION% -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% %APPVEYOR_BUILD_FOLDER%
@REM cmake.exe -G "%GENERATOR%" -DCMAKE_BUILD_TYPE=%CONFIGURATION% -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX="%INSTALL_DIR%" "%APPVEYOR_BUILD_FOLDER%"
cmake --build . --config %CONFIGURATION%
cmake --install . --config %CONFIGURATION%

cd %BUILD_DIR%
ctest