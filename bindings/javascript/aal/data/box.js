const Aal = require("../gir.js").Aal
const AalWrapper = require("../wrapper.js").AalWrapper
const Matrix = require("../math/matrix.js").Matrix
const Vector = require("../math/vector.js").Vector

exports.Box = class Box extends AalWrapper {
    get volume() {
        return this._object.getVolume()
    }
}

exports.ParallelepipedBox = class ParallelepipedBox extends exports.Box {
    static create(origin, edge, boundaries) {
        const obj = Aal.ParallelepipedBox.create(origin._object, edge._object, boundaries)
        return new ParallelepipedBox(obj)
    }

    get edge() {
        return new Matrix(this._object.getEdge())
    }

    set edge(value) {
        this._object.setEdge(value._object)
    }

    get origin() {
        return new Vector(this._object.getOrigin())
    }

    set origin(value) {
        this._object.setOrigin(value._object)
    }

    get boundaries() {
        return this._object.getBoundaries()
    }

    set boundaries(value) {
        this._object.setBoundaries(value)
    }
}
