#!/bin/bash

meson setup build                     \
    -Dtypes:build-type=doc \
    -Dbox:build-type=doc        \
    -Dcore:build-type=doc       \
    -Dlammpsio:build-type=doc   \
    -Dmath:build-type=doc       \
    -Dparticles:build-type=doc  \
&& ninja -C build
