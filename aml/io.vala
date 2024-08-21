namespace Aml
{
    public class Io : Object
    {
        public Parser parser;

        public Io.create(Parser parser)
        {
            this.parser = parser;
        }

        public List<Frame> load_frames(string path) throws Error
        {
            var dis = new DataInputStream(File.new_for_path(path).read());
            return this.parser.parse_frames(dis);
        }

        public Frame load_frame(string path) throws Error
        {
            var dis = new DataInputStream(File.new_for_path(path).read());
            return this.parser.parse_frame(dis);
        }

        public void dump_frames(List<Frame> frames, string path) throws Error
        {
            var dis = new DataOutputStream(File.new_for_path(path).create_readwrite(FileCreateFlags.PRIVATE).output_stream);
            this.parser.compose_frames(frames, dis);
        }

        public void dump_frame(Frame frame, string path) throws Error
        {
            var dis = new DataOutputStream(File.new_for_path(path).create_readwrite(FileCreateFlags.PRIVATE).output_stream);
            this.parser.compose_frame(frame, dis);
        }
    }
}
