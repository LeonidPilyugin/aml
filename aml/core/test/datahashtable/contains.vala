using AmlCore;

public static int main(string[] args)
{
    var a = new DataHashTable.empty();    
    var b = new DataHashTable.empty();    
    a.set_element("el", b);
    assert(a.contains(b));
    return 0;
}
