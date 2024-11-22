namespace Aml
{
    /**
     * Reads and writes frames to files
     */
    public class Io : Object
    {
        /**
         * Parser to use
         */
        public Parser parser;

        /**
         * Creates new Io with parser
         * 
         * @param parser Parser to set
         */
        public Io.create(owned Parser parser)
        {
            this.parser = parser;
        }

        /**
         * Loads frames from file
         * 
         * @param path Path to file
         * 
         * @return List of frames
         */
        public List<Frame> load_frames(string path) throws Error
        {
            var dis = new DataInputStream(File.new_for_path(path).read());
            return this.parser.parse_frames(dis);
        }

        /**
         * Loads frame from file
         * 
         * @param path Path to file
         * 
         * @return Frame
         */
        public Frame load_frame(string path) throws Error
        {
            var dis = new DataInputStream(File.new_for_path(path).read());
            return this.parser.parse_frame(dis);
        }

        /**
         * Writes frames to file
         * 
         * @param frames List of frames
         * @param path Path to file
         */
        public void dump_frames(List<Frame> frames, string path) throws Error
        {
            var dis = new DataOutputStream(File.new_for_path(path).replace_readwrite(null, false, FileCreateFlags.PRIVATE).output_stream);
            this.parser.compose_frames(frames, dis);
        }

        /**
         * Writes frame to file
         * 
         * @param frame Frame
         * @param path Path to file
         */
        public void dump_frame(Frame frame, string path) throws Error
        {
            var dis = new DataOutputStream(File.new_for_path(path).replace_readwrite(null, false, FileCreateFlags.PRIVATE).output_stream);
            this.parser.compose_frame(frame, dis);
        }
    }
}
