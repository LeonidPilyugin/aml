using AmlBox;
using AmlMath;

public static int main(string[] args)
{
    double[] arr = { 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0 };
    Matrix valid_edge = new Matrix.from_array(arr, 3);
    arr = { 0.0, 0.0, 0.0 };
    Vector valid_origin = new Vector.from_array(arr);
    bool[] valid_bounds = { true, false, true };
    Matrix edge;
    Vector origin;
    bool[] bounds;

    try {
        arr = { 1.0, 2.0, 3.0, 4.0 };
        edge = new Matrix.from_array(arr, 2);
        new ParallelepipedBox.create(edge, valid_origin, valid_bounds);
        assert_not_reached();
    } catch (ParallelepipedBoxError.INVALID_EDGE e) {}
    try {
        arr = { 1.0, 2.0, 3.0, 4.0 };
        edge = new Matrix.from_array(arr, 4);
        new ParallelepipedBox.create(edge, valid_origin, valid_bounds);
        assert_not_reached();
    } catch (ParallelepipedBoxError.INVALID_EDGE e) {}
    try {
        arr = { 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0 };
        edge = new Matrix.from_array(arr, 3);
        new ParallelepipedBox.create(edge, valid_origin, valid_bounds);
        assert_not_reached();
    } catch (ParallelepipedBoxError.INVALID_EDGE e) {}
    try {
        arr = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };
        edge = new Matrix.from_array(arr, 3);
        new ParallelepipedBox.create(edge, valid_origin, valid_bounds);
        assert_not_reached();
    } catch (ParallelepipedBoxError.INVALID_EDGE e) {}
    try {
        arr = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };
        origin = new Vector.from_array(arr);
        new ParallelepipedBox.create(valid_edge, origin, valid_bounds);
        assert_not_reached();
    } catch (ParallelepipedBoxError.INVALID_ORIGIN e) {}
    try {
        arr = { 0.0, 0.0 };
        origin = new Vector.from_array(arr);
        new ParallelepipedBox.create(valid_edge, origin, valid_bounds);
        assert_not_reached();
    } catch (ParallelepipedBoxError.INVALID_ORIGIN e) {}
    try {
        bounds = { true, false };
        new ParallelepipedBox.create(valid_edge, valid_origin, bounds);
        assert_not_reached();
    } catch (ParallelepipedBoxError.INVALID_BOUNDARIES e) {}
    try {
        bounds = { true, false, true, true };
        new ParallelepipedBox.create(valid_edge, valid_origin, bounds);
        assert_not_reached();
    } catch (ParallelepipedBoxError.INVALID_BOUNDARIES e) {}

    return 0;    
}
