namespace Aml
{
    /**
     * Frame obejct
     */
    public class Frame : Object
    {
        /**
         * Simulation box
         */
        public Box box;
        /**
         * Atoms
         */
        public Atoms atoms;

        private HashTable<string, FrameProperty> properties;

        /**
         * Creates frame from box and atoms
         * 
         * @param box Simulation box
         * @param atoms Atoms
         */
        public Frame.create(owned Box box, owned Atoms atoms)
        {
            this.box = box;
            this.atoms = atoms;
            this.properties = new HashTable<string, FrameProperty>(str_hash, str_equal);
        }

        /**
         * Returns true if has property with id
         * 
         * @param id ID
         * 
         * @return True if has property with id
         */
        public bool has_prop(string id)
        {
            return this.properties.contains(id);
        }
        
        /**
         * Returns copy of property by id
         * 
         * @param id ID
         * 
         * @return Copy of property by id
         * 
         * @throws CollectionError.KEY_ERROR If got invalid id
         */
        public FrameProperty get_prop(string id) throws CollectionError
        {
            if (!this.has_prop(id))
                throw new CollectionError.KEY_ERROR("Invalid id");

            return this.properties.get(id).copy();
        }

        /**
         * Removes property by id
         * 
         * @param id ID
         * 
         * @throws CollectionError.KEY_ERROR If got invalid id
         */
        public void del_prop(string id) throws CollectionError
        {
            if (!this.has_prop(id))
                throw new CollectionError.KEY_ERROR("Invalid id");
            
            this.properties.remove(id);
        }

        /**
         * Sets property
         * 
         * @param id ID
         * @param prop Property to set
         */
        public void set_prop(string id, owned FrameProperty prop)
        {
            this.properties.set(id, prop);
        }

        /**
         * List of properties ids
         * 
         * @return List of properties ids
         */
        public List<weak string> get_ids()
        {
            return this.properties.get_keys();
        }

        /**
         * Copies this object
         * 
         * @return copy of this object
         */
        public Frame copy()
        {
            var res = new Frame.create(this.box.copy(), this.atoms.copy());
            foreach (unowned var key in this.get_ids())
                res.set_prop(key, this.get_prop(key));
            return res;
        }
    }
}
