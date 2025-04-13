using AmlMath;

public static int main(string[] args)
{
    var a = new Vector.sized(4);    
    a.get_val(3);
    try {
        a.get_val(4);
        assert_not_reached();
    } catch (VectorError.INDEX_ERROR e) { }
    try {
        a.set_val(4, 0.0);
        assert_not_reached();
    } catch (VectorError.INDEX_ERROR e) { }
    return 0;    
}
