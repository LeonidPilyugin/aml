module_dict = {}

module_dict += { 'module_name': 'LammpsIo' }
module_dict += { 'extless_name': meson.project_name() + module_dict['module_name'] + '-' + meson.project_version() }
module_dict += { 'lib_name': 'lib' + module_dict['extless_name'].to_lower() + '.so' }
module_dict += { 'gir_name': module_dict['extless_name'] + '.gir' }
module_dict += { 'typelib_name': module_dict['extless_name'] + '.typelib' }
module_dict += { 'header_name': module_dict['extless_name'] + '.h' }
module_dict += { 'build_dir': meson.current_build_dir() }

module_dict += { 'doc_dependencies': [
    '--pkg=glib-2.0',
    '--pkg=gobject-2.0',
    '--pkg=gio-2.0',
] }

module_dict += {
    'dependencies': [
        module_dict['doc_dependencies'],
        '--pkg=' + modules['core']['extless_name'],
        '--pkg=' + modules['basictypes']['extless_name'],
        '--pkg=' + modules['box']['extless_name'],
        '--pkg=' + modules['particles']['extless_name'],
        '--pkg=' + modules['math']['extless_name'],
    ]
}

module_dict += { 'sources': files(
    'src/inputhelper.vala',
    'src/dumpreader.vala',
    'src/dumpwriter.vala',
) }

module_dict += { 'c_args': [
    '-X', '-fPIC',
    '-X', '-shared',
    '-X', '-o' + module_dict['build_dir'] / module_dict['lib_name'],
    '-X', '-w',
    '-X', '-I' + modules['core']['build_dir'],
    '-X', '-I' + modules['basictypes']['build_dir'],
    '-X', '-I' + modules['box']['build_dir'],
    '-X', '-I' + modules['particles']['build_dir'],
    '-X', '-I' + modules['math']['build_dir'],
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
            '--girdir=' + modules['basictypes']['build_dir'],
            '--vapidir=' + modules['basictypes']['build_dir'],
            '--girdir=' + modules['box']['build_dir'],
            '--vapidir=' + modules['box']['build_dir'],
            '--girdir=' + modules['particles']['build_dir'],
            '--vapidir=' + modules['particles']['build_dir'],
            '--girdir=' + modules['math']['build_dir'],
            '--vapidir=' + modules['math']['build_dir'],
            '-H', module_dict['build_dir'] / module_dict['header_name'],
            module_dict['dependencies'],
            '--output=' + module_dict['lib_name'],
            module_dict['c_args'],
            modules['core']['link_args'],
            modules['math']['link_args'],
            modules['box']['link_args'],
            modules['basictypes']['link_args'],
            modules['particles']['link_args'],
            module_dict['sources'],
        ],
        depends: [
            modules['core']['gir_target'],
            modules['basictypes']['gir_target'],
            modules['box']['gir_target'],
            modules['particles']['gir_target'],
            modules['math']['gir_target'],
        ],
        output: [module_dict['lib_name'], module_dict['header_name'], module_dict['gir_name']],
        build_by_default: true,
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
            '--includedir=' + modules['particles']['build_dir'],
            '--shared-library',
            module_dict['lib_target'].full_path(),
            '--output=' + module_dict['build_dir'] / module_dict['typelib_name'],
            module_dict['build_dir'] / module_dict['gir_name'],
        ],
        depends: module_dict['lib_target'],
        output: module_dict['typelib_name'],
        build_by_default: true,
    ) }
endif

modules += { 'lammpsio': module_dict }
