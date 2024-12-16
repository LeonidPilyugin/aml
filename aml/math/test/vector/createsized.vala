using AmlMath;

public static int main(string[] args)
{
    var a = new Vector.sized(4);    
    try {
        var b = new Vector.sized(0);    
        assert_not_reached();
    } catch (VectorError.SIZE_ERROR e) { }
    
    return 0;    
}
