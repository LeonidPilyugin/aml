project(
  'Aml',
  ['vala', 'c'],
  version: '0.1',
  license: 'GPL-3.0',
  meson_version: '>=1.1.0',
  default_options: [
    'buildtype=debugoptimized',
  ]
)

# list keeps the order
subprojects = [
  [ 'core', { } ],
  [ 'types', { } ],
  [ 'math', { } ],
  [ 'box', { } ],
  [ 'particles', { } ],
  [ 'lammpsio', { } ],
]

subproject_objects = [ ]

foreach sp : subprojects
  project_name = sp[0]
  build_infos = sp[1]
  is_required = build_infos.get('option', true)
  default_options = build_infos.get('subproject_options', [])

  subproject_objects += subproject(project_name, required: is_required, default_options: default_options)
endforeach

subdir('doc')
