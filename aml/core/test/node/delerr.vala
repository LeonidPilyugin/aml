using AmlCore;

public static int main(string[] args)
{
    var a = new DataCollection.empty();
    assert(!a.has_element("el"));
    try {
        a.del_element("el");
        assert_not_reached();
    } catch (DataCollectionError.ID_ERROR e) { }
    return 0;
}
