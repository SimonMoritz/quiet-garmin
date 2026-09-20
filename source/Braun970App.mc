import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class Braun970App extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new Braun970View() ];
    }

    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }
}
