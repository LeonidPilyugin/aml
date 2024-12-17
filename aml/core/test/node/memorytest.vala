using AmlCore;

class VeryBigObject : DataObject
{
    public int buff[1000 * 1000];

    public override DataObject copy()
    {
        return new VeryBigObject();
    }
}

public static int main(string[] args)
{
    for (long i = 0; i < 1000 * 1000; i++) {
        var a = new DataCollection.empty();
        var b = new DataCollection.empty();
        var c = new VeryBigObject();
        assert(!a.has_element("el"));
        a.set_element("el", b);
        assert(a.has_element("el"));
        a.set_element("el", c);
        assert(a.has_element("el"));
    }
    return 0;    
}
