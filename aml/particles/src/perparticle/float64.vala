namespace AmlParticles
{
    public interface ConvertableToFloat64 : Object
    {
        public abstract Float64PerParticleProperty convert_to_float64() throws PerParticlePropertyError.TYPE_ERROR;
    }

    public class Float64PerParticleProperty : PerParticleProperty, ConvertableToBool, ConvertableToInt64, ConvertableToString, ConvertableToFloat64
    {
        private Array<double> array = new Array<double>();

        public Float64PerParticleProperty.from_array(owned double[] array)
        {
            this.set_arr(array);
        }

        public double[] get_arr()
        {
            unowned var a = this.array.data;
            return a.copy();
        }

        public void set_arr(owned double[] array)
        {
            this.array = new Array<double>.take(array);
        }

        public void set_val(uint index, double value) throws PerParticlePropertyError.INDEX_ERROR
        {
            if (index >= this.array.length)
                throw new PerParticlePropertyError.INDEX_ERROR("Index out of range");
            double *temp = this.array.data;
            temp[index] = value;
            //this.array.data[index] = value;
        }

        public double get_val(uint index) throws PerParticlePropertyError.INDEX_ERROR
        {
            if (index >= this.array.length)
                throw new PerParticlePropertyError.INDEX_ERROR("Index out of range");
            return this.array.index(index);
        }

        public void insert_val(uint index, double value) throws PerParticlePropertyError.INDEX_ERROR, PerParticlePropertyError.SIZE_ERROR
        {
            if (this.get_size() == uint.MAX)
                throw new PerParticlePropertyError.SIZE_ERROR("Size out of range");
            if (index > this.get_size())
                throw new PerParticlePropertyError.INDEX_ERROR("Index out of range");
            this.array.insert_val(index, value);
        }

        public void insert_last(double value) throws PerParticlePropertyError.SIZE_ERROR
        {
            this.insert_val(this.get_size(), value);
        }

        public void insert_first(double value) throws PerParticlePropertyError.SIZE_ERROR
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
            return new Variant.double(this.get_val(index));
        }

        public override void set_val_variant(uint index, Variant v) throws PerParticlePropertyError.INDEX_ERROR, PerParticlePropertyError.TYPE_ERROR
        {
            if (v.classify() != Variant.Class.DOUBLE)
                throw new PerParticlePropertyError.TYPE_ERROR("Variant must hold double");
            var temp = v.get_double();
            this.set_val(index, temp);
        }

        public override void insert_val_variant(uint index, Variant v) throws PerParticlePropertyError.SIZE_ERROR, PerParticlePropertyError.INDEX_ERROR, PerParticlePropertyError.TYPE_ERROR
        {
            if (this.get_size() == uint.MAX)
                throw new PerParticlePropertyError.SIZE_ERROR("Size is out of range");
            if (index > this.get_size())
                throw new PerParticlePropertyError.INDEX_ERROR("Index is out of range");
            if (v.classify() != Variant.Class.DOUBLE)
                throw new PerParticlePropertyError.TYPE_ERROR("Variant must hold double");
            var temp = v.get_double();
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
            return new Float64PerParticleProperty.from_array(this.get_arr());
        }

        public override BoolPerParticleProperty convert_to_bool()
        {
            var res = new BoolPerParticleProperty();
            res.set_size(this.get_size());
            for (uint i = 0; i < this.get_size(); i++)
                res.set_val(i, this.get_val(i) == 0.0);
            return res;
        }

        public override Int64PerParticleProperty convert_to_int64()
        {
            var res = new Int64PerParticleProperty();
            res.set_size(this.get_size());
            for (uint i = 0; i < this.get_size(); i++)
                res.set_val(i, (int64) this.get_val(i));
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
            if (!(property is ConvertableToFloat64))
                throw new PerParticlePropertyError.TYPE_ERROR(@"Cannot convert to float64");
            var prop = (ConvertableToFloat64) property;
            var temp = prop.convert_to_float64();
            this.array = temp.array;
        }

        public override Float64PerParticleProperty convert_to_float64()
        {
            return (Float64PerParticleProperty) this.copy();
        }


       // public static Float64PerParticleProperty create_from(PerParticleProperty prop) throws PerParticlePropertyError.TYPE_ERROR
       // {
       //     double[] arr = new double[prop.get_size()];

       //     if (prop is StringPerParticleProperty) {
       //         StringPerParticleProperty temp_prop = (StringPerParticleProperty) prop;
       //         for (uint i = 0; i < arr.length; i++)
       //             if (!double.try_parse(temp_prop.get_val(i), out arr[i]))
       //                 throw new PerParticlePropertyError.TYPE_ERROR(@"Cannot parse string \"$(temp_prop.get_val(i))\" at index $i to double");
       //     } else if (prop is Int64PerParticleProperty) {
       //         Int64PerParticleProperty temp_prop = (Int64PerParticleProperty) prop;
       //         for (uint i = 0; i < arr.length; i++)
       //             arr[i] = (double) temp_prop.get_val(i);
       //     } else if (prop is Float64PerParticleProperty) {
       //         Float64PerParticleProperty temp_prop = (Float64PerParticleProperty) prop;
       //         arr = temp_prop.get_arr();
       //     } else if (prop is Float64PerParticleProperty) {
       //         BoolPerParticleProperty temp_prop = (BoolPerParticleProperty) prop;
       //         for (uint i = 0; i < arr.length; i++)
       //             arr[i] = temp_prop.get_val(i) ? 1.0 : 0.0;
       //     } else {
       //         throw new PerParticlePropertyError.TYPE_ERROR("Unknown prop type");
       //     }

       //     return new Float64PerParticleProperty.from_array(arr);
       // }
    }
}
