import os, sequtils, strutils
import std/unicode
type
  Folder* =  ref object
    depth*: int
    path*: var string
    letter*: string


proc createNest*(path: string) =
  ## Used to create a nested folder system
  ## path is the path to the start of the foldr system
  ## ie data/a/

  var
    sym: seq[char] = toSeq("abcdefghijklmnopqrstuvwxyz01234567890".items)
    fpath: string
  if path.endsWith("/"):
    fpath = path
  else:
    fpath = path & "/"
  createDir(fpath)
  # vars used for nesting
  var fpath0, fpath1, fpath2: string

  for it in sym.mapIt($it):
    fpath0  = fpath & it & "/"
    createDir(fpath0)
    for l1 in sym.mapIt($it):
      fpath1 = fpath0 & l1 & "/"
      createDir(fpath1)
      for l2 in sym.mapIt($it):
        fpath2 = fpath1 & l2 & "/"
        createDir(fpath2)
proc sortLineA*(path, line: string) =
  ## used to sort the lines into a nested folder system.
  ## line is a email:pass line.
  ## level is how man chars out of thee email to use as the index
  ## be sure to use the same level -1 as you do for the nesting!

  var
    email: string
    email_username: string
    password: string
    lineSplit1: string
    lineSplit2: string
    letters: seq[char]
    # used to determin how far a line goes
    level_path: int
    #file_path: string
    fpath: string
    outLine: string

  if path.contains("/"):
    fpath = path
  else:
    fpath = path & "/"
  # lets see if its in email:pass or pass:email
  try:
    lineSplit1 = line.split(":")[0]
    lineSplit2 = line.split(":")[1]
    if lineSplit1.contains("@"):
      email = linesplit1
      email_username = email.split("@")[0].toLower()
      password = linesplit2
    else:
      email = linesplit2
      email_username = email.split("@")[0].toLower()
      password = linesplit1

    letters = toSeq(email_username.items)
  except ValueError:
    echo("invalid line: " & line)
    # geting the level
  except IndexDefect:
    discard
  # lets get the level
  try:
    for letter in letters[0..2]:
      if isAlphaNumeric(letter) == true:
        level_path += 1
      else:
        break
  except IndexDefect:
    discard

    # creating the path
  # a path should look like this
  # data/a/b/c/c.txt
  var letter: char
  if level_path == 0:
    fpath = fpath & "outliers.txt"
  if level_path == 1:
    letter = letters[0]
    if isAlphaNumeric(letter) == true:
      fpath = fpath & "/" & "symbols.txt"
    else:
      fpath = fpath & "/" & "symbols.txt"
  if level_path == 2:
    letter = letters[1]
    if isAlphaNumeric(letter) == true:
      fpath = fpath & $letters[0] & "/"  & "symbols.txt"
    else:
      fpath = fpath & $letters[0] & "/" & "symbols.txt"
  if level_path == 3:
    letter = letters[2]
    if isAlphaNumeric(letter) == true:
      fpath = fpath & $letters[0] & "/" & $letters[1] & "/" & $letters[2] & ".txt"
    else:
      fpath = fpath & $letters[0] & "/" & $letters[1] & "/" & $letters[2] & "/" & "symbols.txt"
  outLine = email & ":" & password & "\n"
  try:
    let outFile = open(fpath, fmAppend)
    outFile.write(outLine)
    defer: outFile.close()
  except IOError:
    echo(email, ":", fpath)
    let outFile = open(fpath, fmWrite)
    outFile.write(outLine)
    defer: outFile.close()

proc sortLineB*(path, line: string) =
  ## Sort line to files for split sqlite3 based on first letter of email.
  ## path is path to the directory wher the txt files will be stored.
  ## returns a string
  var
    fpath: string
    email: string
    password: string
    email_username: string
    lineSplit1: string
    lineSplit2: string
    outLine: string
  if path.contains("/"):
    fpath = path
  else:
    fpath = path & "/"
  # lets see if its in email:pass or pass:email
  try:
    lineSplit1 = line.split(":")[0]
    lineSplit2 = line.split(":")[1]
    if lineSplit1.contains("@"):
      email = linesplit1
      email_username = email.split("@")[0].toLower()
      password = linesplit2
    else:
      email = linesplit2
      email_username = email.split("@")[0]
      password = linesplit1
  except KeyError:
    echo(line)
  except IndexDefect:
    echo(line)
  var first_char = toSeq(email_username)[0]
  fpath = path & "/" & $first_char & ".txt"
  outLine = email & ":" & password & "\n"
  try:
    let outFile = open(fpath, fmAppend)
    defer: outFile.close()
    outFile.write(outLine)
  except IOError:
    let outFile = open(fpath, fmWrite)
    outFile.write(outLine)
    defer: outFile.close()
proc comboSortA(path, input_file: string) =
  # sorts a input file to a nested folder system
  let inputFile = open(input_file, fmRead)
  for line in inputFile.lines:
    try:
      sortLineA(path, line)
    except IndexDefect:
      echo(line)

proc comboSortB(path, input_file: string) =
  let inputFile = open(input_file, fmRead)
  for line in inputFile.lines:
    try:
      sortLineB(path, line)
    except IndexDefect:
      echo(line)


when isMainModule:
  echo("Running tests")
  echo("creating folder forest")
  #createNest("data-testing/")
  echo("creating split dir")
  createDir("/tmp/data/")
  echo("testing split sqlite3")
  comboSortB("/tmp/data", "./test.txt")
  #echo("testing nested folders")
  comboSortA("data-testing", "test.txt")
  echo("all tests complete")
