namespace AmlMath
{
    public struct Matrix3
    {
        double _data[9];

        public double get_element(uint x, uint y)
            requires (x < 3)
            requires (y < 3)
        {
            return _data[y * 3 + x];
        }

        public void set_element(uint x, uint y, double val)
            requires (x < 3)
            requires (y < 3)
        {
            _data[y * 3 + x] = val;
        }

        public bool is_diagonal()
        {
            bool result = true;
            for (uint i = 0; i < 3; i++)
            {
                for (uint j = 0; j < 3; j++)
                {
                    if (i != j) result &= _data[i+j*3] == 0.0;
                }
            }

            return result;
        }

        public double det()
        {
            return _data[0+0*3] * _data[1+1*3] * _data[2+2*3] +
                   _data[0+1*3] * _data[1+2*3] * _data[2+0*3] +
                   _data[0+2*3] * _data[1+0*3] * _data[2+1*3] -
                   _data[0+2*3] * _data[1+1*3] * _data[2+0*3] -
                   _data[0+0*3] * _data[1+2*3] * _data[2+1*3] -
                   _data[0+1*3] * _data[1+0*3] * _data[2+2*3];
        }

        public void transpose()
        {
            double temp;
            for (uint i = 1; i < 3; i++)
            {
                for (uint j = 0; j < i; j++)
                {
                    temp = _data[j+i*3];
                    _data[j+i*3] = _data[i+j*3];
                    _data[i+j*3] = temp;
                }
            }
        }

        public void get_row(int n, Vector3 result)
            requires (n < 3)
        {
            for (uint i = 0; i < 3; i++)
            {
                result._data[i] = _data[i+n*3];
            }
        }

        public void get_column(int n, Vector3 result)
            requires (n < 3)
        {
            for (uint i = 0; i < 3; i++)
            {
                result._data[i] = _data[n+i*3];
            }
        }

        public Matrix3 copy()
        {
            Matrix3 result = Matrix3();
            result._data = _data.copy();
            return result;
        }

        public static void multiply(Matrix3 left, Matrix3 right, Matrix3 result)
        {
            for (uint i = 0; i < 3; i++)
            {
                for (uint j = 0; j < 3; j++)
                {
                    result._data[i+j*3] = 0.0;
                    for (uint k = 0; k < 3; k++)
                    {
                        result._data[i+j*3] += left._data[k+j*3] * right._data[i+k*3];
                    }
                }
            }
        }

        public static void multiply_right(Matrix3 left, Vector3 right, Vector3 result)
        {
            for (uint i = 0; i < 3; i++)
            {
                result._data[i] = 0.0;
                for (uint j = 0; j < 3; j++)
                {
                    result._data[i] += right._data[j] * left._data[j+i*3];
                }
            }
        }

        public static void multiply_left(Vector3 left, Matrix3 right, Vector3 result)
        {
            for (uint i = 0; i < 3; i++)
            {
                result._data[i] = 0.0;
                for (uint j = 0; j < 3; j++)
                {
                    result._data[i] += left._data[j] * right._data[i+j*3];
                }
            }
        }
    }
}
