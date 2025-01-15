#!/bin/bash

set -euo pipefail

help () {
    echo "Usage:"
    echo "$ ./add-module.sh <module_name>"
}

project_dir=$PWD/aml
module_name=$1

module_dir="$project_dir/$module_name"
test_dir="$module_dir/test"
src_dir="$module_dir/src"
mkdir -p "$module_dir" "$test_dir" "$src_dir"

module_meson="$module_dir/meson.build"
test_meson="$module_dir/test/meson.build"

cat <<EOF > "$module_meson"
module_name = '$module_name'

dependencies = [
    'glib-2.0',
    'gobject-2.0',
]

aml_dependencies = [
]

sources = files(
)

c_args = [
    '-fPIC',
    '-shared',
]

vala_args = [
]

g_ir_args = [
]


############################
# DO NOT CHANGE CODE BELOW #
############################

module_dict = {}

module_dict += { 'module_name': module_name }
module_dict += { 'extless_name': meson.project_name() + module_name[0].to_upper() + module_name.substring(1) + '-' + meson.project_version() }
module_dict += { 'lib_name': 'lib' + module_dict['extless_name'].to_lower() + '.so' }
module_dict += { 'gir_name': module_dict['extless_name'] + '.gir' }
module_dict += { 'typelib_name': module_dict['extless_name'] + '.typelib' }
module_dict += { 'header_name': module_dict['extless_name'] + '.h' }
module_dict += { 'build_dir': meson.current_build_dir() }

module_dict += { 'sources': sources }

_dependencies = []
foreach dep : dependencies
    _dependencies += '--pkg=' + dep
endforeach

module_dict += { 'doc_dependencies': _dependencies }

_aml_dependencies = []
foreach dep : aml_dependencies
    _aml_dependencies += '--pkg=' + modules[dep]['extless_name']
endforeach

foreach dep : aml_dependencies
    _dependencies += modules[dep]['dependencies']
endforeach

module_dict += { 'dependencies': [ _dependencies, _aml_dependencies ] }

c_args += [
    '-o' + module_dict['build_dir'] / module_dict['lib_name'],
]

_c_include_args = []
_c_link_args = []
foreach dep : aml_dependencies
    _c_include_args += '-I' + modules[dep]['build_dir']
    _c_link_args += '-L' + modules[dep]['build_dir']
    _c_link_args += '-l' + modules[dep]['extless_name'].to_lower()
endforeach

_c_link_args += '-L' + module_dict['build_dir']
_c_link_args += '-l' + module_dict['extless_name'].to_lower()
_c_include_args += '-I' + module_dict['build_dir']

foreach dep : aml_dependencies
    _c_link_args += modules[dep]['c_link_args']
    _c_include_args += modules[dep]['c_include_args']
endforeach

c_args += _c_link_args
c_args += _c_include_args

module_dict += {
    'c_link_args': _c_link_args,
    'c_include_args': _c_include_args,
}

_c_args = []
foreach arg : c_args
    _c_args += [ '-X', arg ]
endforeach

vala_args += _c_args

vala_args += [
    '--directory=' + module_dict['build_dir'],
    '-H', module_dict['build_dir'] / module_dict['header_name'],
    '--gir=' + module_dict['gir_name'],
    '--library=' + module_dict['extless_name'],
    _aml_dependencies,
    '--output=' + module_dict['lib_name'],
]

_girdir_args = []
_vapidir_args = []
foreach dep : aml_dependencies
    _girdir_args += '--girdir=' + modules[dep]['build_dir']
    _vapidir_args += '--vapidir=' + modules[dep]['build_dir']
    _girdir_args += modules[dep]['girdir_args']
    _vapidir_args += modules[dep]['vapidir_args']
endforeach

module_dict += { 'girdir_args': _girdir_args }
module_dict += { 'vapidir_args': _vapidir_args }

vala_args += [ _girdir_args, _vapidir_args ]
vala_args += _dependencies

foreach dep : aml_dependencies
    g_ir_args += '--includedir=' + modules[dep]['build_dir']
endforeach

g_ir_args += '--output=' + module_dict['build_dir'] / module_dict['typelib_name']

if compile_lib
    _aml_deps = []
    foreach dep : aml_dependencies
        _aml_deps += modules[dep]['typelib_target']
    endforeach

    module_dict += {
        'lib_target': custom_target(
            module_name + 'lib',
            command: [
                valac,
                vala_args,
                sources
            ],
            depends: _aml_deps,
            output: module_dict['lib_name'],
            build_by_default: true,
        )
    }

    module_dict += {
        'typelib_target': custom_target(
            module_name + 'typelib',
            command: [
                g_ir_compiler,
                g_ir_args,
                '--shared-library',
                module_dict['lib_target'].full_path(),
                '--output=' + module_dict['build_dir'] / module_dict['typelib_name'],
                module_dict['build_dir'] / module_dict['gir_name'],
            ],
            depends: module_dict['lib_target'],
            output: module_dict['typelib_name'],
            build_by_default: true,
        )
    }

    subdir('test')
endif

modules += { module_name: module_dict }
EOF

cat <<EOF > "$test_dir/dummy.vala"
public static int main(string[] args)
{
    return 0;
}
EOF

cat <<EOF > "$test_meson"
tests = {
    'Dummy': files('dummy.vala'),
}

############################
# DO NOT CHANGE CODE BELOW #
############################

_c_args = []
foreach arg : module_dict['c_include_args']
    _c_args += [ '-X', arg ]
endforeach
foreach arg : module_dict['c_link_args']
    _c_args += [ '-X', arg ]
endforeach

foreach name, sources : tests
    test(
        module_dict['module_name'] + name,
        custom_target(
            name,
            command: [
                valac,
                '--directory=' + meson.current_build_dir(),
                _girdir_args,
                '--girdir=' + module_dict['build_dir'],
                _vapidir_args,
                '--vapidir=' + module_dict['build_dir'],
                [ module_dict['dependencies'], '--pkg=' + module_dict['extless_name'] ],
                '--output=' + name,
                _c_args,
                '-X', '-I' + module_dict['build_dir'],
                sources
            ],
            output: name,
            depends: module_dict['lib_target'],
            build_by_default: true,
        ),
        env: [ 'G_DEBUG=fatal_warnings' ]
    )
endforeach
EOF
