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
        private Matrix edge;
        private Vector origin;
        private bool[] boundaries;

        public ParallelepipedBox.create(Matrix edge, Vector origin, bool[] boundaries) throws ParallelepipedBoxError
        {
            this.set_edge(edge);
            this.set_origin(origin);
            this.set_boundaries(boundaries);
        }

        public Matrix get_edge()
        {
            return this.edge.copy();
        }

        public void set_edge(Matrix matrix) throws ParallelepipedBoxError
        {
            if (matrix.get_rows() != 3 || matrix.get_columns() != 3)
                throw new ParallelepipedBoxError.INVALID_EDGE("Invalid matrix size");
            if (matrix.det() == 0.0)
                throw new ParallelepipedBoxError.INVALID_EDGE("Zero box volume");
            if (matrix.det() < 0.0)
                throw new ParallelepipedBoxError.INVALID_EDGE("Negative box volume");
            this.edge = matrix.copy();
        }

        public Vector get_origin()
        {
            return this.origin.copy();
        }

        public void set_origin(Vector vector) throws ParallelepipedBoxError
        {
            if (vector.get_size() != 3)
                throw new ParallelepipedBoxError.INVALID_ORIGIN("Invalid vector size");
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
    }
}
