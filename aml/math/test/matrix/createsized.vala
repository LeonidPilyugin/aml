using AmlMath;

public static int main(string[] args)
{
    var a = new Matrix.sized(4, 4);    
    try {
        var b = new Matrix.sized(0, 0);    
        assert_not_reached();
    } catch (MatrixError.SIZE_ERROR e) { }
    try {
        var b = new Matrix.sized(4, 0);    
        assert_not_reached();
    } catch (MatrixError.SIZE_ERROR e) { }
    try {
        var b = new Matrix.sized(0, 4);    
        assert_not_reached();
    } catch (MatrixError.SIZE_ERROR e) { }
    
    return 0;    
}
