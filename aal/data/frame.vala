namespace Aal {
    public errordomain FrameError {
        CONSTRUCTION_ERROR,
        INVALID_PROPERTY,
        INVALID_ID,
    }

    public class FrameInitData {
        public Box? box;
        public Atoms atoms;
        public PropertyList<FrameProperty> properties;

        public FrameInitData() {
            this.box = null;
            this.atoms = Atoms.create(0);
            this.properties = new PropertyList<FrameProperty>();
        }
    }

    public class Frame : Object {
        public Box box { get; protected set; }
        public Atoms atoms { get; protected set; }
        public PropertyList<FrameProperty> properties { protected get; protected set; }

        public Frame(FrameInitData data) throws FrameError.CONSTRUCTION_ERROR {
            if (data.box == null)
                throw new FrameError.CONSTRUCTION_ERROR("No box specified");

            this.box = data.box;
            this.atoms = data.atoms;
            this.properties = data.properties;
        }

        public static Frame create(
            Box box,
            Atoms atoms
        ) {
            var data = new FrameInitData();
            data.box = box;
            data.atoms = atoms;

            return new Frame(data);
        }

        public FrameProperty? get_prop(string id) {
            return (FrameProperty?) this.properties.get_prop(id);
        }

        public void set_prop(FrameProperty prop) throws FrameError.INVALID_PROPERTY {
            try {
                this.properties.append(prop);
            } catch (PropertyListError.EXISTS e) {
                throw new FrameError.INVALID_PROPERTY("Invalid property id");
            }
        }

        public void del_prop(string id) throws FrameError.INVALID_ID {
            try {
                this.properties.del_prop(id);
            } catch (PropertyListError.NOT_EXISTS e) {
                throw new FrameError.INVALID_ID("Id does not exist");
            }
        }

        public List<string> get_prop_ids() {
            return this.properties.get_prop_ids();
        }
    }
}
