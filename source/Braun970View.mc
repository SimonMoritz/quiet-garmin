import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class Braun970View extends WatchUi.WatchFace {
    private var _sleeping as Boolean = false;

    private const MONTHS = [
        "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
        "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
    ];

    private const WEEKDAYS = [
        "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"
    ];

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var centerX = width / 2;

        // Move the low-power layout a few pixels over time to reduce AMOLED wear.
        var clock = System.getClockTime();
        var driftX = _sleeping ? ((clock.minute % 3) - 1) * 3 : 0;
        var driftY = _sleeping ? (((clock.minute / 3) % 3) - 1) * 3 : 0;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var foreground = _sleeping ? 0x777777 : Graphics.COLOR_WHITE;
        var secondary = _sleeping ? 0x444444 : 0x8D9198;
        var accent = _sleeping ? 0x555555 : 0xF0A84B;

        var timeText = Lang.format("$1$:$2$", [
            clock.hour.format("%02d"),
            clock.minute.format("%02d")
        ]);

        dc.setColor(foreground, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX + driftX,
            (height * 0.32).toNumber() + driftY,
            Graphics.FONT_NUMBER_HOT,
            timeText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var weekday = WEEKDAYS[today.day_of_week - 1];
        var month = MONTHS[today.month - 1];
        var dateText = Lang.format("$1$  $2$ $3$", [
            weekday,
            today.day.format("%02d"),
            month
        ]);

        dc.setColor(secondary, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX + driftX,
            (height * 0.53).toNumber() + driftY,
            Graphics.FONT_SMALL,
            dateText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Keep the always-on display intentionally sparse and inexpensive.
        if (!_sleeping) {
            drawDetails(dc, centerX, (height * 0.72).toNumber(), accent, secondary);
        }
    }

    private function drawDetails(
        dc as Dc,
        centerX as Number,
        y as Number,
        accent as Number,
        secondary as Number
    ) as Void {
        var activityInfo = Activity.getActivityInfo();
        var heartRate = activityInfo.currentHeartRate;
        var heartText = heartRate == null ? "--" : heartRate.format("%d");

        var monitorInfo = ActivityMonitor.getInfo();
        var stepsText = compactNumber(monitorInfo.steps);

        var battery = System.getSystemStats().battery.toNumber();
        var batteryText = battery.format("%d%%");

        var leftX = (dc.getWidth() * 0.25).toNumber();
        var rightX = (dc.getWidth() * 0.75).toNumber();

        dc.setColor(accent, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            leftX,
            y,
            Graphics.FONT_TINY,
            Lang.format("$1$ BPM", [heartText]),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(secondary, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            y,
            Graphics.FONT_TINY,
            batteryText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawText(
            rightX,
            y,
            Graphics.FONT_TINY,
            Lang.format("$1$ STEPS", [stepsText]),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function compactNumber(value as Number or Null) as String {
        if (value == null) {
            return "--";
        }
        if (value >= 1000) {
            return Lang.format("$1$.$2$K", [value / 1000, (value % 1000) / 100]);
        }
        return value.format("%d");
    }

    function onHide() as Void {
    }

    function onExitSleep() as Void {
        _sleeping = false;
        WatchUi.requestUpdate();
    }

    function onEnterSleep() as Void {
        _sleeping = true;
        WatchUi.requestUpdate();
    }
}
