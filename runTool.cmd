@echo off
rem *****************************************************************************
rem  2022 by Swiss Post, Information Technology Services
rem
rem  Version 8.0.2
rem *****************************************************************************

rem *****************************************************************************
rem   Environment Variables
rem
rem   Set desired set and versions of tools in this section
rem
rem   Examples:
rem
rem   Skip installation for unnecessary tools:
rem   set <tool>.optional=true
rem
rem   Set tool version:
rem   set <tool>.version=<tool-version>
rem *****************************************************************************

SETLOCAL
set maven.version=3.8.5
set ant.version=1.7.0
set java.version=jdk17_35
set eclipse.version=4.2.2-2.0.0
set eclipse-workspace.version=4.2.2-2.0.0
set tomcat.version=8.0.18-x64
set node.version=v16.13.2-x64
set spark.version=3.1.1-bin-hadoop3.2
set hadoop.version=3.2.1
set scala.version=2.12.10

set maven.optional=false
set eclipse.optional=true
set eclipse-workspace.optional=true
set java.optional=false
set tomcat.optional=true
set node.optional=false
set spark.optional=true
set hadoop.optional=true
set scala.optional=true

rem *****************************************************************************
rem   Do not alter script beyond this point for project usage
rem *****************************************************************************

rem call help
:CHECK_PARAMETERS
if "%1" == "-h"  goto USAGE
if "%1" == "help"  goto USAGE
if "%1" == "?"  goto USAGE

rem *****************************************************************************
rem   Tool installation - Defaults
rem *****************************************************************************

:CHECK_JREPO_HOME
if not '%JREPO_HOME%'=='' goto CHECK_JREPO_LOCAL
set JREPO_HOME=https://artifactory.tools.post.ch/artifactory/generic-tools-local/ch/post/it/tools
set JREPO_RUN_HOME=https://gitit.post.ch/projects/JAVA/repos/runtool/raw

:CHECK_JREPO_LOCAL
if not '%JREPO_LOCAL%'=='' goto SET_DEFAULTS
set JREPO_LOCAL=C:\work\jrepo-local

rem ****************************************************************************
rem   Tool installation - Prerequisites
rem ****************************************************************************

:SET_DEFAULTS
set JREPO_LOCAL_TOOLS=%JREPO_LOCAL%\tools
set JREPO_TEMP=%JREPO_LOCAL%\temp
set JAVA_HOME=%JREPO_LOCAL_TOOLS%\java\java-%java.version%

:RUN
if not '%1'=='install' if not '%1'=='' goto RUN_TOOL

rem *****************************************************************************
rem   Tool installation (via apache ant)
rem *****************************************************************************

echo RunTool prerequisites verification:
echo.

:CHECK_JAVA
echo Ensure Java executable is available
echo.

:CHECK_JAVA_HOME
set JAVA_INSTALLATION_TYPE=JAVA_HOME (PROJECT)
echo|set /p="..... looking for Java executable in JAVA_HOME (%JAVA_HOME%): "
if exist %JAVA_HOME% (
  echo Found
  echo.
  goto INSTALL
)
echo Not found
echo.

:CHECK_JAVA_PATH
set JAVA_INSTALLATION_TYPE=PATH (SYSTEM)
echo|set /p="..... looking for Java executable in PATH: "
where java >nul 2>&1
if %ERRORLEVEL% NEQ 1 (
  echo Found
  echo.
  goto INSTALL
)
echo Not found
echo.

:CHECK_JAVA_JREPO_LOCAL
set JAVA_INSTALLATION_TYPE=JPREPO_LOCAL (RUNTOOL DEFAULT)
set JAVA_DEFAULT_VERSION=jdk11.0.2_9
set JAVA_DEFAULT_HOME=%JREPO_LOCAL_TOOLS%\java\java-%JAVA_DEFAULT_VERSION%
echo|set /p="..... looking for Java executable in JREPO_LOCAL (%JAVA_DEFAULT_HOME%): "
if exist %JAVA_DEFAULT_HOME% (
  echo Found
  echo.
  goto SET_JAVA_DEFAULT_HOME
)
echo Not found
echo.

:DEPENCENCY_CHECK_FAILED
echo Required dependencies have not been found and will be installed
echo.

