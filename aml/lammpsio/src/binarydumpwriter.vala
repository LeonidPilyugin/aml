using AmlCore;
using AmlBasicTypes;
using AmlBox;
using AmlParticles;
using AmlMath;

namespace AmlLammpsIo
{
    public class BinaryDumpWriter : AmlCore.Action
    {
        protected override string get_params_error_message(ActionParams params)
        {
            if (!(params is WriterParams))
                return "Params shoud be instance of AmlLammpsIo.WriterParams";

            WriterParams ps = (WriterParams) params;

            if (ps.get_particles_id() == DataCollectionHelper.EMPTY_ID || !DataCollection.is_valid_id(ps.get_particles_id()))
                return @"particles_id \"$(ps.get_particles_id())\" is not a valid id";
            if (ps.get_box_id() == DataCollectionHelper.EMPTY_ID || !DataCollection.is_valid_id(ps.get_box_id()))
                return @"box_id \"$(ps.get_box_id())\" is not a valid id";
            if (ps.get_timestep_id() == DataCollectionHelper.EMPTY_ID || !DataCollection.is_valid_id(ps.get_timestep_id()))
                return @"timestep_id \"$(ps.get_timestep_id())\" is not a valid id";
            if (ps.get_time_id() != DataCollectionHelper.EMPTY_ID && !DataCollection.is_valid_id(ps.get_time_id()))
                return @"time_id \"$(ps.get_time_id())\" is not a valid id";
            if (ps.get_units_id() != DataCollectionHelper.EMPTY_ID && !DataCollection.is_valid_id(ps.get_units_id()))
                return @"units_id \"$(ps.get_units_id())\" is not a valid id";

            return "";
        }

        private void put_timestep(OutputHelper output, int64 timestep) throws ActionError
        {
            // put magic string
            string magic_string = "DUMPCUSTOM";
            output.put_int64(-magic_string.length);
            output.put_string(magic_string);

            // put endian
            output.put_int32(0x0001);

            // put revision
            output.put_int32(0x0002);

            // put timestep
            output.put_int64(timestep);
        }

        private void put_n_atoms(OutputHelper output, int64 n_atoms) throws ActionError
        {
            output.put_int64(n_atoms);
        }

        private void put_box(OutputHelper output, ParallelepipedBox box) throws ActionError
        {
            var edge = box.get_edge();
            var origin = box.get_origin();
            var boundaries = box.get_boundaries();

            // put triclinic id
            output.put_int32(edge.is_diagonal() ? 0 : 2);
            
            // put boundaries
            for (uint8 i = 0; i < 3; i++)
                for (uint8 j = 0; j < 2; j++)
                    output.put_int32(boundaries[i] ? 0 : 1);

            // put triclinic
            if (edge.is_diagonal())
            {
                for (uint8 i = 0; i < 3; i++)
                {
                    output.put_double(origin.get_val(i));
                    output.put_double(origin.get_val(i) + edge.get_val(i, i));
                }
            } else
            {
                for (uint8 i = 0; i < 3; i++)
                    for (uint8 j = 0; j < 3; j++)
                        output.put_double(edge.get_val(i, j));
                for (uint8 i = 0; i < 3; i++)
                    output.put_double(origin.get_val(i));
            }
        }

        private void put_size_one(OutputHelper output, int32 size_one) throws ActionError
        {
            output.put_int32(size_one);
        }

        private void put_units(OutputHelper output, string? units) throws ActionError
        {
            if (units == null)
            {
                output.put_int32(0);
                return;
            }

            output.put_int32((int32) units.length);
            output.put_string(units);
        }

        private void put_time(OutputHelper output, double? time) throws ActionError
        {
            if (time == null)
            {
                output.put_uint8(0);
                return;
            }

            output.put_uint8(1);
            output.put_double(time);
        }

        private void put_columns(OutputHelper output, string[] properties) throws ActionError
        {
            var str = string.joinv(" ", properties);
            output.put_int32(str.length);
            output.put_string(str);
        }

        private void put_particles(OutputHelper output, Particles particles, unowned Float64PerParticleProperty[] props) throws ActionError
        {
            int32 size_one = (int32) props.length;
            int32 max_buff_size = 1024 * 32;
            int32 max_lines = (int32) (max_buff_size / (size_one * sizeof(double)));
            int32 max_n = size_one * max_lines;
            int32 particles_size = (int32) particles.get_size();
            int32 nchunk = particles_size / max_lines;
            if (nchunk * max_lines != particles_size) nchunk++;

            uint index = 0;

            output.put_int32(nchunk);
            for (int32 i = 0; i < nchunk - 1; i++)
            {
                output.put_int32(max_n);
                for (int32 j = 0; j < max_lines; j++)
                {
                    for (int32 k = 0; k < size_one; k++)
                        output.put_double(props[k].get_val(index));
                    index++;
                }
            }

            int32 last_size = particles_size - (nchunk - 1) * max_lines;
            int32 last_n = size_one * last_size;
            output.put_int32(last_n);
            for (int32 j = 0; j < last_size; j++)
            {
                for (int32 k = 0; k < size_one; k++)
                    output.put_double(props[k].get_val(index));
                index++;
            }
        }

        private Float64PerParticleProperty[] get_float64_perparticle_properties(Particles particles, unowned string[] properties) throws ActionError
        {
            Float64PerParticleProperty[] props = new Float64PerParticleProperty[properties.length];
            if (particles != null)
            {
                for (uint i = 0; i < props.length; i++)
                {
                    if (!particles.has_prop(properties[i]))
                        throw new ActionError.LOGIC_ERROR(@"Particles does not contain property \"$(properties[i])\"");
                    var precast = particles.get_prop(properties[i]);
                    if (!(precast is ConvertableToString))
                        throw new ActionError.LOGIC_ERROR(@"Element \"$(properties[i])\" is not instance of ConvertableToString");
                    props[i] = ((ConvertableToFloat64) precast).convert_to_float64();
                }
            }
            return props;
        }

        public override void perform(DataCollection data) throws ActionError
        {
            WriterParams params = (WriterParams) this.get_params();
            string[] properties = params.get_properties();

            DataCollectionHelper datahelper = new DataCollectionHelper(data);

            Particles? particles = datahelper.load_dataobject<Particles>(params.get_particles_id());
            if (particles == null)
                throw new ActionError.LOGIC_ERROR(@"Cannot load particles with id \"$(params.get_particles_id())\"");

            ParallelepipedBox? box = datahelper.load_dataobject<ParallelepipedBox>(params.get_box_id());
            if (box == null)
                throw new ActionError.LOGIC_ERROR(@"Cannot load box with id \"$(params.get_box_id())\"");

            double? time = datahelper.load_dataobject<Float64>(params.get_time_id())?.get_val();

            int64? timestep = datahelper.load_dataobject<Int64>(params.get_timestep_id())?.get_val();
            if (timestep == null)
                throw new ActionError.LOGIC_ERROR(@"Cannot load timestep with id \"$(params.get_timestep_id())\"");

            string? units = datahelper.load_dataobject<String>(params.get_units_id())?.get_val();

            Float64PerParticleProperty[] props = this.get_float64_perparticle_properties(particles, properties);
                        
            OutputHelper output = new OutputHelper(params.get_filepath());

            this.put_timestep(output, timestep);
            this.put_n_atoms(output, (int64) particles.get_size());
            this.put_box(output, box);
            this.put_size_one(output, (int32) properties.length);
            this.put_units(output, units);
            this.put_time(output, time);
            this.put_columns(output, properties);
            this.put_particles(output, particles, props);
        }
    }
}
