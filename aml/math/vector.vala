using Gsl;

namespace Aml
{
    /**
     *  A simple wrap over [[https://valadoc.org/gsl/Gsl.Vector.html|GSL Vector]]
     */
    public class Vector :
        Object
    {
        /**
         * Wrapped GSL Vector
         */
        public Gsl.Vector vector { get; private owned set; } 

        /**
         * Creates sized Vector
         * 
         * @param size Size of Vector
         * 
         * @throws CollectionError.SIZE_ERROR if size = 0
         */
        public Vector.sized(uint size)
            throws CollectionError.SIZE_ERROR
        {
            if (size == 0)
                throw new CollectionError.SIZE_ERROR("Got zero size");
            this.vector = new Gsl.Vector.with_zeros(size);
        }

        /**
         * Creates Vector from GSL Vector
         * 
         * @param vector GSL Vector to wrap
         * 
         * @throws CollectionError.SIZE_ERROR if size of vector is 0
         */
        public Vector.from_gsl(owned Gsl.Vector vector)
            throws CollectionError.SIZE_ERROR
        {
            if (vector.size == 0)
                throw new CollectionError.SIZE_ERROR("Got zero-sized vector");
            this.vector = (owned) vector;
        }

        /**
         * Creates Vector initialized data
         * 
         * @param array Array to use as Vector data
         * 
         * @return New Vector initialized with data = array
         * 
         * @throws CollectionError.SIZE_ERROR If array is empty
         */
        public Vector.from_array(double[] array)
            throws CollectionError.SIZE_ERROR
        {
            this.sized(array.length);
            this.set_arr(array);
        }

        public double get_val(uint index)
            throws CollectionError
        {
            if (index >= this.get_size())
                throw new CollectionError.INDEX_ERROR("Index is out of range");
            return this.vector.get(index);
        }

        public void set_val(uint index, double value)
            throws CollectionError
        {
            if (index >= this.get_size())
                throw new CollectionError.INDEX_ERROR("Index is out of range");
            this.vector.set(index, value);
        }

        public double[] get_arr()
        {
            unowned double[] res = (double[]) this.vector.data;
            res.length = (int) (this.vector.size);
            return res.copy();
        }

        public void set_arr(double[] array)
            throws CollectionError
        {
            if (array.length != this.vector.size)
                throw new CollectionError.VALUE_ERROR("Got invalid array");
            Memory.copy(this.vector.data, (void*) array, sizeof(double) * array.length);
        }

        public Vector copy()
        {
            Vector result = new Vector.sized(this.get_size());
            result.vector.memcpy(this.vector);
            return result;
        }

        public uint get_size()
        {
            return (uint) this.vector.size;
        }
    }
}
