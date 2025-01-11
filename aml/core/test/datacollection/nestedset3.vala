using AmlCore;

public static int main(string[] args)
{
    var a = new DataCollection();
    var b = new DataCollection();
    var c = new DataCollection();
    a.set_element("el.1", b);
    a.set_element("el.2", c);
    assert(a.has_element("el.1") && a.has_element("el.2"));
    return 0;
}
