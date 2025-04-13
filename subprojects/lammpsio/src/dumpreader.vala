using AmlCore;
using AmlBasicTypes;
using AmlBox;
using AmlParticles;
using AmlMath;

namespace AmlLammpsIo
{
    public class DumpReader : AmlCore.Action
    {
        protected override string get_params_error_message(ActionParams params)
        {
            if (!(params is ReaderParams))
                return "Params shoud be instance of AmlLammpsIo.ReaderParams";

            ReaderParams ps = (ReaderParams) params;

            var file = File.new_for_path(ps.get_filepath());
            if(!file.query_exists())
                return @"Path \"$(ps.get_filepath())\" does not exist";

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

            HashTable<string, Type> props = ps.get_properties();
            foreach (unowned var key in props.get_keys())
            {
                unowned Type t = props.get(key);
                if (!t.is_a(typeof(PerParticleProperty)))
                    return @"\"$key\" is not instance of AmlParticle.PerParticleProperty";
                if (t.is_abstract())
                    return @"\"$key\" is abstract";
            }

            return "";
        }

        private void read_units(InputHelper input, ref string? units) throws ActionError
        {
            if (units != null)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): units are already set");

            units = input.read_line();
            
            if (units == null)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): unexpected EOF");
        }

        private void read_timestep(InputHelper input, ref int64? timestep) throws ActionError
        {
            if (timestep != null)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): timestep is already set");

            if (input.read_line() == null)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): unexpected EOF");

            if (!int64.try_parse(input.line, out timestep))
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): cannot parse timestep");
        }

        private void read_time(InputHelper input, ref double? time) throws ActionError
        {
            if (time != null)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): time is already set");

            if (input.read_line() == null)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): unexpected EOF");

            if (!double.try_parse(input.line, out time))
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): cannot parse time");
        }

        private void read_box_triclinic(InputHelper input, ref Box? box) throws ActionError
        {
            if (box != null)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): box is already set");

            var temp_split = input.line.split_set(" \t");
            if (temp_split.length != 12)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid number of boundary conditions");

            temp_split = temp_split[9:];

            var bx = new bool[3];
            for (uint8 i = 0; i < 3; i++)
                bx[i] = temp_split[i] == "pp";

            var px = new double[3,3];
            for (uint8 i = 0; i < 3; i++)
            {
                if (input.read_line() == null)
                    throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): unexpected EOF");
                temp_split = input.line.split_set(" \t");
                if (temp_split.length != 4)
                    throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid number of boundary parameters");
                for (uint8 j = 0; j < 3; j++)
                    if (!double.try_parse(temp_split[j], out px[i,j]))
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): cannot parse boundaries");
            }
            px[0,0] -= double.min(double.min(double.min(px[0,2], px[1,2]), px[0,2] + px[1,2]), 0.0);
            px[1,0] -= double.max(double.max(double.max(px[0,2], px[0,1]), px[0,2] + px[1,2]), 0.0);
            px[0,1] -= double.min(px[2,2], 0.0);
            px[1,1] -= double.max(px[2,2], 0.0);

            var edge = Matrix3();

            edge.set_element(0, 0, px[1,0] - px[0,0]);
            edge.set_element(1, 0, px[0,2]);
            edge.set_element(1, 1, px[1,1] - px[0,1]);
            edge.set_element(2, 0, px[1,2]);
            edge.set_element(2, 1, px[2,2]);
            edge.set_element(2, 2, px[1,2] - px[0,2]);

            var origin = Vector3();

            for (uint8 i = 0; i < 3; i++)
                origin.set_element(i, px[0,i]);

            try
            {
                box = new ParallelepipedBox.create(edge, origin, bx);
            } catch (ParallelepipedBoxError e)
            {
                throw new ActionError.LOGIC_ERROR("Invalid simulation box data");
            }
        }

        private void read_box_abc_origin(InputHelper input, ref Box? box) throws ActionError
        {
            if (box != null)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): box is already set");
            
            var temp_split = input.line.split_set(" \t");
            if (temp_split.length != 8)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid number of boundary conditions");
            temp_split = temp_split[5:];

            var bx = new bool[3];
            for (uint8 i = 0; i < 3; i++)
                bx[i] = temp_split[i] == "pp";

            var px = new double[3,4];
            for (uint8 i = 0; i < 3; i++)
            {
                if (input.read_line() == null)
                    throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): unexpected EOF");
                temp_split = input.line.split_set(" \t");
                if (temp_split.length != 4)
                    throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid number of boundary parameters");
                for (uint8 j = 0; j < 4; j++)
                    if (!double.try_parse(temp_split[j], out px[i,j]))
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): cannot parse boundaries");
            }

            var origin = Vector3();
            var edge = Matrix3();
            for (uint8 i = 0; i < 3; i++)
            {
                origin.set_element(i, px[i,3]);
                for (uint8 j = 0; j < 3; j++)
                    edge.set_element(i, j, px[i,j]);
            }

            try
            {
                box = new ParallelepipedBox.create(edge, origin, bx);
            } catch (ParallelepipedBoxError e)
            {
                throw new ActionError.LOGIC_ERROR("Invalid simulation box data");
            }
        }

        private void read_box(InputHelper input, ref Box? box) throws ActionError
        {
            if (box != null)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): box is already set");

            var temp_split = input.line.split_set(" \t");
            if (temp_split.length != 6)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid number of boundary conditions");
            temp_split = temp_split[3:];

            var bx = new bool[3];

            for (uint8 i = 0; i < 3; i++)
                bx[i] = temp_split[i] == "pp";

            var px = new double[3,2];
            for (uint8 i = 0; i < 3; i++)
            {
                if (input.read_line() == null)
                    throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): unexpected EOF");

                temp_split = input.line.split_set(" \t");
                if (temp_split.length != 2)
                    throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid bounds number");
                for (uint8 j = 0; j < 2; j++)
                    if (!double.try_parse(temp_split[j], out px[i,j]))
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): cannot parse boundaries");
            }

            var edge = Matrix3();
            var origin = Vector3();
            for (uint8 i = 0; i < 3; i++)
            {
                edge.set_element(i, i, px[i,1] - px[i,0]);
                origin.set_element(i, px[i,0]);
            }

            try
            {
                box = new ParallelepipedBox.create(edge, origin, bx);
            } catch (ParallelepipedBoxError e)
            {
                throw new ActionError.LOGIC_ERROR("Invalid simulation box data");
            }
        }

        private void read_particles_n(InputHelper input, ref uint? particles_n) throws ActionError
        {
            if (particles_n != null)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): number of particles is already set");

            if (input.read_line() == null)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): unexpected EOF");

            if (!uint.try_parse(input.line, out particles_n))
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): cannot parse number of particles");
        }

        private void read_particles(InputHelper input, uint? particles_n, unowned HashTable<string, Type> properties, ref Particles? particles) throws ActionError
        {
            if (particles != null)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): particles are already set");
            if (particles_n == null)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): number of particles is not set");
            particles = new Particles.sized(particles_n);

            var temp_split = input.line.split_set(" \t");
            if (temp_split.length < 3)
                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): no per-particle property ids");

            var keys = temp_split[2:];
            var props = new StringPerParticleProperty?[keys.length];
            for (uint i = 0; i < keys.length; i++)
            {
                props[i] = (keys[i] in properties) ? new StringPerParticleProperty() : null;
                for (uint j = i + 1; j < keys.length; j++)
                    if (keys[i] == keys[j])
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): repeating property %s");
                props[i]?.set_size(particles.get_size());
            }

            for (uint i = 0; i < particles.get_size(); i++)
            {
                if (input.read_line() == null) throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): unexpected EOF");
                temp_split = input.line.split_set(" \t");
                if (temp_split.length != keys.length)
                    throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid property number");
                for (uint j = 0; j < keys.length; j++)
                    props[j]?.set_val(i, temp_split[j]);
            }

            for (uint i = 0; i < keys.length; i++)
            {
                if (props[i] != null)
                {
                    var new_prop_type = properties.get(keys[i]);
                    var new_obj = (PerParticleProperty) Object.new(new_prop_type);
                    new_obj.replace_with(props[i]);
                    particles.set_prop(keys[i], new_obj);
                }
            }
        }

        public override void perform(DataCollection data) throws ActionError
        {
            ReaderParams params = (ReaderParams) this.get_params();

            string filepath = params.get_filepath();

            string particles_id = params.get_particles_id();
            string box_id = params.get_box_id();
            string time_id = params.get_time_id();
            string timestep_id = params.get_timestep_id();
            string units_id = params.get_units_id();

            var properties = params.get_properties();

            bool load_particles = particles_id != DataCollection.EMPTY_ID;
            bool load_box = box_id != DataCollection.EMPTY_ID;
            bool load_time = time_id != DataCollection.EMPTY_ID;
            bool load_timestep  = timestep_id != DataCollection.EMPTY_ID;
            bool load_units  = units_id != DataCollection.EMPTY_ID;

            var input = new InputHelper(filepath);

            Box? box = null;
            Particles? particles = null;
            bool ok = true;
            int64? timestep = null;
            double? time = null;
            string? units = null;
            uint? particles_n = null;

            // read
            while (input.read_line() != null)
            {
                ok = true;
                if (load_units && input.line == "ITEM: UNITS")
                    this.read_units(input, ref units);
                else if (load_timestep && input.line == "ITEM: TIMESTEP")
                    this.read_timestep(input, ref timestep);
                else if (load_time && input.line == "ITEM: TIME")
                    this.read_time(input, ref time);
                else if (load_box && input.line.length > 34 && input.line[:34] == "ITEM: BOX BOUNDS xy xz yz xx yy zz")
                    this.read_box_triclinic(input, ref box);
                else if (load_box && input.line.length > 27 && input.line[:27] == "ITEM: BOX BOUNDS abc origin")
                    this.read_box_abc_origin(input, ref box);
                else if (load_box && input.line.length > 15 && input.line[:16] == "ITEM: BOX BOUNDS")
                    this.read_box(input, ref box);
                else if (load_particles && input.line == "ITEM: NUMBER OF ATOMS")
                    this.read_particles_n(input, ref particles_n);
                else if (load_particles && input.line.length > 10 && input.line[:11] == "ITEM: ATOMS")
                    this.read_particles(input, particles_n, properties, ref particles);
                else if (input.line.length > 4 && input.line[:5] == "ITEM:")
                {
                    // skip unknown sections
                    while (input.read_line() != null && (input.line.length < 5 || input.line[:5] != "ITEM:"));
                    input.prev_line();
                } else
                {
                    throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): parse error");
                }
            }

            if (load_timestep)
            {
                if (timestep == null)
                    throw new ActionError.LOGIC_ERROR(@"File \"$filepath\" does not have TIMESTEP section");
                var obj = new Int64.create((!) timestep);
                try
                {
                    data.set_element(timestep_id, obj);
                } catch (DataCollectionError.ID_ERROR e)
                {
                    throw new ActionError.LOGIC_ERROR(@"Cannot set element \"$timestep_id\"");
                }
            }
            if (load_time)
            {
                if (time == null)
                    throw new ActionError.LOGIC_ERROR(@"File \"$filepath\" does not have TIME section");
                var obj = new Float64.create((!) time);
                try
                {
                    data.set_element(time_id, obj);
                } catch (DataCollectionError.ID_ERROR e)
                {
                    throw new ActionError.LOGIC_ERROR(@"Cannot set element \"$time_id\"");
                }
            }
            if (load_box)
            {
                if (box == null)
                    throw new ActionError.LOGIC_ERROR(@"File \"$filepath\" does not have BOX section");
                try
                {
                    data.set_element(box_id, box);
                } catch (DataCollectionError.ID_ERROR e)
                {
                    throw new ActionError.LOGIC_ERROR(@"Cannot set element \"$box_id\"");
                }
            }
            if (load_particles)
            {
                if (particles == null)
                    throw new ActionError.LOGIC_ERROR(@"File \"$filepath\" does not have ATOMS section");
                try
                {
                    data.set_element(particles_id, particles);
                } catch (DataCollectionError.ID_ERROR e)
                {
                    throw new ActionError.LOGIC_ERROR(@"Cannot set element \"$particles_id\"");
                }
            }
            if (load_units)
            {
                if (units == null)
                    throw new ActionError.LOGIC_ERROR(@"File \"$filepath\" does not have UNITS section");
                var obj = new String.create((!) units);
                try
                {
                    data.set_element(units_id, obj);
                } catch (DataCollectionError.ID_ERROR e)
                {
                    throw new ActionError.LOGIC_ERROR(@"Cannot set element \"$units_id\"");
                }
            }
        }
    }
}
