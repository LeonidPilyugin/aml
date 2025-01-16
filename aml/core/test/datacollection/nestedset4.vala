using AmlCore;

class Dummy : DataObject
{
    public override DataObject copy()
    {
        return new Dummy();
    }
}

public static int main(string[] args)
{
    var a = new DataCollection();
    var b = new Dummy();
    var c = new Dummy();
    a.set_element("el.1", b);
    try
    {
        a.set_element("el.1.2", c);
        assert_not_reached();
    } catch (DataCollectionError.ID_ERROR e) { }
    return 0;
}
