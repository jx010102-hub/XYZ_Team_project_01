import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {

  Future<Database> initializeDB() async{
  String path = await getDatabasesPath();

    return openDatabase(
      join(path, 'xyz.db'),
      onCreate: (db, version) async{
        await db.execute(
          """
          create table customer(
            cseq integer primary key autoincrement,
            cemail text,
            cpw text,
            cphone text,
            cname text,
            caddress text
          )
          """
        );
        await db.execute(
          """
          create table goods(
            gseq integer primary key autoincrement,
            gsumamount integer,
            gname text,
            gengname text,
            gsize text,
            gcolor text,
            gcategory text,
            mainimage blob,
            topimage blob,
            backimage blob,
            sideimage blob
          )
          """
        );
        await db.execute(
          """
          create table branch(
            bid integer primary key,
            blat real,
            blng real,
            bname text
          )
          """
        );
        await db.execute(
          """
          create table employee(
            eseq integer primary key autoincrement,
            eemail text,
            epw text,
            ephone text,
            erank integer,
            erole integer,
            epower integer,
            workplace integer,
            ebid integer
          )
          """
        );
        await db.execute(
          """
          create table supplier(
            sid integer primary key,
            sname text
          )
          """
        );
        await db.execute(
          """
          create table purchase(
            pseq integer primary key autoincrement,
            pstatus integer,
            pdate text,
            pamount integer,
            ppaydate text,
            ppayprice real,
            ppayway integer,
            ppayamount integer,
            pdiscount real,
            userid text
          )
          """
        );
        await db.execute(
          """
          create table refund(
            rseq integer primary key autoincrement,
            rdate text,
            rreason text,
            rstatus integer,
            rpseq integer
          )
          """
        );
        await db.execute(
          """
          create table approval(
            aseq integer primary key autoincrement,
            astatus integer,
            adate text,
            aoseq integer
          )
          """
        );
        await db.execute(
          """
          create table orders(
            oseq integer primary key autoincrement,
            ostatus integer,
            odate text,
            oamount integer
          )
          """
        );
      },
      version: 1,
    );
  }
}
