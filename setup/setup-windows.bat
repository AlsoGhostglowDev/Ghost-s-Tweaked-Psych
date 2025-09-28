@echo off
color 0a
cd ..
@echo on
echo Installing dependencies.
haxelib git hxcpp https://github.com/HaxeFoundation/hxcpp.git
haxelib set lime 8.0.2
haxelib set openfl 9.2.2
haxelib set flixel 5.6.2
haxelib set flixel-addons 3.2.2
haxelib set flixel-ui 2.5.0
haxelib install flixel-tools 
haxelib install hxWindowColorMode 
haxelib install hxCodec
haxelib install tjson
haxelib git hscript-improved-dev https://github.com/CodenameCrew/hscript-improved.git codename-dev
haxelib git flxanimate https://github.com/ShadowMario/flxanimate dev
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc
echo Finished!
pause
