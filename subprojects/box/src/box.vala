using AmlCore;
using AmlMath;

namespace AmlBox
{
    public abstract class Box : DataObject
    {
        public abstract double get_volume();
        public abstract bool contains_point(Vector3 point);
        public abstract void map_periodic(Vector3 point, Vector3 map, Vector3 result);
    }
}
