namespace Aml
{
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
