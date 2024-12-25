using AmlCore;

public static int main(string[] args)
{
    var a = new DataCollection();
    var b = new DataCollection();
    var c = new DataCollection();
    a.set_element("b", b);
    try {
        c.set_element("b", b);
        assert_not_reached();
    } catch (DataObjectError.DOUBLE_ASSIGN_ERROR e) { };
    return 0;
}
