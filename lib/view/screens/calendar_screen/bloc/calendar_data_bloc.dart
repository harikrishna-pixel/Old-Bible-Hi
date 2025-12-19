import 'dart:collection';
import 'dart:developer';

import 'package:biblebookapp/controller/api_service.dart';
import 'package:biblebookapp/controller/dpProvider.dart';
import 'package:biblebookapp/table_calendar/src/shared/utils.dart';
import 'package:biblebookapp/view/constants/constant.dart';
import 'package:biblebookapp/view/screens/calendar_screen/model/calendar_model.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final calendarDataBloc =
    ChangeNotifierProvider<CalendarDataBloc>((ref) => CalendarDataBloc());

class CalendarDataBloc extends ChangeNotifier {
  List<CalendarModel> overAllCalendarData = [];
  late DateTime focusDate;
  late DateTime todayDate;
  late bool isTodaySelected;
  late TextEditingController fieldCon;
  late FocusNode fieldNode;
  late bool isTextEmpty;
  CalendarModel? editData;

  static int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  editCalendar(CalendarModel edit) {
    editData = edit;
    fieldCon.text = edit.title ?? '';
    fieldNode.requestFocus();
    notifyListeners();
  }

  void initState() {
    isTodaySelected = true;
    isTextEmpty = true;
    fieldNode = FocusNode();
    fieldCon = TextEditingController();
    fieldCon.addListener(() {
      textControllerListener();
    });
    todayDate = DateTime.now();
    focusDate = DateTime.now();
  }

  LinkedHashMap<DateTime, List<CalendarModel>> kEvents =
      LinkedHashMap<DateTime, List<CalendarModel>>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  void cancelField() {
    fieldCon.clear();
  }

  textControllerListener() {
    if (isTextEmpty != fieldCon.text.isEmpty) {
      isTextEmpty = fieldCon.text.isEmpty;
      notifyListeners();
    }
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    isTodaySelected = isSameDay(focusedDay, todayDate);
    focusDate = focusedDay;
    notifyListeners();
  }

  Future<void> getLocalDBData() async {
    final dbDatas = await DBHelper().getCalendarData();
    final onlineDBData = (await downloadAndParseCsv())
        .map((e) => e.copyWith(updateCanEdit: false));
    overAllCalendarData = [...dbDatas, ...onlineDBData];
    Map<DateTime, List<CalendarModel>> kEventSource = {};
    List<DateTime> importedDates = [];
    for (var event in overAllCalendarData) {
      final parseDate = DateTime.parse(event.date ?? DateTime.now().toString());
      final dateInFormat =
          DateTime(parseDate.year, parseDate.month, parseDate.day);
      if (!importedDates.contains(dateInFormat)) {
        importedDates.add(dateInFormat);
        final fetchedEventOfDate = overAllCalendarData.where((element) {
          final elementDate =
              DateTime.parse(element.date ?? DateTime.now().toString());
          return isSameDay(elementDate, dateInFormat);
        }).toList();

        kEventSource[dateInFormat] = fetchedEventOfDate;
      }
    }
    kEvents.addAll(kEventSource);

    notifyListeners();
  }

  Future<void> addCalendarData() async {
    log('${editData == null}');
    if (editData == null) {
      final newData =
          CalendarModel(title: fieldCon.text, date: focusDate.toString());
      try {
        await DBHelper().saveCalendarData(newData);
        overAllCalendarData = [...overAllCalendarData, newData];
        kEvents[focusDate] = [...kEvents[focusDate] ?? [], newData];
        notifyListeners();
        cancelField();
        Constants.showToast('Saved Data Successfully');
      } catch (e) {
        log('Error Adding Calendar Data: $e');
      }
    } else {
      final updatedData =
          editData?.copyWith(newTitle: fieldCon.text) ?? CalendarModel();
      try {
        await DBHelper().updateCalendarData(updatedData);
        final updatedDataIndex = overAllCalendarData
            .indexWhere((element) => element.id == editData?.id);
        if (updatedDataIndex != -1) {
          overAllCalendarData[updatedDataIndex] = updatedData;
        }
        final kEventsData = kEvents[focusDate];
        final kEventsDataIndex =
            kEventsData?.indexWhere((element) => element.id == editData?.id);
        if (kEventsDataIndex != -1 && kEventsDataIndex != null) {
          kEvents[focusDate]![kEventsDataIndex] = updatedData;
        }
        editData = null;
        cancelField();
        Constants.showToast('Updated Data Successfully');
        notifyListeners();
      } catch (e) {
        log('Error Updating Calendar Data: $e');
      }
    }
  }

  Future<void> deleteCalendarData(CalendarModel data) async {
    log('Delete Calendar ID: ${data.id}');
    try {
      await DBHelper().deleteCalendarData(data.id ?? 0);
      kEvents[focusDate]?.remove(data);
      Constants.showToast('Deleted Data Successfully');
      notifyListeners();
    } catch (e) {
      log('Error Deleting Calendar Data: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    fieldCon.dispose();
  }
}
