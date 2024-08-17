namespace Aal {
    public errordomain PropertyListError {
        EXISTS,
        NOT_EXISTS,
    }

    public class PropertyList<G> : Object {
        protected List<G> _list;

        public PropertyList() {
            this._list = new List<G>();
        }

        public unowned G? get_prop(string id) {
            foreach (unowned G prop in this._list) {
                if (((Property) prop).id == id) {
                    return prop;
                }
            }

            return null;
        }

        public void del_prop(string id) throws PropertyListError.NOT_EXISTS {
            if (this.get_prop(id) == null)
                throw new PropertyListError.NOT_EXISTS("Property with this id not exists");
            this._list.remove(this.get_prop(id));
        }

        public void append(G prop) throws PropertyListError.EXISTS {
            if (this.get_prop(((Property) prop).id) != null)
                throw new PropertyListError.EXISTS("Property with this id exists");
            this._list.append(prop);
        }

        public List<string> get_prop_ids() {
            var result = new List<string>();
            foreach (unowned G prop in this._list) {
                result.append(((Property) prop).id);
            }
            return result;
        }
    }
}