:INSTALL_JAVA_DEFAULT
set JAVA_DEFAULT_VERSION_ORIGIN=jdk-11.0.2+9
set JAVA_DEFAULT_DOWNLOAD_URL=https://artifactory.tools.post.ch/artifactory/generic-github-remote/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.2+9/OpenJDK11U-jdk_x64_windows_hotspot_11.0.2_9.zip
echo Installing java into %JAVA_DEFAULT_HOME%
echo.
echo Source %JAVA_DEFAULT_DOWNLOAD_URL%
echo.

if not exist %JREPO_LOCAL_TOOLS%\java ( mkdir %JREPO_LOCAL_TOOLS%\java )
if not exist %JREPO_TEMP% ( mkdir %JREPO_TEMP% )
if not exist %JREPO_TEMP%\sources\java ( mkdir %JREPO_TEMP%\sources\java )

rem download the java default version and put it in place according to the naming convention used (JAVA_DEFAULT_VERSION vs JAVA_DEFAULT_VERSION_ORIGIN)
powershell -Command "& {$webClient=New-Object System.Net.WebClient; $webclient.DownloadFile('%JAVA_DEFAULT_DOWNLOAD_URL%','%JREPO_TEMP%\sources\java\java-%JAVA_DEFAULT_VERSION%.zip')}"
powershell -Command "& {Expand-Archive -Path '%JREPO_TEMP%\sources\java\java-%JAVA_DEFAULT_VERSION%.zip' -DestinationPath '%JREPO_TEMP%\sources\java'}"
powershell -Command "& {Move-Item -Force -Path '%JREPO_TEMP%\sources\java\%JAVA_DEFAULT_VERSION_ORIGIN%' -Destination '%JAVA_DEFAULT_HOME%';}"

:SET_JAVA_DEFAULT_HOME
set JAVA_HOME=%JREPO_LOCAL_TOOLS%\java\java-%JAVA_DEFAULT_VERSION%

:INSTALL
rem downloads of programs end in a temp folder for installation, this folder will be deleted at the end
if not exist %JREPO_TEMP% ( mkdir %JREPO_TEMP% )
cd %JREPO_TEMP%

:CHECK_ANT_HOME
if not '%ANT_HOME%'=='' goto CHECK_ANT
set ANT_HOME=%JREPO_LOCAL%\tools\ant\ant-%ant.version%

:CHECK_ANT
if exist %ANT_HOME%\lib\ant.jar goto RUN_ANT
goto FETCH_ANT

:FETCH_ANT
if not exist %ANT_HOME% mkdir %ANT_HOME%
mkdir %JREPO_TEMP%\sources\ant
powershell -Command "& {$webClient=New-Object System.Net.WebClient; $webclient.DownloadFile('%JREPO_HOME%/ant/ant-%ant.version%.zip','%JREPO_TEMP%\sources\ant\ant-%ant.version%.zip')}"
powershell -Command "& {Expand-Archive -Path %JREPO_TEMP%\sources\ant\ant-%ant.version%.zip -DestinationPath %ANT_HOME%}"
goto RUN_ANT

rem ****************************************************************************
rem install and or run ant
rem ****************************************************************************

:RUN_ANT

powershell -Command "& {$webClient=New-Object System.Net.WebClient; $webclient.DownloadFile('%JREPO_RUN_HOME%\build.xml?at=master','%JREPO_TEMP%\build.xml')}"

if '%1'=='' goto ANT_INSTALL_ALL
if '%1'=='install' (if '%2' == '' (goto ANT_INSTALL_ALL) else (goto ANT_INSTALL))
goto usage

:ANT_INSTALL
if '%2'=='' (
  goto ANT_INSTALL_ALL
) else (
    goto LOOP
)

:LOOP
shift
if '%1'=='' goto CONTINUE
set params=%params%,%1
goto LOOP

:CONTINUE
call %ANT_HOME%\bin\ant.bat -quiet -f %JREPO_TEMP%\build.xml install -Dtools="%params%" -DdirectInstall=true
goto deltemp

:ANT_INSTALL_ALL
if '%1' == '' set params=-DnoArgs=true
call %ANT_HOME%\bin\ant.bat -quiet -f %JREPO_TEMP%\build.xml install %params%
goto deltemp


