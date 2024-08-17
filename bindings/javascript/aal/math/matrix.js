const Aal = require("../gir.js").Aal
const AalWrapper = require("../wrapper.js").AalWrapper

exports.Matrix = class Matrix extends AalWrapper {
    get size() {
        return [this._object.getRowsNumber(), this._object.getColumnsNumber()]
    }

    get rows() {
        return this._object.getRowsNumber()
    }

    get columns() {
        return this._object.getColumnsNumber()
    }

    static sized(rows, columns) {
        const obj = Aal.Matrix.create(rows, columns)
        return new Matrix(obj)
    }

    static from_array(array) {
        const arr = []
        for (let i = 0; i < array.length; i++) {
            for (let j = 0; j < array[0].length; j++) {
                arr[i * array[0].length + j] = array[i][j]
            }
        }
        const res = new Matrix()
        res._object.setArray(arr, array.length)
        return res
    }

    get(i, j) {
        return this._object.getVal(i, j)
    }

    set(i, j, v) {
        this._object.setVal(i, j, v)
    }

    to_array() {
        const arr = new Array(this.rows)
        const ar = this._object.toArray()
        for (let i = 0; i < arr.length; i++) {
            arr[i] = new Array(this.columns)
            for (let j = 0; j < this.columns; j++) {
                arr[i][j] = ar[i * this.rows + j]
            }
        }
        return arr
    }

    copy() {
        result = new Matrix(this.rows, this.columns)
        result._object = this._object.copy()
        return result
    }

    get det() {
        return this._object.det()
    }

    get is_diagonal() {
        return this._object.isDiagonal()
    }
}
