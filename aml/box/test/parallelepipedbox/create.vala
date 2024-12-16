using AmlBox;
using AmlMath;

public static int main(string[] args)
{
    double[] arr = { 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0 };
    var edge = new Matrix.from_array(arr, 3);
    arr = { 0.0, 0.0, 0.0 };
    var origin = new Vector.from_array(arr);
    bool[] bounds = { true, false, true };
    var res = new ParallelepipedBox.create(edge, origin, bounds);

    origin.set_val(0, 10.0);
    assert(res.get_origin().get_val(0) == 0.0);

    edge.set_val(0, 0, 10.0);
    assert(res.get_edge().get_val(0, 0) == 1.0);

    bounds[0] = false;
    assert(res.get_boundaries()[0]);

    return 0;    
}
