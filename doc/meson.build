valadoc = find_program('valadoc', required : false)

if valadoc.found()
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
        girdirs += '--girdir=' + module['build_dir']
        girs += module['gir_target']
    endforeach

    custom_target(
        'doc',
        command: [
            valadoc,
            girdirs,
            '--force',
            '-o',
            meson.current_build_dir(),
            dependencies,
            '--package-name=' + meson.project_name(),
            '--package-version=' + meson.project_version(),
            sources,
        ],
        output: 'index.html',
        depends: girs,
  )
endif
