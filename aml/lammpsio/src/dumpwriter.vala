using AmlCore;
using AmlBasicTypes;
using AmlBox;
using AmlParticles;
using AmlMath;

namespace AmlLammpsIo
{
    public class DumpWriter : AmlCore.Action
    {
        protected override string get_params_error_message(ActionParams params)
        {
            if (!(params is WriterParams))
                return "Params shoud be instance of AmlLammpsIo.WriterParams";

            WriterParams ps = (WriterParams) params;

            if (ps.get_particles_id() != Presets.EMPTY_ID && !DataCollection.is_valid_id(ps.get_particles_id()))
                return @"particles_id \"$(ps.get_particles_id())\" is not a valid id";
            if (ps.get_box_id() != Presets.EMPTY_ID && !DataCollection.is_valid_id(ps.get_box_id()))
                return @"box_id \"$(ps.get_box_id())\" is not a valid id";
            if (ps.get_timestep_id() != Presets.EMPTY_ID && !DataCollection.is_valid_id(ps.get_timestep_id()))
                return @"timestep_id \"$(ps.get_timestep_id())\" is not a valid id";
            if (ps.get_time_id() != Presets.EMPTY_ID && !DataCollection.is_valid_id(ps.get_time_id()))
                return @"time_id \"$(ps.get_time_id())\" is not a valid id";
            if (ps.get_units_id() != Presets.EMPTY_ID && !DataCollection.is_valid_id(ps.get_units_id()))
                return @"units_id \"$(ps.get_units_id())\" is not a valid id";

            return "";
        }

        private DataObject? load_dataobject(string id, Type type, DataCollection data) throws ActionError
        {
            if (id == Presets.EMPTY_ID) return null;

            if (!data.has_element(id))
                throw new ActionError.LOGIC_ERROR(@"Data does not contain element \"$id\"");

            DataObject result = data.get_element(id);

            if (!result.get_type().is_a(type))
                throw new ActionError.LOGIC_ERROR(@"Element \"$id\" is not instance of $(type.name())");

            return result;
        }

        private void put_time(OutputHelper output, double time) throws ActionError
        {
            output.put_string(@"ITEM: TIME\n$time\n");
        }

        private void put_units(OutputHelper output, string units) throws ActionError
        {
            output.put_string(@"ITEM: UNITS\n$units\n");
        }

        private void put_timestep(OutputHelper output, int64 timestep) throws ActionError
        {
            output.put_string(@"ITEM: TIMESTEP\n$timestep\n");
        }

        private void put_n_atoms(OutputHelper output, uint n_atoms) throws ActionError
        {
            output.put_string(@"ITEM: NUMBER OF ATOMS\n$(n_atoms)\n");
        }

        private void put_box(OutputHelper output, ParallelepipedBox box) throws ActionError
        {
            var edge = box.get_edge();
            var origin = box.get_origin();
            var boundaries = box.get_boundaries();

            output.put_string("ITEM: BOX BOUNDS ");
            if (!edge.is_diagonal())
                output.put_string("abc origin ");
            for (uint8 i = 0; i < 3; i++)
                output.put_string(boundaries[i] ? "pp " : "ff ");
            output.put_string("\n");
            if (edge.is_diagonal())
            {
                for (uint8 i = 0; i < 3; i++)
                    output.put_string(@"$(origin.get_val(i)) $(origin.get_val(i) + edge.get_val(i, i))\n");
            } else
            {
                for (uint8 i = 0; i < 3; i++)
                {
                    for (uint8 j = 0; j < 3; j++)
                        output.put_string(@"$(edge.get_val(i, j)) ");
                    output.put_string(@"$(origin.get_val(i))\n");
                }
            }
        }

        private StringPerParticleProperty[] get_string_perparticle_properties(Particles particles, unowned string[] properties) throws ActionError
        {
            StringPerParticleProperty[] props = new StringPerParticleProperty[properties.length];
            if (particles != null)
            {
                for (uint i = 0; i < props.length; i++)
                {
                    if (!particles.has_prop(properties[i]))
                        throw new ActionError.LOGIC_ERROR(@"Particles does not contain property \"$(properties[i])\"");
                    var precast = particles.get_prop(properties[i]);
                    if (!(precast is ConvertableToString))
                        throw new ActionError.LOGIC_ERROR(@"Element \"$(properties[i])\" is not instance of ConvertableToString");
                    props[i] = ((ConvertableToString) precast).convert_to_string();
                }
            }
            return props;
        }

        private void put_particles(OutputHelper output, Particles particles, unowned StringPerParticleProperty[] props, unowned string[] properties) throws ActionError
        {
            output.put_string("ITEM: ATOMS ");
            for (uint i = 0; i < props.length; i++)
                output.put_string(@"$(properties[i]) ");
            output.put_string("\n");

            for (uint i = 0; i < particles.get_size(); i++)
            {
                for (uint j = 0; j < props.length; j++)
                    output.put_string(@"$(props[j].get_val(i)) ");
                output.put_string("\n");
            }
        }

        public override void perform(DataCollection data) throws ActionError
        {
            WriterParams params = (WriterParams) this.get_params();
            string[] properties = params.get_properties();

            Particles? particles = (Particles?) this.load_dataobject(params.get_particles_id(), typeof(Particles), data);
            ParallelepipedBox? box = (ParallelepipedBox?) this.load_dataobject(params.get_box_id(), typeof(ParallelepipedBox), data);
            double? time = ((Float64?) this.load_dataobject(params.get_time_id(), typeof(Float64), data))?.get_val();
            int64? timestep = ((Int64?) this.load_dataobject(params.get_timestep_id(), typeof(Int64), data))?.get_val();
            string? units = ((String?) this.load_dataobject(params.get_units_id(), typeof(String), data))?.get_val();

            StringPerParticleProperty[]? props = null;
            if (particles != null) props = this.get_string_perparticle_properties(particles, properties);
                        
            OutputHelper output = new OutputHelper(params.get_filepath());

            if (time != null) this.put_time(output, time);
            if (units != null) this.put_units(output, units);
            if (timestep != null) this.put_timestep(output, timestep);
            if (particles != null) this.put_n_atoms(output, particles.get_size());
            if (box != null) this.put_box(output, box);


            if (particles != null) this.put_particles(output, particles, props, properties);
        }
    }
}
