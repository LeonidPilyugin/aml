namespace AmlMath
{
    public struct Vector3
    {
        double _data[3];

        public double get_element(uint x)
            requires (x < 3)
        {
            return _data[x];
        }

        public void set_element(uint x, double val)
            requires (x < 3)
        {
            _data[x] = val;
        }

        public Vector3 copy()
        {
            Vector3 result = Vector3();
            result._data = _data.copy();
            return result;
        }

        public double norm()
        {
            return GLib.Math.sqrt(
                this._data[0] * this._data[0] +
                this._data[1] * this._data[1] +
                this._data[2] * this._data[2]
            );
        }

        public void set_with(Vector3 v)
        {
            for (uint i = 0; i < 3; i++)
                this._data[i] = v._data[i];
        }

        public static double scalar_product(Vector3 left, Vector3 right)
        {
            double res = 0.0;
            for (uint i = 0; i < 3; i++)
                res += left._data[i] * right._data[i];
            return res;
        }

        public static Vector3 cross_product(Vector3 left, Vector3 right)
        {
            Vector3 result = Vector3();
            result._data[0] = left._data[1] * right._data[2] - left._data[2] * right._data[1];
            result._data[1] = left._data[2] * right._data[0] - left._data[0] * right._data[2];
            result._data[2] = left._data[0] * right._data[1] - left._data[1] * right._data[0];
            return result;
        }

        public static void product(Vector3 left, Vector3 right, Vector3 result)
        {
            for (uint i = 0; i < 3; i++)
                result._data[i] = left._data[i] * right._data[i];
        }

        public static double volume(Vector3 first, Vector3 second, Vector3 third)
        {
            Vector3 temp = Vector3();
            temp = Vector3.cross_product(second, third);
            return Vector3.scalar_product(first, temp);
        }

        public static Vector3 substract(Vector3 left, Vector3 right)
        {
            Vector3 result = Vector3();
            for (uint i = 0; i < 3; i++)
                result._data[i] = left._data[i] - right._data[i];
            return result;
        }
    }
}
