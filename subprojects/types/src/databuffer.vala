using AmlCore;

namespace AmlTypes
{
    private abstract class AllocStrategy
    {
        public abstract size_t get_new_capacity(size_t new_size, size_t previous_capacity, bool failed = false);
    }

    private class DefaultAllocStrategy : AllocStrategy
    {
        private size_t modifier = 2;

        public override size_t get_new_capacity(size_t new_size, size_t previous_capacity, bool failed = false)
        {
            if (new_size <= previous_capacity) return previous_capacity;

            if (failed) return new_size;

            return size_t.max(
                new_size,
                (size_t) (previous_capacity * this.modifier)
            );
        }
    }

    private errordomain DataBufferError
    {
        MEMORY_ERROR,
    }

    private class DataBuffer : Object
    {
        private char * array = null;
        private size_t size = 0;
        private size_t capacity = 0;
        private AllocStrategy alloc_strategy = new DefaultAllocStrategy();

        ~DataBuffer()
        {
            this.free();
        }

        public size_t get_size()
        {
            return this.size;
        }

        public size_t get_capacity()
        {
            return this.capacity;
        }

        public bool try_set_size(size_t size)
        {
            bool failed = false;
            size_t capacity = this.capacity;

            do {
                capacity = this.alloc_strategy.get_new_capacity(size, capacity, failed);
                failed = !this.try_set_capacity(capacity);
                if (failed && capacity == size) return false;
            } while (failed);

            this.size = size;

            return true;
        }

        public void set_size(size_t size) throws DataBufferError.MEMORY_ERROR
        {
            bool result = this.try_set_size(size);
            if (!result) throw new DataBufferError.MEMORY_ERROR("Out of memory");
        }

        private bool try_set_capacity(size_t capacity)
        {
            if (capacity != this.capacity)
            {
                void * mem = realloc(this.array, capacity);
                if (mem == null && capacity > 0) return false;
                this.array = mem;
            }

            this.capacity = capacity;
            return true;
        }

        public void remove(size_t start, size_t n)
        {
            if (start > this.size) return;
            if (start + n > this.size) n = this.size - start;

            Memory.move(this.array + start, this.array + start + n, this.size - start - n);

            this.set_size(this.size - n);
        }

        public bool optimize()
        {
            return this.try_set_capacity(this.size);
        }

        public void free()
        {
            GLib.free(this.array);
            this.array = null;
            this.size = this.capacity = 0;
        }

        public void move(size_t dest, size_t src, size_t n)
        {
            Memory.move(this.array + dest, this.array + src, n);
        }

        public void * get_address(size_t index)
        {
            return this.array + index;
        }

        public DataBuffer copy()
        {
            var result = new DataBuffer();
            result.array = Memory.dup2(this.array, this.capacity);
            result.size = this.size;
            result.capacity = this.capacity;
            result.alloc_strategy = this.alloc_strategy;
            return result;
        }
    }
}
