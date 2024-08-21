namespace Aml
{
    public errordomain ParserError
    {
        PARSE_ERROR,
        DATA_ERROR,
        NOT_IMPLEMENTED,
    }

    public abstract class Parser : Object
    {
        public abstract void compose_frame(Frame frame, DataOutputStream output)
            throws IOError, ParserError;

        public virtual Frame parse_frame(DataInputStream input)
            throws IOError, ParserError
        {
            return (owned) this.parse_frames(input).first().data;
        }

        public virtual void compose_frames(List<Frame> frames, DataOutputStream output)
            throws IOError, ParserError
        {
            foreach (unowned var frame in frames)
                this.compose_frame(frame, output);
        }

        public abstract List<Frame> parse_frames(DataInputStream input)
            throws IOError, ParserError;
    }
}
