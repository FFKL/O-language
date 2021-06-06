#!/bin/bash

if [[ ! -d dist/ ]]; then
  mkdir dist/
fi

fpc -ap -o./dist/OCompiler ./OCompiler.pas
