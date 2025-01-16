using AmlCore;
using AmlBasicTypes;
using AmlBox;
using AmlParticles;
using AmlMath;

namespace AmlLammpsIo
{
    public class DumpReaderParams : ActionParams
    {
        private string filepath = Presets.EMPTY_ID;
        private string particles_id = Presets.EMPTY_ID;
        private string box_id = Presets.EMPTY_ID;
        private string timestep_id = Presets.EMPTY_ID;
        private string time_id = Presets.EMPTY_ID;
        private HashTable<string, Type> properties = new HashTable<string, Type>(str_hash, str_equal);

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

        public unowned HashTable<string, Type> get_properties()
        {
            return this.properties;
        }

        public void set_properties(owned HashTable<string, Type> properties)
        {
            this.properties = (owned) properties;
        }

        public override ActionParams copy()
        {
            var res = new DumpReaderParams();

            res.filepath = this.filepath;
            res.particles_id = this.particles_id;
            res.box_id = this.box_id;
            res.timestep_id = this.timestep_id;
            res.time_id = this.time_id;
            res.properties = new HashTable<string, Type>(str_hash, str_equal);
            foreach (var key in this.properties.get_keys())
                res.properties.set(key, this.properties.get(key));

            return res;
        }
    }


    public class DumpReader : AmlCore.Action
    {
        protected override string get_params_error_message(ActionParams params)
        {
            if (!(params is DumpReaderParams))
                return "Params shoud be instance of AmlLammpsIo.DumpReaderParams";

            DumpReaderParams ps = (DumpReaderParams) params;

            var file = File.new_for_path(ps.get_filepath());
            if(!file.query_exists())
                return @"Path \"$(ps.get_filepath())\" does not exist";

            if (ps.get_particles_id() != Presets.EMPTY_ID && !DataCollection.is_valid_id(ps.get_particles_id()))
                return @"particles_id \"$(ps.get_particles_id())\" is not a valid id";
            if (ps.get_box_id() != Presets.EMPTY_ID && !DataCollection.is_valid_id(ps.get_box_id()))
                return @"box_id \"$(ps.get_box_id())\" is not a valid id";
            if (ps.get_timestep_id() != Presets.EMPTY_ID && !DataCollection.is_valid_id(ps.get_timestep_id()))
                return @"timestep_id \"$(ps.get_timestep_id())\" is not a valid id";
            if (ps.get_time_id() != Presets.EMPTY_ID && !DataCollection.is_valid_id(ps.get_time_id()))
                return @"time_id \"$(ps.get_time_id())\" is not a valid id";

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

        public override void perform(DataCollection data) throws ActionError
        {
            DumpReaderParams params = (DumpReaderParams) this.get_params();

            string filepath = params.get_filepath();

            string particles_id = params.get_particles_id();
            string box_id = params.get_box_id();
            string time_id = params.get_time_id();
            string timestep_id = params.get_timestep_id();

            var properties = params.get_properties();

            bool load_particles = particles_id != Presets.EMPTY_ID;
            bool load_box = box_id != Presets.EMPTY_ID;
            bool load_time = time_id != Presets.EMPTY_ID;
            bool load_timestep  = timestep_id != Presets.EMPTY_ID;

            var input_stream = new DataInputStream(File.new_for_path(filepath).read());
            var input = new InputHelper(input_stream);
            Box? box = null;
            Particles? particles = null;
            bool ok = true;
            int64? timestep = null;
            double? time = null;
            string[] temp_split;
            bool[] bx;
            double[,] px;

            // read
            while (input.read_line() != null)
            {
                ok = true;
                if (load_timestep && input.line == "ITEM: TIMESTEP")
                {
                    if (!load_timestep)
                    {
                        while (input.read_line() != null) if (input.line[:5] == "ITEM:") break;
                        input.prev_line();
                        continue;
                    }

                    if (timestep != null)
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): timestep is already set");

                    if (input.read_line() == null) break;

                    if (!int64.try_parse(input.line, out timestep))
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid timestep value");
                } else if (input.line == "ITEM: TIME")
                {
                    if (!load_time)
                    {
                        while (input.read_line() != null) if (input.line[:5] == "ITEM:") break;
                        input.prev_line();
                        continue;
                    }

                    if (time != null)
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): time is already set");

                    if (input.read_line() == null) break;

                    if (!double.try_parse(input.line, out time))
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid time value");
                } else if (input.line.length > 34 && input.line[:34] == "ITEM: BOX BOUNDS xy xz yz xx yy zz")
                {
                    if (!load_box)
                    {
                        while (input.read_line() != null) if (input.line[:5] == "ITEM:") break;
                        input.prev_line();
                        continue;
                    }

                    if (box != null)
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): box is already set");

                    temp_split = input.line.split_set(" \t");
                    if (temp_split.length != 12)
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid number of boundary conditions");

                    temp_split = temp_split[9:];

                    bx = new bool[3];
                    for (uint8 i = 0; i < 3; i++)
                        bx[i] = temp_split[i] == "pp";
                    px = new double[3,3];
                    for (uint8 i = 0; i < 3; i++)
                    {
                        if (input.read_line() == null) { ok = false; break; }
                        temp_split = input.line.split_set(" \t");
                        if (temp_split.length != 4)
                            throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid number of boundary parameters");
                        for (uint8 j = 0; j < 3; j++)
                            if (!double.try_parse(temp_split[j], out px[i,j]))
                                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): cannot parse boundaries");
                    } if (!ok) break;

