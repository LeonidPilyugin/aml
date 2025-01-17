using AmlCore;

namespace AmlLammpsIo
{
    private class OutputHelper
    {
        //private DataOutputStream stream;
        private OutputStream stream;
        private FileIOStream iostream;

        public const uint BUFFER_SIZE = 8096;

        public OutputHelper(string filepath) throws ActionError.LOGIC_ERROR
        {
            try
            {
                this.iostream = File.new_for_path(filepath).replace_readwrite(null, false, FileCreateFlags.PRIVATE);
                var bstream = new BufferedOutputStream.sized(this.iostream.output_stream, OutputHelper.BUFFER_SIZE);
                this.stream = bstream; //new DataOutputStream(bstream);
            } catch (Error e)
            {
                throw new ActionError.LOGIC_ERROR(@"Cannot open file \"$filepath\" for write: $(e.message)");
            }
        }

        public void put_string(string val) throws ActionError.LOGIC_ERROR
        {
            try
            {
                this.stream.write(val.data);
            } catch (IOError e)
            {
                this.stream.close();
                throw new ActionError.LOGIC_ERROR(@"IOError: $(e.message)");
            }
        }

        ~OutputHelper()
        {
            this.stream.close();
        }
    }
}
