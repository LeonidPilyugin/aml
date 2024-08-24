project('aml', 'vala', 'c')

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('gio-2.0'),
    dependency('gsl'),
]

deps = [
  '--pkg=glib-2.0',
  '--pkg=gobject-2.0',
  '--pkg=gsl',
  '--pkg=gio-2.0',
]

sources = files(
  'aml/errors.vala',
  'aml/io.vala',

  'aml/parse/parser.vala',
  'aml/parse/lammpstextdumpparser.vala',
  'aml/parse/inputhelper.vala',

  'aml/data/atoms.vala',
  'aml/data/atom.vala',
  'aml/data/box.vala',
  'aml/data/frame.vala',

  'aml/data/property/property.vala',
  'aml/data/property/frameproperty.vala',
  'aml/data/property/peratom/peratom.vala',
  'aml/data/property/peratom/double.vala',
  'aml/data/property/peratom/int.vala',
  'aml/data/property/peratom/string.vala',

  'aml/math/vector.vala',
  'aml/math/matrix.vala',
)

valac = find_program('valac')
c_args = [
  # '-X', '-fsanitize=address',
  '-X', '-fPIC',
  '-X', '-shared',
  '-X', '-olibaml.so',
  # '-X', '-O3',
]
lib = custom_target(
  'aml',
  command: [valac, '--gir=Aml-0.1.gir', '--library=Aml-0.1', '-H', 'Aml-0.1.h', deps, sources, c_args],
  output: 'libaml.so',
  install: true,
  install_dir: 'libaml',
)

g_ir_compiler = find_program('g-ir-compiler')
custom_target('aml typelib', command: [g_ir_compiler, '--shared-library', lib.full_path(),  '--output', '@OUTPUT@', join_paths(meson.current_build_dir(), 'Aml-0.1.gir')],
              output: 'Aml-0.1.typelib',
              depends: lib,
              install: true,
              install_dir: join_paths(get_option('libdir'), 'girepository-1.0'))

valadoc = find_program('valadoc')
doc_dir = 'aml-0.1'
custom_target(
  'doc',
  command: [valadoc, '--force', '-o', doc_dir, deps, sources],
  output: 'index.html',
  depends: lib,
  install: true,
  install_dir: doc_dir
)
