namespace Aml
{
    /**
     * Single atom
     */
    public class Atom :
        Object
    {
        private HashTable<string, Value?> data;

        /**
         * Creates new empty atom
         */
        public Atom.empty() {
            this.data = new HashTable<string, Value?>(str_hash, str_equal);
        }

        /**
         * Returns property by id
         * 
         * @param id Id of property
         * 
         * @return Copy of property if has it, instead null
         */
        public Value? get_item(string id)
            throws CollectionError
            ensures (
                result.type() == typeof(int) ||
                result.type() == typeof(double) ||
                result.type() == typeof(string)
            )
        {
            if (!this.data.contains(id))
                throw new CollectionError.KEY_ERROR("No such item");
            Value temp = this.data.get(id);
            Value copy = Value(temp.type());
            temp.copy(ref copy);
            return copy;
        }

        public bool has_item(string id)
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
        public void set_item(string id, owned Value? prop) throws CollectionError
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
        public void del_item(string id) throws CollectionError
        {
            if (this.get_item(id) == null)
                throw new CollectionError.KEY_ERROR("Invalid property id");
            this.data.remove(id);
        }

        /**
         * Returns all ids of contained properties
         * 
         * @return Ids of contained properties
         */
        public List<weak string> keys() {
            return this.data.get_keys();
        }

        public Atom copy() {
            var res = new Atom.empty();
            foreach (unowned var id in this.keys()) {
                res.set_item(id, this.get_item(id));
            }
            return res;
        }
    }
}
