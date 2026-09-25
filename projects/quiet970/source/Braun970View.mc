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
    private const METRIC_HEART_RATE = 0;
    private const METRIC_BATTERY = 1;
    private const METRIC_STEPS = 2;
    private const METRIC_STRESS = 3;

    private const COLOR_TIME = Graphics.COLOR_WHITE;
    private const COLOR_DATE = 0x8D9198;
    private const COLOR_VALUE = 0xD9DDE0;
    private const COLOR_LABEL = 0x666B73;
    private const COLOR_HEART_RATE = 0xF0A84B;

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
        var clock = System.getClockTime();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        drawClock(dc, centerX, (height * 0.32).toNumber(), clock);

        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var weekday = WEEKDAYS[today.day_of_week - 1];
        var month = MONTHS[today.month - 1];
        var dateText = Lang.format("$1$  $2$ $3$", [
            weekday,
            today.day.format("%02d"),
            month
        ]);

        dc.setColor(COLOR_DATE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            centerX,
            (height * 0.53).toNumber(),
            Graphics.FONT_SMALL,
            dateText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        drawDetails(dc, centerX, (height * 0.72).toNumber());
    }

    private function drawClock(dc as Dc, centerX as Number, y as Number, clock) as Void {
        var font = Graphics.FONT_NUMBER_HOT;
        var gap = (dc.getWidth() * 0.035).toNumber();
        var dotOffset = (dc.getFontHeight(font) * 0.16).toNumber();
        var dotRadius = (dc.getWidth() * 0.01).toNumber();
        var textStyle = Graphics.TEXT_JUSTIFY_VCENTER;

        dc.setColor(COLOR_TIME, Graphics.COLOR_TRANSPARENT);
        dc.drawText(centerX - gap, y, font, clock.hour.format("%02d"),
            Graphics.TEXT_JUSTIFY_RIGHT | textStyle);
        dc.drawText(centerX + gap, y, font, clock.min.format("%02d"),
            Graphics.TEXT_JUSTIFY_LEFT | textStyle);
        dc.fillCircle(centerX, y - dotOffset, dotRadius);
        dc.fillCircle(centerX, y + dotOffset, dotRadius);
    }

    private function drawDetails(
        dc as Dc,
        centerX as Number,
        y as Number
    ) as Void {
        var activityInfo = Activity.getActivityInfo();
        var monitorInfo = ActivityMonitor.getInfo();
        var battery = System.getSystemStats().battery.toNumber();

        var leftMetric = getMetric("left_metric");
        var centerMetric = getMetric("center_metric");
        var rightMetric = getMetric("right_metric");

        var leftX = (dc.getWidth() * 0.25).toNumber();
        var rightX = (dc.getWidth() * 0.75).toNumber();

        drawMetric(dc, leftX, y, leftMetric, activityInfo, monitorInfo, battery);
        drawMetric(dc, centerX, y, centerMetric, activityInfo, monitorInfo, battery);
        drawMetric(dc, rightX, y, rightMetric, activityInfo, monitorInfo, battery);

        var labelY = y + 34;
        var labelStyle = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;
        dc.setColor(COLOR_LABEL, Graphics.COLOR_TRANSPARENT);
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
        battery as Number
    ) as Void {
        var value = "--";
        var color = COLOR_VALUE;

        if (metric == METRIC_HEART_RATE) {
            var heartRate = activityInfo.currentHeartRate;
            value = heartRate == null ? "--" : heartRate.format("%d");
            color = COLOR_HEART_RATE;
        } else if (metric == METRIC_BATTERY) {
            value = battery.format("%d") + "%";
        } else if (metric == METRIC_STEPS) {
            value = WatchNumbers.compact(monitorInfo.steps);
        } else if (metric == METRIC_STRESS) {
            var stress = monitorInfo.stressScore;
            if (stress != null) {
                value = stress.format("%d");
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

    function onHide() as Void {
    }
}