rem *****************************************************************************
rem   Calls to external tool (e.g. mvn jetty:run)
rem *****************************************************************************

:RUN_TOOL
IF /i "%2"=="jetty:run" set MAVEN_OPTS=%MAVEN_OPTS% -Xdebug -Xrunjdwp:transport=dt_socket,address=4000,server=y,suspend=n
if '%MVN_HOME%'=='' set MVN_HOME=%JREPO_LOCAL_TOOLS%\maven\maven-%maven.version%
if '%ANT_HOME%'=='' set ANT_HOME=%JREPO_LOCAL_TOOLS%\ant\ant-%ant.version%
if '%NODE_HOME%'=='' set NODE_HOME=%JREPO_LOCAL_TOOLS%\node\node-%node.version%
if '%HADOOP_HOME%'=='' set HADOOP_HOME=%JREPO_LOCAL_TOOLS%\hadoop\hadoop-%hadoop.version%
if '%SPARK_HOME%'=='' set SPARK_HOME=%JREPO_LOCAL_TOOLS%\spark\spark-%spark.version%\spark-%spark.version%
if '%SCALA_HOME%'=='' set SCALA_HOME=%JREPO_LOCAL_TOOLS%\scala\scala-%scala.version%
if '%node.optional%'=='false' set PATH=%NODE_HOME%;%PATH%

:CALL_TOOL
if /i "%1" == "mvn" goto RUN_MVN
if /i "%1" == "ant" goto RUN_ANT_EXT
if /i "%1" == "java" goto RUN_JAVA
if /i "%1" == "keytool" goto RUN_KEYTOOL
if /i "%1" == "npm" goto RUN_NPM
if /i "%1" == "node" goto RUN_NODE
if /i "%1" == "grunt" goto RUN_GRUNT
if /i "%1" == "yo" goto RUN_YO
if /i "%1" == "ng" goto RUN_NG
if /i "%1" == "apikana" goto RUN_APIKANA
if /i "%1" == "spark" goto RUN_SPARK
if /i "%1" == "spark-shell" goto RUN_SPARK_SHELL
if /i "%1" == "scala" goto RUN_SCALA
goto TOOL_ERROR

:RUN_MVN
if not exist %MVN_HOME%\bin\mvn goto TOOL_NOT_INSTALLED
if not exist %JAVA_HOME%\bin\javac.exe goto JDK_NOT_INSTALLED
rem because of site:generate (findbugs memory consumption)
rem see http://mojo.codehaus.org/findbugs-maven-plugin/usage.html
set MAVEN_OPTS=%MAVEN_OPTS% -Xmx512M
%MVN_HOME%\bin\%*
goto end

:RUN_ANT_EXT
if not exist %ANT_HOME%\bin\ant goto TOOL_NOT_INSTALLED
set ANT_OPTS=-Xmx512M %ANT_OPTS%
%ANT_HOME%\bin\%*
goto end

:RUN_JAVA
if not exist %JAVA_HOME%\bin\java.exe goto TOOL_NOT_INSTALLED
set JAVA_OPTS=%JAVA_OPTS%

%JAVA_HOME%\bin\%*
goto end

:RUN_NPM
if not exist %NODE_HOME%\node.exe goto TOOL_NOT_INSTALLED
%NODE_HOME%\%*
goto end

:RUN_NODE
if not exist %NODE_HOME%\node.exe goto TOOL_NOT_INSTALLED
%NODE_HOME%\%*
goto end

:RUN_GRUNT
if not exist %NODE_HOME%\grunt.cmd goto JSTOOLS_NOT_INSTALLED
call %NODE_HOME%\%*
goto end

:RUN_YO
if not exist %NODE_HOME%\yo.cmd goto JSTOOLS_NOT_INSTALLED
%NODE_HOME%\%*
goto end

:RUN_NG
if not exist %NODE_HOME%\node.exe goto JSTOOLS_NOT_INSTALLED
%NODE_HOME%\npm run-script %*
goto end

:RUN_APIKANA
if not exist %NODE_HOME%\node.exe goto JSTOOLS_NOT_INSTALLED
%NODE_HOME%\node node_modules\apikana\bin\%*
goto end

