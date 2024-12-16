using AmlCore;

public static int main(string[] args)
{
    var a = new StrSepIdParser("abc");
    assert(a.get_separator() == "abc");
    assert(a.next_token("FabcDabcE") == "F");
    assert(a.drop_next_token("FabcDabcE") == "DabcE");
    assert(!a.is_last_token("FabcDabcE"));
    assert(a.is_last_token("F"));
    assert(a.is_last_token(""));
    assert(a.next_token("abc") == "");
    return 0;    
}
