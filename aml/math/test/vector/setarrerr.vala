using AmlMath;

public static int main(string[] args)
{
    var a = new Vector.sized(4);    
    double[] arr;
    try {
        arr = new double[3];
        a.set_arr(arr);
        assert_not_reached();
    } catch (VectorError.VALUE_ERROR e) { }
    try {
        arr = new double[5];
        a.set_arr(arr);
        assert_not_reached();
    } catch (VectorError.VALUE_ERROR e) { }
    return 0;    
}
