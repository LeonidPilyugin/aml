namespace Aal {
    public class InputHelper : Object {
        private DataInputStream stream;
        public string? line { get; private set; }
        public uint line_n { get; private set; }

        public InputHelper(DataInputStream stream) {
            this.stream = stream;
            this.line = null;
            this.line_n = 0;
        }

        public string? read_line() throws IOError {
            this.line = this.stream.read_line()?.strip();
            this.line_n++;
            return this.line;
        }
    }
}
