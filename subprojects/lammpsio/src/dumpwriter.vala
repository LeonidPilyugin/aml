using AmlCore;
using AmlTypes;
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

            if (ps.get_particles_id() != DataCollection.EMPTY_ID && !DataCollection.is_valid_id(ps.get_particles_id()))
                return @"particles_id \"$(ps.get_particles_id())\" is not a valid id";
            if (ps.get_box_id() != DataCollection.EMPTY_ID && !DataCollection.is_valid_id(ps.get_box_id()))
                return @"box_id \"$(ps.get_box_id())\" is not a valid id";
            if (ps.get_timestep_id() != DataCollection.EMPTY_ID && !DataCollection.is_valid_id(ps.get_timestep_id()))
                return @"timestep_id \"$(ps.get_timestep_id())\" is not a valid id";
            if (ps.get_time_id() != DataCollection.EMPTY_ID && !DataCollection.is_valid_id(ps.get_time_id()))
                return @"time_id \"$(ps.get_time_id())\" is not a valid id";
            if (ps.get_units_id() != DataCollection.EMPTY_ID && !DataCollection.is_valid_id(ps.get_units_id()))
                return @"units_id \"$(ps.get_units_id())\" is not a valid id";

            return "";
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

        private void put_n_atoms(OutputHelper output, size_t n_atoms) throws ActionError
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
            for (uint i = 0; i < 3; i++)
                output.put_string(boundaries[i] ? "pp " : "ff ");
            output.put_string("\n");
            if (edge.is_diagonal())
            {
                for (uint i = 0; i < 3; i++)
                    output.put_string(@"$(origin.get_element(i)) $(origin.get_element(i) + edge.get_element(i, i))\n");
            } else
            {
                for (uint i = 0; i < 3; i++)
                {
                    for (uint j = 0; j < 3; j++)
                        output.put_string(@"$(edge.get_element(i, j)) ");
                    output.put_string(@"$(origin.get_element(i))\n");
                }
            }
        }

        private void put_particles(OutputHelper output, Particles particles, string[] properties) throws ActionError
        {
            output.put_string("ITEM: ATOMS ");
            for (uint i = 0; i < properties.length; i++)
                output.put_string(@"$(properties[i]) ");
            output.put_string("\n");

            var temp = new StringProperty.create();
            var props = new ArrayProperty[properties.length];
            var ps = new Property[properties.length];
            for (uint i = 0; i < properties.length; i++)
            {
                props[i] = particles.get_prop(properties[i]);
                ps[i] = props[i].get_type_object().create_property();
            }
            
            for (size_t i = 0; i < particles.get_size(); i++)
            {
                for (uint j = 0; j < props.length; j++)
                {
                    props[j].get_property(i, ps[j]);
                    temp.convert(ps[j]);
                    output.put_string(temp.get_val());
                    output.put_string(" ");
                }
                output.put_string("\n");
            }
        }

        private void check_particles(Particles particles, string[] properties) throws ActionError
        {
            for (uint i = 0; i < properties.length; i++)
            {
                if (!particles.has_prop(properties[i]))
                    throw new ActionError.RUNTIME_ERROR(@"Particles do not contain \"$(properties[i])\" property");
                var prop = particles.get_prop(properties[i]);
                if (!StringType.instance().can_convert(prop.get_type_object()))
                    throw new ActionError.RUNTIME_ERROR(@"Cannot convert \"$(properties[i])\" property to string");
            }
        }

        public override void perform(DataCollection data) throws ActionError
        {
            WriterParams params = (WriterParams) this.get_params();
            string[] properties = params.get_properties();

            Particles? particles  = null;
            ParallelepipedBox? box  = null;
            double? time = null;
            int64? timestep  = null;
            string? units = null;

            try {
                particles = data.get_dataobject<Particles>(params.get_particles_id());
                box = data.get_dataobject<ParallelepipedBox>(params.get_box_id());
                time = data.get_dataobject<Float64Property>(params.get_time_id())?.get_val();
                timestep = data.get_dataobject<Int64Property>(params.get_timestep_id())?.get_val();
                units = data.get_dataobject<StringProperty>(params.get_units_id())?.get_val();
            } catch (DataCollectionError.ELEMENT_ERROR e)
            {
                throw new ActionError.RUNTIME_ERROR(e.message);
            }

            if (particles != null) this.check_particles(particles, properties);
                        
            OutputHelper output = new OutputHelper(params.get_filepath());

            if (time != null) this.put_time(output, time);
            if (units != null) this.put_units(output, units);
            if (timestep != null) this.put_timestep(output, timestep);
            if (particles != null) this.put_n_atoms(output, particles.get_size());
            if (box != null) this.put_box(output, box);

            if (particles != null) this.put_particles(output, particles, properties);
        }
    }
}
