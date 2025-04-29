using AmlCore;

namespace AmlTypes
{
    public abstract class Type : Object
    {
        public abstract uint get_size();

        public abstract void read(Property prop, void * address);
        public abstract void write(Property prop, void * address);
        public virtual void destroy(void * address, size_t n = 1) { }
        public virtual void init(void * address, size_t n = 1)
        {
            Memory.set(address, 0, n * this.get_size());
        }

        public abstract bool can_convert(Type type);

        public abstract Property create_property();
        public abstract ArrayProperty create_array_property();
    }

    public errordomain PropertyError
    {
        TYPE_ERROR,
    }

    public abstract class Property : DataObject
    {
        private Type type;

        protected void assign_type(Type type)
        {
            this.type = type;
        }

        public Type get_type_object()
        {
            return this.type;
        }

        public abstract void convert_unsafe(Property from);

        public virtual bool can_convert(Property from)
        {
            return this.type.can_convert(from.type);
        }

        public virtual void convert(Property from) throws PropertyError.TYPE_ERROR
        {
            bool result = this.can_convert(from);
            if (!result)
                throw new PropertyError.TYPE_ERROR("Type error");
            this.convert_unsafe(from);
        }
    }

    public errordomain ArrayPropertyError
    {
        TYPE_ERROR,
        INDEX_ERROR,
        MEMORY_ERROR,
    }

    public abstract class ArrayProperty : DataObject
    {
        private DataBuffer data = new DataBuffer();
        private Type type;
        private uint element_size = 0;

        ~ArrayProperty()
        {
            this.set_size(0);
        }

        protected void init(Type type, size_t size)
            throws ArrayPropertyError.MEMORY_ERROR
            requires(type.get_size() > 0)
        {
            this.type = type;
            this.element_size = this.type.get_size();
            this.set_size(size);
        }

        public Type get_type_object()
        {
            return this.type;
        }

        private void check_type(Property p)
            throws ArrayPropertyError
        {
            if (p.get_type_object() != this.type)
                throw new ArrayPropertyError.TYPE_ERROR("Got invalid type");
        }

        private void check_index(size_t index, bool insert = false)
            throws ArrayPropertyError
        {
            if (index > this.get_size() || (!insert && index == this.get_size()))
                throw new ArrayPropertyError.INDEX_ERROR("Index is out of range");
        }

        protected void get_property_unsafe(size_t index, Property property)
        {
            this.type.read(property, this.data.get_address(index * this.element_size));
        }

        protected void set_property_unsafe(size_t index, Property property)
        {
            this.type.destroy(this.data.get_address(index * this.element_size));
            this.type.write(property, this.data.get_address(index * this.element_size));
        }

        protected void insert_property_unsafe(size_t index, Property property)
            throws ArrayPropertyError.MEMORY_ERROR
        {
            try
            {
                this.data.set_size(this.data.get_size() + this.element_size);
            } catch (DataBufferError.MEMORY_ERROR e)
            {
                throw new ArrayPropertyError.MEMORY_ERROR("Out of memory");
            }
            this.data.move((index + 1) * this.element_size, index * this.element_size, this.element_size);
            this.type.write(property, this.data.get_address(index * this.element_size));
        }

        protected void remove_property_unsafe(size_t from, size_t n = 1)
        {
            this.type.destroy(this.data.get_address(from * this.element_size), n);
            this.data.remove(from * this.element_size, n * this.element_size);
        }

        public void get_property(size_t index, Property property)
            throws ArrayPropertyError
        {
             this.check_index(index);
             this.check_type(property);
             this.get_property_unsafe(index, property);
        }

        public void set_property(size_t index, Property property)
            throws ArrayPropertyError
        {
             this.check_index(index);
             this.check_type(property);
             this.set_property_unsafe(index, property);
        }

        public void insert_property(size_t index, Property property)
            throws ArrayPropertyError
        {
            this.check_index(index, true);
            this.check_type(property);
            this.insert_property_unsafe(index, property);
        }

        public void remove_property(size_t index, size_t n = 1)
            throws ArrayPropertyError
        {
            this.check_index(index);
            this.check_index(index + n - 1);
            this.remove_property_unsafe(index, n);
        }

        public size_t get_size()
        {
            return this.data.get_size() / this.element_size;
        }

        public void set_size(size_t size) throws ArrayPropertyError.MEMORY_ERROR
        {
            var s = this.get_size();
            if (s == size) return;

            if (size < s) this.remove_property_unsafe(size, s - size);

            try
            {
                this.data.set_size(size * this.element_size);
            } catch (DataBufferError.MEMORY_ERROR e)
            {
                throw new ArrayPropertyError.MEMORY_ERROR("Out of memory");
            }

            if (size > s) this.type.init(this.data.get_address(s * this.element_size), size - s);
        }

        public void * get_address()
        {
            return this.data.get_address(0);
        }

        public virtual bool can_convert(ArrayProperty from)
        {
            return this.type.can_convert(from.type);
        }

        public virtual void convert(ArrayProperty from)
            throws ArrayPropertyError.TYPE_ERROR
        {
            if (!this.can_convert(from))
                throw new ArrayPropertyError.TYPE_ERROR("Type error");

            Property from_temp = from.get_type_object().create_property();
            Property to_temp = this.type.create_property();

            this.set_size(from.get_size());

            for (size_t i = 0; i < from.get_size(); i++)
            {
                from.get_property_unsafe(i, from_temp);
                to_temp.convert_unsafe(from_temp);
                this.set_property_unsafe(i, to_temp);
            }
        }

        public override DataObject copy()
        {
            var result = this.type.create_array_property();
            result.data = this.data.copy();
            return result;
        }
    }
}
