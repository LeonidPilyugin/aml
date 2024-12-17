using AmlCore;

public static int main(string[] args)
{
    var a = new DataHashTable.empty();    
    var b = new DataHashTable.empty();
    var c = new DataHashTable.empty();
    a.set_element("b", b);
    try {
        c.set_element("b", b);
        assert_not_reached();
    } catch (DataObjectError.DOUBLE_ASSIGN_ERROR e) { };
    return 0;    
}
