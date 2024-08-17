namespace Aal {
    public class BoxInitData : Object {
        public BoxInitData() { }
    }

    public abstract class Box : Object {
        protected Box(BoxInitData data) {
        }

        public abstract double volume { get; }
    }

    public class ParallelepipedBoxInitData : BoxInitData {
        public Matrix edge;
        public Vector origin;
        public Array<bool> boundaries;

        public ParallelepipedBoxInitData() {
            base();
            this.edge = new Matrix(3, 3);
            this.origin = new Vector(3);
            this.boundaries = new Array<bool>();
        }
    }

    public errordomain ParallelepipedBoxError {
        INVALID_EDGE,
        INVALID_ORIGIN,
        INVALID_BOUNDARIES,
    }

    public class ParallelepipedBox : Box {
        protected Matrix edge;
        protected Vector origin;
        protected Array<bool> boundaries;

        public ParallelepipedBox(ParallelepipedBoxInitData data)
            throws ParallelepipedBoxError.INVALID_EDGE,
                ParallelepipedBoxError.INVALID_BOUNDARIES,
                ParallelepipedBoxError.INVALID_ORIGIN {
            base(data);
            this.set_edge(data.edge);
            this.set_origin(data.origin);
            this.set_boundaries(data.boundaries);
        }

        public static ParallelepipedBox create(
            Matrix edge,
            Vector origin,
            Array<bool> boundaries
        ) throws ParallelepipedBoxError.INVALID_EDGE,
                ParallelepipedBoxError.INVALID_ORIGIN,
                ParallelepipedBoxError.INVALID_BOUNDARIES {
            var data = new ParallelepipedBoxInitData();
            data.edge = edge;
            data.origin = origin;
            data.boundaries = boundaries;
            return new ParallelepipedBox(data);
        }

        public Matrix get_edge() {
            return this.edge.copy();
        }

        public void set_edge(Matrix matrix) throws ParallelepipedBoxError.INVALID_EDGE {
            if (matrix.get_rows_number() != 3 || matrix.get_columns_number() != 3)
                throw new ParallelepipedBoxError.INVALID_EDGE("Invalid matrix size");
            if (matrix.det() == 0.0)
                throw new ParallelepipedBoxError.INVALID_EDGE("Zero box volume");
            if (matrix.det() < 0.0)
                throw new ParallelepipedBoxError.INVALID_EDGE("Negative box volume");
            this.edge = matrix;
        }

        public Vector get_origin() {
            return this.origin.copy();
        }

        public void set_origin(Vector vector) throws ParallelepipedBoxError.INVALID_ORIGIN {
            if (vector.get_size() != 3)
                throw new ParallelepipedBoxError.INVALID_ORIGIN("Invalid vector size");
            this.origin = vector;
        }

        public Array<bool> get_boundaries() {
            return this.boundaries.copy();
        }

        public void set_boundaries(Array<bool> boundaries) throws ParallelepipedBoxError.INVALID_BOUNDARIES {
            if (boundaries.length != 3)
                throw new ParallelepipedBoxError.INVALID_BOUNDARIES("Invalid array length");
            this.boundaries = boundaries;
        }

        public override double volume {
            get {
                return this.edge.det();
            }
        }
    }
}
