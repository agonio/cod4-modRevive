del z_modrevive.iwd
del mod.ff

xcopy ui_mp ..\..\raw\ui_mp /SY
xcopy maps ..\..\raw\maps /SY
xcopy soundaliases ..\..\raw\soundaliases /SY
xcopy sound ..\..\raw\sound /SY
xcopy materials ..\..\raw\materials /SY
xcopy images ..\..\raw\images /SY

copy /Y mod.csv ..\..\zone_source
cd ..\..\bin
linker_pc.exe -language english -compress -cleanup mod
cd ..\mods\ModRevive
copy ..\..\zone\english\mod.ff
7za a -r -tzip z_modrevive.iwd images
7za a -r -tzip z_modrevive.iwd sound

pause