namespace Aal {
    public errordomain AtomError {
        TYPE_ERROR,
        INVALID_PROPERTY,
    }

    public class Atom : Object {
        protected HashTable<string, Value?> data;

        public Atom() {
            this.data = new HashTable<string, Value?>(str_hash, str_equal);
        }

        public static Atom create() {
            return new Atom();
        }

        protected Atom._copy(Atom atom) {
            this.data = new HashTable<string, Value?>(str_hash, str_equal);
            foreach (unowned var key in atom.data.get_keys())
                this.data.set(key, atom.data.get(key));
        }

        public Value? get_prop(string id)
            ensures (
                result == null ||
                result.type() == typeof(int) ||
                result.type() == typeof(double) ||
                result.type() == typeof(string)
            ) {
            if (!this.data.contains(id)) return null;
            return (Value) this.data.get(id);
        }

        public void set_prop(string id, Value prop) throws AtomError.TYPE_ERROR {
            if (!(
                prop.type() == typeof(int) ||
                prop.type() == typeof(double) ||
                prop.type() == typeof(string)
            )) throw new AtomError.TYPE_ERROR("Invalid value type. Expected int, double or string");
            this.data.set(id, prop);
        }

        public void del_prop(string id) throws AtomError.INVALID_PROPERTY {
            if (this.get_prop(id) == null)
                throw new AtomError.INVALID_PROPERTY("Invalid property id");
            this.data.remove(id);
        }

        public List<weak string> get_prop_ids() {
            return this.data.get_keys();
        }

        public Atom copy() {
            return new Atom._copy(this);
        }
    }
}
