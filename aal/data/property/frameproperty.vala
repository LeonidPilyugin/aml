namespace Aal {
    public class FramePropertyInitData : PropertyInitData {
        public Value data;

        public FramePropertyInitData(string id) {
            base(id);
        }
    }

    public class FrameProperty : Property {
        public Value data { get; set; }
        public FrameProperty(FramePropertyInitData data) {
            base(data);
            this.data = data.data;
        }

        public static FrameProperty create(string id, Value data) {
            var idata = new FramePropertyInitData(id);
            idata.data = data;
            return new FrameProperty(idata);
        }
    }
}
