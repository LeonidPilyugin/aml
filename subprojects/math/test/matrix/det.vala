using AmlMath;

public static int main(string[] args)
{
    var a = new Matrix.sized(2, 2);
    a.set_val(0, 0, 1.0);
    a.set_val(1, 1, 1.0);
    a.set_val(0, 1, 0.0);
    a.set_val(1, 0, 0.0);
    assert(a.det() == 1.0);
    return 0;
}
