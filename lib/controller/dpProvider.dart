import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html_unescape/html_unescape.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as plain;
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher;
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'package:biblebookapp/Model/dailyVersesMainListModel.dart';
import 'package:biblebookapp/view/constants/assets_constants.dart';
import 'package:biblebookapp/view/screens/calendar_screen/model/calendar_model.dart';

import '../Model/bookMarkModel.dart';
import '../Model/highLightContentModal.dart';
import '../Model/saveImagesModel.dart';
import '../Model/saveNotesModel.dart';
import '../Model/verseBookContentModel.dart';

class DBHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    io.Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = p.join(
      documentDirectory.path,
      'bible_enc.db',
    );

    var db = await openDatabase(
      path,
      version: 3,
      password: dotenv.env[AssetsConstants.dbPasswordKey],
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
              'CREATE TABLE "calendar" (id INTEGER PRIMARY KEY AUTOINCREMENT,"title" TEXT,"date"	DATETIME)');
        }
        if (oldVersion < 3) {
          // Changes added in version 3
          await db.execute(
              'CREATE TABLE IF NOT EXISTS "dailyVersesnew" (id INTEGER PRIMARY KEY AUTOINCREMENT, "Category_Name" TEXT, "Category_Id" INTEGER, "Book" TEXT, "Book_Id" INTEGER, "Chapter" INTEGER, "Verse" TEXT, "Date" TEXT, "Verse_Num" INTEGER)');

          try {
            await db.execute(
                'ALTER TABLE bookmark ADD COLUMN plaincontent VARCHAR');
          } catch (e) {
            debugPrint('bookmark: plaincontent already exists or error: $e');
          }

          try {
            await db.execute(
                'ALTER TABLE save_notes ADD COLUMN plaincontent VARCHAR');
          } catch (e) {
            debugPrint('save_notes: plaincontent already exists or error: $e');
          }

          try {
            await db.execute(
                'ALTER TABLE highlight ADD COLUMN plain_content VARCHAR');
          } catch (e) {
            debugPrint('highlight: plain_content already exists or error: $e');
          }

          try {
            await db
                .execute('ALTER TABLE highlight ADD COLUMN verse_id VARCHAR');
          } catch (e) {
            debugPrint('highlight: verse_id already exists or error: $e');
          }
        }
      },
    );
    return db;
  }

  _onCreate(Database db, int version) async {
    try {
      await db.execute(
          'CREATE TABLE "calendar" (id INTEGER PRIMARY KEY AUTOINCREMENT,"title" TEXT,"date"	DATETIME)');
      await db.execute(
          'CREATE TABLE "verse" (id INTEGER PRIMARY KEY AUTOINCREMENT,"book_num"	INTEGER, "chapter_num"	INTEGER, "verse_num"	INTEGER,"content"	TEXT,"is_read"	TEXT,"is_bookmarked"	TEXT,"is_underlined"	TEXT,"is_highlighted"	TEXT,"is_noted"	TEXT)');
      await db.execute(
          'CREATE TABLE "bookmark" (id INTEGER PRIMARY KEY AUTOINCREMENT,"book_num" INTEGER, "chapter_num" INTEGER, "verse_num" INTEGER, "content" VARCHAR, "plaincontent" VARCHAR,"bookName" VARCHAR, "timestamp" DATETIME DEFAULT CURRENT_TIMESTAMP)');
      await db.execute(
          'CREATE TABLE "save_notes" (id INTEGER PRIMARY KEY AUTOINCREMENT,"book_num" INTEGER, "chapter_num" INTEGER, "verse_num" INTEGER, "content" VARCHAR,"book_name" VARCHAR, "notes" VARCHAR, "plaincontent" VARCHAR, "timestamp" DATETIME DEFAULT CURRENT_TIMESTAMP)');
      await db.execute(
          'CREATE TABLE "highlight" (id INTEGER PRIMARY KEY AUTOINCREMENT,"book_num" INTEGER, "chapter_num" INTEGER, "verse_num" INTEGER, "content" VARCHAR, "plain_content" VARCHAR, verse_id VARCHAR, "book_name" VARCHAR,"color" VARCHAR, "timestamp" DATETIME DEFAULT CURRENT_TIMESTAMP)');
      await db.execute(
          'CREATE TABLE "underline" (id INTEGER PRIMARY KEY AUTOINCREMENT,"book_num" INTEGER, "chapter_num" INTEGER, "verse_num" INTEGER, "content" VARCHAR, "plaincontent" VARCHAR, "bookName" VARCHAR, "timestamp" DATETIME DEFAULT CURRENT_TIMESTAMP)');
      await db.execute(
          'CREATE TABLE "book" (id INTEGER PRIMARY KEY AUTOINCREMENT,"book_num"	INTEGER,"title"	TEXT,"short_title"	TEXT,"chapter_count"	INTEGER,"read_per"	TEXT)');
      await db.execute(
          'CREATE TABLE "save_images" (id INTEGER PRIMARY KEY AUTOINCREMENT,"image_path"	TEXT)');
      await db.execute(
          'CREATE TABLE "dailyVersesMainList" (id INTEGER PRIMARY KEY AUTOINCREMENT,"Category_Name" TEXT,"Category_Id" INTEGER,"Book" TEXT,"Book_Id" INTEGER,"Chapter" INTEGER, "Verse" TEXT)');
      await db.execute(
          'CREATE TABLE "dailyVerses" (id INTEGER PRIMARY KEY AUTOINCREMENT,"Category_Name" TEXT,"Category_Id" INTEGER,"Book" TEXT,"Book_Id" INTEGER,"Chapter" INTEGER, "Verse" TEXT,"Date" TEXT,"Verse_Num" INTEGER )');
      await db.execute(
          'CREATE TABLE "dailyVersesnew" (id INTEGER PRIMARY KEY AUTOINCREMENT,"Category_Name" TEXT,"Category_Id" INTEGER,"Book" TEXT,"Book_Id" INTEGER,"Chapter" INTEGER, "Verse" TEXT,"Date" TEXT,"Verse_Num" INTEGER )');
    } catch (e) {
      debugPrint('Error Creating Tables: $e');
    }
  }