                    px[0,0] -= double.min(double.min(double.min(px[0,2], px[1,2]), px[0,2] + px[1,2]), 0.0);
                    px[1,0] -= double.max(double.max(double.max(px[0,2], px[0,1]), px[0,2] + px[1,2]), 0.0);
                    px[0,1] -= double.min(px[2,2], 0.0);
                    px[1,1] -= double.max(px[2,2], 0.0);

                    var edge = new Matrix.sized(3, 3);

                    edge.set_val(0, 0, px[1,0] - px[0,0]);
                    edge.set_val(1, 0, px[0,2]);
                    edge.set_val(1, 1, px[1,1] - px[0,1]);
                    edge.set_val(2, 0, px[1,2]);
                    edge.set_val(2, 1, px[2,2]);
                    edge.set_val(2, 2, px[1,2] - px[0,2]);

                    var origin = new Vector.sized(3);

                    for (uint8 i = 0; i < 3; i++)
                        origin.set_val(i, px[0,i]);

                    try
                    {
                        box = new ParallelepipedBox.create(edge, origin, bx);
                    } catch (ParallelepipedBoxError e)
                    {
                        throw new ActionError.LOGIC_ERROR("Invalid simulation box data");
                    }
                } else if (input.line.length > 27 && input.line[:27] == "ITEM: BOX BOUNDS abc origin") {
                    if (!load_box)
                    {
                        while (input.read_line() != null) if (input.line[:5] == "ITEM:") break;
                        input.prev_line();
                        continue;
                    }

                    // parse box
                    if (box != null)
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): box is already set");

                    temp_split = input.line.split_set(" \t");
                    if (temp_split.length != 8)
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid number of boundary conditions");
                    temp_split = temp_split[5:];

                    bx = new bool[3];
                    for (uint8 i = 0; i < 3; i++)
                        bx[i] = temp_split[i] == "pp";

