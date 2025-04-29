using AmlCore;
using AmlTypes;

namespace AmlParticles
{
    public errordomain ParticlesError
    {
        ID_ERROR,
        TYPE_ERROR,
        SIZE_ERROR,
        INDEX_ERROR,
    }

    public class Particles : DataObject
    {
        private size_t size = 0;
        private HashTable<string, ArrayProperty> properties = new HashTable<string, ArrayProperty>(str_hash, str_equal);

        public Particles.sized(size_t size)
        {
            this.size = size;
        }

        public size_t get_size()
        {
            return this.size;
        }

        public void set_size(size_t size)
            throws ArrayPropertyError.MEMORY_ERROR
        {
            this.size = size;
            foreach (unowned var prop in this.properties.get_values())
                prop.set_size(size);
        }

        public ArrayProperty get_prop(string id) throws ParticlesError.ID_ERROR
        {
            if (!this.properties.contains(id))
                throw new ParticlesError.ID_ERROR(@"Does not contain element with id \"$id\"");
            return (ArrayProperty) this.properties.get(id).copy();
        }

        public bool has_prop(string id)
        {
            return this.properties.contains(id);
        }

        public void set_prop(string id, ArrayProperty prop) throws ParticlesError.SIZE_ERROR
        {
            if (prop.get_size() != this.size)
                throw new ParticlesError.SIZE_ERROR("Property size is different");
            this.properties.set(id, prop);
        }

        public void del_prop(string id) throws ParticleError.ID_ERROR
        {
            if (!this.properties.contains(id))
                throw new ParticlesError.ID_ERROR(@"Does not contain property with id \"$id\"");
            this.properties.take(id);
        }

        public List<weak string> get_ids()
        {
            return this.properties.get_keys();
        }

        public void clear()
        {
            this.properties.remove_all();
        }

        public void get_particle(size_t index, Particle particle) throws ParticlesError.INDEX_ERROR
        {
            particle.clear();
            foreach (unowned var prop_id in particle.get_ids())
            {
                unowned ArrayProperty prop = this.properties.get(prop_id);
                prop.get_property(index, particle.get_prop(prop_id));
            }
        }

        public override DataObject copy()
        {
            var result = new Particles.sized(this.size);
            foreach (unowned var k in this.get_ids())
                result.properties.insert(k, (ArrayProperty) this.get_prop(k));
            return result;
        }
    }
}
