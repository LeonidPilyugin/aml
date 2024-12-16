using AmlMath;

public static int main(string[] args)
{
    var a = new Vector.sized(4);    
    double[] arr = { 0.0, 1.0, 2.0, 3.0 };
    a.set_arr(arr);
    assert(a.get_val(0) == 0.0);
    assert(a.get_val(1) == 1.0);
    assert(a.get_val(2) == 2.0);
    assert(a.get_val(3) == 3.0);
    arr[3] = -1.0;
    assert(a.get_val(0) == 0.0);
    assert(a.get_val(1) == 1.0);
    assert(a.get_val(2) == 2.0);
    assert(a.get_val(3) == 3.0);
    a.set_val(0, 10.0);
    assert(a.get_val(0) == 10.0);
    assert(a.get_val(1) == 1.0);
    assert(a.get_val(2) == 2.0);
    assert(a.get_val(3) == 3.0);
    return 0;
}
