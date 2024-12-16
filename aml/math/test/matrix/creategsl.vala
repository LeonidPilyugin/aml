using AmlMath;
using Gsl;

public static int main(string[] args)
{
    var m = new Gsl.Matrix(4, 4);
    var a = new AmlMath.Matrix.from_gsl((owned) m);    
    m = new Gsl.Matrix(4, 0);
    try {
        a = new AmlMath.Matrix.from_gsl((owned) m);
        assert_not_reached();
    } catch (MatrixError.SIZE_ERROR e) { }
    m = new Gsl.Matrix(0, 4);
    try {
        a = new AmlMath.Matrix.from_gsl((owned) m);
        assert_not_reached();
    } catch (MatrixError.SIZE_ERROR e) { }
    m = new Gsl.Matrix(0, 0);
    try {
        a = new AmlMath.Matrix.from_gsl((owned) m);
        assert_not_reached();
    } catch (MatrixError.SIZE_ERROR e) { }
    return 0;
}
