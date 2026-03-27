@echo off

echo Create INC folders

if not exist .\UMovMutators\Inc\ mkdir .\UMovMutators\Inc
if not exist .\UMovSpecialForcesConfig\Inc\ mkdir .\UMovSpecialForcesConfig\Inc
if not exist .\UMovSpecialForcesMod\Inc\ mkdir .\UMovSpecialForcesMod\Inc

echo Delete old .u files

if exist .\UMovMutators.U DEL .\UMovMutators.U
if exist .\UMovSpecialForcesConfig.U DEL .\UMovSpecialForcesConfig.U
if exist .\UMovSpecialForcesMod.U DEL .\UMovSpecialForcesMod.U
if exist .\VietnamGame.U DEL .\VietnamGame.U
if exist .\VietnamCharacters.U DEL .\VietnamCharacters.U
if exist .\VietnamAI.U DEL .\VietnamAI.U
if exist .\VietnamItems.U DEL .\VietnamItems.U
if exist .\VietnamWeapons.U DEL .\VietnamWeapons.U

REM Tell the user that we are compiling the mod

echo Compiling source code for Men of Valor Special Forces Mod
REM Run UCC.exe from inside Source\System, so that the
REM compiler uses the mod's initialisation files and settings
REM and stores the compiled output in the MyMod\System
REM directory

ucc make -nobind

REM Tell the user that the game has exited, and wait for a keypress
cd ..
echo Finished compiling Men of Valor Special Forces Mod
PAUSE