                    px = new double[3,4];
                    for (uint8 i = 0; i < 3; i++)
                    {
                        if (input.read_line() == null) { ok = false; break; }
                        temp_split = input.line.split_set(" \t");
                        if (temp_split.length != 4)
                            throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid number of boundary parameters");
                        for (uint8 j = 0; j < 4; j++)
                            if (!double.try_parse(temp_split[j], out px[i,j]))
                                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): cannot parse boundaries");
                    } if (!ok) break;

                    var origin = new Vector.sized(3);
                    var edge = new Matrix.sized(3, 3);
                    for (uint8 i = 0; i < 3; i++)
                    {
                        origin.set_val(i, px[i,3]);
                        for (uint8 j = 0; j < 3; j++)
                            edge.set_val(i, j, px[i,j]);
                    }

                    try
                    {
                        box = new ParallelepipedBox.create(edge, origin, bx);
                    } catch (ParallelepipedBoxError e)
                    {
                        throw new ActionError.LOGIC_ERROR("Invalid simulation box data");
                    }
                } else if (input.line.length > 15 && input.line[:16] == "ITEM: BOX BOUNDS") {
                    if (!load_box)
                    {
                        while (input.read_line() != null) if (input.line[:5] == "ITEM:") break;
                        input.prev_line();
                        continue;
                    }

                    // parse box
                    if (box != null)
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): box is already set");

                    temp_split = input.line.split_set(" \t");
                    if (temp_split.length != 6)
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid number of boundary conditions");
                    temp_split = temp_split[3:];

                    bx = new bool[3];

                    for (uint8 i = 0; i < 3; i++)
                        bx[i] = temp_split[i] == "pp";

                    px = new double[3,2];
                    for (uint8 i = 0; i < 3; i++)
                    {
                        if (input.read_line() == null) { ok = false; break; }
                        temp_split = input.line.split_set(" \t");
                        if (temp_split.length != 2)
                            throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid bounds number");
                        for (uint8 j = 0; j < 2; j++)
                            if (!double.try_parse(temp_split[j], out px[i,j]))
                                throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): cannot parse boundaries");
                    } if (!ok) break;

                    var edge = new Matrix.sized(3, 3);
                    var origin = new Vector.sized(3);
                    for (uint8 i = 0; i < 3; i++)
                    {
                        edge.set_val(i, i, px[i,1] - px[i,0]);
                        origin.set_val(i, px[i,0]);
                    }

                    try
                    {
                        box = new ParallelepipedBox.create(edge, origin, bx);
                    } catch (ParallelepipedBoxError e)
                    {
                        throw new ActionError.LOGIC_ERROR("Invalid simulation box data");
                    }
                } else if (input.line == "ITEM: NUMBER OF ATOMS")
                {
                    if (!load_particles)
                    {
                        while (input.read_line() != null) if (input.line[:5] == "ITEM:") break;
                        input.prev_line();
                        continue;
                    }

                    if (particles != null)
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): number of particles is already set");
                    if (input.read_line() == null) break;
                    uint temp_an;
                    if (!uint.try_parse(input.line, out temp_an))
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): cannot parse number of particles");
                    particles = new Particles.sized(temp_an);
                } else if (input.line.length > 10 && input.line[:11] == "ITEM: ATOMS")
                {
                    if (!load_particles)
                    {
                        while (input.read_line() != null) if (input.line[:5] == "ITEM:") break;
                        input.prev_line();
                        continue;
                    }

                    // parse particles and construct frame
                    if (particles == null)
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): number of particles is not set");
                    // get property names
                    temp_split = input.line.split_set(" \t");
                    if (temp_split.length < 3)
                        throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): no per-particle property ids");

                    string[] keys = temp_split[2:];
                    StringPerParticleProperty?[] props = new StringPerParticleProperty?[keys.length];

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
                        if (input.read_line() == null) { ok = false; break; }
                        temp_split = input.line.split_set(" \t");
                        if (temp_split.length != keys.length)
                            throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): invalid property number");
                        for (uint j = 0; j < keys.length; j++)
                            props[j]?.set_val(i, temp_split[j]);
                    } if (!ok) break;

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
                } else if (input.line.length > 4 && input.line[:5] == "ITEM:")
                {
                    // skip unknown sections
                    while (input.read_line() != null && (input.line.length < 5 || input.line[:5] != "ITEM:"));
                    input.prev_line();
                } else
                {
                    throw new ActionError.LOGIC_ERROR(@"Line $(input.line_n): parsing error");
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
        }
    }
}
