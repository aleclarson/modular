#!/usr/bin/env coffee

require "lotus-require"

log = require "lotus-log"

command = process.argv[2]

process.argv = process.argv.slice 3

if command?.length > 0
  require "./commands/" + command

else
  log.red "Needs a command!"
