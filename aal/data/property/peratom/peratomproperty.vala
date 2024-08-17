namespace Aal {
    public errordomain PerAtomPropertyError {
        INDEX_ERROR,
        SIZE_ERROR,
    }

    public abstract class PerAtomPropertyInitData : PropertyInitData {
        protected PerAtomPropertyInitData(string id) {
            base(id);
        }
    }

    public abstract class PerAtomProperty : Property {
        protected PerAtomProperty(PerAtomPropertyInitData data) {
            base(data);
        }

        protected PerAtomProperty._copy(PerAtomProperty prop) {
            base._copy(prop);
        }

        public abstract uint size { get; set; }

        public abstract PerAtomProperty copy();
    }
}
