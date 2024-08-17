using Gsl;

namespace Aal {
    public class Vector : Object {
        private Gsl.Vector _vector;        

        public Vector(uint size) {
            this._vector = new Gsl.Vector.with_zeros(size);
        }

        public Vector.from_gsl_vector(owned Gsl.Vector vector) {
            this._vector = (owned) vector;
        }

        public static Vector sized(uint size) {
            return new Vector(size);
        }

        public unowned Gsl.Vector _get_vector() {
            return this._vector;
        }

        public uint get_size() {
            return (uint) this._vector.size;
        }

        public double get_val(uint index) {
            return this._vector.get(index);
        }

        public void set_val(uint index, double value) {
            this._vector.set(index, value);
        }

        public double[] get_array() {
            void* copy = try_malloc(sizeof(double) * this._vector.size);
            Memory.copy(copy, this._vector.data, sizeof(double) * this._vector.size);
            return (double[]) copy;
        }

        public void set_array(double[] array) {
            this._vector = new Gsl.Vector(array.length);
            this._vector.data = array;
        }

        public Vector copy() {
            Vector result = new Vector(this.get_size());
            result._vector.memcpy(this._vector);
            return result;
        }
    }
}
