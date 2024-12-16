using AmlCore;

public static int main(string[] args)
{
    var a = new DataHashTable.empty();    
    var b = new DataHashTable.empty();    
    var c = new DataHashTable.empty();    
    a.set_element("el", b);
    b.set_element("el", c);
    try {
        c.set_element("el", a);
        assert_not_reached();
    } catch (DataCollectionError.SELF_SET_ERROR e) {
        return 0;
    }
    assert_not_reached();
    return 1;
}
