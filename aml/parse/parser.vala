namespace Aml
{
    public errordomain ParserError
    {
        PARSE_ERROR,
        DATA_ERROR,
        NOT_IMPLEMENTED,
    }

    /**
     * Parses and composes frame objects
     */
    public abstract class Parser : Object
    {
        /**
         * Writes frame to output
         * 
         * @param frame Frame to write
         * @param output Output
         * 
         * @throws IOError If cannot write
         * @throws ParserError If cannot compose
         */
        public abstract void compose_frame(Frame frame, DataOutputStream output)
            throws IOError, ParserError;

        /**
         * Reads frame from input
         * 
         * @param input Input
         * 
         * @return New Frame object
         * 
         * @throws IOError If cannot write
         * @throws ParserError If cannot compose
         */
        public virtual Frame parse_frame(DataInputStream input)
            throws IOError, ParserError
        {
            return (owned) this.parse_frames(input).first().data;
        }

        /**
         * Writes frames to output
         * 
         * @param frames Frames to write
         * @param output Output
         * 
         * @throws IOError If cannot write
         * @throws ParserError If cannot compose
         */
        public virtual void compose_frames(List<Frame> frames, DataOutputStream output)
            throws IOError, ParserError
        {
            foreach (unowned var frame in frames)
                this.compose_frame(frame, output);
        }

        /**
         * Reads frames from input
         * 
         * @param input Input
         * 
         * @return List of frames
         * 
         * @throws IOError If cannot read
         * @throws ParserError If caonnot parse
         */
        public abstract List<Frame> parse_frames(DataInputStream input)
            throws IOError, ParserError;
    }
}
