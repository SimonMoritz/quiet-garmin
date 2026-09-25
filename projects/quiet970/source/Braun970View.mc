import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Application.Properties;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class Braun970View extends WatchUi.WatchFace {
    private var _sleeping as Boolean = false;

    private const METRIC_HEART_RATE = 0;
    private const METRIC_BATTERY = 1;
    private const METRIC_STEPS = 2;
    private const METRIC_STRESS = 3;

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
        var driftX = _sleeping ? ((clock.min % 3) - 1) * 3 : 0;
        var driftY = _sleeping ? (((clock.min / 3) % 3) - 1) * 3 : 0;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var foreground = _sleeping ? 0x777777 : Graphics.COLOR_WHITE;
        var secondary = _sleeping ? 0x444444 : 0x8D9198;
        var accent = _sleeping ? 0x555555 : 0xF0A84B;

        var timeText = Lang.format("$1$:$2$", [
            clock.hour.format("%02d"),
            clock.min.format("%02d")
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
        var monitorInfo = ActivityMonitor.getInfo();
        var battery = System.getSystemStats().battery.toNumber();

        var leftMetric = getMetric("left_metric");
        var centerMetric = getMetric("center_metric");
        var rightMetric = getMetric("right_metric");

        var leftX = (dc.getWidth() * 0.25).toNumber();
        var rightX = (dc.getWidth() * 0.75).toNumber();

        drawMetric(dc, leftX, y, leftMetric, activityInfo, monitorInfo, battery, accent, secondary);
        drawMetric(dc, centerX, y, centerMetric, activityInfo, monitorInfo, battery, accent, secondary);
        drawMetric(dc, rightX, y, rightMetric, activityInfo, monitorInfo, battery, accent, secondary);

        var labelY = y + 34;
        var labelStyle = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        dc.setColor(secondary, Graphics.COLOR_TRANSPARENT);
        dc.drawText(leftX, labelY, Graphics.FONT_XTINY, metricLabel(leftMetric), labelStyle);
        dc.drawText(centerX, labelY, Graphics.FONT_XTINY, metricLabel(centerMetric), labelStyle);
        dc.drawText(rightX, labelY, Graphics.FONT_XTINY, metricLabel(rightMetric), labelStyle);
    }

    private function drawMetric(
        dc as Dc,
        x as Number,
        y as Number,
        metric as Number,
        activityInfo,
        monitorInfo,
        battery as Number,
        accent as Number,
        secondary as Number
    ) as Void {
        var value = "--";
        var color = secondary;

        if (metric == METRIC_HEART_RATE) {
            var heartRate = activityInfo.currentHeartRate;
            value = heartRate == null ? "--" : heartRate.format("%d");
            color = accent;
        } else if (metric == METRIC_BATTERY) {
            value = battery.format("%d") + "%";
        } else if (metric == METRIC_STEPS) {
            value = WatchNumbers.compact(monitorInfo.steps);
        } else if (metric == METRIC_STRESS) {
            var stress = monitorInfo.stressScore;
            if (stress != null) {
                value = stress.format("%d");
                color = stressColor(stress);
            }
        }

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x,
            y,
            Graphics.FONT_TINY,
            value,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    private function getMetric(key as String) as Number {
        return Properties.getValue(key).toNumber();
    }

    private function metricLabel(metric as Number) as String {
        if (metric == METRIC_HEART_RATE) {
            return "BPM";
        } else if (metric == METRIC_BATTERY) {
            return "BATT";
        } else if (metric == METRIC_STEPS) {
            return "STEPS";
        }
        return "STRESS";
    }

    private function stressColor(stress as Number) as Number {
        if (stress <= 25) {
            return 0x4A90E2;
        } else if (stress <= 50) {
            return 0x58B957;
        } else if (stress <= 75) {
            return 0xF2C94C;
        }
        return 0xEB5757;
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
