using AmlCore;

namespace AmlLammpsIo
{
    private class InputHelper
    {
        private DataInputStream stream;
        public string? line { get; private set; }
        public string? raw_line { get; private set; }
        public uint line_n { get; private set; }

        public InputHelper(string filepath) throws ActionError
        {
            try
            {
                this.stream = new DataInputStream(File.new_for_path(filepath).read());
                this.line = null;
                this.raw_line = null;
                this.line_n = 0;
            } catch (Error e)
            {
                throw new ActionError.LOGIC_ERROR(@"Cannot open file \"filepath\": $(e.message)");
            }
        }

        public string? read_line() throws ActionError
        {
            try{
                this.raw_line = this.stream.read_line();
                this.line = this.raw_line?.strip();
                this.line_n++;
                return this.line;
            } catch (IOError e)
            {
                this.stream.close();
                throw new ActionError.LOGIC_ERROR(@"IOError at line $(this.line_n): $(e.message)");
            }
        }

        public void prev_line()
        {
            if (this.raw_line == null) return;
            this.stream.seek(-this.raw_line.length - 1, SeekType.CUR);
        }

        ~InputHelper()
        {
            this.stream.close();
        }
    }
}
