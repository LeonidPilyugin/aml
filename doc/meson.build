sources = []
dependencies = []
girdirs = []
girs = []

foreach i, module : modules
    foreach dep : module['doc_dependencies']
        if dep in dependencies
            continue
        endif
        dependencies += dep
    endforeach
    sources += module['sources']
    if compile_lib
        girdirs += '--girdir=' + module['build_dir']
        girs += module['typelib_target']
    endif
endforeach

custom_target(
    'doc',
    command: [
        valadoc,
        '--force',
        girdirs,
        '-o',
        meson.current_build_dir(),
        '--package-name=' + meson.project_name(),
        '--package-version=' + meson.project_version(),
        dependencies,
        sources,
    ],
    output: 'index.html',
    depends: girs,
    install: true,
    install_dir: meson.current_build_dir(),
)
