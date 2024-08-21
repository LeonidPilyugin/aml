namespace Aml
{
    public class IntPerAtomProperty :
        PerAtomProperty
    {
        private Array<int> array;

        public IntPerAtomProperty.create(owned int[] array)
        {
            this.array = new Array<int>.take(array);
        }

        public IntPerAtomProperty.empty()
        {
            this.array = new Array<int>();
        }

        public int[] get_arr()
        {
            unowned var a = this.array.data;
            return a.copy();
        }

        public void set_arr(owned int[] array)
        {
            this.array = new Array<int>.take(array);
        }

        public void set_val(uint index, int value)
            throws CollectionError.INDEX_ERROR
        {
            if (index >= this.array.length)
                throw new CollectionError.INDEX_ERROR("Index out of range");
            this.array.insert_val(index, value);
            this.array.remove_index(index + 1);
        }

        public int get_val(uint index)
            throws CollectionError.INDEX_ERROR
        {
            if (index >= this.array.length)
                throw new CollectionError.INDEX_ERROR("Index out of range");
            return this.array.index(index);
        }

        public void insert_val(uint index, int value)
            throws CollectionError
        {
            if (this.get_size() == uint.MAX)
                throw new CollectionError.SIZE_ERROR("Size out of range");
            if (index > this.get_size())
                throw new CollectionError.INDEX_ERROR("Index out of range");
            this.array.insert_val(index, value);
        }

        public void insert_last(int value)
            throws CollectionError
        {
            this.insert_val(this.get_size(), value);
        }

        public void insert_first(int value)
            throws CollectionError
        {
            this.insert_val(0, value);
        }

        public override void remove_val(uint index)
            throws CollectionError
        {
            if (index >= this.get_size())
                throw new CollectionError.INDEX_ERROR("Index out of range");
            this.array.remove_index(index);
        }

        public override void remove_first()
            throws CollectionError
        {
            if (this.get_size() == 0)
                throw new CollectionError.SIZE_ERROR("Empty");
            this.remove_val(0);
        }

        public override void remove_last()
            throws CollectionError
        {
            if (this.get_size() == 0)
                throw new CollectionError.SIZE_ERROR("Empty");
            this.remove_val(this.get_size() - 1);
        }
        public override uint get_size()
        {
            return this.array.length;
        }

        public override void set_size(uint size)
        {
            this.array.set_size(size);
        }

        public override PerAtomProperty copy()
        {
            return new IntPerAtomProperty.create(this.get_arr());
        }
    }
}
