using Toybox.Application;
using Toybox.Lang;
using Toybox.WatchUi;

class Braun970App extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new Braun970View() ];
    }
}

