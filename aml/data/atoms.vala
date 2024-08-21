namespace Aml
{
    public class Atoms :
        Object
    {
        private uint size;
        private HashTable<string, PerAtomProperty> properties;        

        public Atoms.sized(uint size)
        {
            this.size = size;
            this.properties = new HashTable<string, PerAtomProperty>(str_hash, str_equal);
        }

        public uint get_size()
        {
            return this.size;
        }

        public void set_size(uint n)
        {
            this.size = n;
            foreach (unowned var prop in this.properties.get_values())
                prop.set_size(n);
        }

        public PerAtomProperty get_item(string id) throws CollectionError
        {
            if (!this.properties.contains(id))
                throw new CollectionError.KEY_ERROR("No such key");
            return this.properties.get(id).copy();
        }

        public void set_item(string id, owned PerAtomProperty prop) throws CollectionError
        {
            if (prop.get_size() != this.size)
                throw new CollectionError.VALUE_ERROR("Invalid property size");
            this.properties.set(id, prop);
        }

        public void del_item(string id) throws CollectionError
        {
            if (!this.properties.contains(id))
                throw new CollectionError.KEY_ERROR("No such property");
            this.properties.take(id);
        }

        public bool has_item(string id)
        {
            return this.properties.contains(id);
        }
        
        public List<weak string> keys()
        {
            return this.properties.get_keys();
        }

        public Atom get_val(uint index) throws CollectionError
        {
            Atom result = new Atom.empty();
            Value temp;
            unowned PerAtomProperty temp_prop;

            foreach (unowned var prop_id in this.properties.get_keys()) {
                temp_prop = this.properties.get(prop_id);
                if (temp_prop is IntPerAtomProperty) {
                    temp = Value(typeof(int));
                    temp.set_int(((IntPerAtomProperty) temp_prop).get_val(index));
                } else if (temp_prop is DoublePerAtomProperty) {
                    temp = Value(typeof(double));
                    temp.set_double(((DoublePerAtomProperty) temp_prop).get_val(index));
                } else {
                    temp = Value(typeof(string));
                    temp.set_string(((StringPerAtomProperty) temp_prop).get_val(index));
                }
                result.set_item(prop_id, temp);
            }

            return result;
        }

        public void set_val(uint index, Atom atom) throws CollectionError
        {
            this.remove_val(index);
            this.insert_val(index, atom);
        }


        public void insert_val(uint index, Atom value) throws CollectionError
        {
            var keys = this.keys();
            var val_keys = value.keys();
            if (keys.length() != val_keys.length())
                throw new CollectionError.VALUE_ERROR("Invalid value");
            foreach (unowned var k in keys)
                if (val_keys.index(k) == -1)
                    throw new CollectionError.VALUE_ERROR("Invalid value");
            Value temp_val;
            unowned PerAtomProperty temp_prop;
            foreach (unowned var k in val_keys) {
                temp_val = value.get_item(k);
                temp_prop = this.properties.get(k);

                if (temp_prop is IntPerAtomProperty)
                    ((IntPerAtomProperty) temp_prop).insert_val(index, (int) temp_val);
                else if (temp_prop is DoublePerAtomProperty)
                    ((DoublePerAtomProperty) temp_prop).insert_val(index, (double) temp_val);
                else
                    ((StringPerAtomProperty) temp_prop).insert_val(index, (string) temp_val);
            }
            this.size++;
        }

        public void insert_first(Atom value) throws CollectionError
        {
            this.insert_val(0, value);
        }

        public void insert_last(Atom value) throws CollectionError
        {
            this.insert_val(this.size, value);
        }

        public void remove_first() throws CollectionError
        {
            this.remove_val(0);
        }

        public void remove_last() throws CollectionError
        {
            this.remove_val(this.size - 1);
        }

        public void remove_val(uint index) throws CollectionError
        {
            foreach (unowned var prop in this.properties.get_values())
                prop.remove_val(index);
        }

        public Atoms copy()
        {
            var result = new Atoms.sized(this.size);
            foreach (unowned var k in this.properties.get_keys())
                result.properties.insert(k, this.get_item(k));
            return result;
        }
    }
}
