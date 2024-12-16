using AmlCore;

public static int main(string[] args)
{
    var a = new DataHashTable.empty();    
    var b = new DataHashTable.empty();
    var c = new DataHashTable.empty();
    assert(!a.has_element("el"));
    a.set_element("el", b);
    assert(a.has_element("el"));
    a.set_element("el", c);
    assert(a.has_element("el"));
    return 0;    
}
