namespace AmlCore
{
    public errordomain DataObjectError
    {
        DOUBLE_ASSIGN_ERROR,
        DOUBLE_RETRACT_ERROR,
    }

    public abstract class DataObject : AmlObject
    {
        private bool assigned = false;

        internal void assign() throws DataObjectError.DOUBLE_ASSIGN_ERROR
        {
            if (this.assigned)
                throw new DataObjectError.DOUBLE_ASSIGN_ERROR("Already assigned");
            this.assigned = true;
        }

        internal void retract() throws DataObjectError.DOUBLE_RETRACT_ERROR
        {
            if (!this.assigned)
                throw new DataObjectError.DOUBLE_RETRACT_ERROR("Is not assigned");
            this.assigned = false;
        }
        
        public abstract DataObject copy();
    }
}
