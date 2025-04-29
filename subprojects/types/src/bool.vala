using AmlCore;

namespace AmlTypes
{
    public interface ConvertableToBool : Object
    {
        public abstract bool get_bool(Property prop);
    }
    
    public class BoolType : Type,
        ConvertableToInt64,
        ConvertableToFloat64,
        ConvertableToBool,
        ConvertableToString
    {
        private static GLib.Once<BoolType> _instance;

        public static unowned BoolType instance()
        {
            return _instance.once(() => {
                return new BoolType();
            });
        }

        public override uint get_size()
        {
            return (uint) sizeof(bool);
        }
        
        public override void read(Property prop, void * address)
            requires(prop is BoolProperty)
        {
            bool * addr = (bool *) address;
            ((BoolProperty) prop).set_val(*addr);
        }

        public override void write(Property prop, void * address)
            requires(prop is BoolProperty)
        {
            bool * addr = (bool *) address;
            *addr = ((BoolProperty) prop).get_val();
        }

        public override bool can_convert(Type type)
        {
            return type is ConvertableToBool;
        }

        public override Property create_property()
        {
            return new BoolProperty.create();
        }

        public override ArrayProperty create_array_property()
        {
            return new BoolArrayProperty.create(0);
        }

        public override bool get_bool(Property prop)
        {
            assert(prop is BoolProperty);
            return ((BoolProperty) prop).get_val();
        }

        public override string get_string(Property prop)
        {
            return this.get_bool(prop).to_string();
        }

        public override double get_float64(Property prop)
        {
            return this.get_bool(prop) ? 1.0 : 0.0;
        }

        public override int64 get_int64(Property prop)
        {
            return this.get_bool(prop) ? 1 : 0;
        }
    }

    public class BoolProperty : Property
    {
        internal bool value;

        private BoolProperty() { }

        public BoolProperty.create()
        {
            this.assign_type(BoolType.instance());
        }

        public override void convert_unsafe(Property prop)
        {
            this.set_val(((ConvertableToBool) prop.get_type_object()).get_bool(prop));
        }

        public bool get_val()
        {
            return this.value;
        }

        public void set_val(bool val)
        {
            this.value = val;
        }

        public override DataObject copy()
        {
            var result = new BoolProperty();
            result.value = this.value;
            return result;
        }
    }

    public class BoolArrayProperty : ArrayProperty
    {
        private BoolArrayProperty() { }

        public BoolArrayProperty.create(size_t size)
        {
            this.init(BoolType.instance(), size);
        }

        public void set_arr(bool[:size_t] array)
        {
            this.set_size(0);
            this.set_size(array.length);
            Memory.copy(this.get_address(), (void *) array, array.length * this.get_type_object().get_size());
        }

        public bool[:size_t] get_arr()
        {
            var result = new bool[this.get_size():size_t];
            Memory.copy((void *) result, this.get_address(), this.get_size() * this.get_type_object().get_size());
            return result;
        }
    }
}
