project(
  'LammpsIO',
  ['vala', 'c'],
  version: '0.1',
  license: 'GPL-3.0',
  meson_version: '>=1.1.0',
  default_options: [
    'buildtype=debugoptimized',
  ]
)

build_type = get_option('build-type')

build_lib = build_type == 'all' or build_type == 'lib' or build_type == 'typelib'
build_typelib = build_type == 'typelib' or build_type == 'all'
build_doc = build_type == 'doc' or build_type == 'all'

thirdparty_dependencies = [
  dependency('glib-2.0'),
  dependency('gobject-2.0'),
  dependency('gio-2.0'),
]

if build_lib
  dependencies = thirdparty_dependencies
  dependencies += [
    dependency('amlcore'),
    dependency('amlparticles'),
    dependency('amlbox'),
    dependency('amltypes'),
    dependency('amlmath'),
  ]
endif

sources = files(
  'src/binarydumpreader.vala',
  'src/binarydumpwriter.vala',
  'src/dumpreader.vala',
  'src/dumpwriter.vala',
  'src/inputhelper.vala',
  'src/outputhelper.vala',
  'src/readerparams.vala',
  'src/writerparams.vala',
)

show_vala_warnings = get_option('vala-warnings')
if not show_vala_warnings
  message('Disabling Vala warnings')
  add_project_arguments('--disable-warnings', language: 'vala')
endif

show_c_warnings = get_option('c-warnings')
if not show_c_warnings
  message('Disabling C warnings')
  add_project_arguments('-w', language: 'c')
endif

include = include_directories('.')
name_prefix = get_option('name-prefix')
name = meson.project_name()
version = meson.project_version()
extless_name = name_prefix + name
extless_v_name = extless_name + '-' + version
lib_name = extless_name.to_lower()
header_name = extless_name.to_lower() + '.h'
vapi_name = extless_name.to_lower() + '.vapi'
gir_name = extless_v_name + '.gir'
lib_dependency_name = extless_name.to_lower()
typelib_name = extless_v_name + '.typelib'
typelib_target_name = extless_name.to_lower() + '_typelib'

if build_lib
  pkgconfig = import('pkgconfig')

  lib = shared_library(
    lib_name,
    sources,
    vala_header: header_name,
    vala_vapi: vapi_name,
    vala_gir: gir_name,
    version: version,
    dependencies: dependencies,
    install: true,
    install_dir: [ true, true, true, true ],
  )

  pkgconfig.generate(
    lib,
  )

  dep = declare_dependency(
    link_with: lib,
    include_directories: include,
    version: version,
    dependencies: dependencies,
    variables: { 'dir': meson.current_build_dir() },
  )
  meson.override_dependency(lib_dependency_name, dep)
endif

if build_typelib
  girdir_args = []
  foreach dep : dependencies
    dir = dep.get_variable('dir', default_value: '')
    if dir != ''
      girdir_args += [ '--includedir=' + dir ]
    endif
  endforeach

  g_ir_compiler = find_program('g-ir-compiler')
  typelib = custom_target(
    typelib_target_name,
    command: [
      g_ir_compiler,
      '--shared-library=' + get_option('prefix') / get_option('libdir') / 'lib' + lib_name + '.so',
      girdir_args,
      '--output',
      '@OUTPUT@',
      meson.current_build_dir() / gir_name,
    ],
    output: typelib_name,
    depends: lib,
    install: true,
    install_dir: '/usr/lib/girepository-1.0',
  )
endif

build_dir = meson.current_build_dir()
