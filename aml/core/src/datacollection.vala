namespace AmlCore
{
    public errordomain DataCollectionError
    {
        ID_ERROR,
        SELF_SET_ERROR,
    }

    public class DataCollection : DataObject 
    {
        private weak DataCollection? parent = null;
        private HashTable<string, DataObject> elements = new HashTable<string, DataObject>(str_hash, str_equal);
        
        public DataCollection.empty() { }

        ~DataCollection()
        {
            foreach (var id in this.get_ids())
                this.del_element(id);
        }

        public bool is_root()
        {
            return this.parent == null;
        }

        public uint n_elements()
        {
            return this.elements.size();
        }

        public DataCollection root()
        {
            if (this.is_root())
                return this;
            return this.parent.root();
        }

        public bool has_element(string id)
        {
            return id in this.elements;
        }

        public List<weak string> get_ids()
        {
            return this.elements.get_keys();
        }

        public DataObject get_element(string id) throws DataCollectionError.ID_ERROR
        {
            if (!has_element(id))
                throw new DataCollectionError.ID_ERROR(@"Does not contain element with id \"$id\"");
            return this.elements.get(id);
        }

        public void set_element(string id, DataObject element) throws DataCollectionError.SELF_SET_ERROR, DataObjectError.DOUBLE_ASSIGN_ERROR
        {
            if (element == this)
                throw new DataCollectionError.SELF_SET_ERROR("Trying to set itself");
            if (element == this.root())
                throw new DataCollectionError.SELF_SET_ERROR("Implicit selfset");
            
            element._assign();
            if (element is DataCollection)
                ((DataCollection) element).parent = this;
            this.elements.set(id, element);
        }

        public void del_element(string id) throws DataCollectionError.ID_ERROR
        {
            var element = this.get_element(id);
            element._retract();
            if (element is DataCollection)
                ((DataCollection) element).parent = null;
            this.elements.remove(id);
        }

        public override DataObject copy()
        {
            var result = new DataCollection.empty();
            foreach(var id in this.get_ids())
                result.set_element(id, this.get_element(id).copy());
            return result;
        }
    }
}
