project(
    'Aml',
    ['vala', 'c'],
    version: '0.1',
    license: 'GPL-3.0',
    meson_version: '>=1.4.0',
)

if get_option('doconly').enabled()
    compile_lib = false
else
    compile_lib = true
    valac = find_program('valac')
    g_ir_compiler = find_program('g-ir-compiler')
endif

modules = {}

subdir('aml/core')
subdir('aml/math')
subdir('aml/box')
subdir('aml/particle')

doc_dir = meson.current_build_dir() / '../doc'

subdir('doc')
