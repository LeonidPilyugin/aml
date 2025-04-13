using Gsl;
using AmlCore;

namespace AmlMath
{
    public errordomain VectorError
    {
        SIZE_ERROR,
        INDEX_ERROR,
        VALUE_ERROR,
    }

    /**
     *  A simple wrap over [[https://valadoc.org/gsl/Gsl.Vector.html|GSL Vector]]
     */
    public class Vector : AmlObject
    {
        /**
         * Wrapped GSL Vector
         */
        private Gsl.Vector vector; 

        /**
         * Creates sized Vector
         * 
         * @param size Size of Vector
         * 
         * @throws VectorError.SIZE_ERROR if size = 0
         */
        public Vector.sized(uint size) throws VectorError
        {
            if (size == 0)
                throw new VectorError.SIZE_ERROR("Got zero size");
            this.vector = new Gsl.Vector.with_zeros(size);
        }

        /**
         * Creates Vector initialized data
         * 
         * @param array Array to use as Vector data
         * 
         * @return New Vector initialized with data = array
         * 
         * @throws VectorError.SIZE_ERROR If array is empty
         */
        public Vector.from_array(double[] array) throws VectorError
        {
            this.sized(array.length);
            this.set_arr(array);
        }
        
        /**
         * Returns element by index
         * 
         * @param index Index
         * 
         * @return Element by index
         */
        public double get_val(uint index) throws VectorError
        {
            if (index >= this.get_size())
                throw new VectorError.INDEX_ERROR("Index is out of range");
            return this.vector.get(index);
        }

        /**
         * Sets element by index
         * 
         * @param index Index
         * @param value Value to set
         */
        public void set_val(uint index, double value)
            throws VectorError
        {
            if (index >= this.get_size())
                throw new VectorError.INDEX_ERROR("Index is out of range");
            this.vector.set(index, value);
        }

        /**
         * Returns copy of GSL Vector data
         * 
         * @return Copy of GSL Vector data
         */
        public double[] get_arr()
        {
            unowned double[] res = (double[]) this.vector.data;
            res.length = (int) (this.vector.size);
            return res.copy();
        }

        /**
         * Copies array to GSL Vector data
         * 
         * @param array Data to set
         */
        public void set_arr(double[] array)
            throws VectorError
        {
            if (array.length != this.vector.size)
                throw new VectorError.VALUE_ERROR("Got invalid array");
            Memory.copy(this.vector.data, (void*) array, sizeof(double) * array.length);
        }

        /**
         * Copies this object
         * 
         * @return Copy of this object
         */
        public Vector copy()
        {
            Vector result = new Vector.sized(this.get_size());
            result.vector.memcpy(this.vector);
            return result;
        }

        /**
         * Returns size
         * 
         * @return Size
         */
        public uint get_size()
        {
            return (uint) this.vector.size;
        }
    }
}
