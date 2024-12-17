using AmlCore;

public static int main(string[] args)
{
    var a = new DataCollection.empty();    
    var b = new DataCollection.empty();
    assert(!a.has_element("el"));
    a.set_element("el", b);
    assert(a.has_element("el"));
    a.del_element("el");
    assert(!a.has_element("el"));
    a.set_element("el", b);
    assert(a.has_element("el"));
    return 0;    
}
