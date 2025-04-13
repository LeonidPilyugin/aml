using AmlCore;
using AmlMath;

namespace AmlBox
{
    public errordomain ParallelepipedBoxError
    {
        INVALID_EDGE,
        INVALID_ORIGIN,
        INVALID_BOUNDARIES,
    }

    public class ParallelepipedBox : Box
    {
        private Matrix3 edge;
        private Vector3 origin;
        private Vector3 a;
        private Vector3 b;
        private Vector3 c;
        private Vector3 a_;
        private Vector3 b_;
        private Vector3 c_;
        private bool[] boundaries;

        public ParallelepipedBox.create(Matrix3 edge, Vector3 origin, bool[] boundaries) throws ParallelepipedBoxError
        {
            this.set_edge(edge);
            this.set_origin(origin);
            this.set_boundaries(boundaries);
        }

        public Matrix3 get_edge()
        {
            return this.edge.copy();
        }

        public void set_edge(Matrix3 matrix) throws ParallelepipedBoxError
        {
            if (matrix.det() == 0.0)
                throw new ParallelepipedBoxError.INVALID_EDGE("Zero box volume");
            if (matrix.det() < 0.0)
                throw new ParallelepipedBoxError.INVALID_EDGE("Negative box volume");
            this.edge = matrix.copy();
            edge.get_column(0, a);
            edge.get_column(1, b);
            edge.get_column(2, c);
            Vector3.cross_product(a, b, c_);
            Vector3.cross_product(b, c, a_);
            Vector3.cross_product(c, a, b_);
        }

        public Vector3 get_origin()
        {
            return this.origin.copy();
        }

        public void set_origin(Vector3 vector)
        {
            this.origin = vector.copy();
        }

        public bool[] get_boundaries()
        {
            return this.boundaries.copy();
        }

        public void set_boundaries(bool[] boundaries) throws ParallelepipedBoxError
        {
            if (boundaries.length != 3)
                throw new ParallelepipedBoxError.INVALID_BOUNDARIES("Invalid array length");
            this.boundaries = boundaries.copy();
        }

        public override double get_volume()
        {
            return this.edge.det();
        }

        public override DataObject copy()
        {
            return new ParallelepipedBox.create(this.edge.copy(), this.origin.copy(), this.boundaries.copy());
        }

        public override bool contains_point(Vector3 point)
        {
            Vector3 x = Vector3(), temp = Vector3();
            Vector3.substract(point, origin, x);
            bool result = true;
            
            Vector3.substract(x, c, temp);
            result &= Vector3.scalar_product(x, c_) * Vector3.scalar_product(temp, c_) < 0.0;
            Vector3.substract(x, b, temp);
            result &= Vector3.scalar_product(x, b_) * Vector3.scalar_product(temp, b_) < 0.0;
            Vector3.substract(x, a, temp);
            result &= Vector3.scalar_product(x, a_) * Vector3.scalar_product(temp, a_) < 0.0;

            return result;
        }

        public override void map_periodic(Vector3 point, Vector3 map, Vector3 result)
        {
            Vector3.product(point, map, result);            
        }
    }
}
