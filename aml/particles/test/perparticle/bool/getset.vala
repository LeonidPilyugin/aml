using AmlParticles;

public static int main(string[] args)
{
    var p = new BoolPerParticleProperty();
    assert(p.get_size() == 0);

    bool[] arr = { true, false, true };
    p = new BoolPerParticleProperty.from_array(arr);
    assert(p.get_size() == arr.length);

    for (int i = 0; i < arr.length; i++)
        assert(arr[i] == p.get_val(i));
    
    for (int i = 0; i < arr.length; i++)
        arr[i] = !arr[i];

    p.set_arr(arr);

    for (int i = 0; i < arr.length; i++)
        assert(arr[i] == p.get_val(i));
    
    for (int i = 0; i < arr.length; i++)
        arr[i] = !arr[i];
    for (int i = 0; i < arr.length; i++)
        p.set_val(i, arr[i]);
    for (int i = 0; i < arr.length; i++)
        assert(p.get_val(i) == arr[i]);

    return 0;
}
