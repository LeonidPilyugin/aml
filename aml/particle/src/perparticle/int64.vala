namespace AmlParticle
{
    public class Int64PerParticleProperty : PerParticleProperty
    {
        private Array<int64> array;

        public Int64PerParticleProperty.from_array(owned int64[] array)
        {
            this.set_arr(array);
        }

        public Int64PerParticleProperty.empty()
        {
            this.array = new Array<int64>();
        }

        public int64[] get_arr()
        {
            unowned var a = this.array.data;
            return a.copy();
        }

        public void set_arr(owned int64[] array)
        {
            this.array = new Array<int64>.take(array);
        }

        public void set_val(uint index, int64 value) throws PerParticlePropertyError.INDEX_ERROR
        {
            if (index >= this.array.length)
                throw new PerParticlePropertyError.INDEX_ERROR("Index out of range");
            this.array.insert_val(index, value);
            this.array.remove_index(index + 1);
        }

        public int64 get_val(uint index) throws PerParticlePropertyError.INDEX_ERROR
        {
            if (index >= this.array.length)
                throw new PerParticlePropertyError.INDEX_ERROR("Index out of range");
            return this.array.index(index);
        }

        public void insert_val(uint index, int64 value) throws PerParticlePropertyError.INDEX_ERROR, PerParticlePropertyError.SIZE_ERROR
        {
            if (this.get_size() == uint.MAX)
                throw new PerParticlePropertyError.SIZE_ERROR("Size out of range");
            if (index > this.get_size())
                throw new PerParticlePropertyError.INDEX_ERROR("Index out of range");
            this.array.insert_val(index, value);
        }

        public void insert_last(int64 value) throws PerParticlePropertyError.SIZE_ERROR
        {
            this.insert_val(this.get_size(), value);
        }

        public void insert_first(int64 value) throws PerParticlePropertyError.SIZE_ERROR
        {
            this.insert_val(0, value);
        }

        public override void remove_val(uint index) throws PerParticlePropertyError.INDEX_ERROR
        {
            if (index >= this.get_size())
                throw new PerParticlePropertyError.INDEX_ERROR("Index out of range");
            this.array.remove_index(index);
        }

        public override Variant get_val_variant(uint index) throws PerParticlePropertyError.INDEX_ERROR
        {
            return new Variant.int64(this.get_val(index));
        }

        public override void set_val_variant(uint index, Variant v) throws PerParticlePropertyError.INDEX_ERROR, PerParticlePropertyError.TYPE_ERROR
        {
            if (index >= this.get_size())
                throw new PerParticlePropertyError.INDEX_ERROR("Index is out of range");
            if (v.classify() != Variant.Class.INT64)
                throw new PerParticlePropertyError.TYPE_ERROR("Variant must hold int64");
            this.array.remove_index(index);
            var temp = v.get_int64();
            this.array.insert_val(index, temp);
        }

        public override void insert_val_variant(uint index, Variant v) throws PerParticlePropertyError.SIZE_ERROR, PerParticlePropertyError.INDEX_ERROR, PerParticlePropertyError.TYPE_ERROR
        {
            if (this.get_size() == uint.MAX)
                throw new PerParticlePropertyError.SIZE_ERROR("Size is out of range");
            if (index > this.get_size())
                throw new PerParticlePropertyError.INDEX_ERROR("Index is out of range");
            if (v.classify() != Variant.Class.INT64)
                throw new PerParticlePropertyError.TYPE_ERROR("Variant must hold int64");
            var temp = v.get_int64();
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

        public override PerParticleProperty copy()
        {
            return new Int64PerParticleProperty.from_array(this.get_arr());
        }

        public static Int64PerParticleProperty create_from(PerParticleProperty prop) throws PerParticlePropertyError.TYPE_ERROR
        {
            int64[] arr = new int64[prop.get_size()];

            if (prop is StringPerParticleProperty) {
                StringPerParticleProperty temp_prop = (StringPerParticleProperty) prop;
                for (uint i = 0; i < arr.length; i++)
                    if (!int64.try_parse(temp_prop.get_val(i), out arr[i]))
                        throw new PerParticlePropertyError.TYPE_ERROR(@"Cannot parse string \"$(temp_prop.get_val(i))\" at index $i to int64");
            } else if (prop is Int64PerParticleProperty) {
                Int64PerParticleProperty temp_prop = (Int64PerParticleProperty) prop;
                arr = temp_prop.get_arr();
            } else if (prop is Float64PerParticleProperty) {
                Float64PerParticleProperty temp_prop = (Float64PerParticleProperty) prop;
                double temp;
                for (uint i = 0; i < arr.length; i++)
                    arr[i] = (int64) temp_prop.get_val(i);
            } else if (prop is BoolPerParticleProperty) {
                BoolPerParticleProperty temp_prop = (BoolPerParticleProperty) prop;
                for (uint i = 0; i < arr.length; i++) {
                    arr[i] = temp_prop.get_val(i) ? 1 : 0;
                }
            } else {
                throw new PerParticlePropertyError.TYPE_ERROR("Unknown prop type");
            }

            return new Int64PerParticleProperty.from_array(arr);
        }
    }
}
