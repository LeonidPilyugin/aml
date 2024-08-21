namespace Aml
{
    /**
     * Simulation box
     */
    public abstract class Box : Object
    {
        /**
         * Volume of simulation box
         */
        public abstract double get_volume();

        /**
         * Copies this object
         * 
         * @return Copy of this object
         */
        public abstract Box copy();
    }

    public errordomain ParallelepipedBoxError
    {
        INVALID_EDGE,
        INVALID_ORIGIN,
        INVALID_BOUNDARIES,
    }

    /**
     * Parallelepiped-shaped box
     * 
     * Described by:
     * 1) edge: 3x3 Matrix, each row describes a formative vector
     * 2) origin: 3D origin Vector
     * 3) boundaries: boolean array of size 3, true means that boundary condition is periodic
     */
    public class ParallelepipedBox : Box
    {
        private Matrix edge;
        private Vector origin;
        private bool[] boundaries;

        /**
         * Creates ParallelepipedBox from edge, origin and boundaries
         * 
         * @param edge Edge matrix
         * @param origin Origin vector
         * @param boundaries Boundaries array
         * 
         * @throws ParallelepipedBoxError.INVALID_EDGE If got invalid edge
         * @throws ParallelepipedBoxError.INVALID_ORIGIN If got invalid origin
         * @throws ParallelepipedBoxError.INVALID_BOUNDARIES If got invalid boundaries
         */
        public ParallelepipedBox.create(Matrix edge, Vector origin, bool[] boundaries)
            throws ParallelepipedBoxError
        {
            this.set_edge(edge);
            this.set_origin(origin);
            this.set_boundaries(boundaries);
        }

        /**
         * Returns copy of edge matrix
         * 
         * @return Copy of edge matrix
         */
        public Matrix get_edge()
        {
            return this.edge.copy();
        }

        /**
         * Sets edge matrix
         * 
         * @param matrix Edge matrix
         * 
         * @throws ParallelepipedBoxError.INVALID_EDGE If matrix is invalid
         */
        public void set_edge(owned Matrix matrix) throws ParallelepipedBoxError
        {
            if (matrix.get_rows() != 3 || matrix.get_columns() != 3)
                throw new ParallelepipedBoxError.INVALID_EDGE("Invalid matrix size");
            if (matrix.det() == 0.0)
                throw new ParallelepipedBoxError.INVALID_EDGE("Zero box volume");
            if (matrix.det() < 0.0)
                throw new ParallelepipedBoxError.INVALID_EDGE("Negative box volume");
            this.edge = matrix;
        }

        /**
         * Returns copy of origin vector
         * 
         * @return Copy of origin vector
         */
        public Vector get_origin()
        {
            return this.origin.copy();
        }

        /**
         * Sets origin vector
         * 
         * @param vector Origin vector to set
         * 
         * @throws ParallelepipedBoxError.INVALID_ORIGIN If origin is invalid
         */
        public void set_origin(owned Vector vector) throws ParallelepipedBoxError
        {
            if (vector.get_size() != 3)
                throw new ParallelepipedBoxError.INVALID_ORIGIN("Invalid vector size");
            this.origin = vector;
        }

        /**
         * Returns copy of boundaries array
         * 
         * @return Copy of boundaries array
         */
        public bool[] get_boundaries()
        {
            return this.boundaries.copy();
        }

        /**
         * Sets boundaries array
         * 
         * @param boundaries Array to set
         * 
         * @throws ParallelepipedBoxError.INVALID_BOUNDARIES If got invalid array
         */
        public void set_boundaries(owned bool[] boundaries) throws ParallelepipedBoxError
        {
            if (boundaries.length != 3)
                throw new ParallelepipedBoxError.INVALID_BOUNDARIES("Invalid array length");
            this.boundaries = boundaries;
        }

        public override double get_volume()
        {
            return this.edge.det();
        }

        public override Box copy()
        {
            return new ParallelepipedBox.create(this.edge.copy(), this.origin.copy(), this.boundaries.copy());
        }
    }
}
