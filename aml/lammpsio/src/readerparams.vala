using AmlCore;

namespace AmlLammpsIo
{
    public class ReaderParams : ActionParams
    {
        private string filepath = Presets.EMPTY_ID;
        private string particles_id = Presets.EMPTY_ID;
        private string box_id = Presets.EMPTY_ID;
        private string timestep_id = Presets.EMPTY_ID;
        private string time_id = Presets.EMPTY_ID;
        private string units_id = Presets.EMPTY_ID;
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

        public string get_units_id()
        {
            return this.units_id;
        }

        public void set_units_id(string units_id)
        {
            this.units_id = units_id;
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
            var res = new ReaderParams();

            res.filepath = this.filepath;
            res.particles_id = this.particles_id;
            res.box_id = this.box_id;
            res.timestep_id = this.timestep_id;
            res.time_id = this.time_id;
            res.units_id = this.units_id;
            res.properties = new HashTable<string, Type>(str_hash, str_equal);
            foreach (var key in this.properties.get_keys())
                res.properties.set(key, this.properties.get(key));

            return res;
        }
    }
}