namespace AmlCore
{
    public abstract class ActionParams
    {
        public abstract ActionParams copy();
    }

    public errordomain ActionError
    {
        PARAMS_ERROR,
        DATA_ERROR,
        RUNTIME_ERROR,
        UNKNOWN_ERROR,
    }

    public abstract class Action
    {
        private ActionParams? params = null;

        public bool is_valid(ActionParams params)
        {
            return this.get_params_error_message(params).length == 0;
        }

        protected abstract string get_params_error_message(ActionParams params);

        public void set_params(ActionParams params) throws ActionError.PARAMS_ERROR
        {
            var str = this.get_params_error_message(params);
            if (str.length > 0)
                throw new ActionError.PARAMS_ERROR(str);
            this.params = params.copy();
        }

        public ActionParams get_params() throws ActionError.PARAMS_ERROR
        {
            if (this.params == null)
                throw new ActionError.PARAMS_ERROR("Params are not set");
            return this.params.copy();
        }

        public abstract void perform(DataCollection data) throws ActionError;

        public virtual DataCollection perform_immutable(DataCollection data) throws ActionError
        {
            var copy = (DataCollection) data.copy();
            this.perform(copy);
            return copy;
        }
    }
}
