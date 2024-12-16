using AmlCore;

namespace AmlParticle
{
    public errordomain ParticlesError
    {
        ID_ERROR,
        SIZE_ERROR,
        INDEX_ERROR,
        TYPE_ERROR,
    }

    public class Particles : DataObject
    {
        private uint size;
        private HashTable<string, PerParticleProperty> properties;

        public Particles.sized(uint size)
        {
            this.size = size;
            this.properties = new HashTable<string, PerParticleProperty>(str_hash, str_equal);
        }

        public Particles.empty()
        {
            this.sized(0);
        }

        public uint get_size()
        {
            return this.size;
        }

        public void set_size(uint size)
        {
            this.size = size;
            foreach (unowned var prop in this.properties.get_values())
                prop.set_size(size);
        }

        public PerParticleProperty get_prop(string id) throws ParticlesError.ID_ERROR
        {
            if (!this.properties.contains(id))
                throw new ParticlesError.ID_ERROR(@"Does not contain element with id \"$id\"");
            return this.properties.get(id).copy();
        }

        public void set_prop(string id, owned PerParticleProperty prop) throws ParticlesError.SIZE_ERROR
        {
            if (prop.get_size() != this.size)
                throw new PerParticlePropertyError.SIZE_ERROR("Property size is different");
            this.properties.set(id, prop);
        }

        public void del_prop(string id) throws ParticlesError.ID_ERROR
        {
            if (!this.properties.contains(id))
                throw new ParticlesError.ID_ERROR(@"Does not contain property with id \"$id\"");
            this.properties.take(id);
        }

        public bool has_prop(string id)
        {
            return this.properties.contains(id);
        }

        public List<weak string> get_ids()
        {
            return this.properties.get_keys();
        }

        public Particle get_particle(uint index) throws ParticlesError.INDEX_ERROR
        {
            if (index > this.size)
                throw new ParticlesError.INDEX_ERROR("Index is out of range");
            
            Particle result = new Particle.empty();
            Variant temp;
            unowned PerParticleProperty temp_prop;

            foreach (unowned var prop_id in this.get_ids())
            {
                temp_prop = this.properties.get(prop_id);
                temp = temp_prop.get_val_variant(index);
                result.set_prop(prop_id, temp);
            }

            return result;
        }

        public void set_particle(uint index, Particle particle) throws ParticlesError.INDEX_ERROR, ParticlesError.TYPE_ERROR, ParticlesError.ID_ERROR
        {
            this.remove_particle(index);
            this.insert_particle(index, particle);
        }

        public void insert_particle(uint index, Particle particle) throws ParticlesError.INDEX_ERROR, ParticlesError.SIZE_ERROR, ParticlesError.TYPE_ERROR, ParticlesError.ID_ERROR
        {
            var keys = this.get_ids();
            var val_keys = particle.get_ids();
            if (keys.length() != val_keys.length())
                throw new ParticlesError.ID_ERROR(@"Particle has $(val_keys.length()) properties instead of $(keys.length())");
            foreach (unowned var k in keys)
                if (val_keys.index(k) == -1)
                    throw new ParticlesError.ID_ERROR(@"Particle does not have property \"$k\"");
            Variant temp_variant;
            unowned PerParticleProperty temp_prop;
            foreach (unowned var k in val_keys)
            {
                temp_variant = particle.get_prop(k);
                temp_prop = this.properties.get(k);
                temp_prop.insert_val_variant(index, temp_variant);
            }
            this.size++;
        }

        public void insert_first(Particle particle) throws ParticlesError.TYPE_ERROR, ParticlesError.ID_ERROR, ParticlesError.SIZE_ERROR
        {
            this.insert_particle(0, particle);
        }


        public void insert_last(Particle particle) throws ParticlesError.TYPE_ERROR, ParticlesError.ID_ERROR, ParticlesError.SIZE_ERROR
        {
            this.insert_particle(this.size, particle);
        }

        public void remove_first() throws ParticlesError.SIZE_ERROR
        {
            if (this.get_size() == 0)
                throw new ParticlesError.SIZE_ERROR("Empty");
            this.remove_particle(0);
        }

        public void remove_last() throws ParticlesError.SIZE_ERROR
        {
            if (this.get_size() == 0)
                throw new ParticlesError.SIZE_ERROR("Empty");
            this.remove_particle(this.size - 1);
        }

        public void remove_particle(uint index) throws ParticlesError.INDEX_ERROR
        {
            if (index >= this.size)
                throw new ParticlesError.INDEX_ERROR("Index is out of range");
            foreach (unowned var prop in this.properties.get_values())
                prop.remove_val(index);
        }

        public override DataObject copy()
        {
            var result = new Particles.sized(this.size);
            foreach (unowned var k in this.get_ids())
                result.properties.insert(k, this.get_prop(k));
            return result;
        }
    }
}
