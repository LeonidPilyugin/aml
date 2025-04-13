for subdir in build/subprojects/*; do
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(pwd)/$subdir
    export GI_TYPELIB_PATH=$GI_TYPELIB_PATH:$(pwd)/$subdir
done
