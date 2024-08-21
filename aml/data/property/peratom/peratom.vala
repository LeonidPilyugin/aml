namespace Aml
{
    /**
     * Base class of all per atom properties
     */
    public abstract class PerAtomProperty :
        Property
    { 
        public abstract PerAtomProperty copy();
        public abstract uint get_size();
        public abstract void set_size(uint size);
        public abstract void remove_val(uint index) throws CollectionError;
        public abstract void remove_first() throws CollectionError;
        public abstract void remove_last() throws CollectionError;
    }
}
