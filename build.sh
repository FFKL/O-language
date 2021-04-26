#!/bin/bash

if [[ ! -d dist/ ]]; then
  mkdir dist/
fi

fpc -ap -o./dist/O ./O.pas
fpc -ap -o./dist/OAsm ./OAsm.pas
