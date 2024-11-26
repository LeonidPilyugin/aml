namespace Aml
{
    public class LammpsTextDumpParser : Parser
    {
        public LammpsTextDumpParser.create() { }

        public override void compose_frame(Frame frame, DataOutputStream output) throws IOError, ParserError
        {
            if (!(frame.box is ParallelepipedBox))
                throw new ParserError.NOT_IMPLEMENTED("Only parallelepiped boxes are implemented");
            var box = (ParallelepipedBox) frame.box;

            // write time
            if (frame.has_prop("time"))
            {
                output.put_string("ITEM: TIME\n");
                output.put_string("%lf\n".printf(frame.get_prop("time").data.get_double()));
            }
            // write timestep
            if (frame.has_prop("timestep"))
            {
                output.put_string("ITEM: TIMESTEP\n");
                output.put_string(frame.get_prop("timestep").data.get_uint64().to_string() + "\n");
            }
            // write number of atoms
            output.put_string("ITEM: NUMBER OF ATOMS\n");
            output.put_string(frame.atoms.get_size().to_string() + "\n");
            // write box
            var edge = box.get_edge();
            var origin = box.get_origin();
            var boundaries = box.get_boundaries();
            output.put_string("ITEM: BOX BOUNDS ");
            if (!edge.is_diagonal())
                output.put_string("abc origin ");
            for (uint8 i = 0; i < 3; i++)
                output.put_string(boundaries[i] ? "pp " : "ff ");
            output.put_string("\n");
            if (edge.is_diagonal())
            {
                for (uint8 i = 0; i < 3; i++)
                {
                    output.put_string("%lf %lf\n".printf(origin.get_val(i), origin.get_val(i) + edge.get_val(i, i)));
                }
            } else
            {
                for (uint8 i = 0; i < 3; i++)
                {
                    for (uint8 j = 0; j < 3; j++)
                    {
                        output.put_string("%lf ".printf(edge.get_val(i, j)));
                    }
                    output.put_string("%lf\n".printf(origin.get_val(i)));
                }
            }
            // write atoms
            var ids = frame.atoms.get_ids();
            var props = new Array<StringPerAtomProperty>();
            output.put_string("ITEM: ATOMS ");
            uint k = 0;
            foreach (unowned var id in ids)
            {
                props.append_val(StringPerAtomProperty.create_from(frame.atoms.get_prop(id)));
                output.put_string("%s ".printf(id));
            }
            output.put_string("\n");

            for (uint i = 0; i < frame.atoms.get_size(); i++)
            {
                for (uint j = 0; j < ids.length(); j++)
                {
                    output.put_string(props.index(j).get_val(i));
                }
                output.put_string("\n");
            }
        }

        public override List<Frame> parse_frames(DataInputStream input_stream) throws IOError, ParserError
        {
            // modified https://gitlab.com/stuko/ovito
            var input = new InputHelper(input_stream);
            Box? box = null;
            Atoms? atoms = null;
            Frame? frame = null;
            var properties = new HashTable<string, FrameProperty>(str_hash, str_equal);
            var result = new List<Frame>();
            bool is_frame_finished = false; // true if frame is successfully parsed
            bool ok = true; // used inside sections
            string[] temp_split; // temporary array for result of string.split()
            double[,] px; // temporary matrix holder
            bool[] bx;

            while (input.read_line() != null)
            {
                is_frame_finished = false;
                ok = true;
                if (input.line == "ITEM: TIMESTEP")
                {
                    // parse timestep
                    if (properties.contains("timestep"))
                        throw new ParserError.PARSE_ERROR("Line %u: timestep is already set".printf(input.line_n));

                    if (input.read_line() == null) break;

                    uint64 timestep;
                    if (!uint64.try_parse(input.line, out timestep))
                        throw new ParserError.PARSE_ERROR("Line %u: invalid timestep value".printf(input.line_n));

                    var val = Value(typeof(uint64));
                    val.set_uint64(timestep);
                    properties.insert("timestep", new FrameProperty.create(val));
                } else if (input.line == "ITEM: TIME")
                {
                    // parse time
                    if (!properties.contains("time"))
                        throw new ParserError.PARSE_ERROR("Line %u: time is already set".printf(input.line_n));

                    if (input.read_line() == null) break;

                    double time;
                    if (!double.try_parse(input.line, out time))
                        throw new ParserError.PARSE_ERROR("Line %u: invalid time value".printf(input.line_n));

                    
                    var val = Value(typeof(double));
                    val.set_double(time);
                    properties.insert("time", new FrameProperty.create(val));
                } else if (input.line.length > 34 && input.line[:34] == "ITEM: BOX BOUNDS xy xz yz xx yy zz")
                {
                    // parse box
                    if (box != null)
                        throw new ParserError.PARSE_ERROR("Line %u: box is already set".printf(input.line_n));

                    temp_split = input.line.split_set(" \t");
                    if (temp_split.length != 12)
                        throw new ParserError.PARSE_ERROR("Line %u: invalid number of boundary conditions".printf(input.line_n));

                    temp_split = temp_split[9:];

                    bx = new bool[3];
                    for (uint8 i = 0; i < 3; i++)
                        bx[i] = temp_split[i] == "pp";

                    px = new double[3,3];
                    for (uint8 i = 0; i < 3; i++)
                    {
                        if (input.read_line() == null) { ok = false; break; }
                        temp_split = input.line.split_set(" \t");
                        if (temp_split.length != 4)
                            throw new ParserError.PARSE_ERROR("Line %u: invalid number of boundary parameters".printf(input.line_n));
                        for (uint8 j = 0; j < 3; j++)
                            if (!double.try_parse(temp_split[j], out px[i,j]))
                                throw new ParserError.PARSE_ERROR("Line %u: cannot parse boundaries".printf(input.line_n));
                    } if (!ok) break;

                    px[0,0] -= double.min(double.min(double.min(px[0,2], px[1,2]), px[0,2] + px[1,2]), 0.0);
                    px[1,0] -= double.max(double.max(double.max(px[0,2], px[0,1]), px[0,2] + px[1,2]), 0.0);
                    px[0,1] -= double.min(px[2,2], 0.0);
                    px[1,1] -= double.max(px[2,2], 0.0);

                    var edge = new Matrix.sized(3, 3);

                    edge.set_val(0, 0, px[1,0] - px[0,0]);
                    edge.set_val(1, 0, px[0,2]);
                    edge.set_val(1, 1, px[1,1] - px[0,1]);
                    edge.set_val(2, 0, px[1,2]);
                    edge.set_val(2, 1, px[2,2]);
                    edge.set_val(2, 2, px[1,2] - px[0,2]);

                    var origin = new Vector.sized(3);

                    for (uint8 i = 0; i < 3; i++)
                        origin.set_val(i, px[0,i]);

                    try
                    {
                        box = new ParallelepipedBox.create(edge, origin, bx);
                    } catch (ParallelepipedBoxError e)
                    {
                        throw new ParserError.DATA_ERROR("Invalid simulation box data");
                    }
                } else if (input.line.length > 27 && input.line[:27] == "ITEM: BOX BOUNDS abc origin") {
                    // parse box
                    if (box != null)
                        throw new ParserError.PARSE_ERROR("Line %u: box is already set".printf(input.line_n));

                    temp_split = input.line.split_set(" \t");
                    if (temp_split.length != 8)
                        throw new ParserError.PARSE_ERROR("Line %u: invalid number of boundary conditions".printf(input.line_n));
                    temp_split = temp_split[5:];

                    bx = new bool[3];
                    for (uint8 i = 0; i < 3; i++)
                        bx[i] = temp_split[i] == "pp";

                    px = new double[3,4];
                    for (uint8 i = 0; i < 3; i++)
                    {
                        if (input.read_line() == null) { ok = false; break; }
                        temp_split = input.line.split_set(" \t");
                        if (temp_split.length != 4)
                            throw new ParserError.PARSE_ERROR("Line %u: invalid number of boundary parameters".printf(input.line_n));
                        for (uint8 j = 0; j < 4; j++)
                            if (!double.try_parse(temp_split[j], out px[i,j]))
                                throw new ParserError.PARSE_ERROR("Line %u: cannot parse boundaries".printf(input.line_n));
                    } if (!ok) break;

                    var origin = new Vector.sized(3);
                    var edge = new Matrix.sized(3, 3);
                    for (uint8 i = 0; i < 3; i++)
                    {
                        origin.set_val(i, px[i,3]);
                        for (uint8 j = 0; j < 3; j++)
                            edge.set_val(i, j, px[i,j]);
                    }

                    try
                    {
                        box = new ParallelepipedBox.create(edge, origin, bx);
                    } catch (ParallelepipedBoxError e)
                    {
                        throw new ParserError.DATA_ERROR("Invalid simulation box data");
                    }
                } else if (input.line.length > 15 && input.line[:16] == "ITEM: BOX BOUNDS") {
                    // parse box
                    if (box != null)
                        throw new ParserError.PARSE_ERROR("Line %u: box is already set".printf(input.line_n));

                    temp_split = input.line.split_set(" \t");
                    if (temp_split.length != 6)
                        throw new ParserError.PARSE_ERROR("Line %u: invalid number of boundary conditions".printf(input.line_n));
                    temp_split = temp_split[3:];

                    bx = new bool[3];

                    for (uint8 i = 0; i < 3; i++)
                        bx[i] = temp_split[i] == "pp";

                    px = new double[3,2];
                    for (uint8 i = 0; i < 3; i++)
                    {
                        if (input.read_line() == null) { ok = false; break; }
                        temp_split = input.line.split_set(" \t");
                        if (temp_split.length != 2)
                            throw new ParserError.PARSE_ERROR("Line %u: invalid bounds number".printf(input.line_n));
                        for (uint8 j = 0; j < 2; j++)
                            if (!double.try_parse(temp_split[j], out px[i,j]))
                                throw new ParserError.PARSE_ERROR("Line %u: cannot parse boundaries".printf(input.line_n));
                    } if (!ok) break;

                    var edge = new Matrix.sized(3, 3);
                    var origin = new Vector.sized(3);
                    for (uint8 i = 0; i < 3; i++)
                    {
                        edge.set_val(i, i, px[i,1] - px[i,0]);
                        origin.set_val(i, px[i,0]);
                    }

                    try
                    {
                        box = new ParallelepipedBox.create(edge, origin, bx);
                    } catch (ParallelepipedBoxError e)
                    {
                        throw new ParserError.DATA_ERROR("Invalid simulation box data");
                    }
                } else if (input.line == "ITEM: NUMBER OF ATOMS")
                {
                    if (atoms != null)
                        throw new ParserError.PARSE_ERROR("Line %u: number of atoms is already set".printf(input.line_n));
                    if (input.read_line() == null) break;
                    uint temp_an;
                    if (!uint.try_parse(input.line, out temp_an))
                        throw new ParserError.PARSE_ERROR("Line %u: cannot parse number of atoms".printf(input.line_n));
                    atoms = new Atoms.sized(temp_an);
                } else if (input.line.length > 10 && input.line[:11] == "ITEM: ATOMS")
                {
                    // parse atoms and construct frame
                    if (atoms == null)
                        throw new ParserError.PARSE_ERROR("Line %u: number of atoms is not set".printf(input.line_n));
                    // get property names
                    temp_split = input.line.split_set(" \t");
                    if (temp_split.length < 3)
                        throw new ParserError.PARSE_ERROR("Line %u: no per-atom property ids".printf(input.line_n));

                    string[] keys = temp_split[2:];

                    for (uint i = 0; i < keys.length; i++)
                        for (uint j = i + 1; j < keys.length; j++)
                            if (keys[i] == keys[j])
                                throw new ParserError.PARSE_ERROR("Line %u: repeating property %s".printf(input.line_n, keys[i]));

                    // load first properties
                    if (input.read_line() == null) break;

                    StringPerAtomProperty[] props = new StringPerAtomProperty[keys.length];
                    temp_split = input.line.split_set(" \t");
                    for (uint i = 0; i < keys.length; i++)
                    {
                        props[i] = new StringPerAtomProperty.empty();
                        props[i].insert_last(temp_split[i]);
                    }

                    // load other properties
                    for (uint i = 1; i < atoms.get_size(); i++)
                    {
                        if (input.read_line() == null) { ok = false; break; }
                        temp_split = input.line.split_set(" \t");
                        if (temp_split.length != keys.length)
                            throw new ParserError.PARSE_ERROR("Line %u: invalid property number".printf(input.line_n));
                        for (uint j = 0; j < keys.length; j++)
                        {
                            props[j].insert_last(temp_split[j]);
                        }
                    } if (!ok) break;

                    for (uint i = 0; i < keys.length; i++)
                        atoms.set_prop(keys[i], props[i]);

                    // construct frame
                    frame = new Frame.create(box, atoms);
                    foreach (unowned var k in properties.get_keys())
                    {
                        frame.set_prop(k, properties.take(k));
                    }
                    is_frame_finished = true;
                    result.append(frame);
                    frame = null;
                    box = null;
                    atoms = null;
                } else if (input.line.length > 4 && input.line[:5] == "ITEM:")
                {
                    // skip unknown sections
                    while (input.read_line() != null && (input.line.length < 5 || input.line[:5] != "ITEM:"));
                } else
                {
                    throw new ParserError.PARSE_ERROR("Line %u: parsing error".printf(input.line_n));
                }
            }
            
            if (!is_frame_finished)
            {
                throw new ParserError.PARSE_ERROR("Line %u: unexpected EOF".printf(input.line_n));
            }

            return result;
        }

    }
}
