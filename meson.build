project(
    'Aml',
    ['vala', 'c'],
    version: '0.1',
    license: 'GPL-3.0',
    meson_version: '>=1.4.0',
)

valac = find_program('valac')
g_ir_compiler = find_program('g-ir-compiler')

modules = {}

subdir('aml/core')
subdir('aml/math')
subdir('aml/box')
subdir('aml/particle')

doc_dir = meson.current_build_dir() / '../doc'

subdir('doc')
