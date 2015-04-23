#!/usr/bin/env lsc -cj
author:
  name: ['Chia-liang Kao']
  email: 'clkao@clkao.org'
name: 'twgeojson'
description: 'GeoJSON files for Administrative divisions in Taiwan'
version: '0.2.0'
repository:
  type: 'git'
  url: 'git://github.com/g0v/twgeojson.git'
scripts:
  prepublish: """
    ./node_modules/.bin/lsc -cj package.ls
  """
engines: {node: '*'}
dependencies: {}
devDependencies:
  LiveScript: '1.2.x'
  csv: '^0.2.9'
  minimist: '^1.1.1'
  topojson: '^1.6.19'
  mapshaper: '^0.2.19'
optionalDependencies: {}
