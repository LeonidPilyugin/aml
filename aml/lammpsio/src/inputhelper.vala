namespace AmlLammpsIo
{
    private class InputHelper
    {
        private DataInputStream stream;
        public string? line { get; private set; }
        public string? raw_line { get; private set; }
        public uint line_n { get; private set; }

        public InputHelper(DataInputStream stream)
        {
            this.stream = stream;
            this.line = null;
            this.raw_line = null;
            this.line_n = 0;
        }

        public string? read_line() throws IOError
        {
            this.raw_line = this.stream.read_line();
            this.line = this.raw_line?.strip();
            this.line_n++;
            return this.line;
        }

        public void prev_line()
        {
            if (this.raw_line == null) return;
            this.stream.seek(-this.raw_line.length - 1, SeekType.CUR);
        }
    }
}
