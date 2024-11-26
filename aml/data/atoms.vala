namespace Aml
{
    /**
     * Atoms object
     */
    public class Atoms : Object
    {
        private uint size;
        private HashTable<string, PerAtomProperty> properties;        

        /**
         * Creates sized object
         * 
         * @param size Number of atoms
         */
        public Atoms.sized(uint size)
        {
            this.size = size;
            this.properties = new HashTable<string, PerAtomProperty>(str_hash, str_equal);
        }

        /**
         * Creates new empty object
         */
        public Atoms.empty()
        {
            this.sized(0);
        }

        /**
         * Returns number of atoms
         * 
         * @return Number of atoms
         */
        public uint get_size()
        {
            return this.size;
        }

        /**
         * Sets number of atoms
         * 
         * @param size New size
         */
        public void set_size(uint size)
        {
            this.size = size;
            foreach (unowned var prop in this.properties.get_values())
                prop.set_size(size);
        }

        /**
         * Returns copy of property by id
         * 
         * @param id Id of property
         * 
         * @return Copy of property by id
         * 
         * @throws CollectionError.KEY_ERROR If got invalid id
         */
        public PerAtomProperty get_prop(string id) throws CollectionError
        {
            if (!this.properties.contains(id))
                throw new CollectionError.KEY_ERROR("No such property");
            return this.properties.get(id).copy();
        }

        /**
         * Sets property
         * 
         * @param id ID of new property
         * @param prop New property
         * 
         * @throws CollectionError.VALUE_ERROR If property size is invalid
         */
        public void set_prop(string id, owned PerAtomProperty prop) throws CollectionError
        {
            if (prop.get_size() != this.size)
                throw new CollectionError.VALUE_ERROR("Invalid property size");
            this.properties.set(id, prop);
        }

        /**
         * Removes property by ID
         * 
         * @param id ID
         * 
         * @throws CollectionError.KEY_ERROR If got invalid id
         */
        public void del_prop(string id) throws CollectionError
        {
            if (!this.properties.contains(id))
                throw new CollectionError.KEY_ERROR("No such property");
            this.properties.take(id);
        }

        /**
         * Returns true if contains property with id
         *
         * @param id ID
         * 
         * @return True if contains property with id
         */
        public bool has_prop(string id)
        {
            return this.properties.contains(id);
        }
        
        /**
         * Returns ids
         * 
         * @return List of ids
         */
        public List<weak string> get_ids()
        {
            return this.properties.get_keys();
        }

        /**
         * Returns copy of atom by index
         * 
         * @param index Index
         * 
         * @return Atom by index
         * 
         * @throws CollectionError.INDEX_ERROR If got invalid index
         */
        public Atom get_val(uint index) throws CollectionError
        {
            Atom result = new Atom.empty();
            Variant temp;
            unowned PerAtomProperty temp_prop;

            foreach (unowned var prop_id in this.get_ids())
            {
                temp_prop = this.properties.get(prop_id);
                temp = temp_prop.get_val_variant(index);
                result.set_prop(prop_id, temp);
            }

            return result;
        }

        /**
         * Sets atom by index
         * 
         * @param index Index
         * @param atom Atom to set
         * 
         * @throws CollectionError.INDEX_ERROR If got invalid index
         * @throws CollectionError.VALUE_ERROR If got invalid atom
         */
        public void set_val(uint index, Atom atom) throws CollectionError
        {
            this.remove_val(index);
            this.insert_val(index, atom);
        }

        /**
         * Inserts atom to index
         * 
         * @param index Index
         * @param atom Atom to set
         * 
         * @throws CollectionError.INDEX_ERROR If got invalid index
         * @throws CollectionError.VALUE_ERROR If got invalid atom
         */
        public void insert_val(uint index, Atom atom) throws CollectionError
        {
            var keys = this.get_ids();
            var val_keys = atom.get_ids();
            if (keys.length() != val_keys.length())
                throw new CollectionError.VALUE_ERROR("Invalid value");
            foreach (unowned var k in keys)
                if (val_keys.index(k) == -1)
                    throw new CollectionError.VALUE_ERROR("Invalid value");
            Variant temp_variant;
            unowned PerAtomProperty temp_prop;
            foreach (unowned var k in val_keys)
            {
                temp_variant = atom.get_prop(k);
                temp_prop = this.properties.get(k);
                temp_prop.insert_val_variant(index, temp_variant);
            }
            this.size++;
        }

        /**
         * Inserts atom to first position
         * 
         * @param atom Atom to set
         * 
         * @throws CollectionError.VALUE_ERROR If got invalid atom
         */
        public void insert_first(Atom atom) throws CollectionError
        {
            this.insert_val(0, atom);
        }

        /**
         * Inserts atom to last position
         * 
         * @param atom Atom to set
         * 
         * @throws CollectionError.VALUE_ERROR If got invalid atom
         */
        public void insert_last(Atom atom) throws CollectionError
        {
            this.insert_val(this.size, atom);
        }

        /**
         * Removes first atom
         * 
         * @throws CollectionError.SIZE_ERROR If empty
         */
        public void remove_first() throws CollectionError
        {
            if (this.get_size() == 0)
                throw new CollectionError.SIZE_ERROR("Empty");
            this.remove_val(0);
        }

        /**
         * Removes last atom
         * 
         * @throws CollectionError.SIZE_ERROR If empty
         */
        public void remove_last() throws CollectionError
        {
            if (this.get_size() == 0)
                throw new CollectionError.SIZE_ERROR("Empty");
            this.remove_val(this.size - 1);
        }

        /**
         * Removes atom by index
         * 
         * @param index Index
         * 
         * @throws CollectionError.INDEX_ERROR If got invalid index
         */
        public void remove_val(uint index) throws CollectionError
        {
            foreach (unowned var prop in this.properties.get_values())
                prop.remove_val(index);
        }

        /**
         * Copies this object
         * 
         * @return Copy of this object
         */
        public Atoms copy()
        {
            var result = new Atoms.sized(this.size);
            foreach (unowned var k in this.get_ids())
                result.properties.insert(k, this.get_prop(k));
            return result;
        }
    }
}
