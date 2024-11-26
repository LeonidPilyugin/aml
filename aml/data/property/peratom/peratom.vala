namespace Aml
{
    public errordomain PerAtomPropertyError
    {
        TYPE_ERROR,
    }

    /**
     * Base class of all per atom properties
     */
    public abstract class PerAtomProperty :
        Property
    {
        /**
         * Copies this object
         * 
         * @return Copy of this object
         */
        public abstract PerAtomProperty copy();

        /**
         * Returns size
         * 
         * @return Size
         */
        public abstract uint get_size();

        /**
         * Sets size
         * 
         * @param size Size to set
         */
        public abstract void set_size(uint size);

        public abstract Variant get_val_variant(uint index);

        public virtual Variant get_first_variant() {
            if (this.get_size() == 0)
                throw new CollectionError.SIZE_ERROR("Empty");
            return this.get_val_variant(0);
        }

        public virtual Variant get_last_variant() {
            if (this.get_size() == 0)
                throw new CollectionError.SIZE_ERROR("Empty");
            return this.get_val_variant(this.get_size() - 1);
        }

        public abstract void set_val_variant(uint index, Variant v);

        public virtual void set_first_variant(Variant v) {
            if (this.get_size() == 0)
                throw new CollectionError.SIZE_ERROR("Empty");
            this.set_val_variant(0, v);
        }

        public virtual void set_last_variant(Variant v) {
            if (this.get_size() == 0)
                throw new CollectionError.SIZE_ERROR("Empty");
            this.set_val_variant(this.get_size() - 1, v);
        }

        public abstract void insert_val_variant(uint index, Variant v);

        public virtual void insert_first_variant(Variant v) {
            this.insert_val_variant(this.get_size(), v);
        }

        public virtual void insert_last_variant(Variant v) {
            this.insert_val_variant(0, v);
        }

        /**
         * Removes value by index
         * 
         * @param index Index
         * 
         * @throws CollectionError.INDEX_ERROR If got invalid index
         */
        public abstract void remove_val(uint index) throws CollectionError;

        /**
         * Removes first value
         * 
         * @throws CollectionError.INDEX_ERROR If got invalid index
         * @throws CollectionError.SIZE_ERROR If empty
         */
        public virtual void remove_first() throws CollectionError
        {
            if (this.get_size() == 0)
                throw new CollectionError.SIZE_ERROR("Empty");
            this.remove_val(0);
        }

        /**
         * Removes last value
         * 
         * @throws CollectionError.INDEX_ERROR If got invalid index
         * @throws CollectionError.SIZE_ERROR If empty
         */
        public virtual void remove_last() throws CollectionError
        {
            if (this.get_size() == 0)
                throw new CollectionError.SIZE_ERROR("Empty");
            this.remove_val(this.get_size() - 1);
        }
    }
}
