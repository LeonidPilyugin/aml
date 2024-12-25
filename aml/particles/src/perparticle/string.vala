namespace AmlParticles
{
    public interface ConvertableToString : Object
    {
        public abstract StringPerParticleProperty convert_to_string() throws PerParticlePropertyError.TYPE_ERROR;
    }

    public class StringPerParticleProperty : PerParticleProperty, ConvertableToBool, ConvertableToFloat64, ConvertableToInt64, ConvertableToString
    {
        private Array<string> array = new Array<string>();

        public StringPerParticleProperty.from_array(owned string[] array)
        {
            this.set_arr(array);
        }

        public string[] get_arr()
        {
            unowned var a = this.array.data;
            return a.copy();
        }

        public void set_arr(owned string[] array)
        {
            this.array = new Array<string>.take(array);
        }

        public void set_val(uint index, string value) throws PerParticlePropertyError.INDEX_ERROR
        {
            if (index >= this.array.length)
                throw new PerParticlePropertyError.INDEX_ERROR("Index out of range");
            this.array.data[index] = value;
        }

        public string get_val(uint index) throws PerParticlePropertyError.INDEX_ERROR
        {
            if (index >= this.array.length)
                throw new PerParticlePropertyError.INDEX_ERROR("Index out of range");
            return this.array.index(index);
        }

        public void insert_val(uint index, string value) throws PerParticlePropertyError.INDEX_ERROR, PerParticlePropertyError.SIZE_ERROR
        {
            if (this.get_size() == uint.MAX)
                throw new PerParticlePropertyError.SIZE_ERROR("Size out of range");
            if (index > this.get_size())
                throw new PerParticlePropertyError.INDEX_ERROR("Index out of range");
            this.array.insert_val(index, value);
        }

        public void insert_last(string value) throws PerParticlePropertyError.SIZE_ERROR
        {
            this.insert_val(this.get_size(), value);
        }

        public void insert_first(string value) throws PerParticlePropertyError.SIZE_ERROR
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
            return new Variant.string(this.get_val(index));
        }

        public override void set_val_variant(uint index, Variant v) throws PerParticlePropertyError.INDEX_ERROR, PerParticlePropertyError.TYPE_ERROR
        {
            if (v.classify() != Variant.Class.STRING)
                throw new PerParticlePropertyError.TYPE_ERROR("Variant must hold string");
            this.set_val(index, v.get_string());
        }

        public override void insert_val_variant(uint index, Variant v) throws PerParticlePropertyError.SIZE_ERROR, PerParticlePropertyError.INDEX_ERROR, PerParticlePropertyError.TYPE_ERROR
        {
            if (this.get_size() == uint.MAX)
                throw new PerParticlePropertyError.SIZE_ERROR("Size is out of range");
            if (index > this.get_size())
                throw new PerParticlePropertyError.INDEX_ERROR("Index is out of range");
            if (v.classify() != Variant.Class.STRING)
                throw new PerParticlePropertyError.TYPE_ERROR("Variant must hold string");
            var temp = v.get_string();
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
            return new StringPerParticleProperty.from_array(this.get_arr());
        }

        public override BoolPerParticleProperty convert_to_bool() throws PerParticlePropertyError.TYPE_ERROR
        {
            var res = new BoolPerParticleProperty();
            res.set_size(this.get_size());
            bool temp;
            for (uint i = 0; i < this.get_size(); i++)
            {
                if (!bool.try_parse(this.get_val(i), out temp))
                    throw new PerParticlePropertyError.TYPE_ERROR(@"Cannot convert \"$(this.get_val(i))\" at index $i to bool");
                res.set_val(i, temp);
            }
            return res;
        }

        public override Float64PerParticleProperty convert_to_float64() throws PerParticlePropertyError.TYPE_ERROR
        {
            var res = new Float64PerParticleProperty();
            res.set_size(this.get_size());
            double temp;
            for (uint i = 0; i < this.get_size(); i++)
            {
                if (!double.try_parse(this.get_val(i), out temp))
                    throw new PerParticlePropertyError.TYPE_ERROR(@"Cannot convert \"$(this.get_val(i))\" at index $i to float64");
                res.set_val(i, temp);
            }
            return res;
        }

        public override Int64PerParticleProperty convert_to_int64() throws PerParticlePropertyError.TYPE_ERROR
        {
            var res = new Int64PerParticleProperty();
            res.set_size(this.get_size());
            int64 temp;
            for (uint i = 0; i < this.get_size(); i++)
            {
                if (!int64.try_parse(this.get_val(i), out temp))
                    throw new PerParticlePropertyError.TYPE_ERROR(@"Cannot convert \"$(this.get_val(i))\" at index $i to int64");
                res.set_val(i, temp);
            }
            return res;
        }

        public override StringPerParticleProperty convert_to_string()
        {
            return (StringPerParticleProperty) this.copy();
        }

        public override void replace_with(PerParticleProperty property) throws PerParticlePropertyError.TYPE_ERROR
        {
            if (!(property is ConvertableToString))
                throw new PerParticlePropertyError.TYPE_ERROR(@"Cannot convert to string");
            var prop = (ConvertableToString) property;
            var temp = prop.convert_to_string();
            this.array = temp.array;
        }



       // public static StringPerParticleProperty create_from(PerParticleProperty prop) throws PerParticlePropertyError.TYPE_ERROR
       // {
       //     string[] arr = new string[prop.get_size()];

       //     if (prop is StringPerParticleProperty) {
       //         StringPerParticleProperty temp_prop = (StringPerParticleProperty) prop;
       //         arr = temp_prop.get_arr();
       //     } else if (prop is Int64PerParticleProperty) {
       //         Int64PerParticleProperty temp_prop = (Int64PerParticleProperty) prop;
       //         for (uint i = 0; i < arr.length; i++)
       //             arr[i] = temp_prop.get_val(i).to_string();
       //     } else if (prop is Float64PerParticleProperty) {
       //         Float64PerParticleProperty temp_prop = (Float64PerParticleProperty) prop;
       //         for (uint i = 0; i < arr.length; i++)
       //             arr[i] = temp_prop.get_val(i).to_string();
       //     } else if (prop is BoolPerParticleProperty) {
       //         BoolPerParticleProperty temp_prop = (BoolPerParticleProperty) prop;
       //         for (uint i = 0; i < arr.length; i++)
       //             arr[i] = temp_prop.get_val(i).to_string();
       //         
       //     } else {
       //         throw new PerParticlePropertyError.TYPE_ERROR("Unknown prop type");
       //     }

       //     return new StringPerParticleProperty.from_array(arr);
       // }
    }
}
