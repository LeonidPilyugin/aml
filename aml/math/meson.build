module_dict = {}

module_dict += { 'module_name': 'Math' }
module_dict += { 'extless_name': meson.project_name() + module_dict['module_name'] + '-' + meson.project_version() }
module_dict += { 'lib_name': 'lib' + module_dict['extless_name'].to_lower() + '.so' }
module_dict += { 'gir_name': module_dict['extless_name'] + '.gir' }
module_dict += { 'typelib_name': module_dict['extless_name'] + '.typelib' }
module_dict += { 'header_name': module_dict['extless_name'] + '.h' }
module_dict += { 'build_dir': meson.current_build_dir() }

module_dict += { 'doc_dependencies': [
    '--pkg=glib-2.0',
    '--pkg=gobject-2.0',
    '--pkg=gsl',
] }

module_dict += { 'dependencies': [ module_dict['doc_dependencies'], '--pkg=' + modules['core']['extless_name'] ] }

module_dict += { 'sources': files(
    'src/linalg/matrix.vala',
    'src/linalg/vector.vala',
) }

module_dict += { 'c_args': [
    '-X', '-fPIC',
    '-X', '-shared',
    '-X', '-o' + module_dict['build_dir'] / module_dict['lib_name'],
    '-X', '-w',
    '-X', '-I' + modules['core']['build_dir'],
] }

if compile_lib
    module_dict += { 'lib_target': custom_target(
        'lib',
        command: [
            valac,
            '--directory=' + module_dict['build_dir'],
            '--gir=' + module_dict['gir_name'],
            '--library=' + module_dict['extless_name'],
            '--girdir=' + modules['core']['build_dir'],
            '--vapidir=' + modules['core']['build_dir'],
            '-H', module_dict['build_dir'] / module_dict['header_name'],
            module_dict['dependencies'],
            '--output=' + module_dict['lib_name'],
            module_dict['c_args'],
            modules['core']['link_args'],
            module_dict['sources'],
        ],
        depends: modules['core']['gir_target'],
        output: [module_dict['lib_name'], module_dict['header_name'], module_dict['gir_name']],
    ) }

    module_dict += { 'link_args': [ '-X', '-L' + module_dict['build_dir'], '-X', '-l' + module_dict['extless_name'].to_lower() ] }

    subdir('test')
endif

if generate_typelib
    module_dict += { 'gir_target': custom_target(
        'typelib',
        command: [
            g_ir_compiler,
            '--includedir=' + modules['core']['build_dir'],
            '--shared-library',
            module_dict['lib_target'].full_path(),
            '--output=' + module_dict['build_dir'] / module_dict['typelib_name'],
            module_dict['build_dir'] / module_dict['gir_name'],
        ],
        depends: module_dict['lib_target'],
        output: module_dict['typelib_name'],
    ) }
endif

modules += { 'math': module_dict }
