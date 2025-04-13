using AmlMath;

public static int main(string[] args)
{
    var arr = new double[16];
    var a = new Vector.from_array(arr);    
    assert(a.get_size() == 16);
    return 0;
}
