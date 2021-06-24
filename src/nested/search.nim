import folders
import os, sequtils, strutils
import memfiles
import ../sqlite/splitDb
proc searchLine*(line, path: string): string =
  var
    fpath: string
    email, domain, password: string

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
      break

when isMainModule:
  try:
    echo(searchLine("testin123@mail.com", "data-testing/"))
  except OSError:
    echo("not found")
