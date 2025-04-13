namespace AmlParticles
{
    public interface ConvertableToBool : Object
    {
        public abstract BoolPerParticleProperty convert_to_bool() throws PerParticlePropertyError.TYPE_ERROR;
    }

    public class BoolPerParticleProperty : PerParticleProperty, ConvertableToFloat64, ConvertableToInt64, ConvertableToString, ConvertableToBool
    {
        private Array<bool> array = new Array<bool>();

        public BoolPerParticleProperty.from_array(owned bool[] array)
        {
            this.set_arr(array);
        }

        public bool[] get_arr()
        {
            unowned var a = this.array.data;
            return a.copy();
        }

        public void set_arr(owned bool[] array)
        {
            this.array = new Array<bool>.take(array);
        }

        public void set_val(uint index, bool value) throws PerParticlePropertyError.INDEX_ERROR
        {
            if (index >= this.array.length)
                throw new PerParticlePropertyError.INDEX_ERROR("Index out of range");
            bool *temp = this.array.data;
            temp[index] = value;
        }

        public bool get_val(uint index) throws PerParticlePropertyError.INDEX_ERROR
        {
            if (index >= this.array.length)
                throw new PerParticlePropertyError.INDEX_ERROR("Index out of range");
            return this.array.index(index);
        }

        public void insert_val(uint index, bool value) throws PerParticlePropertyError.INDEX_ERROR, PerParticlePropertyError.SIZE_ERROR
        {
            if (this.get_size() == uint.MAX)
                throw new PerParticlePropertyError.SIZE_ERROR("Size out of range");
            if (index > this.get_size())
                throw new PerParticlePropertyError.INDEX_ERROR("Index out of range");
            this.array.insert_val(index, value);
        }

        public void insert_last(bool value) throws PerParticlePropertyError.SIZE_ERROR
        {
            this.insert_val(this.get_size(), value);
        }

        public void insert_first(bool value) throws PerParticlePropertyError.SIZE_ERROR
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
            return new Variant.boolean(this.get_val(index));
        }

        public override void set_val_variant(uint index, Variant v) throws PerParticlePropertyError.INDEX_ERROR, PerParticlePropertyError.TYPE_ERROR
        {
            if (v.classify() != Variant.Class.BOOLEAN)
                throw new PerParticlePropertyError.TYPE_ERROR("Variant must hold boolean");
            var temp = v.get_boolean();
            this.set_val(index, temp);
        }

        public override void insert_val_variant(uint index, Variant v) throws PerParticlePropertyError.SIZE_ERROR, PerParticlePropertyError.INDEX_ERROR, PerParticlePropertyError.TYPE_ERROR
        {
            if (this.get_size() == uint.MAX)
                throw new PerParticlePropertyError.SIZE_ERROR("Size is out of range");
            if (index > this.get_size())
                throw new PerParticlePropertyError.INDEX_ERROR("Index is out of range");
            if (v.classify() != Variant.Class.BOOLEAN)
                throw new PerParticlePropertyError.TYPE_ERROR("Variant must hold boolean");
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

        public override PerParticleProperty copy()
        {
            return new BoolPerParticleProperty.from_array(this.get_arr());
        }

        public override Float64PerParticleProperty convert_to_float64()
        {
            var res = new Float64PerParticleProperty();
            res.set_size(this.get_size());
            for (uint i = 0; i < this.get_size(); i++)
                res.set_val(i, this.get_val(i) ? 1.0 : 0.0);
            return res;
        }

        public override Int64PerParticleProperty convert_to_int64()
        {
            var res = new Int64PerParticleProperty();
            res.set_size(this.get_size());
            for (uint i = 0; i < this.get_size(); i++)
                res.set_val(i, this.get_val(i) ? 1 : 0);
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
            if (!(property is ConvertableToBool))
                throw new PerParticlePropertyError.TYPE_ERROR(@"Cannot convert to bool");
            var prop = (ConvertableToBool) property;
            var temp = prop.convert_to_bool();
            this.array = temp.array;
        }

        public override BoolPerParticleProperty convert_to_bool()
        {
            return (BoolPerParticleProperty) this.copy();
        }
    }
}
