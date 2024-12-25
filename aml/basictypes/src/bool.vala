using AmlCore;

namespace AmlBasicTypes
{
    public class Bool : BasicType 
    {
        private bool data;

        public Bool.create(bool data)
        {
            this.data = data;
        }

        public bool get_val()
        {
            return this.data;
        }

        public void set_val(bool data)
        {
            this.data = data;
        }

        public override DataObject copy()
        {
            return new Bool.create(this.data);
        }
    }
}
