using AmlCore;

namespace AmlParticle
{
    public errordomain ParticleError
    {
        ID_ERROR,
        TYPE_ERROR,
    }

    public class Particle : AmlObject
    {
        private HashTable<string, Variant> data;

        public Particle.empty()
        {
            this.data = new HashTable<string, Variant>(str_hash, str_equal);
        }

        public Variant get_prop(string id) throws ParticleError.ID_ERROR
        {
            if (!this.has_prop(id))
                throw new ParticleError.ID_ERROR(@"Does not contain property with id \"$id\"");
            return this.data.get(id);
        }

        public bool has_prop(string id)
        {
            return this.data.contains(id);
        }

        public void set_prop(string id, owned Variant prop)
        {
            this.data.set(id, prop);
        }

        public void del_prop(string id) throws ParticleError.ID_ERROR
        {
            if (!this.has_prop(id))
                throw new ParticleError.ID_ERROR(@"Does not contain property with id \"$id\"");
            this.data.remove(id);
        }

        public List<weak string> get_ids()
        {
            return this.data.get_keys();
        }

        public Particle copy()
        {
            var res = new Particle.empty();
            foreach (unowned var id in this.get_ids())
            {
                res.set_prop(id, this.get_prop(id));
            }
            return res;
        }
    }
}
