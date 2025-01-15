project(
    'Aml',
    ['vala', 'c'],
    version: '0.1',
    license: 'GPL-3.0',
    meson_version: '>=1.4.0',
)

compile_lib = get_option('lib')
generate_doc = get_option('doc')

if compile_lib
    valac = find_program('valac')
    g_ir_compiler = find_program('g-ir-compiler')
endif

modules = {}

subdir('aml/core')
subdir('aml/basictypes')
subdir('aml/math')
subdir('aml/box')
subdir('aml/particles')
subdir('aml/lammpsio')

if generate_doc
    valadoc = find_program('valadoc')
    subdir('doc')
endif
    
