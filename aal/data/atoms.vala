namespace Aal {
    public errordomain AtomsError {
        INVALID_PROPERTY,
        INVALID_ID,
        INVALID_ATOM,
        INVALID_INDEX,
        SIZE_ERROR,
    }

    public class AtomsInitData {
        public uint size;
        public List<PerAtomProperty> properties;

        public AtomsInitData() {
            this.size = 0;
            this.properties = new List<PerAtomProperty>();
        }
    }

    public class Atoms : Object {
        protected uint size;
        public PropertyList<PerAtomProperty> properties { protected get; protected set; }

        public Atoms(AtomsInitData data) throws AtomsError.INVALID_PROPERTY {
            this.size = data.size;
            this.properties = new PropertyList<PerAtomProperty>();
            foreach (var prop in data.properties) {
                this.properties.append(prop);
                if (prop.size != this.size)
                    throw new AtomsError.INVALID_PROPERTY(
                        "Property '%s' contains %u atoms instead of %u".printf(prop.id, prop.size, this.size)
                    );
            }
        }

        public static Atoms create(uint size) {
            var data = new AtomsInitData();
            data.size = size;
            return new Atoms(data);
        }

        public uint get_size() {
            return this.size;
        }

        public void set_size(uint n) {
            this.size = n;
        }

        public PerAtomProperty? get_prop(string id) {
            return (PerAtomProperty?) this.properties.get_prop(id)?.copy();
        }

        public void set_prop(PerAtomProperty prop) throws AtomsError.INVALID_PROPERTY {
            if (prop.size != this.size)
                throw new AtomsError.INVALID_PROPERTY("Invalid property length");
            try {
                this.properties.append(prop);
            } catch (PropertyListError.EXISTS e) {
                throw new AtomsError.INVALID_PROPERTY("Property with this id exists");
            }
        }

        public void del_prop(string id) throws AtomsError.INVALID_ID {
            try {
                this.properties.del_prop(id);
            } catch (PropertyListError.NOT_EXISTS e) {
                throw new AtomsError.INVALID_ID("Property with this id does not exist");
            }
        }
        
        public List<string> get_prop_ids() {
            return this.properties.get_prop_ids();
        }

        public Atom get_atom(uint index)
            requires (index < this.size) {
            Atom result = new Atom();
            Value temp;
            PerAtomProperty temp_prop;

            foreach (unowned var prop_id in this.properties.get_prop_ids()) {
                temp_prop = this.properties.get_prop(prop_id);
                if (temp_prop is IntPerAtomProperty) {
                    temp = Value(typeof(int));
                    temp.set_int(((IntPerAtomProperty) temp_prop).get_val(index));
                } else if (temp_prop is DoublePerAtomProperty) {
                    temp = Value(typeof(double));
                    temp.set_double(((DoublePerAtomProperty) temp_prop).get_val(index));
                } else {
                    temp = Value(typeof(string));
                    temp.set_string(((StringPerAtomProperty) temp_prop).get_val(index));
                }
                result.set_prop(prop_id, temp);
            }

            return result;
        }

        public bool can_insert(Atom atom) {
            var atom_ids = atom.get_prop_ids();
            var this_ids = this.properties.get_prop_ids();
            if (atom_ids.length() != this_ids.length())
                return false;
            foreach (unowned var id in atom_ids) {
                if (this_ids.index(id) != -1)
                    return false;
                if (!(
                    (atom.get_prop(id).type() == typeof(int) && this.properties.get_prop(id) is IntPerAtomProperty) ||
                    (atom.get_prop(id).type() == typeof(double) && this.properties.get_prop(id) is DoublePerAtomProperty) ||
                    (atom.get_prop(id).type() == typeof(string) && this.properties.get_prop(id) is StringPerAtomProperty)
                )) return false;
            }
            return true;
        }

        public void append_atom(Atom atom) throws AtomsError.INVALID_ATOM, AtomsError.SIZE_ERROR {
            if (!this.can_insert(atom))
                throw new AtomsError.INVALID_ATOM("Invalid atom");
            if (this.get_size() == uint.MAX)
                throw new AtomsError.SIZE_ERROR("Size out of range");

            Value temp_prop;
            foreach (unowned var prop_id in atom.get_prop_ids()) {
                temp_prop = atom.get_prop(prop_id);
                if (temp_prop.type() == typeof(int)) {
                    ((IntPerAtomProperty) this.properties.get_prop(prop_id)).append_val(temp_prop.get_int());
                } else if (temp_prop.type() == typeof(double)) {
                    ((DoublePerAtomProperty) this.properties.get_prop(prop_id)).append_val(temp_prop.get_double());
                } else {
                    ((StringPerAtomProperty) this.properties.get_prop(prop_id)).append_val(temp_prop.get_string());
                }
            }

            this.size++;
        }

        public void del_atom(uint index) throws AtomsError.INVALID_INDEX {
            if (index >= this.size)
                throw new AtomsError.INVALID_INDEX("Invalid index");
            PerAtomProperty prop;
            foreach (unowned var prop_id in this.properties.get_prop_ids()) {
                prop = this.properties.get_prop(prop_id);
                if (prop is IntPerAtomProperty) {
                    ((IntPerAtomProperty) prop).remove(index);
                } else if (prop is DoublePerAtomProperty) {
                    ((DoublePerAtomProperty) prop).remove(index);
                } else {
                    ((StringPerAtomProperty) prop).remove(index);
                }
            }
        }

        public void set_atom(uint index, Atom atom) throws AtomsError.INVALID_ATOM, AtomsError.INVALID_INDEX {
            if (!this.can_insert(atom))
                throw new AtomsError.INVALID_ATOM("Invalid atom");
            if (index >= this.size)
                throw new AtomsError.INVALID_INDEX("Invalid index");

            Value temp_prop;
            foreach (unowned var prop_id in atom.get_prop_ids()) {
                temp_prop = atom.get_prop(prop_id);
                if (temp_prop.type() == typeof(int)) {
                    ((IntPerAtomProperty) this.properties.get_prop(prop_id)).set_val(index, temp_prop.get_int());
                } else if (temp_prop.type() == typeof(double)) {
                    ((DoublePerAtomProperty) this.properties.get_prop(prop_id)).set_val(index, temp_prop.get_double());
                } else {
                    ((StringPerAtomProperty) this.properties.get_prop(prop_id)).set_val(index, temp_prop.get_string());
                }
            }
        }
    }
}
