using AmlMath;

public static int main(string[] args)
{
    var arr = new double[16];
    var a = new Matrix.from_array(arr, 1);    
    assert(a.get_rows() == 1 && a.get_columns() == 16);
    a = new Matrix.from_array(arr, 2);    
    assert(a.get_rows() == 2 && a.get_columns() == 8);
    a = new Matrix.from_array(arr, 4);    
    assert(a.get_rows() == 4 && a.get_columns() == 4);
    a = new Matrix.from_array(arr, 8);    
    assert(a.get_rows() == 8 && a.get_columns() == 2);
    a = new Matrix.from_array(arr, 16);    
    assert(a.get_rows() == 16 && a.get_columns() == 1);

    arr = new double[17];
    try {
        a = new Matrix.from_array(arr, 2);
        assert_not_reached();
    } catch (MatrixError.SIZE_ERROR e) { }
    return 0;
}
