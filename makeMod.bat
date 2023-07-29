del z_modrevive.iwd
del mod.ff

xcopy ui_mp ..\..\raw\ui_mp /SY
xcopy maps ..\..\raw\maps /SY

copy /Y mod.csv ..\..\zone_source
cd ..\..\bin
linker_pc.exe -language english -compress -cleanup mod
cd ..\mods\ModRevive
copy ..\..\zone\english\mod.ff
7za a -r -tzip z_modrevive.iwd maps
7za a -r -tzip z_modrevive.iwd images

pause