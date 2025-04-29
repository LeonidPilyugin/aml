using AmlCore;

namespace AmlTypes
{
    public interface ConvertableToFloat64 : Object
    {
        public abstract double get_float64(Property prop);
    }
    
    public class Float64Type : Type,
        ConvertableToFloat64,
        ConvertableToInt64,
        ConvertableToBool,
        ConvertableToString
    {
        private static GLib.Once<Float64Type> _instance;

        public static unowned Float64Type instance()
        {
            return _instance.once(() => {
                return new Float64Type();
            });
        }

        public override uint get_size()
        {
            return (uint) sizeof(double);
        }
        
        public override void read(Property prop, void * address)
            requires(prop is Float64Property)
        {
            double * addr = (double *) address;
            ((Float64Property) prop).set_val(*addr);
        }

        public override void write(Property prop, void * address)
            requires(prop is Float64Property)
        {
            double * addr = (double *) address;
            *addr = ((Float64Property) prop).get_val();
        }

        public override bool can_convert(Type type)
        {
            return type is ConvertableToFloat64;
        }

        public override Property create_property()
        {
            return new Float64Property.create();
        }

        public override ArrayProperty create_array_property()
        {
            return new Float64ArrayProperty.create(0);
        }

        public override double get_float64(Property prop)
        {
            assert(prop is Float64Property);
            return ((Float64Property) prop).get_val();
        }

        public override int64 get_int64(Property prop)
        {
            return (int64) this.get_float64(prop);
        }

        public override bool get_bool(Property prop)
        {
            return 0.0 != this.get_float64(prop);
        }

        public override string get_string(Property prop)
        {
            return this.get_float64(prop).to_string();
        }
    }

    public class Float64Property : Property
    {
        internal double value;

        private Float64Property() { }

        public Float64Property.create()
        {
            this.assign_type(Float64Type.instance());
        }

        public override void convert_unsafe(Property prop)
        {
            this.set_val(((ConvertableToFloat64) prop.get_type_object()).get_float64(prop));
        }

        public double get_val()
        {
            return this.value;
        }

        public void set_val(double val)
        {
            this.value = val;
        }

        public override DataObject copy()
        {
            var result = new Float64Property();
            result.value = this.value;
            return result;
        }
    }

    public class Float64ArrayProperty : ArrayProperty
    {
        private Float64ArrayProperty() { }

        public Float64ArrayProperty.create(size_t size)
        {
            this.init(Float64Type.instance(), size);
        }

        public void set_arr(double[:size_t] array)
        {
            this.set_size(0);
            this.set_size(array.length);
            Memory.copy(this.get_address(), (void *) array, array.length * this.get_type_object().get_size());
        }

        public double[:size_t] get_arr()
        {
            var result = new double[this.get_size():size_t];
            Memory.copy((void *) result, this.get_address(), this.get_size() * this.get_type_object().get_size());
            return result;
        }
    }
}
