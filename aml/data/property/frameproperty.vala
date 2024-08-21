namespace Aml
{
    /**
     * Property of Frame
     */
    public class FrameProperty : Property
    {
        /**
         * Data
         */
        public Value data;

        /**
         * Creates FrameProperty from data
         * 
         * @param data Data to set
         */
        public FrameProperty.create(owned Value data)
        {
            this.data = data;
        }

        /**
         * Copies this object
         * 
         * @return Copy of this object
         */
        public FrameProperty copy()
        {
            Value copy = Value(this.data.type());
            this.data.copy(ref copy);
            return new FrameProperty.create(copy);
        }
    }
}
