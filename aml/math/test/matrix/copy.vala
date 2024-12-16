using AmlMath;

public static int main(string[] args)
{
    var a = new Matrix.sized(2, 2);    
    double[] arr = { 0.0, 1.0, 2.0, 3.0 };
    a.set_arr(arr);
    assert(a.get_val(0, 0) == 0.0);
    assert(a.get_val(0, 1) == 1.0);
    assert(a.get_val(1, 0) == 2.0);
    assert(a.get_val(1, 1) == 3.0);

    var b = a.copy();
    assert(b.get_val(0, 0) == 0.0);
    assert(b.get_val(0, 1) == 1.0);
    assert(b.get_val(1, 0) == 2.0);
    assert(b.get_val(1, 1) == 3.0);
    b.set_val(0, 0, -1.0);
    assert(a.get_val(0, 0) == 0.0);
    assert(a.get_val(0, 1) == 1.0);
    assert(a.get_val(1, 0) == 2.0);
    assert(a.get_val(1, 1) == 3.0);
    assert(b.get_val(0, 0) == -1.0);
    assert(b.get_val(0, 1) == 1.0);
    assert(b.get_val(1, 0) == 2.0);
    assert(b.get_val(1, 1) == 3.0);
    return 0;
}