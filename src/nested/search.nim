import folders
import os, sequtils, strutils, re, memfiles
import ../sqlite/splitDb

proc searchEmail*(line, path: string): string =
  ## Search a email from a nested folder system
  ## Line is a email
  ##
  ## Example: searchDomain("test@gmail.com", "data/")

  var fpath: string
  var inputEmail = parseLine(line)
  echo("Searching: ", inputEmail.email)
  fpath = getPath(inputEmail.username, path)
  echo(fpath)
  var mfile = memfiles.open(fpath, mode = fmRead)
  defer: mfile.close()

  for l in lines(mfile):
    let lineEmail = parseLine(l.split(":")[0])
    if lineEmail.email == inputEmail.email:
      result = l

proc searchDomain*(line, path: string) =
  ## Search for emails from a domain from a nested folder system
  ## Line is domain
  ## Should be noted this can take a very long time to find all results!
  ##
  ## Example: searchDomain("gmail.com", "data/")

  var inputDomain: Email
  inputDomain = parseLine(line)

  # lets walk the folder forest
  for file in walkDirRec(path & "/"):
    if file.match re".*\.txt":
      var mfile = memfiles.open(file, mode = fmread)
      defer: mfile.close()
      for line in lines(mfile):
        let lineDomain = parseLine(line.split(":")[0])
        if lineDomain.domain == inputDomain.domain:
          echo(line)

proc searchPassword*(password, path: string) =
  # lets walk the folder forest
  for file in walkDirRec(path & "/"):
    if file.match re".*\.txt":
      var mfile = memfiles.open(file, mode = fmread)
      defer: mfile.close()
      for line in lines(mfile):
        let linePassword = parseLine(line)
        if linePassword.password == password:
          echo(line)
when isMainModule:
  echo(searchEmail("sokalstefan@gmail.com", "data/"))
