namespace Aml
{
    /**
     * Int peratom property
     */
    public class IntPerAtomProperty : PerAtomProperty
    {
        private Array<int> array;

        /**
         * Creates from array
         * 
         * @param array Array to use
         */
        public IntPerAtomProperty.from_array(owned int[] array)
        {
            this.set_arr(array);
        }

        /**
         * Creates new empty obejct
         */
        public IntPerAtomProperty.empty()
        {
            this.array = new Array<int>();
        }

        /**
         * Returns copy of array
         * 
         * @return Copy of array
         */
        public int[] get_arr()
        {
            unowned var a = this.array.data;
            return a.copy();
        }

        /**
         * Sets array
         * 
         * @param array Array to set
         */
        public void set_arr(owned int[] array)
        {
            this.array = new Array<int>.take(array);
        }

        /**
         * Sets element by index
         * 
         * @param index Index
         * @param value Value to set
         * 
         * @throws CollectionError.INDEX_ERROR If got invalid index
         */
        public void set_val(uint index, int value) throws CollectionError
        {
            if (index >= this.array.length)
                throw new CollectionError.INDEX_ERROR("Index out of range");
            this.array.insert_val(index, value);
            this.array.remove_index(index + 1);
        }

        /**
         * Returns element by index
         * 
         * @param index Index
         * 
         * @return Element by index
         * 
         * @throws CollectionError.INDEX_ERROR If got invalid index
         */
        public int get_val(uint index) throws CollectionError
        {
            if (index >= this.array.length)
                throw new CollectionError.INDEX_ERROR("Index out of range");
            return this.array.index(index);
        }

        /**
         * Inserts value to index
         * 
         * @param index Index
         * @param value Value to insert
         * 
         * @throws CollectionError.SIZE_ERROR If new size is too big
         * @throws CollectionError.INDEX_ERROR If index is out of range
         */
        public void insert_val(uint index, int value) throws CollectionError
        {
            if (this.get_size() == uint.MAX)
                throw new CollectionError.SIZE_ERROR("Size out of range");
            if (index > this.get_size())
                throw new CollectionError.INDEX_ERROR("Index out of range");
            this.array.insert_val(index, value);
        }

        /**
         * Inserts value to last position
         * 
         * @param value Value to insert
         * 
         * @throws CollectionError.SIZE_ERROR If new size is too big
         */
        public void insert_last(int value) throws CollectionError
        {
            this.insert_val(this.get_size(), value);
        }

        /**
         * Inserts value to first position
         * 
         * @param value Value to insert
         * 
         * @throws CollectionError.SIZE_ERROR If new size is too big
         * @throws CollectionError.INDEX_ERROR If index is out of range
         */
        public void insert_first(int value) throws CollectionError
        {
            this.insert_val(0, value);
        }

        public override void remove_val(uint index) throws CollectionError
        {
            if (index >= this.get_size())
                throw new CollectionError.INDEX_ERROR("Index out of range");
            this.array.remove_index(index);
        }

        public override uint get_size()
        {
            return this.array.length;
        }

        public override void set_size(uint size)
        {
            this.array.set_size(size);
        }

        public override PerAtomProperty copy()
        {
            return new IntPerAtomProperty.from_array(this.get_arr());
        }
    }
}
