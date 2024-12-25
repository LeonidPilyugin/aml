tests = { }

foreach name, sources : tests
    test(
        module_dict['module_name'] + name,
        custom_target(
            name,
            command: [
                valac,
                '--directory=' + meson.current_build_dir(),
                '--vapidir=' + module_dict['build_dir'],
                '--girdir=' + module_dict['build_dir'],
                '--vapidir=' + modules['core']['build_dir'],
                '--girdir=' + modules['core']['build_dir'],
                [ module_dict['dependencies'], '--pkg=' + module_dict['extless_name'] ],
                '--output=' + name,
                '-X', '-static-libasan',
                '-X', '-I' + module_dict['build_dir'],
                '-X', '-I' + modules['core']['build_dir'],
                '-X', '-w',
                module_dict['link_args'],
                modules['core']['link_args'],
                sources,
            ],
            output: name,
            depends: module_dict['lib_target'],
        ),
      env: [ 'G_DEBUG=fatal_warnings' ]
    )
endforeach