////
  /// Calendar CRUD
  ///
////
  Future<void> saveCalendarData(CalendarModel calendar) async {
    var dbAccount = await db;
    try {
      await dbAccount!.insert("calendar", calendar.toJson());
    } catch (_) {
      rethrow;
    }
  }

  Future<List<CalendarModel>> getCalendarData() async {
    try {
      var dbAccount = await db;
      final List<Map<String, Object?>> queryResult =
          await dbAccount!.query("calendar");
      return queryResult.map((e) => CalendarModel.fromJson(e)).toList();
    } catch (_) {
      rethrow;
    }
  }

  Future<int> deleteCalendarData(int id) async {
    var dbAccount = await db;
    return await dbAccount!
        .delete("calendar", where: "id = ?", whereArgs: [id]);
  }

  Future<int> updateCalendarData(CalendarModel calendarData) async {
    var dbClient = await db;
    var res = await dbClient!.update("calendar", calendarData.toJson(),
        where: "id = ?", whereArgs: [calendarData.id]);
    return res;
  }

  ////
  /// End of Calendar CRUD
  ///
  ///.

  /// Save images
  Future<SaveImageModel> saveImage(SaveImageModel saveimagemodel) async {
    var dbAccount = await db;
    try {
      await dbAccount!.insert("save_images", saveimagemodel.toJson());
    } catch (e) {
      // print(e);
    }
    return saveimagemodel;
  }

  ///
  ///
  ///
  Future<List<SaveImageModel>> getImage() async {
    try {
      var dbAccount = await db;
      final List<Map<String, Object?>> queryResult =
          await dbAccount!.query("save_images", orderBy: "id DESC");
      return queryResult.map((e) => SaveImageModel.fromJson(e)).toList();
    } catch (_) {
      rethrow;
    }
  }

  Future<int> deleteImage(int id) async {
    var dbAccount = await db;
    return await dbAccount!
        .delete("save_images", where: "id = ?", whereArgs: [id]);
  }

  /// main Book List content

  Future<int> updateBookData(int id, String title, String value) async {
    var dbClient = await db;
    var res = await dbClient!
        .update("book", {title: value}, where: "id = ?", whereArgs: [id]);
    return res;
  }

  /// verse Book content
  Future<List<VerseBookContentModel>> getVerse() async {
    var dbAccount = await db;
    final List<Map<String, Object?>> queryResult =
        await dbAccount!.query("verse");
    debugPrint("queryResult V is  $queryResult");
    return queryResult.map((e) => VerseBookContentModel.fromJson(e)).toList();
  }

  Future<int> updateVersesData(int? id, String title, String value) async {
    if (id != null) {
      var dbClient = await db;
      var res = await dbClient!
          .update("verse", {title: value}, where: "id = ?", whereArgs: [id]);
      return res;
    }
    return 0;
  }

  Future<int> updateVersesDataBatch(
      int id, Map<String, dynamic> updates) async {
    var dbClient = await db;
    var res = await dbClient!.update(
      "verse",
      updates,
      where: "id = ?",
      whereArgs: [id],
    );
    return res;
  }

  Future<int> updateVersesDataByContent(
      String content, String title, String value) async {
    var dbClient = await db;
    var res = await dbClient!.update("verse", {title: value},
        where: "content = ?", whereArgs: [content]);
    return res;
  }

  Future<int> updateVersesDataByContentnew(
      String plainContent, String title, String value) async {
    final dbClient = await db;

    // Step 1: Get all verses
    final List<Map<String, dynamic>> verses = await dbClient!.query("verse");

    // Step 2: Find the one with matching plain text
    for (final verse in verses) {
      final htmlContent = verse["content"] ?? "";
      final parsedText = html_parser.parse(htmlContent).body?.text ?? "";
      // debugPrint(
      //     "check highlight - ${verse["id"]}  ${parsedText.trim()} =  ${plainContent.trim()}");
      if (parsedText.trim() == plainContent.trim()) {
        final int id = verse["id"];

        // Step 3: Update this verse
        return await dbClient.update(
          "verse",
          {title: value},
          where: "id = ?",
          whereArgs: [id],
        );
      }
    }

    return 0; // No match found
  }

  Future<int> updateVersesDataByContentnewcheck(
      String plainContent, String title, String value) async {
    final dbClient = await db;

    // Step 1: Get all verses
    final List<Map<String, dynamic>> verses = await dbClient!.query("verse");

    // Step 2: Find the one with matching plain text
    for (final verse in verses) {
      final htmlContent = verse["content"] ?? "";
      final parsedText = html_parser.parse(htmlContent).body?.text ?? "";

      if (parsedText.trim() == plainContent.trim()) {
        final int id = verse["id"];
        // debugPrint(
        //     "check highlight - ${verse["id"]}  ${parsedText.trim()} =  ${plainContent.trim()}");
        // Step 3: Update this verse
        return await dbClient.update(
          "verse",
          {title: value},
          where: "id = ?",
          whereArgs: [id],
        );
      }
    }

    return 0; // No match found
  }

  Future<int> updateVersesDataByContentmy(
      String content, String title, String value) async {
    // var dbClient = await db;
    // var res = await dbClient!.update("verse", {title: value},
    //     where: "content = ?", whereArgs: [content]);
    // return res;
    final dbClient = await db;
    try {
      final res = await dbClient!.update(
        'verse',
        {title: value},
        where: 'content = ?',
        whereArgs: [content],
      );
      return res;
    } catch (e) {
      debugPrint('Error updating verse: $e');
      return 0; // or -1 based on how you handle failure
    }
  }

  ///BookMark Functions
  Future<BookMarkModel> insertBookmark(BookMarkModel bookmarkmodel) async {
    var dbAccount = await db;
    try {
      await dbAccount!.insert("bookmark", bookmarkmodel.toJson());
    } catch (e) {
      // print(e);
    }
    return bookmarkmodel;
  }

  ///
  ///
  ///
  Future<List<BookMarkModel>> getBookMark() async {
    var dbAccount = await db;
    final List<Map<String, Object?>> queryResult =
        await dbAccount!.query("bookmark");
    return queryResult.map((e) => BookMarkModel.fromJson(e)).toList();
  }

  Future<int> deleteBookmark(int id) async {
    var dbAccount = await db;
    return await dbAccount!
        .delete("bookmark", where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteBookmarkByContent(String content) async {
    var dbAccount = await db;
    return await dbAccount!
        .delete("bookmark", where: "content = ?", whereArgs: [content]);
  }

  Future clearBookMarkTable() async {
    var dbAccount = await db;
    try {
      await dbAccount!.delete("bookmark");
    } catch (e) {
      // print(e);
    }
  }

  /// Save Notes Functions
  Future<SaveNotesModel> insertNotes(SaveNotesModel savenotesmodel) async {
    var dbAccount = await db;
    try {
      await dbAccount!.insert("save_notes", savenotesmodel.toJson());
    } catch (e) {
      // print(e);
    }
    return savenotesmodel;
  }

  ///
  ///
  ///
  Future<List<SaveNotesModel>> getNotes() async {
    var dbAccount = await db;
    final List<Map<String, Object?>> queryResult =
        await dbAccount!.query("save_notes");
    // print(queryResult);
    return queryResult.map((e) => SaveNotesModel.fromJson(e)).toList();
  }

  Future<int> updateNotesData(
      String content, String title, String value) async {
    var dbClient = await db;
    var res = await dbClient!.update("save_notes", {title: value},
        where: "content = ?", whereArgs: [content]);
    return res;
  }

  Future<int> deleteNotes(int id) async {
    var dbAccount = await db;
    return await dbAccount!
        .delete("save_notes", where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteNotesByContent(String content) async {
    var dbAccount = await db;
    return await dbAccount!
        .delete("save_notes", where: "content = ?", whereArgs: [content]);
  }

  Future clearNotesTable() async {
    var dbAccount = await db;
    try {
      await dbAccount!.delete("save_notes");
    } catch (e) {
      // print(e);
    }
  }

  ///Highlight Functions

  Future<HighLightContentModal> insertIntoHighLight(
      HighLightContentModal highlightcontentmodel) async {
    var dbAccount = await db;
    try {
      await dbAccount!.insert("highlight", highlightcontentmodel.toJson());
    } catch (e) {
      // print(e);
    }
    return highlightcontentmodel;
  }

  ///
  ///
  ///
  Future<List<HighLightContentModal>> getHighlight() async {
    var dbAccount = await db;
    final List<Map<String, Object?>> queryResult =
        await dbAccount!.query("highlight");
    // print(queryResult);
    return queryResult.map((e) => HighLightContentModal.fromJson(e)).toList();
  }

  Future<String?> getColorByContent(String content) async {
    var dbAccount = await db;
    // final List<Map<String, Object?>> queryResult = await dbAccount!.query(
    //   //   "highlight",
    //   //   where: "content = ?",
    //   //   whereArgs: [content],
    //   //  columns: ["color"],
    //   "highlight",
    //   where: "content = ?",
    //   whereArgs: [content],
    //   limit: 1, // We only need the first match
    // );

    final normalized = normalizeHtml(content);

    // debugPrint("highlight colr parse 2 : $normalized");

    final result = await dbAccount!.query(
      "highlight",
      where: "LOWER(plain_content) = LOWER(?)",
      whereArgs: [normalized],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first["color"]?.toString();
    }

    return null;

    // if (queryResult.isNotEmpty) {

    // return queryResult.first["color"] as String?;
    // }
    //  return null;
  }

  String normalizeHtml(String htmlContent) {
    final unescape = HtmlUnescape();
    final document = html_parser.parse(htmlContent);
    final normalized =
        unescape.convert(document.body?.text ?? htmlContent).trim();
    return normalized.replaceAll("'", '').replaceAll('"', '');
    // return unescape.convert(document.body?.text ?? htmlContent).trim();
    //return document.body?.text.trim() ?? htmlContent.trim();
  }

  // Stream<String?> getColorStreamByContent(String content) {
  //   return Stream.fromFuture(getColorByContent(content));
  // }

  Stream<String?> getColorStreamByContent(String content) async* {
    final color = await getColorByContent(content);
    yield color;
  }

  Future<int> deleteHighlight(int id) async {
    var dbAccount = await db;
    return await dbAccount!
        .delete("highlight", where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteHighlightByContent(String content) async {
    var dbAccount = await db;
    return await dbAccount!
        .delete("highlight", where: "content = ?", whereArgs: [content]);
  }

  Future<int> updateHighLight(
      HighLightContentModal highlight, content, data) async {
    var dbAccount = await db;
    return await dbAccount!.update("highlight", highlight.toJson(),
        where: '$content = ?', whereArgs: [data]);
  }

  Future clearHighLightTable() async {
    var dbAccount = await db;
    try {
      await dbAccount!.delete("highlight");
    } catch (e) {
      // print(e);
    }
  }

  ///UnderLine Functions
  Future<BookMarkModel> insertUnderLine(BookMarkModel bookmarkmodel) async {
    var dbAccount = await db;
    try {
      await dbAccount!.insert("underline", bookmarkmodel.toJson());
    } catch (e) {
      // print(e);
    }
    return bookmarkmodel;
  }

  ///
  ///
  ///
  Future<List<BookMarkModel>> getUnderLine() async {
    var dbAccount = await db;
    final List<Map<String, Object?>> queryResult =
        await dbAccount!.query("underline");
    print(queryResult);
    return queryResult.map((e) => BookMarkModel.fromJson(e)).toList();
  }

  Future<int> deleteUnderline(int id) async {
    var dbAccount = await db;
    return await dbAccount!
        .delete("underline", where: "id = ?", whereArgs: [id]);
  }

  Future<int> deleteUnderlineByContent(String content) async {
    var dbAccount = await db;
    return await dbAccount!
        .delete("underline", where: "content = ?", whereArgs: [content]);
  }

  Future clearUnderLine() async {
    var dbAccount = await db;
    try {
      await dbAccount!.delete("underline");
    } catch (e) {
      // print(e);
    }
  }

  Future<List<VerseBookContentModel>> getSelectedBookContent(
      selectedBookNum, selectedChapter) async {
    var dbAccount = await db;
    final List<Map<String, Object?>> queryResult = await dbAccount!.rawQuery(
        "SELECT * From verse WHERE book_num ='${int.parse(selectedBookNum)}' AND chapter_num = '${int.parse(selectedChapter) - 1}'");
    return queryResult.map((e) => VerseBookContentModel.fromJson(e)).toList();
  }
}

// class DBMigrationHelper {
//   static const _unencryptedDbName = 'bible.db';
//   static const _encryptedDbName = '.bible.db';
//   static const _newDbName = 'bible_enc.db'; // ✅ Target encrypted DB

//   static Future<String?> getSourceDbPath() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final unencryptedPath = p.join(dir.path, _unencryptedDbName);
//     final encryptedPath = p.join(dir.path, _encryptedDbName);

//     if (await File(unencryptedPath).exists()) {
//       debugPrint("testapp Found unencrypted DB at: $unencryptedPath");
//       return unencryptedPath;
//     } else if (await File(encryptedPath).exists()) {
//       debugPrint("testapp Found encrypted DB at: $encryptedPath");
//       return encryptedPath;
//     }
//     return null;
//   }

//   static Future<String> getNewDbPath() async {
//     final dir = await getApplicationDocumentsDirectory();
//     return p.join(dir.path, _newDbName);
//   }

//   static Future<void> migrateToEncryptedDatabase(String password) async {
//     final sourceDbPath = await getSourceDbPath();
//     final newDbPath = await getNewDbPath();

//     if (await File(newDbPath).exists()) {
//       //debugPrint('testapp New encrypted DB already exists at $newDbPath');
//       return;
//     }

//     if (sourceDbPath == null || !await File(sourceDbPath).exists()) {
//       debugPrint('testapp No source DB found for migration.');
//       return;
//     }

//     // await EasyLoading.showInfo('Please wait... Updating database...');

//     final isUnencrypted = sourceDbPath.endsWith(_unencryptedDbName);

//     // // Step 1: Open source DB (plain or encrypted)
//     // final oldDb = isUnencrypted
//     //     ? await plain.openDatabase(sourceDbPath)
//     //     : await sqlcipher.openDatabase(sourceDbPath, password: password);

//     // // Step 2: Open new encrypted DB
//     // final newDb = await sqlcipher.openDatabase(
//     //   newDbPath,
//     //   password: password,
//     //   version: 3,
//     //   onCreate: (db, version) async {
//     //     await _createTables(db); // replicate schema
//     //   },
//     // );

//     // // Step 3: Copy tables and data
//     // final tables = await oldDb.rawQuery(
//     //     "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");

//     // for (final tableMap in tables) {
//     //   final tableName = tableMap['name'] as String;
//     //   final rows = await oldDb.query(tableName);
//     //   for (final row in rows) {
//     //     try {
//     //       await newDb.insert(tableName, row);
//     //     } catch (e) {
//     //       debugPrint("testapp Error inserting into $tableName: $e");
//     //     }
//     //   }
//     // }

//     // Step 1: Open source DB (plain or encrypted)
//     late Database oldDb;
//     try {
//       oldDb = isUnencrypted
//           ? await plain.openDatabase(sourceDbPath)
//           : await sqlcipher.openDatabase(sourceDbPath, password: password);
//     } catch (e) {
//       debugPrint('Error opening source DB: $e');
//       return;
//     }

//     // Step 2: Create & open encrypted target DB
//     late Database newDb;
//     try {
//       newDb = await sqlcipher.openDatabase(
//         newDbPath,
//         password: password,
//         version: 3,
//         onCreate: (db, version) async {
//           await _createTables(db); // Ensure schema
//         },
//       );
//     } catch (e) {
//       debugPrint('Error creating encrypted DB: $e');
//       return;
//     }

//     // Step 3: Copy all tables
//     try {
//       final tables = await oldDb.rawQuery(
//           "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");

//       for (final tableMap in tables) {
//         final tableName = tableMap['name'] as String;
//         final rows = await oldDb.query(tableName);
//         for (final row in rows) {
//           try {
//             await newDb.insert(tableName, row);
//           } catch (e) {
//             debugPrint("Insert error in '$tableName': $e");
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint('Error during table migration: $e');
//     }

//     try {
//       final String dailyVerseResponse =
//           await rootBundle.loadString('assets/jsonFile/dailyVerse.json');
//       final dailyVerseData = json.decode(dailyVerseResponse);

//       final dailyVerseDataList = List.from(dailyVerseData)
//           .map<DailyVersesMainListModel>(
//               (item) => DailyVersesMainListModel.fromJson(item))
//           .toList();

//       await newDb.transaction((txn) async {
//         await txn.delete('dailyVersesMainList');
//         final batch = txn.batch();

//         for (final item in dailyVerseDataList) {
//           final insertData = {
//             "Category_Name": item.mainCategory,
//             "Category_Id": item.categoryId,
//             "Book": item.book,
//             "Book_Id": item.bookId,
//             "Chapter": item.chapter,
//             "Verse": item.verse,
//           };
//           batch.insert('dailyVersesMainList', insertData);
//         }

//         final isUpload = await batch.commit();

//         if (isUpload.isNotEmpty) {
//           debugPrint("testapp dailyVersesMainList inserted successfully.");
//         }
//       });
//     } catch (e) {
//       debugPrint("testapp Error loading daily verses JSON: $e");
//     }

//     await oldDb.close();
//     await newDb.close();
//     // await EasyLoading.dismiss();

//     // try {
//     //   final dir = await getApplicationDocumentsDirectory();
//     //   final oldDbFile = File(p.join(dir.path, 'bible.db'));
//     //   if (await oldDbFile.exists()) {
//     //     await oldDbFile.delete();
//     //     debugPrint('Deleted old unencrypted DB: bible.db');
//     //   }

//     //   final dotDbFile = File(p.join(dir.path, '.bible.db'));
//     //   if (await dotDbFile.exists()) {
//     //     await dotDbFile.delete();
//     //     debugPrint('Deleted old encrypted DB: .bible.db');
//     //   }
//     // } catch (e) {
//     //   debugPrint('Error deleting old DB files: $e');
//     // }

//     debugPrint("testapp Migration to $newDbPath complete.");
//   }

class DBMigrationHelper {
  static const _unencryptedDbName = 'bible.db';
  static const _legacyEncryptedName = '.bible.db';
  static const _encryptedDbName = 'bible2.db';
  static const _newDbName = 'bible_enc.db';

  /// Map old column names to new column names
  static final Map<String, String> _columnNameMap = {
    'plain_content': 'plaincontent',
    //'book_name': 'bookName',
  };

  /// Rename legacy `.bible.db` → `bible2.db`
  static Future<void> _renameLegacyEncryptedIfAny() async {
    final dir = await getApplicationDocumentsDirectory();
    final legacyPath = p.join(dir.path, _legacyEncryptedName);
    final newNamePath = p.join(dir.path, _encryptedDbName);

    if (await File(legacyPath).exists()) {
      try {
        if (await File(newNamePath).exists()) {
          await File(legacyPath).delete();
          debugPrint(
              "testapp Removed legacy $_legacyEncryptedName (target exists).");
        } else {
          await File(legacyPath).rename(newNamePath);
          debugPrint(
              "testapp Renamed $_legacyEncryptedName → $_encryptedDbName");
        }
      } catch (e) {
        debugPrint("testapp Rename error for $_legacyEncryptedName: $e");
      }
    }
  }

  static Future<bool> _isDatabaseEncrypted(String path) async {
    try {
      final db = await plain.openDatabase(path);
      await db.rawQuery("SELECT name FROM sqlite_master LIMIT 1");
      await db.close();
      debugPrint("testapp DB at $path is UNENCRYPTED.");
      return false;
    } catch (_) {
      debugPrint("testapp DB at $path is ENCRYPTED or not plain.");
      return true;
    }
  }

  static Future<String?> getSourceDbPath() async {
    await _renameLegacyEncryptedIfAny();

    final dir = await getApplicationDocumentsDirectory();
    final unencryptedPath = p.join(dir.path, _unencryptedDbName);
    final maybeEncryptedPath = p.join(dir.path, _encryptedDbName);

    if (await File(unencryptedPath).exists()) {
      debugPrint("testapp Found plain DB at: $unencryptedPath");
      return unencryptedPath;
    }
    if (await File(maybeEncryptedPath).exists()) {
      debugPrint("testapp Found DB at: $maybeEncryptedPath");
      return maybeEncryptedPath;
    }
    return null;
  }

  static Future<String> getNewDbPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, _newDbName);
  }

  /// Get columns from target table
  static Future<List<String>> _getTableColumns(
      sqlcipher.Database db, String table) async {
    final result = await db.rawQuery('PRAGMA table_info($table)');
    return result.map((row) => row['name'] as String).toList();
  }

  /// Filter + map old row to target schema
  static Map<String, Object?> _mapAndFilterRow(
      Map<String, Object?> oldRow, List<String> targetColumns) {
    final Map<String, Object?> mapped = {};
    oldRow.forEach((oldCol, value) {
      // Map old col name if needed
      final newCol = _columnNameMap[oldCol] ?? oldCol;
      if (targetColumns.contains(newCol)) {
        mapped[newCol] = value;
      }
    });
    return mapped;
  }

  static Future<void> migrateToEncryptedDatabase(String password) async {
    final sourceDbPath = await getSourceDbPath();
    final newDbPath = await getNewDbPath();

    if (await File(newDbPath).exists()) {
      debugPrint('testapp Target encrypted DB exists. Skipping migration.');
      return;
    }
    if (sourceDbPath == null || !await File(sourceDbPath).exists()) {
      debugPrint('testapp No source DB found.');
      return;
    }

    final looksEncrypted = !sourceDbPath.endsWith(_unencryptedDbName)
        ? await _isDatabaseEncrypted(sourceDbPath)
        : false;

    // Open old DB
    dynamic oldDb;
    try {
      oldDb = looksEncrypted
          ? await sqlcipher.openDatabase(sourceDbPath, password: password)
          : await plain.openDatabase(sourceDbPath);
    } catch (e) {
      debugPrint('testapp Error opening source DB: $e');
      return;
    }

    // Create new encrypted DB
    sqlcipher.Database? newDb;
    try {
      newDb = await sqlcipher.openDatabase(
        newDbPath,
        password: password,
        version: 3,
        onCreate: (db, version) async {
          await _createTables(db);
        },
      );
    } catch (e) {
      debugPrint('testapp Error creating new DB: $e');
      await oldDb?.close();
      return;
    }

    // Copy tables
    try {
      final tables = await oldDb.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );

      for (final tableMap in tables) {
        final tableName = tableMap['name'] as String;
        if (tableName == 'android_metadata') continue;

        final targetColumns = await _getTableColumns(newDb, tableName);
        final rows = await oldDb.query(tableName);

        for (final row in rows) {
          final mappedRow = _mapAndFilterRow(row, targetColumns);
          try {
            if (mappedRow.isNotEmpty) {
              await newDb.insert(tableName, mappedRow,
                  conflictAlgorithm: sqlcipher.ConflictAlgorithm.ignore);
            }
          } catch (e) {
            debugPrint("testapp Insert error in '$tableName': $e");
          }
        }
      }

      try {
        final String dailyVerseResponse =
            await rootBundle.loadString('assets/jsonFile/dailyVerse.json');
        final dailyVerseData = json.decode(dailyVerseResponse);

        final dailyVerseDataList = List.from(dailyVerseData)
            .map<DailyVersesMainListModel>(
                (item) => DailyVersesMainListModel.fromJson(item))
            .toList();

        await newDb.transaction((txn) async {
          await txn.delete('dailyVersesMainList');
          final batch = txn.batch();

          for (final item in dailyVerseDataList) {
            final insertData = {
              "Category_Name": item.mainCategory,
              "Category_Id": item.categoryId,
              "Book": item.book,
              "Book_Id": item.bookId,
              "Chapter": item.chapter,
              "Verse": item.verse,
            };
            batch.insert('dailyVersesMainList', insertData);
          }

          final isUpload = await batch.commit();

          if (isUpload.isNotEmpty) {
            debugPrint("testapp dailyVersesMainList inserted successfully.");
          }
        });
      } catch (e) {
        debugPrint("testapp Error loading daily verses JSON: $e");
      }

      debugPrint("testapp ✅ Migration finished successfully.");
    } catch (e) {
      debugPrint('testapp Migration error: $e');
    } finally {
      await oldDb?.close();
      await newDb.close();
    }
  }

  static Future<void> _createTables(sqlcipher.Database db) async {
    try {
      await db.execute(
          'CREATE TABLE "calendar" (id INTEGER PRIMARY KEY AUTOINCREMENT,"title" TEXT,"date" DATETIME)');
      await db.execute(
          'CREATE TABLE "verse" (id INTEGER PRIMARY KEY AUTOINCREMENT,"book_num" INTEGER, "chapter_num" INTEGER, "verse_num" INTEGER,"content" TEXT,"is_read" TEXT,"is_bookmarked" TEXT,"is_underlined" TEXT,"is_highlighted" TEXT,"is_noted" TEXT)');
      await db.execute(
          'CREATE TABLE "bookmark" (id INTEGER PRIMARY KEY AUTOINCREMENT,"book_num" INTEGER, "chapter_num" INTEGER, "verse_num" INTEGER, "content" VARCHAR, "plaincontent" VARCHAR,"bookName" VARCHAR, "timestamp" DATETIME DEFAULT CURRENT_TIMESTAMP)');
      await db.execute(
          'CREATE TABLE "save_notes" (id INTEGER PRIMARY KEY AUTOINCREMENT,"book_num" INTEGER, "chapter_num" INTEGER, "verse_num" INTEGER, "content" VARCHAR,"book_name" VARCHAR, "notes" VARCHAR, "plaincontent" VARCHAR, "timestamp" DATETIME DEFAULT CURRENT_TIMESTAMP)');
      await db.execute(
          'CREATE TABLE "highlight" (id INTEGER PRIMARY KEY AUTOINCREMENT,"book_num" INTEGER, "chapter_num" INTEGER, "verse_num" INTEGER, "content" VARCHAR, "plain_content" VARCHAR, verse_id VARCHAR, "book_name" VARCHAR,"color" VARCHAR, "timestamp" DATETIME DEFAULT CURRENT_TIMESTAMP)');
      await db.execute(
          'CREATE TABLE "underline" (id INTEGER PRIMARY KEY AUTOINCREMENT,"book_num" INTEGER, "chapter_num" INTEGER, "verse_num" INTEGER, "content" VARCHAR, "plaincontent" VARCHAR, "bookName" VARCHAR, "timestamp" DATETIME DEFAULT CURRENT_TIMESTAMP)');
      await db.execute(
          'CREATE TABLE "book" (id INTEGER PRIMARY KEY AUTOINCREMENT,"book_num" INTEGER,"title" TEXT,"short_title" TEXT,"chapter_count" INTEGER,"read_per" TEXT)');
      await db.execute(
          'CREATE TABLE "save_images" (id INTEGER PRIMARY KEY AUTOINCREMENT,"image_path" TEXT)');
      await db.execute(
          'CREATE TABLE "dailyVersesMainList" (id INTEGER PRIMARY KEY AUTOINCREMENT,"Category_Name" TEXT,"Category_Id" INTEGER,"Book" TEXT,"Book_Id" INTEGER,"Chapter" INTEGER, "Verse" TEXT)');
      await db.execute(
          'CREATE TABLE "dailyVerses" (id INTEGER PRIMARY KEY AUTOINCREMENT,"Category_Name" TEXT,"Category_Id" INTEGER,"Book" TEXT,"Book_Id" INTEGER,"Chapter" INTEGER, "Verse" TEXT,"Date" TEXT,"Verse_Num" INTEGER )');
      await db.execute(
          'CREATE TABLE "dailyVersesnew" (id INTEGER PRIMARY KEY AUTOINCREMENT,"Category_Name" TEXT,"Category_Id" INTEGER,"Book" TEXT,"Book_Id" INTEGER,"Chapter" INTEGER, "Verse" TEXT,"Date" TEXT,"Verse_Num" INTEGER )');
    } catch (e) {
      debugPrint("testapp Error creating tables: $e");
    }
  }
}
