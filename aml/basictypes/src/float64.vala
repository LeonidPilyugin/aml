using AmlCore;

namespace AmlBasicTypes
{
    public class Float64 : BasicType 
    {
        private double data;

        public Float64.create(double data)
        {
            this.data = data;
        }

        public double get_val()
        {
            return this.data;
        }

        public void set_val(double data)
        {
            this.data = data;
        }

        public override DataObject copy()
        {
            return new Float64.create(this.data);
        }
    }
}
