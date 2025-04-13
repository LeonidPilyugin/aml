namespace AmlCore
{
    private class DataCollectionIdParser
    {
        private string separator;
        private Regex alphanumeric;

        public DataCollectionIdParser()
        {
            this.separator = ".";
            this.alphanumeric = new Regex("[1-zA-Z0-9]+");
        }

        public bool is_valid_id(string id)
        {
            var tokens = id.split(this.separator);
            foreach (unowned var token in tokens)
                if (!this.is_valid_token(token)) return false;
            return tokens.length > 0;
        }

        public bool is_valid_token(string token)
        {
            var temp = this.alphanumeric.split(token);
            return temp.length == 2 && "" == temp[0] && "" == temp[1];
        }

        public string get_next_token(string id)
        {
            var tokens = id.split(this.separator);
            return tokens[0];
        }

        public string drop_next_token(string id)
        {
            var tokens = id.split(this.separator)[1:];
            return string.joinv(this.separator, tokens);
        }

        public string concat(string first, string second)
        {
            return first + this.separator + second;
        }
    }

    public errordomain DataCollectionError
    {
        ID_ERROR,
        SELF_SET_ERROR,
        ELEMENT_ERROR,
    }

    public class DataCollection : DataObject 
    {
        public const string EMPTY_ID = "";
        private weak DataCollection? parent = null;
        private HashTable<string, DataObject> elements = new HashTable<string, DataObject>(str_hash, str_equal);
        private static DataCollectionIdParser parser = null;
        
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

        public static bool is_valid_id(string id)
        {
            // if init parser in static constructor, it will be set only after first instance created
            if (DataCollection.parser == null) DataCollection.parser = new DataCollectionIdParser();
            return DataCollection.parser.is_valid_id(id);
        }

        public bool has_element(string id) throws DataCollectionError.ID_ERROR
        {
            if (!DataCollection.is_valid_id(id))
                throw new DataCollectionError.ID_ERROR(@"Got invalid id \"$id\"");
            unowned List<string>? element = this.get_nested_ids().find_custom(id, strcmp);
            return element != null;
        }

        public List<weak string> get_ids()
        {
            return this.elements.get_keys();
        }

        public List<string> get_nested_ids()
        {
            var res = new List<string>();
            foreach (var key in this.elements.get_keys())
            {
                res.append(key);
                var val = this.elements.get(key);
                if (val is DataCollection)
                {
                    var to_append = ((DataCollection) val).get_nested_ids();
                    foreach (var str in to_append)
                        res.append(DataCollection.parser.concat(key, str));
                }
            }
            
            return res;
        }

        public DataObject get_element(string id) throws DataCollectionError.ID_ERROR
        {
            if (!has_element(id))
                throw new DataCollectionError.ID_ERROR(@"Does not contain element with id \"$id\"");

            if (id in this.elements)
                return this.elements.get(id);
            
            var next_token = DataCollection.parser.get_next_token(id);
            var next_id = DataCollection.parser.drop_next_token(id);
            var next_dc = (DataCollection) this.elements.get(next_token);
            
            return next_dc.get_element(next_id);
        }

        public void set_element(string id, DataObject element) throws DataCollectionError.ID_ERROR, DataCollectionError.SELF_SET_ERROR, DataObjectError.DOUBLE_ASSIGN_ERROR
        {
            if (!DataCollection.is_valid_id(id))
                throw new DataCollectionError.ID_ERROR(@"Got invalid id \"$id\"");
            if (element == this)
                throw new DataCollectionError.SELF_SET_ERROR("Trying to set itself");
            if (element == this.root())
                throw new DataCollectionError.SELF_SET_ERROR("Implicit selfset");
            
            if (DataCollection.parser.is_valid_token(id))
            {
                element.assign();
                if (element is DataCollection)
                    ((DataCollection) element).parent = this;

                this.elements.set(id, element);
                return;
            }

            var next_token = DataCollection.parser.get_next_token(id);
            var next_id = DataCollection.parser.drop_next_token(id);

            DataCollection next_dc;
            if (this.has_element(next_token))
            {
                var next = this.get_element(next_token);
                if (!(next is DataCollection))
                    throw new DataCollectionError.ID_ERROR(@"Element \"$next_token\" exists and is not a DataCollection");
                next_dc = (DataCollection) next;
            }
            else
            {
                next_dc = new DataCollection();
                this.set_element(next_token, next_dc);
            }
            next_dc.set_element(next_id, element);
        }

        public void del_element(string id) throws DataCollectionError.ID_ERROR
        {
            if (!has_element(id))
                throw new DataCollectionError.ID_ERROR(@"Does not contain element with id \"$id\"");

            if (DataCollection.parser.is_valid_token(id))
            {
                var element = this.get_element(id);
                element.retract();
                if (element is DataCollection)
                    ((DataCollection) element).parent = null;
                this.elements.remove(id);
                return;
            }

            var next_token = DataCollection.parser.get_next_token(id);
            var next_id = DataCollection.parser.drop_next_token(id);
            var next_dc = (DataCollection) this.elements.get(next_token);
            
            next_dc.del_element(next_id);
        }

        public override DataObject copy()
        {
            var result = new DataCollection();
            foreach(var id in this.elements.get_keys())
                result.set_element(id, this.get_element(id).copy());
            return result;
        }

        public T? get_dataobject<T>(string id) throws DataCollectionError
        {
            if (id == DataCollection.EMPTY_ID) return null;

            if (!this.has_element(id))
                throw new DataCollectionError.ELEMENT_ERROR(@"DataCollection does not contain element \"$id\"");

            DataObject result = this.get_element(id);

            if (!(result is T))
                throw new DataCollectionError.ELEMENT_ERROR(@"Element \"$id\" is not instance of $(typeof(T).name())");

            return result;
        }
    }
}
