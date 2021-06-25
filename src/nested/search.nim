import folders
import os, sequtils, strutils
import memfiles
import ../sqlite/splitDb
proc searchEmail*(line, path: string): string =
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
      break

