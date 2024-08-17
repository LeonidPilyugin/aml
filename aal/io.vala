namespace Aal {
    public class Io : Object {
        public IParser parser { get; set; }

        public Io(IParser parser) {
            this.parser = parser;
        }

        public static Io create(IParser parser) {
            return new Io(parser);
        }

        public List<Frame> load_frames(string path) throws Error {
            var dis = new DataInputStream(File.new_for_path(path).read());
            return this.parser.parse_frames(dis);
        }

        public Frame load_frame(string path) throws Error {
            return this.load_frames(path).first().data;
        }

        public void dump_frames(List<Frame> frames, string path) throws Error {
            var dis = new DataOutputStream(File.new_for_path(path).create_readwrite(FileCreateFlags.PRIVATE).output_stream);
            this.parser.compose_frames(frames, dis);
        }

        public void dump_frame(Frame frame, string path) throws Error {
            var frames = new List<Frame>();
            frames.prepend(frame);
            this.dump_frames(frames, path);
        }
    }
}
