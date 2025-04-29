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
                throw new ActionError.RUNTIME_ERROR(@"Cannot open file \"filepath\": $(e.message)");
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
                throw new ActionError.RUNTIME_ERROR(@"IOError at line $(this.line_n): $(e.message)");
            }
        }

        public void prev_line()
        {
            if (this.raw_line == null) return;
            this.stream.seek(-this.raw_line.length - 1, SeekType.CUR);
        }

        public void read_bytes(uint8[] bytes) throws ActionError
        {
            try
            {
                this.stream.read(bytes);
            } catch (IOError e)
            {
                this.stream.close();
                throw new ActionError.RUNTIME_ERROR(@"IOError: $(e.message)");
            }
        }

        public double read_double() throws ActionError
        {
            uint8[] buffer = new uint8[sizeof(double)];
            this.read_bytes(buffer);
            return ((double*) buffer)[0];
        }

        public int32 read_int32() throws ActionError
        {
            uint8[] buffer = new uint8[sizeof(int32)];
            this.read_bytes(buffer);
            return ((int32*) buffer)[0];
        }

        public int64 read_int64() throws ActionError
        {
            uint8[] buffer = new uint8[sizeof(int64)];
            this.read_bytes(buffer);
            return ((int64*) buffer)[0];
        }

        public uint8 read_uint8() throws ActionError
        {
            uint8[] buffer = new uint8[1];
            this.read_bytes(buffer);
            return buffer[0];
        }

        public string read_string(uint size) throws ActionError
        {
            uint8[] buffer = new uint8[size];
            this.read_bytes(buffer);
            return (string) buffer;
        }

        ~InputHelper()
        {
            this.stream.close();
        }
    }
}
