using AmlBox;
using AmlMath;

public static int main(string[] args)
{
    double[] arr = { 2.0, 0.0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 4.0 };
    var edge = new Matrix.from_array(arr, 3);
    arr = { 0.0, 0.0, 0.0 };
    var origin = new Vector.from_array(arr);
    bool[] bounds = { true, false, true };
    var res = new ParallelepipedBox.create(edge, origin, bounds);

    assert(res.get_volume() == 2.0 * 3.0 * 4.0);

    return 0;    
}
