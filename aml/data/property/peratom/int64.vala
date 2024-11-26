namespace Aml
{
    /**
     * Int peratom property
     */
    public class Int64PerAtomProperty : PerAtomProperty
    {
        private Array<int64> array;

        /**
         * Creates from array
         * 
         * @param array Array to use
         */
        public Int64PerAtomProperty.from_array(owned int64[] array)
        {
            this.set_arr(array);
        }

        /**
         * Creates new empty obejct
         */
        public Int64PerAtomProperty.empty()
        {
            this.array = new Array<int64>();
        }

        /**
         * Returns copy of array
         * 
         * @return Copy of array
         */
        public int64[] get_arr()
        {
            unowned var a = this.array.data;
            return a.copy();
        }

        /**
         * Sets array
         * 
         * @param array Array to set
         */
        public void set_arr(owned int64[] array)
        {
            this.array = new Array<int64>.take(array);
        }

        /**
         * Sets element by index
         * 
         * @param index Index
         * @param value Value to set
         * 
         * @throws CollectionError.INDEX_ERROR If got invalid index
         */
        public void set_val(uint index, int64 value) throws CollectionError
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
        public int64 get_val(uint index) throws CollectionError
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
        public void insert_val(uint index, int64 value) throws CollectionError
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
        public void insert_last(int64 value) throws CollectionError
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
        public void insert_first(int64 value) throws CollectionError
        {
            this.insert_val(0, value);
        }

        public override Variant get_val_variant(uint index)
        {
            return new Variant.int64(this.get_val(index));
        }

        public override void set_val_variant(uint index, Variant v)
        {
            if (this.get_size() == uint.MAX)
                throw new CollectionError.SIZE_ERROR("Size out of range");
            if (index > this.get_size())
                throw new CollectionError.INDEX_ERROR("Index out of range");
            if (v.classify() != Variant.Class.INT64)
                throw new PerAtomPropertyError.TYPE_ERROR("Value must hold int64");
            var temp = v.get_int64();
            this.array.insert_val(index, temp);
            this.array.remove_index(index + 1);
        }

        public override void insert_val_variant(uint index, Variant v)
        {
            if (this.get_size() == uint.MAX)
                throw new CollectionError.SIZE_ERROR("Size out of range");
            if (index > this.get_size())
                throw new CollectionError.INDEX_ERROR("Index out of range");
            if (v.classify() != Variant.Class.INT64)
                throw new PerAtomPropertyError.TYPE_ERROR("Value must hold int64");
            var temp = v.get_int64();
            this.array.insert_val(index, temp);
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
            return new Int64PerAtomProperty.from_array(this.get_arr());
        }

        public static Int64PerAtomProperty create_from(PerAtomProperty prop) {
            int64[] arr = new int64[prop.get_size()];

            if (prop is StringPerAtomProperty) {
                StringPerAtomProperty temp_prop = (StringPerAtomProperty) prop;
                for (uint i = 0; i < arr.length; i++) {
                    if (!int64.try_parse(temp_prop.get_val(i), out arr[i])) throw new PerAtomPropertyError.TYPE_ERROR("");
                }
            } else if (prop is Int64PerAtomProperty) {
                Int64PerAtomProperty temp_prop = (Int64PerAtomProperty) prop;
                arr = temp_prop.get_arr();
            } else if (prop is Float64PerAtomProperty) {
                Float64PerAtomProperty temp_prop = (Float64PerAtomProperty) prop;
                double temp;
                for (uint i = 0; i < arr.length; i++) {
                    temp = temp_prop.get_val(i);
                    if (temp > int64.MAX || temp < int64.MIN) throw new PerAtomPropertyError.TYPE_ERROR("");
                    arr[i] = (int64) temp;
                }
            } else if (prop is BoolPerAtomProperty) {
                BoolPerAtomProperty temp_prop = (BoolPerAtomProperty) prop;
                for (uint i = 0; i < arr.length; i++) {
                    arr[i] = temp_prop.get_val(i) ? 1 : 0;
                }
            } else {
                throw new PerAtomPropertyError.TYPE_ERROR("");
            }

            return new Int64PerAtomProperty.from_array(arr);
        }
    }
}
