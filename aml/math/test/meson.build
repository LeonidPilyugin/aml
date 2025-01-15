tests = {
    'Dummy': files('dummy.vala'),
}

subdir('matrix')
subdir('vector')

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
