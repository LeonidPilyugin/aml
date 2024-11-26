namespace Aml
{
    /**
     * Int peratom property
     */
    public class BoolPerAtomProperty : PerAtomProperty
    {
        private Array<bool> array;

        /**
         * Creates from array
         * 
         * @param array Array to use
         */
        public BoolPerAtomProperty.from_array(owned bool[] array)
        {
            this.set_arr(array);
        }

        /**
         * Creates new empty obejct
         */
        public BoolPerAtomProperty.empty()
        {
            this.array = new Array<bool>();
        }

        /**
         * Returns copy of array
         * 
         * @return Copy of array
         */
        public bool[] get_arr()
        {
            unowned var a = this.array.data;
            return a.copy();
        }

        /**
         * Sets array
         * 
         * @param array Array to set
         */
        public void set_arr(owned bool[] array)
        {
            this.array = new Array<bool>.take(array);
        }

        /**
         * Sets element by index
         * 
         * @param index Index
         * @param value Value to set
         * 
         * @throws CollectionError.INDEX_ERROR If got invalid index
         */
        public void set_val(uint index, bool value) throws CollectionError
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
        public bool get_val(uint index) throws CollectionError
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
        public void insert_val(uint index, bool value) throws CollectionError
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
        public void insert_last(bool value) throws CollectionError
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
        public void insert_first(bool value) throws CollectionError
        {
            this.insert_val(0, value);
        }

        public override void remove_val(uint index) throws CollectionError
        {
            if (index >= this.get_size())
                throw new CollectionError.INDEX_ERROR("Index out of range");
            this.array.remove_index(index);
        }

        public override Variant get_val_variant(uint index)
        {
            return new Variant.boolean(this.get_val(index));
        }

        public override void set_val_variant(uint index, Variant v)
        {
            if (this.get_size() == uint.MAX)
                throw new CollectionError.SIZE_ERROR("Size out of range");
            if (index > this.get_size())
                throw new CollectionError.INDEX_ERROR("Index out of range");
            if (v.classify() != Variant.Class.BOOLEAN)
                throw new PerAtomPropertyError.TYPE_ERROR("Value must hold bool");
            var temp = v.get_boolean();
            this.array.insert_val(index, temp);
            this.array.remove_index(index + 1);
        }

        public override void insert_val_variant(uint index, Variant v)
        {
            if (this.get_size() == uint.MAX)
                throw new CollectionError.SIZE_ERROR("Size out of range");
            if (index > this.get_size())
                throw new CollectionError.INDEX_ERROR("Index out of range");
            if (v.classify() != Variant.Class.BOOLEAN)
                throw new PerAtomPropertyError.TYPE_ERROR("Value must hold bool");
            var temp = v.get_boolean();
            this.array.insert_val(index, temp);
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
            return new BoolPerAtomProperty.from_array(this.get_arr());
        }

        public static BoolPerAtomProperty create_from(PerAtomProperty prop) {
            bool[] arr = new bool[prop.get_size()];

            if (prop is StringPerAtomProperty) {
                StringPerAtomProperty temp_prop = (StringPerAtomProperty) prop;
                for (uint i = 0; i < arr.length; i++) {
                    if (!bool.try_parse(temp_prop.get_val(i), out arr[i])) throw new PerAtomPropertyError.TYPE_ERROR("");
                }
            } else if (prop is Int64PerAtomProperty) {
                Int64PerAtomProperty temp_prop = (Int64PerAtomProperty) prop;
                for (uint i = 0; i < arr.length; i++) {
                    arr[i] = temp_prop.get_val(i) != 0;
                }
            } else if (prop is Float64PerAtomProperty) {
                Float64PerAtomProperty temp_prop = (Float64PerAtomProperty) prop;
                for (uint i = 0; i < arr.length; i++) {
                    arr[i] = temp_prop.get_val(i) != 0.0;
                }
            } else if (prop is BoolPerAtomProperty) {
                BoolPerAtomProperty temp_prop = (BoolPerAtomProperty) prop;
                arr = temp_prop.get_arr();
            } else {
                throw new PerAtomPropertyError.TYPE_ERROR("");
            }

            return new BoolPerAtomProperty.from_array(arr);
        }
    }
}
