namespace Aml
{
    /**
     * String peratom property
     */
    public class StringPerAtomProperty : PerAtomProperty
    {
        private Array<string> array;

        /**
         * Creates from array
         * 
         * @param array Array to use
         */
        public StringPerAtomProperty.from_array(owned string[] array)
        {
            this.set_arr(array);
        }

        /**
         * Creates new empty obejct
         */
        public StringPerAtomProperty.empty()
        {
            this.array = new Array<string>();
        }

        /**
         * Returns copy of array
         * 
         * @return Copy of array
         */
        public string[] get_arr()
        {
            unowned var a = this.array.data;
            return a.copy();
        }

        /**
         * Sets array
         * 
         * @param array Array to set
         */
        public void set_arr(owned string[] array)
        {
            this.array = new Array<string>.take(array);
        }

        /**
         * Sets element by index
         * 
         * @param index Index
         * @param value Value to set
         * 
         * @throws CollectionError.INDEX_ERROR If got invalid index
         */
        public void set_val(uint index, string value) throws CollectionError
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
        public string get_val(uint index) throws CollectionError
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
        public void insert_val(uint index, string value) throws CollectionError
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
        public void insert_last(string value) throws CollectionError
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
        public void insert_first(string value) throws CollectionError
        {
            this.insert_val(0, value);
        }

        public override Variant get_val_variant(uint index)
        {
            return new Variant.string(this.get_val(index));
        }

        public override void set_val_variant(uint index, Variant v)
        {
            if (this.get_size() == uint.MAX)
                throw new CollectionError.SIZE_ERROR("Size out of range");
            if (index > this.get_size())
                throw new CollectionError.INDEX_ERROR("Index out of range");
            if (v.classify() != Variant.Class.STRING)
                throw new PerAtomPropertyError.TYPE_ERROR("Value must hold string");
            var temp = v.get_string();
            this.array.insert_val(index, temp);
            this.array.remove_index(index + 1);
        }

        public override void insert_val_variant(uint index, Variant v)
        {
            if (this.get_size() == uint.MAX)
                throw new CollectionError.SIZE_ERROR("Size out of range");
            if (index > this.get_size())
                throw new CollectionError.INDEX_ERROR("Index out of range");
            if (v.classify() != Variant.Class.STRING)
                throw new PerAtomPropertyError.TYPE_ERROR("Value must hold string");
            var temp = v.get_string();
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
            return new StringPerAtomProperty.from_array(this.get_arr());
        }

        public static StringPerAtomProperty create_from(PerAtomProperty prop) {
            string[] arr = new string[prop.get_size()];

            if (prop is StringPerAtomProperty) {
                StringPerAtomProperty temp_prop = (StringPerAtomProperty) prop;
                arr = temp_prop.get_arr();
            } else if (prop is Int64PerAtomProperty) {
                Int64PerAtomProperty temp_prop = (Int64PerAtomProperty) prop;
                int64 temp;
                for (uint i = 0; i < arr.length; i++) {
                    temp = temp_prop.get_val(i);
                    arr[i] = temp.to_string();
                }
            } else if (prop is Float64PerAtomProperty) {
                Float64PerAtomProperty temp_prop = (Float64PerAtomProperty) prop;
                double temp;
                for (uint i = 0; i < arr.length; i++) {
                    temp = temp_prop.get_val(i);
                    arr[i] = temp.to_string();
                }
            } else if (prop is BoolPerAtomProperty) {
                BoolPerAtomProperty temp_prop = (BoolPerAtomProperty) prop;
                for (uint i = 0; i < arr.length; i++) {
                    arr[i] = temp_prop.get_val(i) ? "true" : "false";
                }
            } else {
                throw new PerAtomPropertyError.TYPE_ERROR("");
            }

            return new StringPerAtomProperty.from_array(arr);
        }
    }
}
