
namespace Aml
{
    static Regex alphanum;

    static bool match_func(string id)
    {
        var temp = alphanum.split(id);
        return temp.length == 2 && "" == temp[0] && "" == temp[1];
    }

    public static int main(string[] args)
    {
        alphanum = new Regex("[1-zA-Z0-9]+");
        assert(match_func("abcd"));
        assert(!match_func("ab\ncd"));
        assert(!match_func("\nabcd"));
        assert(!match_func("abcd\n"));
        assert(match_func("abcd123"));
        assert(match_func("ab7cd123"));
        assert(match_func("715"));
        assert(!match_func("abcd.efg"));
        assert(!match_func(""));
        assert(!match_func(" "));
        assert(!match_func("abc deg"));

        return 0;    
    }
}
