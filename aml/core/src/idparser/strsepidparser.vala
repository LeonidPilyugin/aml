namespace AmlCore
{
    public class StrSepIdParser : IdParser
    {
        private string separator;
        
        public StrSepIdParser(string separator)
        {
            this.separator = separator;
        }

        public string get_separator()
        {
            return this.separator;
        }

        public override string next_token(string id)
        {
            return id.split(this.separator)[0];
        }

        public override string drop_next_token(string id)
        {
            return string.joinv(this.separator, id.split(this.separator)[1:]);
        }

        public override bool is_last_token(string id)
        {
            return !(this.separator in id);
        }
    }
}
