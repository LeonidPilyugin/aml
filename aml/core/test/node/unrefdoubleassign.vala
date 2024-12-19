using AmlCore;

public static int main(string[] args)
{
    var b = new DataCollection.empty();
    var c = new DataCollection.empty();

    {
        var a = new DataCollection.empty();
        a.set_element("b", b);
    }

    c.set_element("b", b);
    return 0;
}
