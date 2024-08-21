namespace Aml
{
    public class Frame :
        Object
    {
        public Box box;
        public Atoms atoms;
        private HashTable<string, FrameProperty> properties;

        public Frame.create(owned Box box, owned Atoms atoms)
        {
            this.box = box;
            this.atoms = atoms;
            this.properties = new HashTable<string, FrameProperty>(str_hash, str_equal);
        }

        public bool has_item(string id)
        {
            return this.properties.contains(id);
        }

        public FrameProperty get_item(string id) throws CollectionError
        {
            if (!this.has_item(id))
                throw new CollectionError.KEY_ERROR("Invalid key");

            return this.properties.get(id).copy();
        }

        public void del_item(string id) throws CollectionError
        {
            if (!this.has_item(id))
                throw new CollectionError.KEY_ERROR("Invalid key");
            
            this.properties.remove(id);
        }

        public void set_item(string id, owned FrameProperty item) throws CollectionError
        {
            this.properties.set(id, item);
        }

        public List<weak string> keys()
        {
            return this.properties.get_keys();
        }

        public Frame copy()
        {
            var res = new Frame.create(this.box.copy(), this.atoms.copy());
            foreach (unowned var key in this.keys())
                res.set_item(key, this.get_item(key));
            return res;
        }
    }
}
