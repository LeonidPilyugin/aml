using AmlMath;

public static int main(string[] args)
{
    var a = new Matrix.sized(3, 4);    
    try {
        a.get_val(4, 5);
        assert_not_reached();
    } catch (MatrixError.INDEX_ERROR e) { }
    try {
        a.get_val(3, 4);
        assert_not_reached();
    } catch (MatrixError.INDEX_ERROR e) { }
    try {
        a.get_val(3, 3);
        assert_not_reached();
    } catch (MatrixError.INDEX_ERROR e) { }
    try {
        a.get_val(2, 5);
        assert_not_reached();
    } catch (MatrixError.INDEX_ERROR e) { }
    try {
        a.set_val(4, 5, 0.0);
        assert_not_reached();
    } catch (MatrixError.INDEX_ERROR e) { }
    try {
        a.set_val(3, 4, 0.0);
        assert_not_reached();
    } catch (MatrixError.INDEX_ERROR e) { }
    try {
        a.set_val(3, 3, 0.0);
        assert_not_reached();
    } catch (MatrixError.INDEX_ERROR e) { }
    try {
        a.set_val(2, 5, 0.0);
        assert_not_reached();
    } catch (MatrixError.INDEX_ERROR e) { }
    return 0;    
}
