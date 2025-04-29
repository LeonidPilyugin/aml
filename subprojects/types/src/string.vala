using AmlCore;

namespace AmlTypes
{
    private struct StringData
    {
        unowned string str;
        size_t refs;
    }

    private class StringCache
    {
        private HashTable<string, StringData *> htable = new HashTable<string, StringData *>.full(str_hash, str_equal, free, free);
        private static Once<StringCache> _instance;

        public static unowned StringCache instance()
        {
            return _instance.once(() => {
                return new StringCache();
            });
        }

        public StringData * add(string str)
        {
            unowned string key;
            StringData * value;
            bool result = this.htable.lookup_extended(str, out key, out value);

            if (result)
            {
                value->refs += 1;
                return value;
            }

            value = malloc(sizeof(StringData));
            value->refs = 1;
            this.htable.set(str, value);

            // get reference to stored string
            this.htable.lookup_extended(str, out key, out value);
            value->str = key;

            return value;
        }

        public void del(StringData * data)
        {
            data->refs--;
            if (data->refs == 0)
                this.htable.remove(data->str);
        }

        public unowned string get(StringData * data)
        {
            return data->str;
        }
    }

    public interface ConvertableToString : Object
    {
        public abstract string get_string(Property prop);
    }
    
    public class StringType : Type,
        ConvertableToInt64,
        ConvertableToFloat64,
        ConvertableToBool,
        ConvertableToString
    {
        private static Once<StringType> _instance;
        private StringCache cache;
        private static string default_string = "";

        private StringType.create()
        {
            this.cache = StringCache.instance();
        }

        public static unowned StringType instance()
        {
            return _instance.once(() => {
                return new StringType.create();
            });
        }

        public override uint get_size()
        {
            return (uint) sizeof(StringData *);
        }
        
        public override void read(Property prop, void * address)
            requires(prop is StringProperty)
        {
            prop.set_val(this.cache.get(*((StringData **) address)));
        }

        public override void write(Property prop, void * address)
            requires(prop is StringProperty)
        {
            StringData ** addr = (StringData **) address;
            *addr = this.cache.add(prop.get_val());
        }

        public override void destroy(void * address, size_t n = 1)
        {
            for (size_t i = 0; i < n; i++)
                this.cache.del(*(((StringData **) address) + i));
        }

        public override void init(void * address, size_t n = 1)
        {
            StringData ** addr = (StringData **) address;
            for (size_t i = 0; i < n; i++)
                *(addr + i) = this.cache.add(this.default_string);
        }

        public override bool can_convert(Type type)
        {
            return type is ConvertableToString;
        }

        public override Property create_property()
        {
            return new StringProperty.create();
        }

        public override ArrayProperty create_array_property()
        {
            return new StringArrayProperty.create(0);
        }

        public override int64 get_int64(Property prop)
        {
            string val = this.get_string(prop);

            int64 result;
            if (!int64.try_parse(val, out result))
                result = 0;
            return result;
        }

        public override double get_float64(Property prop)
        {
            string val = this.get_string(prop);

            double result;
            if (!double.try_parse(val, out result))
                result = 0;
            return result;
        }

        public override bool get_bool(Property prop)
        {
            string val = this.get_string(prop);

            bool result;
            if (!bool.try_parse(val, out result))
                result = false;
            return result;
        }

        public override string get_string(Property prop)
        {
            assert(prop is StringProperty);
            return ((StringProperty) prop).get_val();
        }
    }

    public class StringProperty : Property
    {
        internal string value;

        private StringProperty() { }

        public StringProperty.create()
        {
            this.assign_type(StringType.instance());
        }

        public override void convert_unsafe(Property prop)
        {
            this.set_val(((ConvertableToString) prop.get_type_object()).get_string(prop));
        }

        public string get_val()
        {
            return this.value;
        }

        public void set_val(string val)
        {
            this.value = val;
        }

        public override DataObject copy()
        {
            var result = new StringProperty();
            result.value = this.value;
            return result;
        }
    }

    public class StringArrayProperty : ArrayProperty
    {
        private StringArrayProperty() { }

        public StringArrayProperty.create(size_t size)
        {
            this.init(StringType.instance(), size);
        }

        public void set_arr(string[:size_t] array)
        {
            this.set_size(0);
            this.set_size(array.length);
            var temp = new StringProperty.create();
            for (size_t i = 0; i < array.length; i++)
            {
                temp.set_val(array[i]);
                this.set_property_unsafe(i, temp);
            }
        }

        public string[:size_t] get_arr()
        {
            var result = new string[this.get_size():size_t];
            var temp = new StringProperty.create();
            
            for (size_t i = 0; i < result.length; i++)
            {
                this.get_property_unsafe(i, temp);
                result[i] = temp.get_val();
            }

            return result;
        }

        public override DataObject copy()
        {
            var result = (StringArrayProperty) this.get_type_object().create_array_property();

            result.set_arr(this.get_arr());

            return result;
        }
    }
}
