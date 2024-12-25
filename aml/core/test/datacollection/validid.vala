using AmlCore;

public static int main(string[] args)
{
    var a = new DataCollection();
    assert(a.is_valid_id("a.b.c.d"));
    assert(a.is_valid_id("el"));
    assert(!a.is_valid_id("\nel"));
    assert(!a.is_valid_id("el\n"));
    assert(!a.is_valid_id(""));
    return 0;    
}
