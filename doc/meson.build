valadoc = find_program('valadoc')

valadoc_args = [ ]
sources = [ ]

foreach sp : subproject_objects
  build_doc = sp.get_variable('build_doc', false)
  if build_doc
    sources += sp.get_variable('sources') 
    dir = sp.get_variable('build_dir')
    valadoc_args += [
      '--girdir=' + dir,
    ]
    dependencies = sp.get_variable('thirdparty_dependencies')
    foreach dep : dependencies
      valadoc_args += [
        '--pkg=' + dep.name(),
      ]
    endforeach
  endif
endforeach

custom_target(
  'doc',
  command: [
    valadoc,
    '--force',
    '-o',
    meson.current_build_dir(),
    '--package-name=' + meson.project_name(),
    '--package-version=' + meson.project_version(),
    valadoc_args,
    sources,
  ],
  output: 'index.html',
  install: false,
)
