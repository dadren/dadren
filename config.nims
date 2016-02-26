import strutils
import sequtils
import ospaths

let
  root_path = thisDir()
  source_path = root_path / "dadren"
  docs_path = root_path / "docs"
  tests_path = root_path / "tests"
  build_path = root_path / "gh_pages"
  docs_repo = "git@github.com:dadren/dadren.github.io.git"

proc compile(file: string, run = false, verbosity = 0,
             hints = false, warnings = false,
             extra_paths = newSeq[string]()) =
  let
    cmd = "nim $1 $2 $3 $4 c $5 $6"
    run_str = if run: "-r" else: ""
    verbosity_str = "--verbosity:$1".format(verbosity)
    hints_str = if hints: "--hints:on" else: "--hints:off"
    warnings_str = if warnings: "--warnings:on" else: "--warnings:off"

  var paths = ""
  for path in extra_paths:
    paths = paths & " -p:$1".format(path)

  exec(cmd.format(verbosity_str, hints_str, warnings_str, paths, run_str, file))

proc docgen(file: string, index = true, verbosity = 0,
             hints = false, warnings = false,
             extra_paths = newSeq[string]()) =
  let
    cmd = "nim $1 $2 $3 $4 $5 doc2 $6"
    index_str = if index: "--index:on" else: "--index:off"
    verbosity_str = "--verbosity:$1".format(verbosity)
    hints_str = if hints: "--hints:on" else: "--hints:off"
    warnings_str = if warnings: "--warnings:on" else: "--warnings:off"

  var paths = ""
  for path in extra_paths:
    paths = paths & " -p:$1".format(path)

  exec(cmd.format(verbosity_str, hints_str, warnings_str, paths, index_str, file))


task docs, "build the dadren documentation":
  rmDir(build_path)
  mkDir(build_path)
  echo "Generating source documentation..."
  withDir(build_path):
    for file in listFiles(source_path):
      echo file
      let (_, _, ext) = splitFile(file)
      if ext == ".nim":
        try: docgen(file)
        except: discard
    try: exec("nim buildIndex .")
    except: echo("Failed to build index.")
    echo "Generating rst documentation..."
    try: exec("nim rst2html $1".format(docs_path / "index.rst"))
    except: echo("Failed to build index.rst")
    mvFile(docs_path / "index.html", "index.html")

task deploy, "deploy the dadren documentation":
  withDir(build_path):
    rmDir(".git")
    exec("git init")
    exec("git remote add origin $1".format(docs_repo))
    exec("git add ./*")
    exec("git commit -am 'Automated commit'")
    exec("git push --force origin master")

task test, "run the dadren tests":
  withDir(tests_path):
    for file in listFiles(tests_path):
      let (_, _, ext) = splitFile(file)
      if ext == ".nim":
        compile(file, run=true)
    try: exec("find . -type f ! -name '*.*' -delete")
    except: discard
