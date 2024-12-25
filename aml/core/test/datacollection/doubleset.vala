using AmlCore;

public static int main(string[] args)
{
    var a = new DataCollection();
    var b = new DataCollection();
    var c = new DataCollection();
    assert(!a.has_element("el"));
    a.set_element("el", b);
    assert(a.has_element("el"));
    a.set_element("el", c);
    assert(a.has_element("el"));
    return 0;    
}
