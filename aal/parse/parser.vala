namespace Aal {
    public errordomain IParserError {
        PARSE_ERROR,
        DATA_ERROR,
        NOT_IMPLEMENTED,
    }

    public interface IParser : Object {
        public abstract void compose_frames(List<Frame> frame, DataOutputStream output) throws IOError, IParserError;
        public abstract List<Frame> parse_frames(DataInputStream input) throws IOError, IParserError;
    }
}
