using AmlCore;

public static int main(string[] args)
{
    var a = new DataHashTable.empty();    
    assert(!a.has_element("el"));
    try {
        var b = a.get_element("el");
        assert_not_reached();
    } catch (DataCollectionError.ID_ERROR e) { }
    return 0;
}
