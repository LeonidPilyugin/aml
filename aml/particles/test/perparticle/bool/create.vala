using AmlParticles;

public static int main(string[] args)
{
    var p = new BoolPerParticleProperty();
    assert(p.get_size() == 0);

    bool[] arr = { true, false, true };
    p = new BoolPerParticleProperty.from_array(arr);
    var brr = p.get_arr();

    for (int i = 0; i < arr.length; i++)
        assert(arr[i] == brr[i]);

    brr[0] = !arr[0];

    assert(p.get_val(0) != brr[0]);

    return 0;
}
