using AmlCore;

public static int main(string[] args)
{
    var a = new DataCollection();
    var b = new DataCollection();
    var c = new DataCollection();
    a.set_element("el", b);
    b.set_element("el", c);
    DataCollection d = (DataCollection) a.get_element("el");
    assert(d.get_element("el") == c);
    return 0;
}
