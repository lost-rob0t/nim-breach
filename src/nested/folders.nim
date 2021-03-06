import os, sequtils, strutils
import memfiles
import ../sqlite/splitDb


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

proc checkLine*(path, email: string): bool =
  ## used to check a file for duplicates before writing
  var mfile = memfiles.open(path, mode = fmReadWrite)
  defer: mfile.close()
  for line in lines(mfile):
    if line.len == 0: break
    if line == email:
      break
      result = true
  result = false
proc parseLine*(line: string): Email =
   var
    email: string
    email_username: string
    password: string
    lineSplit1: string
    lineSplit2: string
    nEmail: Email
   try:
    lineSplit1 = line.split(":")[0]
    lineSplit2 = line.split(":")[1]
   except ValueError:
    echo("invalid line: " & line)
    # geting the level
   except IndexDefect:
     discard
   if lineSplit1.contains("@"):
     email = linesplit1
     nEmail = Email(username: email.split("@")[0], domain: email.split("@")[1], password: linesplit2, email: email)
   else:
    email = linesplit2
    nEmail = Email(username: email.split("@")[0], domain: email.split("@")[1], password: linesplit1, email: email)
   result = nEmail

proc getPath*(line, path: string): string =
  ## Used to return a path for a line in a nested folder
  ##
  ## Example: x = getPath("test@gmail.com")
  var
    level_path: int
    fpath: string
    letters: seq[char]

  if line.len < 2:
    result = path & "outliers.txt" # dummy result to keep it from crashing

  letters = toSeq(line.items)
  try:
    for letter in letters[0..2]:
      if isAlphaNumeric(letter) == true:
        level_path += 1
      else:
        break
  except IndexDefect:
    discard


  var letter: char
  if level_path == 0:
    fpath = fpath & "outliers.txt"
  if level_path == 1:
    letter = letters[0]
    if isAlphaNumeric(letter) == true:
      fpath = fpath & "/" & $letter & ".txt"
    else:
      fpath = fpath & "/" & "symbols.txt"
  if level_path == 2:
    letter = letters[1]
    if isAlphaNumeric(letter) == true:
      fpath = fpath & $letters[0] & "/"  & $letters[1] & ".txt"
    else:
      fpath = fpath & $letters[0] & "/" & "symbols.txt"
  if level_path == 3:
    letter = letters[2]
    if isAlphaNumeric(letter) == true:
      fpath = fpath & $letters[0] & "/" & $letters[1] & "/" & $letters[2] & ".txt"
    else:
      fpath = fpath & $letters[0] & "/" & $letters[1] & "/" & $letters[2] & "/" & "symbols.txt"
  result = path & fpath
  return result.toLower()
proc sortLineA*(path: var string, line: string) =
  ## used to sort the lines into a nested folder system.
  ## line is a email:pass line.
  ## level is how man chars out of thee email to use as the index
  ## be sure to use the same level -1 as you do for the nesting!
  var
    fpath, outLine: string

  if path.contains("/"):
    discard
  else:
    path = path & "/"
  # lets see if its in email:pass or pass:email
  var parsedLine = parseLine(line)

  # lets get th full path
  fpath = getPath(parsedLine.username.toLower, path)

  outLine = parsedLine.email & ":" & parsedLine.password & "\n"
  try:
    if fileExists(fpath) == false:
      let outFile = system.open(fpath, fmWrite)
      defer: outfile.close()
      outFile.write(outLine)
    else:
        let outFile = system.open(fpath, fmAppend)
        outFile.write(outLine)
        defer: outFile.close()
  except OSError:
    echo(fpath)
  except IOError:
    echo(line)
    echo(fpath)

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
    let outFile = system.open(fpath, fmAppend)
    defer: outFile.close()
    outFile.write(outLine)
  except IOError:
    let outFile = system.open(fpath, fmWrite)
    outFile.write(outLine)
    defer: outFile.close()
proc comboSortA*(path, input_file: string) =
  ## sorts a input file to a nested folder system
  ## A folder nest looks like data/a/b/c/d.txt
  ##
  ## Example comboSortA("data", "test.txt")
  let inputFile = system.open(input_file, fmRead)
  for line in inputFile.lines:
    try:
      var path2 = path
      sortLineA(path2, line)
    except IndexDefect:
      echo(line)

proc comboSortB*(path, input_file: string) =
  ## Sort a input file into a set of files in <path> dir
  ## filename is based on the first letter of the email
  ## Example comboSortB("data", "test.txt")
  let inputFile = system.open(input_file, fmRead)
  for line in inputFile.lines:
    try:
      sortLineB(path, line)
    except IndexDefect:
      echo(line)

proc splitSqlite*(path, input_file, tmp_dir: string) =
  ## Splits a input file into a set of slite3 database files
  ## example: data/a.db, data/b.db. the filename is determined by the first letter
  ## of the email.
  ## All lines must be in email:pass or pass:email and seperatd by a : or a defined sep
  ## Usage: splitSqlite(<path to output>, <input txt file>, <name of tmp dir>)
  ##
  var tpath: string
  if tmp_dir.contains("/"):
    tpath = tmp_dir
  else:
    tpath = tmp_dir & "/"
  createDir(tmp_dir)
  comboSortB(tmp_dir, input_file)
  echo("inserting data into sqlite3 databases")
  for file in walkFiles(tpath & "*.txt"):
    echo(file)
    var fpath = expandFilename(file)
    let tFile = system.open(fpath, fmRead)
    var
      buf: seq[string]
      i: int
    for line in tFile.lines:
      if i < 500:
        buf.add(line)
        i += 1
      if i == 500:
        for email in buf.items:
          echo(email)
        i = 0

when isMainModule:
  echo("Running tests")
  echo("Test get nesting")
  echo(getPath("test@gmail.com", "data-testing/"))
  echo("creating folder forest")
  createNest("data-testing/")
  echo("creating split dir")
  #createDir("split-test")
  #echo("testing split sqlite3")
  #comboSortB("split-test", "./test.txt")
  echo("testing nested folders")
  comboSortA("data-testing", "test.txt")
  #splitSqlite("data/", "test.txt", "data/tmp/")
  echo("all tests complete")
