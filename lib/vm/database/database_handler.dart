// lib/vm/database/database_handler.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {
  Future<Database> initializeDB() async {
    final String path = await getDatabasesPath();

    return openDatabase(
      join(path, 'xyz.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE customer(
            cseq INTEGER PRIMARY KEY AUTOINCREMENT,
            cemail TEXT,
            cpw TEXT,
            cphone TEXT,
            cname TEXT,
            caddress TEXT
          )
        """);

        await db.execute("""
          CREATE TABLE goods(
            gseq INTEGER PRIMARY KEY AUTOINCREMENT,
            gsumamount INTEGER,
            gname TEXT,
            gengname TEXT,
            gsize TEXT,
            gcolor TEXT,
            gcategory TEXT,
            manufacturer TEXT,
            price REAL,
            mainimage BLOB,
            topimage BLOB,
            backimage BLOB,
            sideimage BLOB
          )
        """);

        await db.execute("""
          CREATE TABLE branch(
            bid INTEGER PRIMARY KEY,
            blat REAL,
            blng REAL,
            bname TEXT
          )
        """);

        await db.execute("""
          CREATE TABLE employee(
            eseq INTEGER PRIMARY KEY AUTOINCREMENT,
            eemail TEXT,
            epw TEXT,
            ename TEXT,
            ephone TEXT,
            erank INTEGER,
            erole INTEGER,
            epower INTEGER,
            workplace INTEGER,
            ebid INTEGER
          )
        """);

        await db.execute("""
          CREATE TABLE supplier(
            sid INTEGER PRIMARY KEY,
            sname TEXT
          )
        """);

        await db.execute("""
          CREATE TABLE purchase(
            pseq INTEGER PRIMARY KEY AUTOINCREMENT,
            pstatus INTEGER,
            pdate TEXT,
            pamount INTEGER,
            ppaydate TEXT,
            ppayprice REAL,
            ppayway INTEGER,
            ppayamount INTEGER,
            pdiscount REAL,
            userid TEXT,
            gseq INTEGER,
            gsize TEXT,
            gcolor TEXT
          )
        """);

        await db.execute("""
          CREATE TABLE refund(
            rseq INTEGER PRIMARY KEY AUTOINCREMENT,
            rdate TEXT,
            rreason TEXT,
            rstatus INTEGER,
            rpseq INTEGER
          )
        """);

        await db.execute("""
          CREATE TABLE approval(
            aseq INTEGER PRIMARY KEY AUTOINCREMENT,
            astatus INTEGER,
            adate TEXT,
            aoseq INTEGER
          )
        """);

        await db.execute("""
          CREATE TABLE orders(
            oseq INTEGER PRIMARY KEY AUTOINCREMENT,
            ostatus INTEGER,
            odate TEXT,
            oamount INTEGER
          )
        """);

        await db.execute("""
          CREATE TABLE supply_order(
            oseq INTEGER PRIMARY KEY AUTOINCREMENT,
            manufacturer TEXT,
            requester TEXT,
            gseq INTEGER,
            gname TEXT,
            gsize TEXT,
            gcolor TEXT,
            qty INTEGER,
            status INTEGER,
            reqdate TEXT,
            apprdate TEXT
          )
        """);

        await db.execute("""
          CREATE TABLE basket(
            bseq INTEGER PRIMARY KEY AUTOINCREMENT,
            userid TEXT,
            gname TEXT,
            gsize TEXT,
            gcolor TEXT,
            qty INTEGER,
            createdAt TEXT
          )
        """);
      },
    );
  }
}
