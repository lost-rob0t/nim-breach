import nested/[folders, search]
import os, strutils

proc insertBreach(mode="nested",
                  output="data/", input="data/", email = "test@gmail.com", password = false, domain = false) =
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

    for x in walkFiles(input & "/*"):
      i += 1
    echo("Found: ", i, " files to sort")
    for file in walkFiles(input & "*"):
      echo("Sorting File: ", file)
      comboSortA(output, file)
      counter += 1
      echo("done: ", counter, "/", i)

    echo("Done sorting!")

  if mode == "search":
    if password == true:
      searchPassword(email, input)
    if domain == true:
      if not email.contains("@"):
        var email1 = "test@" & email
        searchDomain(email1, input)
      else:
        searchDomain(email, input)
    if domain == false and password == false:
      echo(searchEmail(email, input))
    else:
      echo("What are you trying to do?")

import cligen; dispatch(insertBreach)
