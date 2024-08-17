namespace Aal {
    public class IntPerAtomPropertyInitData : PerAtomPropertyInitData {
        public Array<int> array;

        public IntPerAtomPropertyInitData(string id, uint size) {
            base(id);
            this.array = new Array<int>.sized(false, false, sizeof(int), size);
        }
    }

    public class IntPerAtomProperty : PerAtomProperty {
        public Array<int> array { get; set; }

        public IntPerAtomProperty(IntPerAtomPropertyInitData data) {
            base(data);
            this.array = data.array;
        }

        public static IntPerAtomProperty create(string id, Array<int> arr) {
            var data = new IntPerAtomPropertyInitData(id, arr.length);
            data.array = arr;
            return new IntPerAtomProperty(data);
        }

        protected IntPerAtomProperty._copy(IntPerAtomProperty prop) {
            base._copy(prop);
            this.array = prop.array.copy();
        }

        public void set_val(uint index, int value) throws PerAtomPropertyError.INDEX_ERROR {
            if (index >= this.array.length)
                throw new PerAtomPropertyError.INDEX_ERROR("Index out of range");
            this.array.insert_val(index, value);
            this.array.remove_index(index + 1);
        }

        public int get_val(uint index) throws PerAtomPropertyError.INDEX_ERROR {
            if (index >= this.array.length)
                throw new PerAtomPropertyError.INDEX_ERROR("Index out of range");
            return this.array.index(index);
        }

        public void append_val(int value) throws PerAtomPropertyError.SIZE_ERROR {
            if (this.size == uint.MAX)
                throw new PerAtomPropertyError.SIZE_ERROR("Size out of range");
            this.array.append_val(value);
        }

        public void remove(uint index) throws PerAtomPropertyError.INDEX_ERROR {
            if (index >= this.size)
                throw new PerAtomPropertyError.INDEX_ERROR("Index out of range");
            this.array.remove_index(index);
        }

        public override uint size {
            get { return this.array.length; }
            set { this.array.set_size(value); }
        }

        public override PerAtomProperty copy() {
            return new IntPerAtomProperty._copy(this);
        }
    }
}
