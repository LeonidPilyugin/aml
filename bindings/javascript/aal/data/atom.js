const gir = require("../gir.js")
const Aal = gir.Aal
const GObject = gir.GObject
const AalWrapper = require("../wrapper.js").AalWrapper

exports.Atom = class Atom extends AalWrapper {
    static create() {
        const obj = Aal.Atom.create()
        return new Atom(obj)
    }

    static #val_to_js(val) {
        if (val.gType === GObject.TYPE_INT) {
            return val.getInt()
        } else if (val.gType === GObject.TYPE_DOUBLE) {
            return val.getDouble()
        } else if (val.gType === GObject.TYPE_STRING) {
            return val.getString()
        } else {
            throw new Error("Value type is not implemented")
        }
    }

    static #js_to_val(val) {
        const res = new GObject.Value()
        if (typeof val === "number" && val % 1 === val) {
            res.init(GObject.TYPE_INT)
            res.setInt(val)
            return res
        } else if (typeof val === "number" && val % 1 !== val) {
            res.init(GObject.TYPE_DOUBLE)
            res.setDouble(val)
            return res
        } else if (typeof val === "string") {
            res.init(GObject.TYPE_STRING)
            res.setString(val)
            return res
        } else {
            throw new Error("Type is not implemented")
        }
    }

    get(i) {
        return Atom.#val_to_js(this._object.getProp(i))
    }

    set(i, v) {
        this._object.setProp(i, Atom.#js_to_val(v))
    }

    del(i) {
        this._object.delProp(i)
    }

    get keys() {
        return this._object.getPropIds()
    }

    copy() {
        return new Atom(this._object.copy())
    }
}
