namespace AmlCore
{
    public abstract class Action : AmlObject
    {
        public abstract DataCollection perform(DataCollection frame, bool change = false);
    }
}
