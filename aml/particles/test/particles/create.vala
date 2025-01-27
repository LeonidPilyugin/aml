using AmlParticles;

public static int main(string[] args)
{
    uint size = 10;
    Particles p;
    p = new Particles();
    assert(p.get_size() == 0);
    p = new Particles.sized(size);
    assert(p.get_size() == size);
    assert(p.get_ids().length() == 0);
    return 0;
}
