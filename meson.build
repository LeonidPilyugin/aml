project('aal', 'vala', 'c')

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gio-2.0'),
    dependency('gsl'),
]

sources = files(
  'aal/io.vala',
  'aal/boolhelper.vala',

  'aal/parse/parser.vala',
  'aal/parse/lammpstextdumpparser.vala',
  'aal/parse/inputhelper.vala',

  'aal/data/atoms.vala',
  'aal/data/atom.vala',
  'aal/data/box.vala',
  'aal/data/frame.vala',

  'aal/data/property/property.vala',
  'aal/data/property/propertylist.vala',
  'aal/data/property/frameproperty.vala',
  'aal/data/property/peratom/peratomproperty.vala',
  'aal/data/property/peratom/double.vala',
  'aal/data/property/peratom/int.vala',
  'aal/data/property/peratom/string.vala',

  'aal/math/vector.vala',
  'aal/math/matrix.vala',
)

lib = shared_library(
  'aal', sources,
  vala_gir: 'Aal-0.1.gir',
  dependencies: dependencies,
  install: true,
  install_dir: [true, true, true, true]
)

g_ir_compiler = find_program('g-ir-compiler')
custom_target('aal typelib', command: [g_ir_compiler, '--shared-library', lib.full_path(),  '--output', '@OUTPUT@', join_paths(meson.current_build_dir(), 'Aal-0.1.gir')],
              output: 'Aal-0.1.typelib',
              depends: lib,
              install: true,
              install_dir: join_paths(get_option('libdir'), 'girepository-1.0'))
