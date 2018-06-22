Scriptname Seasons_ReminderQuestScript extends Quest

; Seasons Reminder
; by Dracotorre
;
; Display notification for first day of each season and holidays.
; For first day of season, we allow an extra day in case player 
; manages to go through day without sleeping, traveling, or loading.
;
; note: assume normal game progression and not skipping around dates
;
; This script watches player sleep event
; See the Seasons_PlayerAliasScript for other events including load game and location change.


GlobalVariable Property GameMonth Auto Const
GlobalVariable Property GameDay Auto Const
GlobalVariable property Seasons_SettingHolidaysEnabled auto const
{ show holiday notification setting }
GlobalVariable property Seasons_SettingShowReminder auto const
{ enable notification setting }
Message property Seasons_RemindAutumnMsg auto const
Message property Seasons_RemindSpringMsg auto const
Message property Seasons_RemindSummerMsg auto const
Message property Seasons_RemindWinterMsg auto const
Message property Seasons_RemindNewYearMsg auto const
Message property Seasons_RemindIndependenceDayMsg auto const
Message property Seasons_RemindHalloweenMsg auto const
Message property Seasons_RemindChristmasMsg auto const
Message property Seasons_RemindPatrickDayMsg auto const
Message property Seasons_RemindRobCoDayMsg auto const
Message property Seasons_RemindNukaWorldDayMsg auto const
Message property Seasons_RemindNukaQuantumMsg auto const
Message property Seasons_RemindBostonTeaPartyMsg auto const
Message property Seasons_RemindMrPebblesDayMsg auto const

int hasShownReminderDay = 0		; flag if shown to limit once per day
int lastCheckedDay = 0          ; to short-circuit checking same day

Event OnQuestInit()
	RegisterForPlayerSleep()
	StartTimer(4.0, 101) 
EndEvent

Event OnTimer(int aiTimerID)
	if (aiTimerID == 101)
		CheckDayForReminder()
	endIf
EndEvent

Event OnPlayerSleepStop(bool abInterrupted, ObjectReference akBed)
	
	StartTimer(8.0, 101)
endEvent

Function CheckDayForReminder()
	int day = GameDay.GetValueInt()
	int month = GameMonth.GetValueInt()
	
	; check notification setting here at end so may short-circuit to reset flags
	;
	if (hasShownReminderDay <= 0 && lastCheckedDay != day && Seasons_SettingShowReminder.GetValueInt() > 0)
		
		if (Seasons_SettingHolidaysEnabled.GetValueInt() > 0 && month == 1 && day == 1)
			ShowReminder(Seasons_RemindNewYearMsg, day)
		elseIf (month == 3)
			if (day == 17 && Seasons_SettingHolidaysEnabled.GetValueInt() > 0)
				ShowReminder(Seasons_RemindPatrickDayMsg, day)
			elseIf (day >= 20 && day < 22)
				; allow an extra day
				ShowReminder(Seasons_RemindSpringMsg, day)
			endIf
		elseIf (month == 5)
			if (day == 1 && Seasons_SettingHolidaysEnabled.GetValueInt() > 0)
				ShowReminder(Seasons_RemindNukaWorldDayMsg, day)
			endIf
		elseIf (month == 6)
			if (day >= 20 && day < 22)
				ShowReminder(Seasons_RemindSummerMsg, day)
			elseIf (day == 25 && Seasons_SettingHolidaysEnabled.GetValueInt() > 0)
				ShowReminder(Seasons_RemindRobCoDayMsg, day)
			endIf
		elseIf (month == 7)
			if (day == 4 && Seasons_SettingHolidaysEnabled.GetValueInt() > 0)
				ShowReminder(Seasons_RemindIndependenceDayMsg, day)
			endIf
		elseIf (month == 9 && day >= 21 && day < 23)
			ShowReminder(Seasons_RemindAutumnMsg, day)
		elseIf (month == 10)
			if (day == 20 && Seasons_SettingHolidaysEnabled.GetValueInt() > 0)
				ShowReminder(Seasons_RemindNukaQuantumMsg, day)
			elseIf (day == 31 && Seasons_SettingHolidaysEnabled.GetValueInt() > 0)
				ShowReminder(Seasons_RemindHalloweenMsg, day)
			endIf
		elseIf (month == 11)
			if (day == 3 && Seasons_SettingHolidaysEnabled.GetValueInt() > 0)
				ShowReminder(Seasons_RemindMrPebblesDayMsg, day)
			endIf
		elseIf (month == 12)
			if (day == 16 && Seasons_SettingHolidaysEnabled.GetValueInt() > 0)
				ShowReminder(Seasons_RemindBostonTeaPartyMsg, day)
			elseIf (day >= 21 && day < 23)
				ShowReminder(Seasons_RemindWinterMsg, day)
			elseIf (Seasons_SettingHolidaysEnabled.GetValueInt() > 0 && day == 25)
				ShowReminder(Seasons_RemindChristmasMsg, day)
			endIf		
		endIf
		
		; flag to skip same day
		lastCheckedDay = day
		
	elseIf (day != hasShownReminderDay)
	
		if (day > (hasShownReminderDay + 1))
			; 2+ days after (since we allow extra day) - reset flag
			hasShownReminderDay = -1
		elseIf (day < hasShownReminderDay)
			; reset flag
			hasShownReminderDay = -1
		endIf
	endIf
endFunction

Function ShowReminder(Message msg, int flagVal)
		
	msg.Show()
	hasShownReminderDay = flagVal
endFunction