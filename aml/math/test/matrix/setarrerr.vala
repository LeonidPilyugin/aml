using AmlMath;

public static int main(string[] args)
{
    var a = new Matrix.sized(3, 4);    
    double[] arr;
    try {
        arr = new double[11];
        a.set_arr(arr);
        assert_not_reached();
    } catch (MatrixError.VALUE_ERROR e) { }
    try {
        arr = new double[11];
        a.set_arr(arr);
        assert_not_reached();
    } catch (MatrixError.VALUE_ERROR e) { }
    return 0;    
}
