using AmlCore;

public static int main(string[] args)
{
    var a = new DataHashTable.empty();    
    var b = new DataHashTable.empty();    
    try {
        a.set_element("f.g.s.f.d.s", b);
        assert_not_reached();
    } catch (DataCollectionError.ID_ERROR e) {
        return 0;
    }
    assert_not_reached();
    return 1;
}
