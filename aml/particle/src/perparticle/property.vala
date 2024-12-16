using AmlCore;

namespace AmlParticle
{
    public errordomain PerParticlePropertyError
    {
        INDEX_ERROR,
        SIZE_ERROR,
        TYPE_ERROR,
    }

    public abstract class PerParticleProperty : AmlObject
    {
        public abstract uint get_size();
        public abstract void set_size(uint size);

        public abstract Variant get_val_variant(uint index) throws PerParticlePropertyError.INDEX_ERROR;

        public virtual Variant get_first_variant() throws PerParticlePropertyError.SIZE_ERROR
        {
            if (this.get_size() == 0)
                throw new PerParticlePropertyError.SIZE_ERROR("Empty");
            return this.get_val_variant(0);
        }

        public virtual Variant get_last_variant() throws PerParticlePropertyError.SIZE_ERROR
        {
            if (this.get_size() == 0)
                throw new PerParticlePropertyError.SIZE_ERROR("Empty");
            return this.get_val_variant(this.get_size() - 1);
        }

        public abstract void set_val_variant(uint index, Variant v) throws PerParticlePropertyError.INDEX_ERROR, PerParticlePropertyError.TYPE_ERROR;

        public virtual void set_first_variant(Variant v) throws PerParticlePropertyError.SIZE_ERROR, PerParticlePropertyError.TYPE_ERROR
        {
            if (this.get_size() == 0)
                throw new PerParticlePropertyError.SIZE_ERROR("Empty");
            this.set_val_variant(0, v);
        }

        public virtual void set_last_variant(Variant v) throws PerParticlePropertyError.SIZE_ERROR, PerParticlePropertyError.TYPE_ERROR
        {
            if (this.get_size() == 0)
                throw new PerParticlePropertyError.SIZE_ERROR("Empty");
            this.set_val_variant(this.get_size() - 1, v);
        }

        public abstract void insert_val_variant(uint index, Variant v) throws PerParticlePropertyError.INDEX_ERROR, PerParticlePropertyError.SIZE_ERROR, PerParticlePropertyError.TYPE_ERROR;

        public virtual void insert_first_variant(Variant v) throws PerParticlePropertyError.SIZE_ERROR, PerParticlePropertyError.TYPE_ERROR
        {
            this.insert_val_variant(0, v);
        }

        public virtual void insert_last_variant(Variant v) throws PerParticlePropertyError.SIZE_ERROR, PerParticlePropertyError.TYPE_ERROR
        {
            this.insert_val_variant(this.get_size(), v);
        }

        public abstract void remove_val(uint index) throws PerParticlePropertyError.INDEX_ERROR;

        public virtual void remove_first() throws PerParticlePropertyError.SIZE_ERROR
        {
            if (this.get_size() == 0)
                throw new PerParticlePropertyError.SIZE_ERROR("Empty");
            this.remove_val(0);
        }

        public virtual void remove_last() throws PerParticlePropertyError.SIZE_ERROR
        {
            if (this.get_size() == 0)
                throw new PerParticlePropertyError.SIZE_ERROR("Empty");
            this.remove_val(this.get_size() - 1);
        }

        public abstract PerParticleProperty copy();
    }
}
