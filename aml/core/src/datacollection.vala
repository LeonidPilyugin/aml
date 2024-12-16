namespace AmlCore
{
    public errordomain DataCollectionError
    {
        ID_ERROR,
        SELF_SET_ERROR,
    }

    public abstract class DataCollection: DataObject
    {
        private IdParser parser = new StrSepIdParser(".");

        public void set_parser(IdParser parser)
        {
            this.parser = parser;
        }


        public IdParser get_parser()
        {
            return this.parser;
        }

        public abstract bool contains(DataObject obj);

        public abstract bool has_element(string id);

        public abstract DataObject get_element(string id) throws DataCollectionError.ID_ERROR;

        public abstract void del_element(string id)throws DataCollectionError.ID_ERROR;

        public abstract void set_element(string id, owned DataObject prop) throws DataCollectionError.ID_ERROR, DataCollectionError.SELF_SET_ERROR;

        public abstract List<weak string> get_ids();
    }
}
