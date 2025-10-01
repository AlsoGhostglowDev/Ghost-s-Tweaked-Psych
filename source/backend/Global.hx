package backend;

import lime.app.Application;

class Global {
    // Versions
    public static var fnfVersion(default, null):String;
    public static var engineVersion(default, null):String;
    public static var modVersion(get, null):String;
    public static var forkVersion(default, null):String;
    public static var forkLatestVersion(default, null):String;
    public static var forkStage(default, null):String;

    public static function init() {
        fnfVersion = Application.current.meta.get('version');
        engineVersion = '0.7.3';
        forkVersion = '0.0.1';
        forkStage = 'alpha';

        var http = new haxe.Http("https://raw.githubusercontent.com/AlsoGhostglowDev/Ghost-s-Tweaked-Psych/main/forkVersion.txt");
        http.onData = function(data:String)
        {
            forkLatestVersion = data.split('\n')[0].trim();
            info('
            Version Info:
                FNF: $fnfVersion,
                Psych: $engineVersion,
                GTPsych: ${forkVersion + forkStage.substr(0,1)}
            ');
            if(forkLatestVersion != forkVersion) {
                warn('Current version is outdated.');
                states.TitleState.mustUpdate = true;
            }
        }
        http.onError = function (error) {
            trace('HTTP: $error');
        }
        http.request();
    }

    static function get_modVersion():String {
        return Mods.getPack()?.version ?? '0.0.0';
    }
}