:RUN_SPARK
echo use 'runTool.cmd spark-shell' to start the spark shell
goto end

:RUN_SPARK_SHELL
if not exist %SPARK_HOME%\bin\spark-shell.cmd goto TOOL_NOT_INSTALLED
%SPARK_HOME%\bin\%*
goto end

:RUN_SCALA
if not exist %SCALA_HOME%\bin\scala.bat goto TOOL_NOT_INSTALLED
%SCALA_HOME%\bin\%*
goto end

:RUN_KEYTOOL
if not exist %JAVA_HOME%\bin\keytool.exe goto JDK_NOT_INSTALLED
mkdir %JREPO_LOCAL%\temp
set JREPO_TEMP=%JREPO_LOCAL%\temp
cd %JREPO_TEMP%

set JAVA_CERTS_REPOSITORY=cacerts
set JAVA_CERTS_REPOSITORY_URL=https://gitit.post.ch/rest/api/latest/projects/pki/repos/%JAVA_CERTS_REPOSITORY%%/archive?format=zip

rem Download latest certificates from git
powershell -Command "& {$webClient=New-Object System.Net.WebClient; $webclient.DownloadFile('%JAVA_CERTS_REPOSITORY_URL%','%JAVA_CERTS_REPOSITORY%.zip')}"
powershell -Command "& {Expand-Archive -Force -Path '%JAVA_CERTS_REPOSITORY%.zip' -DestinationPath '%JAVA_CERTS_REPOSITORY%'}"

rem Manage certificates (remove/add)
cd %JAVA_CERTS_REPOSITORY%\IntermediateCA\
call :importCertificates

cd %JAVA_CERTS_REPOSITORY%\RootCA\
call :importCertificates

rem Print available certificates in keystore
%JAVA_HOME%\bin\keytool.exe -list -v -storepass changeit

cd %JREPO_TEMP%

goto deltemp

rem *****************************************************************************
rem   Errors
rem *****************************************************************************

:TOOL_ERROR
echo *** ERROR: Unsupported tool:  %1
goto end

:TOOL_NOT_INSTALLED
echo *** ERROR: Tool not installed, install by running runTool.cmd install or runTool.cmd install %1
goto end

:JDK_NOT_INSTALLED
echo *** ERROR: JDK not installed, install by running runTool.cmd install java
goto end

:JSTOOLS_NOT_INSTALLED
echo *** ERROR: jstools not installed, install by running runTool.cmd install node
goto end

rem *****************************************************************************
rem   Help
rem *****************************************************************************

:USAGE
echo.
echo usage: runTool install [tool1 [tool2] ...]
echo or runTool tool [arguments]
echo.
echo for example: runTool mvn clean install
echo.
echo without any arguments, you will be prompted if you want to install all tools (same as 'install')
echo.
echo 'install' will install all tools which are not marked as 'optional' (see top of this script)
echo 'install ^<^<tool^>^>' will install the tool specified without considering the 'optional' setting
echo available tools:
echo        - ant
echo        - eclipse
echo        - eclipse-workspace
echo        - java
echo        - keytool (requires java, imports keys in the java keytool)
echo        - jrebel
echo        - maven
echo        - tomcat
echo        - node
echo        - spark
echo        - hadoop
echo        - scala
echo.
echo.
echo The following environment variables are supported
echo.
echo     - JREPO_LOCAL ((default: C:\work\userapp\jrepo-local)
echo.
echo     - JREPO_HOME (default: https://artifactory.tools.post.ch/artifactory/generic-tools-local/ch/post/it/tools)
echo.
echo
goto end

:deltemp
cd ..
rmdir temp /s /q
goto end

:importCertificates
for %%f in (*.cer) do %JAVA_HOME%\bin\keytool.exe -delete -alias "%%f" -storepass changeit & echo "%JAVA_HOME%\bin\keytool.exe -importcert -file '%%f' -alias '%%f' -storepass changeit -trustcacerts" & %JAVA_HOME%\bin\keytool.exe -importcert -file "%%f" -alias "%%f" -storepass changeit -trustcacerts -noprompt
EXIT /B

:end
endlocal

