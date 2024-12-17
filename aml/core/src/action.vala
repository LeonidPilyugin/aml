namespace AmlCore
{
    public abstract class Action : AmlObject
    {
        public abstract void perform(DataCollection data);

        public virtual DataCollection perform_immutable(DataCollection data)
        {
            var copy = (DataCollection) data.copy();
            this.perform(copy);
            return copy;
        }
    }
}
