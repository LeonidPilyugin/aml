using AmlCore;

namespace AmlBasicTypes
{
    public class Int64 : BasicType
    {
        private int64 data;

        public Int64.create(int64 data)
        {
            this.data = data;
        }

        public int64 get_val()
        {
            return this.data;
        }

        public void set_val(int64 data)
        {
            this.data = data;
        }

        public override DataObject copy()
        {
            return new Int64.create(this.data);
        }
    }
}
