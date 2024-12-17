namespace AmlCore
{
    public errordomain DataObjectError
    {
        DOUBLE_ASSIGN_ERROR,
    }

    public abstract class DataObject : AmlObject
    {
        private bool assigned = false;
        
        public bool is_assigned()
        {
            return this.assigned;
        }

        public void assign() throws DataObjectError.DOUBLE_ASSIGN_ERROR
        {
            if (this.assigned)
                throw new DataObjectError.DOUBLE_ASSIGN_ERROR("Already assigned");
            this.assigned = true;
        }

        public void retract()
        {
            this.assigned = false;
        }

        public abstract DataObject copy();
    }
}
