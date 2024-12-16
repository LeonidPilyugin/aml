using AmlCore;

public static int main(string[] args)
{
    var a = new DataHashTable.empty();    
    var b = new DataHashTable.empty();    
    var c = new DataHashTable.empty();    
    a.set_element("el", b);
    b.set_element("el", c);
    assert(a.contains(c));
    return 0;
}
