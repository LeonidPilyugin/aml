namespace AmlCore
{
    public class DataHashTable : DataCollection
    {
        private HashTable<string, DataObject> elements;

        public DataHashTable.empty()
        {
            this.elements = new HashTable<string, DataObject>(str_hash, str_equal);
        }

        public override bool contains(DataObject obj)
        {
            var vals = this.elements.get_values();
            foreach (unowned var v in vals) {
                if (v == obj) return true;
            }
            foreach (unowned var v in vals)
                if (v is DataCollection)
                    if (((DataCollection) v).contains(obj)) return true;
            return false;
                    
        }

        public override bool has_element(string id)
        {
            // if last token, check if elements has it
            if (this.get_parser().is_last_token(id))
                return this.elements.contains(id);

            // get next token and id for next data collection
            var next_token = this.get_parser().next_token(id);
            var tail = this.get_parser().drop_next_token(id);

            // if elements has next token, continue
            if (this.elements.contains(next_token))
            {
                // get next element and check if it is datacollection
                var next_element = this.elements.get(next_token);
                if (!(next_element is DataCollection)) return false;
                DataCollection next_dc = (DataCollection) next_element;
                return next_dc.has_element(tail);
            }

            // if not, return false
            return false;
        }

        public override DataObject get_element(string id) throws DataCollectionError.ID_ERROR
        {
            if (!this.has_element(id))
                throw new DataCollectionError.ID_ERROR(@"Does not contain id \"$id\"");
            if (this.get_parser().is_last_token(id))
                return this.elements.get(id);

            var next_token = this.get_parser().next_token(id);
            var tail = this.get_parser().drop_next_token(id);
            var next_element = this.elements.get(next_token);
            DataCollection next_dc = (DataCollection) next_element;
            return next_dc.get_element(tail);
        }

        public override void del_element(string id) throws DataCollectionError.ID_ERROR
        {
            if (!this.has_element(id))
                throw new DataCollectionError.ID_ERROR(@"Does not contain id \"$id\"");
            if (this.get_parser().is_last_token(id))
                this.elements.remove(id);
            var next_token = this.get_parser().next_token(id);
            var tail = this.get_parser().drop_next_token(id);
            DataCollection next_element = (DataCollection) this.elements.get(next_token);
            next_element.del_element(tail);
        }

        public override void set_element(string id, owned DataObject element) throws DataCollectionError.ID_ERROR, DataCollectionError.SELF_SET_ERROR
        {
            // check that not assigning itself
            if (element == this)
                throw new DataCollectionError.SELF_SET_ERROR("Trying to set field with itself");
            if (element is DataCollection && ((DataCollection) element).contains(this))
                throw new DataCollectionError.SELF_SET_ERROR("Trying to set field with itself");
            // if last token, set
            if (this.get_parser().is_last_token(id))
            {
                this.elements.set(id, element);
                return;
            }

            // get next element token
            var next_token = this.get_parser().next_token(id);
            var tail = this.get_parser().drop_next_token(id);
            // if does not contain next element, throw error
            if (!this.elements.contains(next_token))
                throw new DataCollectionError.ID_ERROR(@"Does not contain element \"$next_token\"");
            var next_element = this.elements.get(next_token);
            // if next element is not a DataCollection, throw error
            if (!(next_element is DataCollection))
                throw new DataCollectionError.ID_ERROR(@"Element \"$next_token\" is not an instance of DataCollection");
            DataCollection next_dc = (DataCollection) next_element;
            next_dc.set_element(tail, element);
        }

        public override List<weak string> get_ids()
        {
            return this.elements.get_keys();
        }

        public override DataObject copy()
        {
            var res = new DataHashTable.empty();
            foreach (unowned var key in this.get_ids())
                res.set_element(key, this.get_element(key).copy());
            return res;
        }
    }
}
