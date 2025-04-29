using AmlCore;
using AmlTypes;

namespace AmlLammpsIo
{
    public class ReaderParams : ActionParams
    {
        private string filepath = DataCollection.EMPTY_ID;
        private string particles_id = DataCollection.EMPTY_ID;
        private string box_id = DataCollection.EMPTY_ID;
        private string timestep_id = DataCollection.EMPTY_ID;
        private string time_id = DataCollection.EMPTY_ID;
        private string units_id = DataCollection.EMPTY_ID;
        private string[] keys = {};
        private AmlTypes.Type[] types = {};

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

        public unowned string[] get_keys()
        {
            return this.keys;
        }

        public unowned AmlTypes.Type[] get_types()
        {
            return this.types;
        }

        public void set_properties(owned string[] keys, owned AmlTypes.Type[] types)
        {
            this.keys = (owned) keys;
            this.types = (owned) types;
        }

        public override ActionParams copy()
        {
            var res = new ReaderParams();

            res.filepath = this.filepath;
            res.particles_id = this.particles_id;
            res.box_id = this.box_id;
            res.timestep_id = this.timestep_id;
            res.time_id = this.time_id;
            res.units_id = this.units_id;
            res.keys = this.keys;
            res.types = this.types;

            return res;
        }
    }
}
