using AmlCore;

public static int main(string[] args)
{
    var a = new DataCollection.empty();
    var b = new DataCollection.empty();
    var c = new DataCollection.empty();
    a.set_element("el", b);
    b.set_element("el", c);
    DataCollection d = (DataCollection) a.get_element("el");
    assert(d.get_element("el") == c);
    return 0;
}
