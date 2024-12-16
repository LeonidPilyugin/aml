using Gsl;
using AmlCore;

namespace AmlMath
{
    public errordomain MatrixError
    {
        SIZE_ERROR,
        INDEX_ERROR,
        VALUE_ERROR,
    }

    /**
     * A simple wrap over [[https://valadoc.org/gsl/Gsl.Matrix.html|GSL Matrix]]
     */
    public class Matrix : AmlObject
    {
        /**
         * Wrapped Gsl.Matrix
         */
        public Gsl.Matrix matrix { get; private owned set; }

        /**
         * Creates sized Matrix
         * 
         * @param rows Number of rows
         * @param columns Number of columns
         * 
         * @throws MatrixError.SIZE_ERROR if one of sizes is 0
         */
        public Matrix.sized(uint rows, uint columns) throws MatrixError
        {
            if (rows == 0)
                throw new MatrixError.SIZE_ERROR("Got zero rows");
            if (columns == 0)
                throw new MatrixError.SIZE_ERROR("Got zero columns");
            this.matrix = new Gsl.Matrix.with_zeros(rows, columns);
        }

        /**
         * Creates Matrix from GSL Matrix
         *
         * @param matrix GSL Matrix
         * 
         * @throws MatrixError.SIZE_ERROR If one of dimensions of matrix is 0
         */
        public Matrix.from_gsl(owned Gsl.Matrix matrix) throws MatrixError
        {
            if (matrix.size1 == 0 || matrix.size2 == 0)
                throw new MatrixError.SIZE_ERROR("One of dimensions is zero");
            this.matrix = (owned) matrix;
        }

        /**
         * Creates Matrix initialized data
         * 
         * @param array Array to use as Matrix data
         * @param rows Number of rows
         * 
         * @return New Matrix initialized with data = array
         * 
         * @throws MatrixError.SIZE_ERROR If array is invalid
         */
        public Matrix.from_array(double[] array, uint rows) throws MatrixError
        {
            if (rows == 0)
                throw new MatrixError.SIZE_ERROR("Got zero rows");
            if (array.length == 0)
                throw new MatrixError.SIZE_ERROR("Got empty array");
            if (array.length % rows != 0)
                throw new MatrixError.SIZE_ERROR("Got invalid array");

            this.sized(rows, array.length / rows);
            this.set_arr(array);
        }

        /**
         * Number of rows
         * 
         * @return Number of rows
         */
        public uint get_rows()
        {
            return (uint) this.matrix.size1;
        }

        /**
         * Number of columns
         * 
         * @return Number of columns
         */
        public uint get_columns()
        {
            return (uint) this.matrix.size2;
        }

        /**
         * Returns element by row and column indeces
         * 
         * @param row Row index
         * @param column Column index
         * 
         * @return Element by row and column indeces
         */
        public double get_val(uint row, uint column)
            throws MatrixError.INDEX_ERROR
        {
            if (row >= this.get_rows())
                throw new MatrixError.INDEX_ERROR("Row index out of range");
            if (column >= this.get_columns())
                throw new MatrixError.INDEX_ERROR("Column index out of range");
            return this.matrix.get(row, column);
        }

        /**
         * Sets element by row and column indeces
         * 
         * @param row Row index
         * @param column Column index
         * @param value Value to set
         */
        public void set_val(uint row, uint column, double value)
            throws MatrixError.INDEX_ERROR
        {
            if (row >= this.get_rows())
                throw new MatrixError.INDEX_ERROR("Row index out of range");
            if (column >= this.get_columns())
                throw new MatrixError.INDEX_ERROR("Column index out of range");
            this.matrix.set(row, column, value);
        }

        /**
         * Returns copy of GSL Matrix data
         * 
         * @return Copy of GSL Matrix data
         */
        public double[] get_arr()
        {
            unowned double[] res = (double[]) this.matrix.data;
            res.length = (int) (this.matrix.size1 * this.matrix.size2);
            return res.copy();
        }

        /**
         * Copies array to GSL Matrix data
         * 
         * @param array Data to set
         */
        public void set_arr(double[] array)
            throws MatrixError
        {
            if (array.length != this.matrix.size1 * this.matrix.size2)
                throw new MatrixError.VALUE_ERROR("Got invalid array");
            Memory.copy(this.matrix.data, (void*) array, sizeof(double) * array.length);
        }

        /**
         * Copies this object
         * 
         * @return Copy of this object
         */
        public Matrix copy()
        {
            var result = new Matrix.sized(this.get_rows(), this.get_columns());
            result.matrix.memcpy(this.matrix);
            return result;
        }

        /**
         * Returns determinant of matrix
         * 
         * @return Determinant
         * 
         * @throws MatrixError.SIZE_ERROR If Matrix is not squared
         */
        public double det()
            throws MatrixError.SIZE_ERROR
        {
            if (this.get_rows() != this.get_columns())
                throw new MatrixError.SIZE_ERROR("Matrix should be square");
            double result;
            int s;

            Permutation p = new Permutation(this.get_rows());
            LinAlg.LU_decomp(this.matrix, p, out s);
            result = (double) s;

            for (uint i = 0; i < this.get_rows(); i++)
                result *= this.matrix.get(i, i);

            return result;
        }

        /**
         * Returns true if this matrix is diagonal
         * 
         * @return True if this matrix is diagonal
         */
        public bool is_diagonal()
        {
            for (uint i = 0; i < this.get_rows(); i++)
                for (uint j = 0; j < this.get_columns(); j++)
                    if (i != j && this.matrix.get(i, j) != 0.0)
                        return false;
            return true;
        }
    }
}
