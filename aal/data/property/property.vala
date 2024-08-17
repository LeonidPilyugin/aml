namespace Aal {
    public class PropertyInitData : Object {
        public string id;

        public PropertyInitData(string id) {
            this.id = id;
        }
    }

    public class Property : Object {
        public string id { get; protected set; }

        public Property(PropertyInitData data) {
            this.id = data.id;
        }

        protected Property._copy(Property prop) {
            this.id = prop.id;
        }
    }
}
