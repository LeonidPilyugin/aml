using AmlCore;

public static int main(string[] args)
{
    var a = new DataHashTable.empty();    
    var b = new DataHashTable.empty();    
    var c = new DataHashTable.empty();    
    a.set_element("el", b);
    a.set_element("el.el", c);
    assert(a.get_element("el.el") == c);
    DataCollection d = (DataCollection) a.get_element("el");
    assert(d.get_element("el") == c);
    a.del_element("el.el");
    assert(!a.contains(c));
    return 0;
}
