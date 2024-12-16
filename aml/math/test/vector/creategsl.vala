using AmlMath;
using Gsl;

public static int main(string[] args)
{
    var m = new Gsl.Vector(4);
    var a = new AmlMath.Vector.from_gsl((owned) m);    
    return 0;
}
