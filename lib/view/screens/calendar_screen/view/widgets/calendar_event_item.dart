import 'package:biblebookapp/view/constants/colors.dart';
import 'package:biblebookapp/view/screens/calendar_screen/bloc/calendar_data_bloc.dart';
import 'package:biblebookapp/view/screens/calendar_screen/model/calendar_model.dart';
import 'package:biblebookapp/view/screens/dashboard/constants.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CalendarEventItem extends HookConsumerWidget {
  final CalendarModel calendarModel;
  const CalendarEventItem({super.key, required this.calendarModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            height: 28,
            width: 4,
            color: CommanColor.calendarSelectedColor(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              calendarModel.title ?? '',
              style: const TextStyle(
                  letterSpacing: BibleInfo.letterSpacing,
                  fontSize: BibleInfo.fontSizeScale * 16,
                  fontWeight: FontWeight.w400),
            ),
          ),
          if (calendarModel.canEdit) ...[
            GestureDetector(
              onTap: () {
                ref.read(calendarDataBloc).editCalendar(calendarModel);
              },
              child: Icon(
                Icons.edit_calendar_rounded,
                color: CommanColor.calendarSelectedColor(context),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                ref.read(calendarDataBloc).deleteCalendarData(calendarModel);
              },
              child: Icon(
                Icons.delete,
                color: CommanColor.calendarSelectedColor(context),
              ),
            )
          ],
        ],
      ),
    );
  }
}
