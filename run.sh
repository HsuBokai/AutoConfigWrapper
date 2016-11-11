#!/bin/bash

target=test_project
test=test_temp

cp -r $target $test;
cd $test;
sh ../AutoConfigWrapper.sh;
