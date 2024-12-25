using AmlCore;

namespace AmlBasicTypes
{
    public class String : BasicType 
    {
        private string data;

        public String.create(string data)
        {
            this.data = data;
        }

        public string get_val()
        {
            return this.data;
        }

        public void set_val(string data)
        {
            this.data = data;
        }

        public override DataObject copy()
        {
            return new String.create(this.data);
        }
    }
}
