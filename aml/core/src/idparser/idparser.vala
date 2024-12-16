namespace AmlCore
{
    public abstract class IdParser : AmlObject
    {
        public abstract string next_token(string id);
        public abstract string drop_next_token(string id);
        public abstract bool is_last_token(string id);
    }
}
