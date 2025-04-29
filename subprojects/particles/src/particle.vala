using AmlCore;
using AmlTypes;

namespace AmlParticles
{
    public errordomain ParticleError
    {
        ID_ERROR,
        TYPE_ERROR,
    }

    public class Particle : Object
    {
        private HashTable<string, Property> properties = new HashTable<string, Property>(str_hash, str_equal);

        public unowned Property get_prop(string id) throws ParticleError.ID_ERROR
        {
            if (!this.has_prop(id))
                throw new ParticleError.ID_ERROR(@"Does not contain property with id \"$id\"");
            return this.properties.get(id);
        }

        public bool has_prop(string id)
        {
            return this.properties.contains(id);
        }

        public void set_prop(string id, Property prop)
        {
            this.properties.set(id, prop);
        }

        public void del_prop(string id) throws ParticleError.ID_ERROR
        {
            if (!this.has_prop(id))
                throw new ParticleError.ID_ERROR(@"Does not contain property with id \"$id\"");
            this.properties.remove(id);
        }

        public void clear()
        {
            this.properties.remove_all();
        }

        public List<weak string> get_ids()
        {
            return this.properties.get_keys();
        }

        public Particle copy()
        {
            var res = new Particle();
            foreach (unowned var id in this.get_ids())
            {
                res.set_prop(id, (Property) this.get_prop(id).copy());
            }
            return res;
        }
    }
}
