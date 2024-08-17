const Aal = require("../gir.js").Aal
const AalWrapper = require("../wrapper.js").AalWrapper
const Atom = require("./atom.js").Atom
const PerAtomProperty = require("./property.js").PerAtomProperty

exports.Atoms = class Atoms extends AalWrapper {
    static sized(size) {
        const obj = new Aal.Atoms.create(size)
        return new Atoms(obj)
    }

    get size() {
        return this._object.getSize()
    }

    set size(val) {
        this._object.setSize(val)
    }

    get(i) {
        if (typeof i === "string") {
            return new PerAtomProperty(this._object.getProp(i))
        } else if (typeof i === "number") {
            return new Atom(this._object.getAtom(i)
        } else {
            throw new Error("NotImplemented")
        }
    }

    set(i, v) {
        if (typeof i === "string") {
            this._object.setProp(i, v._object)
        } else if (typeof i === "number") {
            this._object.setAtom(i, v._object)
        } else {
            throw new Error("NotImplemented")
        }
    }

    del(i) {
        if (typeof i === "string") {
            this._object.delProp(i)
        } else if (typeof i === "number") {
            this._object.delAtom(i)
        } else {
            throw new Error("NotImplemented")
        }
    }

    append(atom) {
        this._object.appendAtom(atom._object)
    }

    keys() {
        return this._object.getPropIds()
    }
}
