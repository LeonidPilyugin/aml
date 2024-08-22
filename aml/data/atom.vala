namespace Aml
{
    /**
     * Single atom
     */
    public class Atom : Object
    {
        private HashTable<string, Value?> data;

        /**
         * Creates new empty atom
         */
        public Atom.empty()
        {
            this.data = new HashTable<string, Value?>(str_hash, str_equal);
        }

        /**
         * Returns property by id
         * 
         * @param id Id of property
         * 
         * @return Copy of property
         * 
         * @throws CollectionError.KEY_ERROR If got invalid key
         */
        public Value? get_prop(string id) throws CollectionError
            ensures (
                result.type() == typeof(int) ||
                result.type() == typeof(double) ||
                result.type() == typeof(string)
            )
        {
            if (!this.data.contains(id))
                throw new CollectionError.KEY_ERROR("No such property");
            Value temp = this.data.get(id);
            Value copy = Value(temp.type());
            temp.copy(ref copy);
            return copy;
        }

        /**
         * Returns true if contains property
         * 
         * @return True if contains atom
         */
        public bool has_prop(string id)
        {
            return this.data.contains(id);
        }

        /**
         * Sets property by id
         * 
         * @param id Id of property
         * @param prop Value to set
         * 
         * @throws CollectionError.TYPE_ERROR If type is not supported
         */
        public void set_prop(string id, owned Value? prop) throws CollectionError
        {
            if (!(
                prop == null ||
                prop.type() == typeof(int) ||
                prop.type() == typeof(double) ||
                prop.type() == typeof(string)
            )) throw new CollectionError.TYPE_ERROR("Invalid value type. Expected int, double or string");
            this.data.set(id, prop);
        }

        /**
         * Deletes property by id
         * 
         * @param id Id of property
         * 
         * @throws CollectionError.KEY_ERROR If doesn't have this id
         */
        public void del_prop(string id) throws CollectionError
        {
            if (!this.has_prop(id))
                throw new CollectionError.KEY_ERROR("Invalid property id");
            this.data.remove(id);
        }

        /**
         * Returns all ids of contained properties
         * 
         * @return Ids of contained properties
         */
        public List<weak string> get_ids()
        {
            return this.data.get_keys();
        }

        /**
         * Copies this object
         * 
         * @return Copy of this object
         */
        public Atom copy() {
            var res = new Atom.empty();
            foreach (unowned var id in this.get_ids())
            {
                res.set_prop(id, this.get_prop(id));
            }
            return res;
        }
    }
}
