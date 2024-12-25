using AmlCore;

public static int main(string[] args)
{
    var a = new DataCollection();
    var b = new DataCollection();
    a.set_element("el.el", b);
    DataCollection d = (DataCollection) a.get_element("el.el");
    assert(d == b);
    a.del_element("el.el");
    return 0;
}
