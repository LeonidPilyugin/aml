using AmlCore;

public static int main(string[] args)
{
    var b = new DataCollection();
    var c = new DataCollection();

    {
        var a = new DataCollection();
        a.set_element("b", b);
    }

    c.set_element("b", b);
    return 0;
}
