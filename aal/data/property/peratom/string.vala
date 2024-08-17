namespace Aal {
    public class StringPerAtomPropertyInitData : PerAtomPropertyInitData {
        public Array<string> array;

        public StringPerAtomPropertyInitData(string id, uint size) {
            base(id);
            this.array = new Array<string>.sized(false, false, sizeof(string), size);
        }
    }

    public class StringPerAtomProperty : PerAtomProperty {
        public Array<string> array { get; set; }

        public StringPerAtomProperty(StringPerAtomPropertyInitData data) {
            base(data);
            this.array = data.array;
        }

        public static StringPerAtomProperty create(string id, Array<string> arr) {
            var data = new StringPerAtomPropertyInitData(id, arr.length);
            data.array = arr;
            return new StringPerAtomProperty(data);
        }

        public StringPerAtomProperty._copy(StringPerAtomProperty prop) {
            base._copy(prop);
            this.array = new Array<string>.sized(false, false, sizeof(string), prop.array.length);
            foreach (unowned var str in prop.array)
                this.array.append_val(str);
        }

        public void set_val(uint index, string value) throws PerAtomPropertyError.INDEX_ERROR {
            if (index >= this.size)
                throw new PerAtomPropertyError.INDEX_ERROR("Index out of range");
            this.array.insert_val(index, value);
            this.array.remove_index(index + 1);
        }

        public string get_val(uint index) throws PerAtomPropertyError.INDEX_ERROR {
            if (index >= this.size)
                throw new PerAtomPropertyError.INDEX_ERROR("Index out of range");
            return this.array.index(index);
        }

        public void append_val(string value) throws PerAtomPropertyError.SIZE_ERROR {
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
            return new StringPerAtomProperty._copy(this);
        }
    }
}
