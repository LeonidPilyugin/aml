using AmlCore;

public static int main(string[] args)
{
    var a = new DataCollection();    
    try {
        a.set_element("el", a);
        assert_not_reached();
    } catch (DataCollectionError.SELF_SET_ERROR e) { }
    return 0;
}