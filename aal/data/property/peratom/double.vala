namespace Aal {
    public class DoublePerAtomPropertyInitData : PerAtomPropertyInitData {
        public Array<double> array;

        public DoublePerAtomPropertyInitData(string id, uint size) {
            base(id);
            this.array = new Array<double>.sized(false, false, sizeof(double), size);
        }
    }

    public class DoublePerAtomProperty : PerAtomProperty {
        public Array<double> array { get; set; }

        public DoublePerAtomProperty(DoublePerAtomPropertyInitData data) {
            base(data);
            this.array = data.array;
        }

        public static DoublePerAtomProperty create(string id, Array<double> arr) {
            var data = new DoublePerAtomPropertyInitData(id, arr.length);
            data.array = arr;
            return new DoublePerAtomProperty(data);
        }

        public DoublePerAtomProperty._copy(DoublePerAtomProperty prop) {
            base._copy(prop);
            this.array = prop.array.copy();
        }

        public void set_val(uint index, double value) throws PerAtomPropertyError.INDEX_ERROR {
            if (index >= this.array.length)
                throw new PerAtomPropertyError.INDEX_ERROR("Index out of range");
            this.array.insert_val(index, value);
            this.array.remove_index(index + 1);
        }

        public double get_val(uint index) throws PerAtomPropertyError.INDEX_ERROR {
            if (index >= this.array.length)
                throw new PerAtomPropertyError.INDEX_ERROR("Index out of range");
            return this.array.index(index);
        }

        public void append_val(double value) throws PerAtomPropertyError.SIZE_ERROR {
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
            return new DoublePerAtomProperty._copy(this);
        }
    }
}
