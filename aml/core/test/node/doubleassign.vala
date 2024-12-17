using AmlCore;

public static int main(string[] args)
{
    var a = new DataCollection.empty();
    var b = new DataCollection.empty();
    var c = new DataCollection.empty();
    a.set_element("b", b);
    try {
        c.set_element("b", b);
        assert_not_reached();
    } catch (DataObjectError.DOUBLE_ASSIGN_ERROR e) { };
    return 0;
}
