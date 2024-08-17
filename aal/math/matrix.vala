using Gsl;

namespace Aal {
    public errordomain MatrixError {
        INVALID_SIZE
    }

    public class Matrix : Object {
        private Gsl.Matrix _matrix;

        public Matrix(uint rows, uint columns) {
            this._matrix = new Gsl.Matrix.with_zeros(rows, columns);
        }

        public Matrix.from_gsl_matrix(owned Gsl.Matrix matrix) {
            this._matrix = (owned) matrix;
        }

        public static Matrix sized(uint rows, uint columns) {
            return new Matrix(rows, columns);
        }

        public static Matrix square(uint size) {
            return Matrix.sized(size, size);
        }

        public unowned Gsl.Matrix _get_gsl_matrix() {
            return this._matrix;
        }

        public uint get_rows_number() {
            return (uint) this._matrix.size1;
        }

        public uint get_columns_number() {
            return (uint) this._matrix.size2;
        }

        public double get_val(uint row, uint column) {
            return this._matrix.get(row, column);
        }

        public void set_val(uint row, uint column, double value) {
            this._matrix.set(row, column, value);
        }

        public unowned double[] to_array() {
            unowned double[] result = (double[]) this._matrix.data;
            result.length = (int) (this._matrix.size1 * this._matrix.size2);
            return result;
        }

        public void set_array(double[] array, uint rows) {
            this._matrix = new Gsl.Matrix(rows, array.length / rows);
            this._matrix.data = array.copy();
        }

        public double det() throws MatrixError.INVALID_SIZE {
            if (this.get_rows_number() != this.get_columns_number())
                throw new MatrixError.INVALID_SIZE("Matrix should be square");
            double result;
            int s;

            Permutation p = new Permutation(this.get_rows_number());
            LinAlg.LU_decomp(this._matrix, p, out s);
            result = (double) s;

            for (uint i = 0; i < this.get_rows_number(); i++)
                result *= this._matrix.get(i, i);

            return result;
        }

        public Matrix copy() {
            var result = new Matrix(this.get_rows_number(), this.get_columns_number());
            result._matrix.memcpy(this._matrix);
            return result;
        }

        public bool is_diagonal() {
            for (uint i = 0; i < this.get_rows_number(); i++)
                for (uint j = 0; j < this.get_columns_number(); j++)
                    if (i != j && this._matrix.get(i, j) != 0.0)
                        return false;
            return true;
        }
    }
}
