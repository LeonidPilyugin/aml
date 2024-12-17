using AmlCore;

public static int main(string[] args)
{
    var a = new DataCollection.empty();    
    var b = new DataCollection.empty();
    a.set_element("el", b);
    try {
        b.set_element("el", a);
    } catch (DataCollectionError.SELF_SET_ERROR e) { }
    return 0;    
}
