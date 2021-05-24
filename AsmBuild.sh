#!/bin/bash

if [[ ! -d dist/ ]]; then
  mkdir dist/
fi

fpc -ap -o./dist/OAsm ./OAsm.pas
