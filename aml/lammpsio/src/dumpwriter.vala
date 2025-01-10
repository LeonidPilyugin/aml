using AmlCore;
using AmlBasicTypes;
using AmlBox;
using AmlParticles;
using AmlMath;

namespace AmlLammpsIo
{
    public class DumpWriterParams : ActionParams
    {
        private string filepath = "";
        private string particles_id = "";
        private string box_id = "";
        private string timestep_id = "";
        private string time_id = "";
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

            if (ps.get_particles_id() != "" && !DataCollection.is_valid_id(ps.get_particles_id()))
                return @"particles_id \"$(ps.get_particles_id())\" is not a valid id";
            if (ps.get_box_id() != "" && !DataCollection.is_valid_id(ps.get_box_id()))
                return @"box_id \"$(ps.get_box_id())\" is not a valid id";
            if (ps.get_timestep_id() != "" && !DataCollection.is_valid_id(ps.get_timestep_id()))
                return @"timestep_id \"$(ps.get_timestep_id())\" is not a valid id";
            if (ps.get_time_id() != "" && !DataCollection.is_valid_id(ps.get_time_id()))
                return @"time_id \"$(ps.get_time_id())\" is not a valid id";

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
            string[] properties = params.get_properties();

            // TODO: exceptions
            // TODO: replace /* == "" */ with better code
            // TODO: type casting and checking
            Particles? particles = particles_id == "" ? null : (Particles) data.get_element(particles_id);
            ParallelepipedBox? box = box_id == "" ? null : (ParallelepipedBox) data.get_element(box_id);
            double? time = time_id == "" ? null : (double?) ((Float64) data.get_element(time_id)).get_val();
            int64? timestep = timestep_id == "" ? null : (int64?) ((Int64) data.get_element(timestep_id)).get_val();
            
            // TODO: path checking, exceptions
            var output = new DataOutputStream(File.new_for_path(filepath).replace_readwrite(null, false, FileCreateFlags.PRIVATE).output_stream);

            if (time != null)
                output.put_string(@"ITEM: TIME\n$time\n");
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
                StringPerParticleProperty[] props = new StringPerParticleProperty[properties.length];

                output.put_string("ITEM: ATOMS ");

                for (uint i = 0; i < props.length; i++)
                {
                    // TODO: exceptions
                    var temp = (ConvertableToString) particles.get_prop(properties[i]);
                    props[i] = temp.convert_to_string();
                    output.put_string(@"$(properties[i]) ");
                }
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
