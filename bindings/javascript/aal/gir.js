exports.AAL_VERSION = "0.1"
exports.GLIB_VERSION = "2.0"
exports.GOBJECT_VERSION = "2.0"

const gi = require("node-gtk")

exports.gir_import = function gir_import(module, version) {
    return gi.require(module, version)
}

exports.Aal = exports.gir_import("Aal", exports.AAL_VERSION)
exports.GLib = exports.gir_import("GLib", exports.GLIB_VERSION)
exports.GObject = exports.gir_import("GObject", exports.GOBJECT_VERSION)
