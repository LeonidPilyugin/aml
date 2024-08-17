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

exports.Property = class Property extends AalWrapper {
    get id() {
        return this._object.getId()
    }
}

exports.FrameProperty = class FrameProperty extends Property {
    get data() {
        return this._object.getData()
    }

    set data(val) {
        this._object.setData(val)
    }
}

exports.PerAtomProperty = class PerAtomProperty extends Property {
    enum DType {
        INT,
        DOUBLE,
        STRING,
    }

    static from_array(id, array) {
        const val = array[0]
        let obj = null
        if (typeof val === "number" && val % 1 === val) {
            obj = Aal.IntPerAtomProperty.create(id, array)
        } else if (typeof val === "number" && val % 1 !=== val) {
            obj = Aal.DoublePerAtomProperty.create(id, array)
        } else if (typeof val === "string") {
            obj = Aal.StringPerAtomProperty.create(id, array)
        } else {
            throw new Error("Not implemented")
        }
        return new PerAtomProperty(obj)
    }

    get type() {
        if (this._object instanceof Aal.IntPerAtomProperty) {
            return DType.INT
        } else if (this._object instanceof Aal.DoublePerAtomProperty) {
            return DType.DOUBLE
        } else if (this._object instanceof Aal.StringPerAtomProperty) {
            return DType.STRING
        } else {
            throw new Error("Not implemented")
        }
    }

    get size() {
        return this._object.getSize()
    }

    set size(val) {
        this._object.setSize(val)
    }

    get_array() {
        return this._object.getArray()
    }

    set_array(val) {
        this._object.setArray(val)
    }

    get(i) {
        return this._object.getVal(i)
    }

    set(i, v) {
        this._object.setVal(i, v)
    }

    del(i) {
        this._object.delVal(i)
    }

    copy() {
        return new PerAtomProperty(this._object.copy())
    }
}
