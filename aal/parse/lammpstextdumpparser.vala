namespace Aal {
    [CCode (has_target = false)]
    delegate string AddString(PerAtomProperty p, uint i);

    public class LammpsTextDumpParser : Object, IParser {
        public void compose_frame(Frame frame, DataOutputStream output) throws IOError, IParserError {
            if (!(frame.box is ParallelepipedBox))
                throw new IParserError.NOT_IMPLEMENTED("Only parallelepiped boxes are implemented");
            var box = (ParallelepipedBox) frame.box;

            // write time
            if (frame.get_prop("time") != null) {
                output.put_string("ITEM: TIME\n");
                output.put_string("%lf\n".printf(frame.get_prop("time").data.get_double()));
            }
            // write timestep
            if (frame.get_prop("timestep") != null) {
                output.put_string("ITEM: TIMESTEP\n");
                output.put_string("%u\n".printf(frame.get_prop("timestep").data.get_uint()));
            }
            // write number of atoms
            output.put_string("ITEM: NUMBER OF ATOMS\n");
            output.put_string("%u\n".printf(frame.atoms.get_size()));
            // write box
            var edge = box.get_edge();
            var origin = box.get_origin();
            var boundaries = box.get_boundaries();
            output.put_string("ITEM: BOX BOUNDS ");
            if (!edge.is_diagonal())
                output.put_string("abc origin ");
            for (uint8 i = 0; i < 3; i++)
                output.put_string(boundaries.index(i) ? "pp " : "ff ");
            output.put_string("\n");
            if (edge.is_diagonal()) {
                for (uint8 i = 0; i < 3; i++) {
                    output.put_string("%lf %lf\n".printf(origin.get_val(i), origin.get_val(i) + edge.get_val(i, i)));
                }
            } else {
                for (uint8 i = 0; i < 3; i++) {
                    for (uint8 j = 0; j < 3; j++) {
                        output.put_string("%lf ".printf(edge.get_val(i, j)));
                    }
                    output.put_string("%lf\n".printf(origin.get_val(i)));
                }
            }
            // write atoms
            var ids = frame.atoms.get_prop_ids();
            var props = new Array<PerAtomProperty>();
            var funcs = new AddString[ids.length()];
            PerAtomProperty temp_prop;
            output.put_string("ITEM: ATOMS ");
            uint k = 0;
            foreach (unowned var id in ids) {
                temp_prop = frame.atoms.get_prop(id);
                props.append_val(temp_prop);

                if (temp_prop is IntPerAtomProperty) {
                    funcs[k++] = (p, i) => "%d ".printf(((IntPerAtomProperty) p).get_val(i));
                } else if (temp_prop is DoublePerAtomProperty) {
                    funcs[k++] = (p, i) => "%lf ".printf(((DoublePerAtomProperty) p).get_val(i));
                } else {
                    funcs[k++] = (p, i) => "%s ".printf(((StringPerAtomProperty) p).get_val(i));
                }
                
                output.put_string("%s ".printf(id));
            }
            output.put_string("\n");

            for (uint i = 0; i < frame.atoms.get_size(); i++) {
                for (uint j = 0; j < ids.length(); j++) {
                    output.put_string(funcs[j](props.index(j), i));
                }
                output.put_string("\n");
            }
        }

        public  void compose_frames(List<Frame> frames, DataOutputStream output) throws IOError, IParserError {
            foreach (unowned Frame fr in frames)
                this.compose_frame(fr, output);
        }

        public List<Frame> parse_frames(DataInputStream input_stream) throws IOError, IParserError {
            // modified https://gitlab.com/stuko/ovito
            
            var input = new InputHelper(input_stream);
            var frame_data = new FrameInitData();
            var result = new List<Frame>();
            Frame? frame = null;
            bool is_frame_finished = false; // true if frame is successfully parsed
            bool ok = true; // used inside sections
            bool is_box_set = false;
            string[] temp_split; // temporary array for result of string.split()
            double[,] px; // temporary matrix holder

            while (input.read_line() != null) {
                is_frame_finished = false;
                ok = true;
                if (input.line == "ITEM: TIMESTEP") {
                    // parse timestep
                    if (frame_data.properties.get_prop("timestep") != null)
                        throw new IParserError.PARSE_ERROR("Line %u: timestep is already set".printf(input.line_n));

                    if (input.read_line() == null) break;

                    uint timestep;
                    if (!uint.try_parse(input.line, out timestep))
                        throw new IParserError.PARSE_ERROR("Line %u: invalid timestep value".printf(input.line_n));

                    var frame_prop_data = new FramePropertyInitData("timestep");
                    frame_prop_data.data = Value(typeof(uint));
                    frame_prop_data.data.set_uint(timestep);
                    frame_data.properties.append(new FrameProperty(frame_prop_data));
                } else if (input.line == "ITEM: TIME") {
                    // parse time
                    if (frame_data.properties.get_prop("time") != null)
                        throw new IParserError.PARSE_ERROR("Line %u: time is already set".printf(input.line_n));

                    if (input.read_line() == null) break;

                    double time;
                    if (!double.try_parse(input.line, out time))
                        throw new IParserError.PARSE_ERROR("Line %u: invalid time value".printf(input.line_n));

                    var frame_prop_data = new FramePropertyInitData("time");
                    frame_prop_data.data = Value(typeof(double));
                    frame_prop_data.data.set_double(time);
                    frame_data.properties.append(new FrameProperty(frame_prop_data));
                } else if (input.line.length > 34 && input.line[:34] == "ITEM: BOX BOUNDS xy xz yz xx yy zz") {
                    // parse box
                    if (is_box_set)
                        throw new IParserError.PARSE_ERROR("Line %u: box is already set".printf(input.line_n));

                    temp_split = input.line.split_set(" \t");
                    if (temp_split.length != 12)
                        throw new IParserError.PARSE_ERROR("Line %u: invalid number of boundary conditions".printf(input.line_n));

                    temp_split = temp_split[9:];

                    var box_data = new ParallelepipedBoxInitData();

                    for (uint8 i = 0; i < 3; i++)
                        box_data.boundaries.insert_val(i, temp_split[i] == "pp" ? BoolHelper.T : BoolHelper.F);

                    px = new double[3,3];
                    for (uint8 i = 0; i < 3; i++) {
                        if (input.read_line() == null) { ok = false; break; }
                        temp_split = input.line.split_set(" \t");
                        if (temp_split.length != 4)
                            throw new IParserError.PARSE_ERROR("Line %u: invalid number of boundary parameters".printf(input.line_n));
                        for (uint8 j = 0; j < 3; j++)
                            if (!double.try_parse(temp_split[j], out px[i,j]))
                                throw new IParserError.PARSE_ERROR("Line %u: cannot parse boundaries".printf(input.line_n));
                    } if (!ok) break;

                    px[0,0] -= double.min(double.min(double.min(px[0,2], px[1,2]), px[0,2] + px[1,2]), 0.0);
                    px[1,0] -= double.max(double.max(double.max(px[0,2], px[0,1]), px[0,2] + px[1,2]), 0.0);
                    px[0,1] -= double.min(px[2,2], 0.0);
                    px[1,1] -= double.max(px[2,2], 0.0);

                    box_data.edge.set_val(0, 0, px[1,0] - px[0,0]);
                    box_data.edge.set_val(1, 0, px[0,2]);
                    box_data.edge.set_val(1, 1, px[1,1] - px[0,1]);
                    box_data.edge.set_val(2, 0, px[1,2]);
                    box_data.edge.set_val(2, 1, px[2,2]);
                    box_data.edge.set_val(2, 2, px[1,2] - px[0,2]);

                    for (uint8 i = 0; i < 3; i++)
                        box_data.origin.set_val(i, px[0,i]);

                    try {
                        frame_data.box = new ParallelepipedBox(box_data);
                    } catch (ParallelepipedBoxError e) {
                        throw new IParserError.DATA_ERROR("Invalid simulation box data");
                    }
                } else if (input.line.length > 27 && input.line[:27] == "ITEM: BOX BOUNDS abc origin") {
                    // parse box
                    if (is_box_set)
                        throw new IParserError.PARSE_ERROR("Line %u: box is already set".printf(input.line_n));

                    temp_split = input.line.split_set(" \t");
                    if (temp_split.length != 8)
                        throw new IParserError.PARSE_ERROR("Line %u: invalid number of boundary conditions".printf(input.line_n));
                    temp_split = temp_split[5:];

                    var box_data = new ParallelepipedBoxInitData();

                    for (uint8 i = 0; i < 3; i++)
                        box_data.boundaries.insert_val(i, temp_split[i] == "pp" ? BoolHelper.T : BoolHelper.F);

                    px = new double[3,4];
                    for (uint8 i = 0; i < 3; i++) {
                        if (input.read_line() == null) { ok = false; break; }
                        temp_split = input.line.split_set(" \t");
                        if (temp_split.length != 4)
                            throw new IParserError.PARSE_ERROR("Line %u: invalid number of boundary parameters".printf(input.line_n));
                        for (uint8 j = 0; j < 4; j++)
                            if (!double.try_parse(temp_split[j], out px[i,j]))
                                throw new IParserError.PARSE_ERROR("Line %u: cannot parse boundaries".printf(input.line_n));
                    } if (!ok) break;

                    for (uint8 i = 0; i < 3; i++) {
                        box_data.origin.set_val(i, px[i,3]);
                        for (uint8 j = 0; j < 3; j++)
                            box_data.edge.set_val(i, j, px[i,j]);
                    }

                    try {
                        frame_data.box = new ParallelepipedBox(box_data);
                    } catch (ParallelepipedBoxError e) {
                        throw new IParserError.DATA_ERROR("Invalid simulation box data");
                    }
                } else if (input.line.length > 15 && input.line[:16] == "ITEM: BOX BOUNDS") {
                    // parse box
                    if (is_box_set)
                        throw new IParserError.PARSE_ERROR("Line %u: box is already set".printf(input.line_n));

                    temp_split = input.line.split_set(" \t");
                    if (temp_split.length != 6)
                        throw new IParserError.PARSE_ERROR("Line %u: invalid number of boundary conditions".printf(input.line_n));
                    temp_split = temp_split[3:];

                    var box_data = new ParallelepipedBoxInitData();

                    for (uint8 i = 0; i < 3; i++)
                        box_data.boundaries.insert_val(i, temp_split[i] == "pp" ? BoolHelper.T : BoolHelper.F);

                    px = new double[3,2];
                    for (uint8 i = 0; i < 3; i++) {
                        if (input.read_line() == null) { ok = false; break; }
                        temp_split = input.line.split_set(" \t");
                        if (temp_split.length != 2)
                            throw new IParserError.PARSE_ERROR("Line %u: invalid bounds number".printf(input.line_n));
                        for (uint8 j = 0; j < 2; j++)
                            if (!double.try_parse(temp_split[j], out px[i,j]))
                                throw new IParserError.PARSE_ERROR("Line %u: cannot parse boundaries".printf(input.line_n));
                    } if (!ok) break;

                    for (uint8 i = 0; i < 3; i++) {
                        box_data.edge.set_val(i, i, px[i,1] - px[i,0]);
                        box_data.origin.set_val(i, px[i,0]);
                    }

                    try {
                        frame_data.box = new ParallelepipedBox(box_data);
                    } catch (ParallelepipedBoxError e) {
                        throw new IParserError.DATA_ERROR("Invalid simulation box data");
                    }
                } else if (input.line == "ITEM: NUMBER OF ATOMS") {
                    if (input.read_line() == null) break;
                    uint temp_an;
                    if (!uint.try_parse(input.line, out temp_an))
                        throw new IParserError.PARSE_ERROR("Line %u: cannot parse number of atoms".printf(input.line_n));
                    frame_data.atoms.set_size(temp_an);
                } else if (input.line.length > 10 && input.line[:11] == "ITEM: ATOMS") {
                    // parse atoms and construct frame
                    // get property names
                    temp_split = input.line.split_set(" \t");
                    if (temp_split.length < 3)
                        throw new IParserError.PARSE_ERROR("Line %u: no per-atom property ids".printf(input.line_n));

                    string[] keys = temp_split[2:];

                    for (uint i = 0; i < keys.length; i++)
                        for (uint j = i + 1; j < keys.length; j++)
                            if (keys[i] == keys[j])
                                throw new IParserError.PARSE_ERROR("Line %u: repeating property %s".printf(input.line_n, keys[i]));

                    // load first properties
                    if (input.read_line() == null) break;

                    PerAtomProperty[] props = new PerAtomProperty[keys.length];
                    temp_split = input.line.split_set(" \t");
                    double temp_double;
                    int temp_int;
                    for (uint i = 0; i < keys.length; i++) {
                        if (int.try_parse(temp_split[i], out temp_int)) {
                            props[i] = new IntPerAtomProperty(
                                new IntPerAtomPropertyInitData(
                                    keys[i],
                                    frame_data.atoms.get_size()
                                )
                            );
                            ((IntPerAtomProperty) props[i]).append_val(temp_int);
                        } else if (double.try_parse(temp_split[i], out temp_double)) {
                            props[i] = new DoublePerAtomProperty(
                                new DoublePerAtomPropertyInitData(
                                    keys[i],
                                    frame_data.atoms.get_size()
                                )
                            );
                            ((DoublePerAtomProperty) props[i]).append_val(temp_double);
                        } else {
                            props[i] = new StringPerAtomProperty(
                                new StringPerAtomPropertyInitData(
                                    keys[i],
                                    frame_data.atoms.get_size()
                                )
                            );
                            ((StringPerAtomProperty) props[i]).append_val(temp_split[i]);
                        }
                    }

                    // load other properties
                    for (uint i = 1; i < frame_data.atoms.get_size(); i++) {
                        if (input.read_line() == null) { ok = false; break; }
                        temp_split = input.line.split_set(" \t");
                        if (temp_split.length != keys.length)
                            throw new IParserError.PARSE_ERROR("Line %u: invalid property number".printf(input.line_n));
                        for (uint j = 0; j < keys.length; j++) {
                            if (props[j] is DoublePerAtomProperty) {
                                if (!double.try_parse(temp_split[j], out temp_double))
                                    throw new IParserError.PARSE_ERROR("Line %u: invalid type".printf(input.line_n));
                                ((DoublePerAtomProperty) props[j]).append_val(temp_double);
                            } else if (props[j] is IntPerAtomProperty) {
                                if (!int.try_parse(temp_split[j], out temp_int))
                                    throw new IParserError.PARSE_ERROR("Line %u: invalid type".printf(input.line_n));
                                ((IntPerAtomProperty) props[j]).append_val(temp_int);
                            } else {
                                ((StringPerAtomProperty) props[j]).append_val(temp_split[j]);
                            }
                        }
                    } if (!ok) break;

                    for (uint i = 0; i < keys.length; i++)
                        frame_data.atoms.set_prop(props[i]);

                    // construct frame
                    try {
                        frame = new Frame(frame_data);
                    } catch (FrameError.CONSTRUCTION_ERROR ex) {
                        throw new IParserError.PARSE_ERROR("Invalid frame");
                    }
                    is_frame_finished = true;
                    result.append(frame);
                    frame_data = new FrameInitData();
                    is_box_set = false;
                } else if (input.line.length > 4 && input.line[:5] == "ITEM:") {
                    // skip unknown sections
                    while (input.read_line() != null && (input.line.length < 5 || input.line[:5] != "ITEM:"));
                } else {
                    throw new IParserError.PARSE_ERROR("Line %u: parsing error".printf(input.line_n));
                }
            }
            
            if (!is_frame_finished) {
                throw new IParserError.PARSE_ERROR("Line %u: unexpected EOF".printf(input.line_n));
            }

            return result;
        }

    }
}
