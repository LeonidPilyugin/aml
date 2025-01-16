namespace AmlParticles
{
    public interface ConvertableToInt64 : Object
    {
        public abstract Int64PerParticleProperty convert_to_int64() throws PerParticlePropertyError.TYPE_ERROR;
    }

    public class Int64PerParticleProperty : PerParticleProperty, ConvertableToBool, ConvertableToFloat64, ConvertableToString, ConvertableToInt64
    {
        private Array<int64> array = new Array<int64>();

        public Int64PerParticleProperty.from_array(owned int64[] array)
        {
            this.set_arr(array);
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
            int64 *temp = this.array.data;
            temp[index] = value;
            //this.array.data[index] = value;
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
            if (v.classify() != Variant.Class.INT64)
                throw new PerParticlePropertyError.TYPE_ERROR("Variant must hold int64");
            var temp = v.get_int64();
            this.set_val(index, temp);
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

        public override BoolPerParticleProperty convert_to_bool()
        {
            var res = new BoolPerParticleProperty();
            res.set_size(this.get_size());
            for (uint i = 0; i < this.get_size(); i++)
                res.set_val(i, this.get_val(i) == 0);
            return res;
        }

        public override Float64PerParticleProperty convert_to_float64()
        {
            var res = new Float64PerParticleProperty();
            res.set_size(this.get_size());
            for (uint i = 0; i < this.get_size(); i++)
                res.set_val(i, (double) this.get_val(i));
            return res;
        }

        public override StringPerParticleProperty convert_to_string()
        {
            var res = new StringPerParticleProperty();
            res.set_size(this.get_size());
            for (uint i = 0; i < this.get_size(); i++)
                res.set_val(i, this.get_val(i).to_string());
            return res;
        }

        public override void replace_with(PerParticleProperty property) throws PerParticlePropertyError.TYPE_ERROR
        {
            if (!(property is ConvertableToInt64))
                throw new PerParticlePropertyError.TYPE_ERROR(@"Cannot convert to int64");
            var prop = (ConvertableToInt64) property;
            var temp = prop.convert_to_int64();
            this.array = temp.array;
        }

        public override Int64PerParticleProperty convert_to_int64()
        {
            return (Int64PerParticleProperty) this.copy();
        }
    }
}
