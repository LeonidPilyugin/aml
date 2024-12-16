using AmlMath;
using Gsl;

public static int main(string[] args)
{
    var m = new Gsl.Vector(4);
    var a = new AmlMath.Vector.from_gsl((owned) m);    
    m = new Gsl.Vector(0);
    try {
        a = new AmlMath.Vector.from_gsl((owned) m);
        assert_not_reached();
    } catch (VectorError.SIZE_ERROR e) { }
    return 0;
}
