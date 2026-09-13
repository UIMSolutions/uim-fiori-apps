sap.ui.define([], function () {
    "use strict";
    var VALID_STATES = {
        None: true,
        Success: true,
        Warning: true,
        Error: true,
        Information: true
    };
    function normalizeState(value) {
        if (!value) {
            return "None";
        }
        if (value === "Good") {
            return "Success";
        }
        if (value === "Critical") {
            return "Warning";
        }
        if (VALID_STATES[value]) {
            return value;
        }
        return "None";
    }
    return {
        toValueState: normalizeState
    };
});
