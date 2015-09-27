
{ sync, async } = require "io"
{ execSync } = require "child_process"
runParallel = require "run-parallel"
readFile = require "read-file"
globby = require "globby"
Path = require "path"
log = require "lotus-log"

# Ask for permission.
execSync "which node"

# The module name that should be searched for.
target = process.argv[0]

log.moat 1
log "Searching "
log.yellow process.cwd()
log " for packages..."
log.moat 1

paths = globby.sync process.cwd() + "/*/package.json"

paths = sync.map paths, (path) ->
  Path.resolve path

paths = sync.filter paths, (path) ->
  pkgJson = JSON.parse sync.read path
  pkgJson.dependencies?[target]? or pkgJson.devDependencies?[target]?

removePath = (path) ->
  log.moat 1
  log.red "Removing "
  log "'#{path}'..."
  log.moat 1
  sync.remove path

copyTree = (path, dest) ->
  log.moat 1
  log.yellow "Copying "
  log "'#{path}' to '#{dest}'"
  log.moat 1
  sync.copy path, dest

reportSuccess = (path) ->
  log.moat 1
  log.it "Successfully installed into: "
  log.green path
  log.moat 1

if paths.length > 0

  log.moat 1
  log.yellow "Installing "
  log target
  log.moat 1

  path = paths.shift()
  cwd = Path.dirname path
  modulePath = "#{cwd}/node_modules/#{target}"
  removePath modulePath
  execSync "sudo npm install", { cwd }
  reportSuccess modulePath

  async.each paths, (path) ->
    cwd = Path.dirname path
    moduleDest = "#{cwd}/node_modules/#{target}"
    removePath moduleDest
    copyTree modulePath, moduleDest
    reportSuccess moduleDest

  .then (error) ->
    log.moat 1
    log.green "Done without errors!"
    log.moat 1

  .done()

else
  log.moat 1
  log.red "No packages found."
  log.moat 1
