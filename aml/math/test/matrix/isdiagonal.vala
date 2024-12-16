using AmlMath;

public static int main(string[] args)
{
    Matrix a;
    double[] arr2x2 = { 1.0, 0.0, 0.0, 1.0 };
    double[] arr2x3 = { 1.0, 0.0, 0.0, 0.0, 1.0, 0.0 };
    double[] arr3x2 = { 1.0, 0.0, 0.0, 1.0, 0.0, 0.0 };

    a = new Matrix.from_array(arr2x2, 2);
    assert(a.is_diagonal());
    a.set_val(0, 0, -3.0);
    assert(a.is_diagonal());
    a.set_val(1, 0, -3.0);
    assert(!a.is_diagonal());

    a = new Matrix.from_array(arr2x3, 2);
    assert(a.is_diagonal());
    a.set_val(0, 0, -3.0);
    assert(a.is_diagonal());
    a.set_val(1, 2, -3.0);
    assert(!a.is_diagonal());

    a = new Matrix.from_array(arr3x2, 3);
    assert(a.is_diagonal());
    a.set_val(0, 0, -3.0);
    assert(a.is_diagonal());
    a.set_val(2, 1, -3.0);
    assert(!a.is_diagonal());

    return 0;
}
