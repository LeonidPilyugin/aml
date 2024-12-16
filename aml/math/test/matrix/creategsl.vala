using AmlMath;
using Gsl;

public static int main(string[] args)
{
    var m = new Gsl.Matrix(4, 4);
    var a = new AmlMath.Matrix.from_gsl((owned) m);    
    return 0;
}
