import os, sequtils, strutils
import std/unicode
type
  Folder* =  ref object
    depth*: int
    path*: var string
    letter*: string


proc createNest*(path: string, level: int) =
  ## Used to create a nested folder system
  ## path is the path to the start of the foldr system
  ## ie data/a/
  ## level is how many levels to nest it, you should not use more than 5

  var
    sym: seq[char] = toSeq("abcdefghijklmnopkurstuvwxyz01234567890".items)
    i: int
    fpath: string
  for l in 0..level:

    for it in sym.mapIt($it):
      fpath = path & it & "/"
      if i != 0:
        fpath = fpath & it & "/"
      createDir(fpath)
      for it in sym.mapIt($it):
        createDir(fpath & it & "/")
    i += 1

proc sortLine*(path, line: string, level: int) =
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
      email_username = email.split("@")[0]
      password = linesplit2
    else:
      email = linesplit2
      email_username = email.split("@")[0]
      password = linesplit1

    letters = toSeq(email_username.items)
  except ValueError:
    echo("invalid line: " & line)
    # geting the level

  var i = 0
  # lets get the level
  for letter in letters.mapIt($it):

    if letter == "@" or letter == "." or letter == "!" or letter == "-" or letter == "_":
        continue
    if level_path == email_username.len: break
    if i == level: break
    if letter.isAlpha():
      level_path += 1
      i += 1


  var x = 0
  # creating the path
  # a path should look like this
  # data/a/b/c/c.txt
  for letter in letters:
    if $letter == "@" or $letter == "." or $letter == "!" or $letter == "-" or $letter == "_": continue
    if x == level_path:
      fpath = fpath & $letters[x] & ".txt"
      if fpath.contains("."):
        break
      else:
        level_path = x - 1
        fpath = fpath & "../" & $letters[level_path] & ".txt"
        break
    fpath = fpath &  $letter & "/"
    x += 1
  when isMainModule:
    echo(fpath, " ", level_path)
    echo(email, ":", password)

proc sortLine*(path, line: string) =
  ## Sort line to files for split sqlite3 based on first letter of email.
  ## path is path to the directory wher the txt files will be stored.
  var
    fpath: string
    email: string
    password: string
    email_username: string
    lineSplit1: string
    lineSplit2: string

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
      email_username = email.split("@")[0]
      password = linesplit2
    else:
      email = linesplit2
      email_username = email.split("@")[0]
      password = linesplit1
  except KeyError:
    discard
  var first_char = toSeq(email_username)[0]
  fpath = path & "/" & $first_char & ".txt"
  when isMainModule:
    echo(fpath)

when isMainModule:
  echo("Running tests")
  createNest("data/", 5)
  echo("test 1 complete")
  sortLine("data", "test@gmail.com:password", 3)
  echo("test 2 complete")
  sortLine("data", "te.st@gmail.com:password", 3)
  echo("test 3 complete")
  sortLine("data/", "passwordFirs:test@gmail.com", 3)
  echo("test 5 complete")
  sortLine("data", "test@gmail.com:password")
  echo("all tests complete")
