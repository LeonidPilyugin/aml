using AmlCore;
using AmlBasicTypes;
using AmlBox;
using AmlParticles;
using AmlMath;

namespace AmlLammpsIo
{
    public class DumpWriterParams : ActionParams
    {
        private string filepath = Presets.EMPTY_ID;
        private string particles_id = Presets.EMPTY_ID;
        private string box_id = Presets.EMPTY_ID;
        private string timestep_id = Presets.EMPTY_ID;
        private string time_id = Presets.EMPTY_ID;
        private string units_id = Presets.EMPTY_ID;
        private string[] properties = {};

        public string get_filepath()
        {
            return this.filepath;
        }

        public void set_filepath(string filepath)
        {
            this.filepath = filepath;
        }

        public string get_particles_id()
        {
            return this.particles_id;
        }

        public void set_particles_id(string particles_id)
        {
            this.particles_id = particles_id;
        }

        public string get_box_id()
        {
            return this.box_id;
        }

        public void set_box_id(string box_id)
        {
            this.box_id = box_id;
        }

        public string get_timestep_id()
        {
            return this.timestep_id;
        }

        public void set_timestep_id(string timestep_id)
        {
            this.timestep_id = timestep_id;
        }

        public string get_time_id()
        {
            return this.time_id;
        }

        public void set_time_id(string time_id)
        {
            this.time_id = time_id;
        }

        public string get_units_id()
        {
            return this.units_id;
        }

        public void set_units_id(string units_id)
        {
            this.units_id = units_id;
        }

        public unowned string[] get_properties()
        {
            return this.properties;
        }

        public void set_properties(owned string[] properties)
        {
            this.properties = (owned) properties;
        }

        public override ActionParams copy()
        {
            var res = new DumpWriterParams();

            res.filepath = this.filepath;
            res.particles_id = this.particles_id;
            res.box_id = this.box_id;
            res.timestep_id = this.timestep_id;
            res.time_id = this.time_id;
            res.units_id = this.units_id;
            res.properties = this.properties;

            return res;
        }
    }
 
    public class DumpWriter : AmlCore.Action
    {
        protected override string get_params_error_message(ActionParams params)
        {
            if (!(params is DumpWriterParams))
                return "Params shoud be instance of AmlLammpsIo.DumpWriterParams";

            DumpWriterParams ps = (DumpWriterParams) params;

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

        public override void perform(DataCollection data) throws ActionError
        {
            DumpWriterParams params = (DumpWriterParams) this.get_params();

            string filepath = params.get_filepath();
            string particles_id = params.get_particles_id();
            string box_id = params.get_box_id();
            string timestep_id = params.get_timestep_id();
            string time_id = params.get_time_id();
            string units_id = params.get_units_id();
            string[] properties = params.get_properties();

            DataObject precast;
            Particles? particles = null;
            if (particles_id != Presets.EMPTY_ID)
            {
                if (!data.has_element(particles_id))
                    throw new ActionError.LOGIC_ERROR(@"Data does not contain element \"$particles_id\"");
                precast = data.get_element(particles_id);
                if (!(precast is Particles))
                    throw new ActionError.LOGIC_ERROR(@"Element \"$particles_id\" is not instance of Particles");
                particles = (Particles) precast;
            }

            ParallelepipedBox? box = null;
            if (box_id != Presets.EMPTY_ID)
            {
                if (!data.has_element(box_id))
                    throw new ActionError.LOGIC_ERROR(@"Data does not contain element \"$box_id\"");
                precast = data.get_element(box_id);
                if (!(precast is ParallelepipedBox))
                    throw new ActionError.LOGIC_ERROR(@"Element \"$box_id\" is not instance of ParallelepipedBox");
                box = (ParallelepipedBox) precast;
            }

            double? time = null;
            if (time_id != Presets.EMPTY_ID)
            {
                if (!data.has_element(time_id))
                    throw new ActionError.LOGIC_ERROR(@"Data does not contain element \"$time_id\"");
                precast = data.get_element(time_id);
                if (!(precast is Float64))
                    throw new ActionError.LOGIC_ERROR(@"Element \"$time_id\" is not instance of Float64 basic type");
                time = ((Float64) precast).get_val();
            }

            int64? timestep = null;
            if (timestep_id != Presets.EMPTY_ID)
            {
                if (!data.has_element(timestep_id))
                    throw new ActionError.LOGIC_ERROR(@"Data does not contain element \"$timestep_id\"");
                precast = data.get_element(timestep_id);
                if (!(precast is Int64))
                    throw new ActionError.LOGIC_ERROR(@"Element \"$timestep_id\" is not instance of Int64 basic type");
                time = ((Int64) precast).get_val();
            }

            string? units = null;
            if (units_id != Presets.EMPTY_ID)
            {
                if (!data.has_element(units_id))
                    throw new ActionError.LOGIC_ERROR(@"Data does not contain element \"$units_id\"");
                precast = data.get_element(units_id);
                if (!(precast is String))
                    throw new ActionError.LOGIC_ERROR(@"Element \"$units_id\" is not instance of String basic type");
                units = ((String) precast).get_val();
            }

            StringPerParticleProperty[] props = new StringPerParticleProperty[properties.length];
            if (particles != null)
            {
                for (uint i = 0; i < props.length; i++)
                {
                    if (!particles.has_prop(properties[i]))
                        throw new ActionError.LOGIC_ERROR(@"Particles does not contain property \"$(properties[i])\"");
                    var precast_ppp = particles.get_prop(properties[i]);
                    if (!(precast_ppp is ConvertableToString))
                        throw new ActionError.LOGIC_ERROR(@"Element \"$(properties[i])\" is not instance of ConvertableToString");
                    props[i] = ((ConvertableToString) precast_ppp).convert_to_string();
                }
            }
            
            DataOutputStream output;
            try
            {
                output = new DataOutputStream(File.new_for_path(filepath).replace_readwrite(null, false, FileCreateFlags.PRIVATE).output_stream);
            } catch(Error e)
            {
                throw new ActionError.LOGIC_ERROR(@"Cannot open file \"$filepath\" for write: $(e.message)");
            }

            if (time != null)
                output.put_string(@"ITEM: TIME\n$time\n");
            if (units != null)
                output.put_string(@"ITEM: UNITS\n$units\n");
            if (timestep != null)
                output.put_string(@"ITEM: TIMESTEP\n$timestep\n");
            if (particles != null)
                output.put_string(@"ITEM: NUMBER OF ATOMS\n$(particles.get_size())\n");
            if (box != null)
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
            if (particles != null)
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
        }
    }
}
