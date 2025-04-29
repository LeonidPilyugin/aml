using AmlCore;

namespace AmlTypes
{
    public interface ConvertableToInt64 : Object
    {
        public abstract int64 get_int64(Property prop);
    }
    
    public class Int64Type : Type,
        ConvertableToInt64,
        ConvertableToFloat64,
        ConvertableToBool,
        ConvertableToString
    {
        private static GLib.Once<Int64Type> _instance;

        public static unowned Int64Type instance()
        {
            return _instance.once(() => {
                return new Int64Type();
            });
        }

        public override uint get_size()
        {
            return (uint) sizeof(int64);
        }
        
        public override void read(Property prop, void * address)
            requires(prop is Int64Property)
        {
            int64 * addr = (int64 *) address;
            ((Int64Property) prop).set_val(*addr);
        }

        public override void write(Property prop, void * address)
            requires(prop is Int64Property)
        {
            int64 * addr = (int64 *) address;
            *addr = ((Int64Property) prop).get_val();
        }

        public override bool can_convert(Type type)
        {
            return type is ConvertableToInt64;
        }

        public override Property create_property()
        {
            return new Int64Property.create();
        }

        public override ArrayProperty create_array_property()
        {
            return new Int64ArrayProperty.create(0);
        }

        public override int64 get_int64(Property prop)
        {
            assert(prop is Int64Property);
            return ((Int64Property) prop).get_val();
        }

        public override string get_string(Property prop)
        {
            return this.get_int64(prop).to_string();
        }

        public override double get_float64(Property prop)
        {
            return (double) this.get_int64(prop);
        }

        public override bool get_bool(Property prop)
        {
            return 0 != this.get_int64(prop);
        }
    }

    public class Int64Property : Property
    {
        internal int64 value;

        private Int64Property() { }

        public Int64Property.create()
        {
            this.assign_type(Int64Type.instance());
        }

        public override void convert_unsafe(Property prop)
        {
            this.set_val(((ConvertableToInt64) prop.get_type_object()).get_int64(prop));
        }

        public int64 get_val()
        {
            return this.value;
        }

        public void set_val(int64 val)
        {
            this.value = val;
        }

        public override DataObject copy()
        {
            var result = new Int64Property();
            result.value = this.value;
            return result;
        }
    }

    public class Int64ArrayProperty : ArrayProperty
    {
        private Int64ArrayProperty() { }

        public Int64ArrayProperty.create(size_t size)
        {
            this.init(Int64Type.instance(), size);
        }

        public void set_arr(int64[:size_t] array)
        {
            this.set_size(0);
            this.set_size(array.length);
            Memory.copy(this.get_address(), (void *) array, array.length * this.get_type_object().get_size());
        }

        public int64[:size_t] get_arr()
        {
            var result = new int64[this.get_size():size_t];
            Memory.copy((void *) result, this.get_address(), this.get_size() * this.get_type_object().get_size());
            return result;
        }
    }
}
