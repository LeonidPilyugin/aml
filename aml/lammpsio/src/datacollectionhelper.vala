using AmlCore;

namespace AmlLammpsIo
{
    private class DataCollectionHelper
    {
        public const string EMPTY_ID = "";
        private DataCollection data;

        public DataCollectionHelper(DataCollection data)
        {
            this.data = data;
        }

        public T? load_dataobject<T>(string id) throws ActionError
        {
            if (id == EMPTY_ID) return null;

            if (!data.has_element(id))
                throw new ActionError.LOGIC_ERROR(@"Data does not contain element \"$id\"");

            DataObject result = this.data.get_element(id);

            if (!(result is T))
                throw new ActionError.LOGIC_ERROR(@"Element \"$id\" is not instance of $(typeof(T).name())");

            return result;
        }
    }
}
