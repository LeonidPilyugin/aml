namespace Aml
{
    public class FrameProperty : Property
    {
        public Value data;

        public FrameProperty.create(owned Value data)
        {
            this.data = data;
        }

        public FrameProperty copy()
        {
            Value copy = Value(this.data.type());
            this.data.copy(ref copy);
            return new FrameProperty.create(copy);
        }
    }
}
