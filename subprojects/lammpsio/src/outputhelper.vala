using AmlCore;

namespace AmlLammpsIo
{
    private class OutputHelper
    {
        private OutputStream stream;
        private FileIOStream iostream;

        public const uint BUFFER_SIZE = 8096;

        public OutputHelper(string filepath) throws ActionError.RUNTIME_ERROR
        {
            try
            {
                this.iostream = File.new_for_path(filepath).replace_readwrite(null, false, FileCreateFlags.PRIVATE);
                this.stream = this.iostream.output_stream;
                var bstream = new BufferedOutputStream.sized(this.iostream.output_stream, OutputHelper.BUFFER_SIZE);

                this.stream = bstream;
            } catch (Error e)
            {
                throw new ActionError.RUNTIME_ERROR(@"Cannot open file \"$filepath\" for write: $(e.message)");
            }
        }

        public void put_bytes(unowned uint8[] bytes) throws ActionError.RUNTIME_ERROR
        {
            ssize_t written = 0;
            try
            {
                while (written < bytes.length)
                    written += this.stream.write(bytes[written:bytes.length]);
            } catch (IOError e)
            {
                this.stream.close();
                throw new ActionError.RUNTIME_ERROR(@"IOError: $(e.message)");
            }
        }

        public void put_string(string val) throws ActionError.RUNTIME_ERROR
        {
            this.put_bytes(val.data);
        }

        public void put_double(double val) throws ActionError.RUNTIME_ERROR
        {
            this.put_bytes((uint8[]) val);
        }

        public void put_int64(int64 val) throws ActionError.RUNTIME_ERROR
        {
            this.put_bytes((uint8[]) val);
        }

        public void put_int32(int32 val) throws ActionError.RUNTIME_ERROR
        {
            this.put_bytes((uint8[]) val);
        }

        public void put_uint8(uint8 val) throws ActionError.RUNTIME_ERROR
        {
            this.put_bytes((uint8[]) val);
        }

        ~OutputHelper()
        {
            this.stream.close();
        }
    }
}
