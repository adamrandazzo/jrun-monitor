@echo off
SETLOCAL ENABLEEXTENSIONS
set bad=0
set good=0

:runit
for /f "skip=2 tokens=2 delims=," %%c in ('typeperf "\Process(jrun)\%% Processor Time" -sc 1') do (
	set cpu_usage=%%~c
	goto :testcpu
)
	
:testcpu
set cpu_usage=%cpu_usage:.=%
echo 1%cpu_usage% 
if 1%cpu_usage% LSS 150000000 (
	echo GOOD
	set /a good=%good%+1
	if %good% GEQ 10 (
		set bad=0
		set good=0
	)
) else (
	echo BAD
	set /a bad=%bad%+1
	set good=0
)	

if %bad% GEQ 20 (
	echo ABORT
	Taskkill /IM jrun.exe /F
	for /F "tokens=2" %%i in ('date /t') do set mydate=%%i
	set mytime=%time%	
	echo %mydate% %mytime% Killed JRUN - Good: %good% Bad: %bad% >> jrun-kills.txt
	pathping 127.0.0.1 -n -q 1 -p 30000 >nul 2>&1
	set bad=0
	set good=0	
)

echo Good: %good% Bad: %bad%
echo ---------------

pathping 127.0.0.1 -n -q 1 -p 2000 >nul 2>&1
goto :runit
ENDLOCAL
