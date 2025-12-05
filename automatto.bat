@echo off
cls
setlocal
goto start

:onBreak
color 07
echo.
cls
echo Bye!
endlocal
exit /b

:start
echo AUTO IL MATTO FIRMWARE FLASHING.
echo MAKE SURE atmega644pa-12mhz_2048.hex IS LOCATED IN SAME FOLDER
color 0b
echo. 
echo. 
echo. 
echo. 
pause
:loop

cls
set "outputFile=avrdude_output.txt"
color 0e
echo ****   FLASHING HIGH FUSE   ****
avrdude -c c232hm -p m644p -F -U hfuse:w:0x9c:m >> "%outputFile%" 2>&1
color 0d
echo ****   FLASHING LOW FUSE   ****
avrdude -c c232hm -p m644p -F -U lfuse:w:0xff:m >> "%outputFile%" 2>&1
color 0a
echo ****   FLASHING FIRMWARE   ****
avrdude -c c232hm -p m644p -F -U flash:w:atmega644pa-12mhz_2048.hex:i >> "%outputFile%" 2>&1
echo.   

:: Check for multiple success patterns
findstr /C:"Fuses OK (E:FF, H:9C, L:FF)" "%outputFile%" >nul
set "FOUND_FUSES_OK=%ERRORLEVEL%"

findstr /C:"bytes of flash verified" "%outputFile%" >nul
set "FOUND_FLASH_VERIFIED=%ERRORLEVEL%"

findstr /C:"avrdude done.  Thank you." "%outputFile%" >nul
set "FOUND_AVRDUDE_DONE=%ERRORLEVEL%"

:: Check for common warnings that are acceptable
findstr /C:"safemode" "%outputFile%" >nul
set "FOUND_SAFEMODE=%ERRORLEVEL%"

findstr /C:"SCK" "%outputFile%" >nul
set "FOUND_SCK_WARNING=%ERRORLEVEL%"

:: Success if we have either:
:: - Traditional success message OR
:: - Flash verified + avrdude completed (even with SCK warnings)
if "%FOUND_FUSES_OK%"=="0" (
    set "SUCCESS=1"
) else if "%FOUND_FLASH_VERIFIED%"=="0" (
    if "%FOUND_AVRDUDE_DONE%"=="0" (
        set "SUCCESS=1"
    ) else (
        set "SUCCESS=0"
    )
) else (
    set "SUCCESS=0"
)

if "%SUCCESS%"=="1" (
    color 2f
    echo  _____   _  __
    echo ^|  _  ^| ^| ^|/ /
    echo ^| ^| ^| ^| ^| ' / 
    echo ^| ^|_^| ^| ^| . \ 
    echo ^|_____^| ^|_^|\_\
    echo.
    echo ALL GOOD! TIME FOR THE NEXT BOARD!
    
    :: Show additional info if there were warnings but it still worked
    if "%FOUND_SCK_WARNING%"=="0" (
        echo.
        echo Note: SCK warning detected but flash completed successfully.
        echo This is normal with USB 3.0 ports.
    )
    if "%FOUND_FUSES_OK%"=="1" (
        echo.
        echo Note: Different success message detected \(likely USB 3.0\).
        echo Flash verification completed successfully.
    )
) else (
    color 4F
    echo ERROR PLEASE CHECK OUTPUT
    echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    echo "^^^^^   CHECK OUTPUT ABOVE  ^^^^^"
    echo "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
    echo. 
    echo EXPECTED SUCCESS INDICATORS:
    echo - Flash verified \(bytes of flash verified\)
    echo - OR Fuses OK \(E:FF, H:9C, L:FF\)
    echo - AND avrdude completed successfully
    echo.
    echo Note: SCK warnings with USB 3.0 are normal and don't indicate failure.
)

echo. 
echo. 
echo. 
echo. 
del "%outputFile%"


echo. 
echo. 
echo. 
echo. 
choice /C EQ /N /M "Press E to continue or Q to quit..."

if errorlevel 2 (
    goto onBreak
) else (
    goto loop
)