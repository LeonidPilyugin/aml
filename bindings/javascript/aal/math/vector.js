const Aal = require("../gir.js").Aal
const AalWrapper = require("../wrapper.js").AalWrapper

exports.Vector = class Vector extends AalWrapper {
    constructor(size = 3) {
        super()
        this._object = new Aal.Vector.create(size)
    }

    get size() {
        return this._object.get_size()
    }

    static from_array(array) {
        const res = new Vector(1)
        res._object.setArray(array)
        return res
    }

    get(i) {
        return this._object.getVal(i)
    }

    set(i, v) {
        this._object.setVal(i, v)
    }

    to_array() {
        return this._object.toArray()
    }

    copy() {
        result = new Vector(this.size)
        result._object = this._object.copy()
        return result
    }
}
