import strutils, sequtils
import db_sqlite
type
  Email* = ref object
    email*: string
    password*: string
    domain*: string


func newEmail*(email: var string, password: string): Email =
  var
    username = email.split("@")[0]
    domain = email.split("@")[1]
  Email(email: username, password: password, domain: domain)

proc createDatabase*(path: string): DbConn =
  ## Creats a database if it doesnt exists
  ## returns a Dbconn object
  var conn = open(path, "", "", "")
  defer: conn.close()
  conn.exec(sql"""CREATE TABLE IF NOT EXISTS "emails" (
                    "email" TEXT NOT NULL,
                    "password" TEXT NOT NULL,
                    "domain" TEXT NOT NULL,
                    "id" INTEGER PRIMARY KEY,
                    CONSTRAINT "uniqueEmail" UNIQUE("email","password","domain"))""")
  #conn.exec(sql"COMMIT")
  return conn

proc insertEmail*(email: Email, conn: DbConn) =
  conn.exec(sql"""INSERT INTO emails (email, password, domain)
                  VALUES (?, ? ?)""", email.email, email.password, email.domain)
when isMainModule:
  var t = createDatabase("test.db")
