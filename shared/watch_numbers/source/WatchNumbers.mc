import Toybox.Lang;

module WatchNumbers {
    function compact(value as Number or Null) as String {
        if (value == null) {
            return "--";
        }
        if (value >= 1000) {
            return Lang.format("$1$.$2$K", [value / 1000, (value % 1000) / 100]);
        }
        return value.format("%d");
    }
}
