import nested/[folders, search]
import os, strutils

proc insertBreach(mode="nested",
                  output="data", input="in-data", email =  "test@gmail.com", paths: seq[string]) =
  ## Insert data into a database
  ## Mode meanings
  ## Nested: a nested folder system like baseQurey: data/a/b/c/d.txt
  ## Split: data/a.txt, data/b.txt, ect
  ##
  ##Sqlite3: data.db
  ##
  ##Split sqlite3: data/a.db
  ##
  ##Use -h for more help
  if mode == "split":
    createDir(output)
    for file in walkFiles(input & "*"):
      comboSortB(output, file)
  if mode == "sqlite":
    echo("The mode hasnt been added yet")
  if mode == "nested":
    echo("Creating output nesting Please wait....")
    createNest(output)
    echo("Nesting done!")
    echo("Sorting files")

    # lets count the number of input files
    var i, counter: int

    for x in walkFiles(input & "*"):
      i += 1
    echo("Found: ", i, " files to sort")
    for file in walkFiles(input & "*"):
      echo("Sorting File: ", file)
      comboSortA(output, file)
      counter += 1
      echo("done: ", counter, "/", i)

    echo("Done sorting!")
  if mode == "email":
    echo(searchEmail(input, email))
  else:
    echo("nothing")

import cligen; dispatch(insertBreach)
