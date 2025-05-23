using AmlCore;
using AmlTypes;
using AmlBox;
using AmlParticles;
using AmlMath;

namespace AmlLammpsIo
{
    public class BinaryDumpReader : AmlCore.Action
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

            var keys = ps.get_keys();
            var types = ps.get_types();

            if (keys.length != types.length)
                return "Sizes of keys and types are not same";

            for (uint i = 0; i < keys.length; i++)
                for (uint j = i + 1; j < keys.length; j++)
                    if (keys[i] == keys[j])
                        return @"Repeating property \"$(keys[i])\"";

            for (uint i = 0; i < types.length; i++)
                if (!types[i].can_convert(Float64Type.instance()))
                    return @"Cannot convert float64 to \"$(types[i].get_type().name())\" property";

            return "";
        }

        private void read_units(InputHelper input, ref string? units) throws ActionError
        {
            if (units != null)
                throw new ActionError.RUNTIME_ERROR(@"Units are already set");

            int32 len = input.read_int32();
            if (len > 0)
                units = input.read_string(len);
        }

        private void read_timestep(InputHelper input, ref int64? timestep) throws ActionError
        {
            if (timestep != null)
                throw new ActionError.RUNTIME_ERROR(@"Timestep is already set");

            timestep = input.read_int64();

            if (timestep >= 0)
                throw new ActionError.RUNTIME_ERROR(@"Old format is not supported");

            input.read_string((uint) (-(!)timestep));
            input.read_int32();
            input.read_int32();

            timestep = input.read_int64();
        }

        private void read_time(InputHelper input, ref double? time) throws ActionError
        {
            if (time != null)
                throw new ActionError.RUNTIME_ERROR(@"Time is already set");

            uint flag = input.read_uint8();
            if (flag != 0)
                time = input.read_double();
        }

        private void read_triclinic0(InputHelper input, bool[] bounds, ref Box? box) throws ActionError
        {
            double[,] px = new double[3,2];
            for (uint i = 0; i < 3; i++)
                for (uint j = 0; j < 2; j++)
                    px[i,j] = input.read_double();

            var origin = Vector3();
            var edge = Matrix3();

            for (uint i = 0; i < 3; i++)
            {
                edge.set_element(i, i, px[i, 1] - px[i, 0]);
                origin.set_element(i, px[i, 0]);
            }

            try
            {
                box = new ParallelepipedBox.create(edge, origin, bounds);
            } catch (ParallelepipedBoxError e)
            {
                throw new ActionError.RUNTIME_ERROR("Invalid simulation box data");
            }
        }

        private void read_triclinic1(InputHelper input, bool[] bounds, ref Box? box) throws ActionError
        {
            double[,] px = new double[3,3];
            for (uint i = 0; i < 3; i++)
                for (uint j = 0; j < 2; j++)
                    px[i, j] = input.read_double();
            for (uint i = 0; i < 3; i++)
                px[i, 2] = input.read_double();

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

            for (uint i = 0; i < 3; i++)
                origin.set_element(i, px[0,i]);

            try
            {
                box = new ParallelepipedBox.create(edge, origin, bounds);
            } catch (ParallelepipedBoxError e)
            {
                throw new ActionError.RUNTIME_ERROR("Invalid simulation box data");
            }
            
        }

        private void read_triclinic2(InputHelper input, bool[] bounds, ref Box? box) throws ActionError
        {
            double[,] px = new double[3,4];
            for (uint i = 0; i < 3; i++)
                for (uint j = 0; j < 3; j++)
                    px[i, j] = input.read_double();
            for (uint i = 0; i < 3; i++)
                px[i, 3] = input.read_double();


            var origin = Vector3();
            var edge = Matrix3();
            for (uint i = 0; i < 3; i++)
            {
                origin.set_element(i, px[i,3]);
                for (uint j = 0; j < 3; j++)
                    edge.set_element(i, j, px[i,j]);
            }

            try
            {
                box = new ParallelepipedBox.create(edge, origin, bounds);
            } catch (ParallelepipedBoxError e)
            {
                throw new ActionError.RUNTIME_ERROR("Invalid simulation box data");
            }
        }

        private void read_box(InputHelper input, ref Box? box) throws ActionError
        {
            if (box != null)
                throw new ActionError.RUNTIME_ERROR(@"Box is already set");

            int32 triclinic = input.read_int32();

            bool[] boundaries = new bool[3];
            for (uint i = 0; i < 3; i++)
            {
                boundaries[i] = 0 == input.read_int32();
                input.read_int32();
            }

            if (triclinic == 0) this.read_triclinic0(input, boundaries, ref box);
            else if (triclinic == 1) this.read_triclinic1(input, boundaries, ref box);
            else if (triclinic == 2) this.read_triclinic2(input, boundaries, ref box);
            else throw new ActionError.RUNTIME_ERROR(@"Unknown triclinic number: $triclinic");
        }

        private void read_particles_n(InputHelper input, ref size_t? particles_n) throws ActionError
        {
            if (particles_n != null)
                throw new ActionError.RUNTIME_ERROR(@"Number of particles is already set");

            var temp = input.read_int64();

            if ((ulong) temp > size_t.MAX)
                throw new ActionError.RUNTIME_ERROR(@"$temp is more than max particles limit $(size_t.MAX)");

            particles_n = (size_t) temp;
        }

        private void read_size_one(InputHelper input, ref uint? size_one) throws ActionError
        {
            if (size_one != null)
                throw new ActionError.RUNTIME_ERROR(@"size_one is already set");

            size_one = input.read_int32();
        }

        private void read_particles(InputHelper input, size_t? particles_n, string[] pkeys, AmlTypes.Type[] ptypes, ref Particles? particles, uint? size_one) throws ActionError
        {
            if (particles != null)
                throw new ActionError.RUNTIME_ERROR(@"Particles are already set");
            if (particles_n == null)
                throw new ActionError.RUNTIME_ERROR(@"Number of particles is not set");
            if (size_one == null)
                throw new ActionError.RUNTIME_ERROR(@"size_one is not set");

            particles = new Particles.sized(particles_n);

            uint len = input.read_int32();
            string[] keys = input.read_string(len).split_set(" \t");

            var temp_prop = new Float64Property.create();
            var props = new Property?[keys.length];
            var arrayprops = new ArrayProperty?[keys.length];

            if (pkeys.length > keys.length)
                for (uint i = 0; i < pkeys.length; i++)
                    if (!(pkeys[i] in keys))
                        throw new ActionError.RUNTIME_ERROR(@"Did not met property $(pkeys[i])");

            for (uint i = 0; i < keys.length; i++)
            {
                props[i] = null;
                arrayprops[i] = null;

                uint index;
                for (index = 0; index < pkeys.length; index++)
                {
                    if (pkeys[index] == keys[i])
                    {
                        props[i] = ptypes[i].create_property();
                        arrayprops[i] = ptypes[i].create_array_property();
                        break;
                    }
                }

                if (index == pkeys.length) continue;

                for (uint j = i + 1; j < keys.length; j++)
                    if (keys[i] == keys[j])
                        throw new ActionError.RUNTIME_ERROR(@"Line $(input.line_n): repeating property $(keys[i])");

                arrayprops[i].set_size(particles.get_size());
            }

            int32 nchunk = input.read_int32();
            size_t count = 0;
            for (uint32 i = 0; i < nchunk; i++)
            {
                int32 n = input.read_int32() / (int32) size_one;
                for (uint32 j = 0; j < n; j++)
                {
                    for (uint k = 0; k < size_one; k++)
                    {
                        temp_prop.set_val(input.read_double());
                        props[k].convert_unsafe(temp_prop);
                        arrayprops[k].set_property(count, props[k]);
                    }
                    count++;
                }
            }

            for (uint i = 0; i < keys.length; i++)
                if (arrayprops[i] != null)
                    particles.set_prop(keys[i], arrayprops[i]);
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

            var keys = params.get_keys();
            var types = params.get_types();

            bool load_particles = particles_id != DataCollection.EMPTY_ID;
            bool load_box = box_id != DataCollection.EMPTY_ID;
            bool load_time = time_id != DataCollection.EMPTY_ID;
            bool load_timestep  = timestep_id != DataCollection.EMPTY_ID;
            bool load_units  = units_id != DataCollection.EMPTY_ID;

            var input = new InputHelper(filepath);

            Box? box = null;
            Particles? particles = null;
            int64? timestep = null;
            double? time = null;
            string? units = null;
            size_t? particles_n = null;
            uint? size_one = null;

            this.read_timestep(input, ref timestep);
            this.read_particles_n(input, ref particles_n);
            this.read_box(input, ref box);
            this.read_size_one(input, ref size_one);
            this.read_units(input, ref units);
            this.read_time(input, ref time);
            this.read_particles(input, particles_n, keys, types, ref particles, size_one);

            if (load_timestep)
            {
                if (timestep == null)
                    throw new ActionError.RUNTIME_ERROR(@"File \"$filepath\" does not have TIMESTEP section");
                var obj = new Int64Property.create();
                obj.set_val(timestep);
                try
                {
                    data.set_element(timestep_id, obj);
                } catch (DataCollectionError.ID_ERROR e)
                {
                    throw new ActionError.RUNTIME_ERROR(@"Cannot set element \"$timestep_id\"");
                }
            }
            if (load_time)
            {
                if (time == null)
                    throw new ActionError.RUNTIME_ERROR(@"File \"$filepath\" does not have TIME section");
                var obj = new Float64Property.create();
                obj.set_val(time);
                try
                {
                    data.set_element(time_id, obj);
                } catch (DataCollectionError.ID_ERROR e)
                {
                    throw new ActionError.RUNTIME_ERROR(@"Cannot set element \"$time_id\"");
                }
            }
            if (load_box)
            {
                if (box == null)
                    throw new ActionError.RUNTIME_ERROR(@"File \"$filepath\" does not have BOX section");
                try
                {
                    data.set_element(box_id, box);
                } catch (DataCollectionError.ID_ERROR e)
                {
                    throw new ActionError.RUNTIME_ERROR(@"Cannot set element \"$box_id\"");
                }
            }
            if (load_particles)
            {
                if (particles == null)
                    throw new ActionError.RUNTIME_ERROR(@"File \"$filepath\" does not have ATOMS section");
                try
                {
                    data.set_element(particles_id, particles);
                } catch (DataCollectionError.ID_ERROR e)
                {
                    throw new ActionError.RUNTIME_ERROR(@"Cannot set element \"$particles_id\"");
                }
            }
            if (load_units)
            {
                if (units == null)
                    throw new ActionError.RUNTIME_ERROR(@"File \"$filepath\" does not have UNITS section");
                var obj = new StringProperty.create();
                obj.set_val(units);
                try
                {
                    data.set_element(units_id, obj);
                } catch (DataCollectionError.ID_ERROR e)
                {
                    throw new ActionError.RUNTIME_ERROR(@"Cannot set element \"$units_id\"");
                }
            }
        }
    }
}
