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

Quest property MQ101 auto const
Quest property MQ102 auto const
GlobalVariable property GameYear auto const		; ESL version -- might be None for some players prior v1.12
GlobalVariable property GameMonth Auto Const
GlobalVariable property GameDay Auto Const
GlobalVariable property Seasons_SettingHolidaysEnabled auto const
{ show holiday notification setting }
GlobalVariable property Seasons_SettingShowReminder auto const
{ enable notification setting }
GlobalVariable property Seasons_DOW auto		; ESL version -- might be None for some players prior v1.12
{ day of week; 0 = Sunday ... 6 = Saturday }
Message property Seasons_RemindAutumnMsg auto const
Message property Seasons_RemindSpringMsg auto const
Message property Seasons_RemindSummerMsg auto const
Message property Seasons_RemindWinterMsg auto const
Message property Seasons_RemindNewYearMsg auto const
Message property Seasons_RemindIndependenceDayMsg auto const
Message property Seasons_RemindHalloweenMsg auto const
Message property Seasons_RemindChristmasMsg auto const
Message property Seasons_RemindPatrickDayMsg auto const
Message property Seasons_RemindValentineDayMsg auto const
Message property Seasons_RemindRobCoDayMsg auto const
Message property Seasons_RemindNukaWorldDayMsg auto const
Message property Seasons_RemindNukaQuantumMsg auto const
Message property Seasons_RemindBostonTeaPartyMsg auto const
Message property Seasons_RemindMrPebblesDayMsg auto const
Message property Seasons_RemindGreatWarMsg auto const

int property CurrentDOWVal = -1 auto hidden
bool property DOWInvalid = false auto hidden

int hasShownReminderDay = 0		; flag if shown to limit once per day
int lastCheckedDay = 0          ; to short-circuit checking same day
int lastDOWUpdateDay = -1		; day of week last checked day
int lastDOWUpdateMonth = -1

Event OnQuestInit()
	RegisterForPlayerSleep()
	; wait to register for menu - added v1.11
	
	StartTimer(4.0, 101) 
EndEvent

Event OnTimer(int aiTimerID)
	if (aiTimerID == 101)
		CheckDayForReminder()
	endIf
EndEvent

;
; Pipboy open/close Menu event - v1.11
; if new day need to update day-of-week for holotape display
; this handles case after midnight
; and before location change 
;
Event OnMenuOpenCloseEvent(string asMenuName, bool abOpening)
	
    if (asMenuName== "PipboyMenu")
        if (abOpening)
			
			CheckDayForDOW()
        endIf
    endIf
endEvent

Event OnPlayerSleepStop(bool abInterrupted, ObjectReference akBed)
	
	StartTimer(8.0, 101)
endEvent

;
; Day-of-Week check - added v1.10
;
Function CheckDayForDOW()
	int day = GameDay.GetValueInt()
	int month = GameMonth.GetValueInt()
	
	; check month in case user skips dates
	if (lastDOWUpdateDay != day || lastDOWUpdateMonth != month || CurrentDOWVal < 0)
		
		CurrentDOWVal = DayOfWeek()
		
		if (Seasons_DOW != None)
			; update day of week
			Seasons_DOW.SetValueInt(CurrentDOWVal)
			
			DOWInvalid = false
		else
			DOWInvalid = true
		endIf
		
		; mark day as checked
		lastDOWUpdateDay = day
		lastDOWUpdateMonth = month
		
	endIf
endFunction

;
; notification only if new day
;
Function CheckDayForReminder()
	int day = GameDay.GetValueInt()
	int month = GameMonth.GetValueInt()
	int checkDOW = -2
	float gTime = Utility.GetCurrentGameTime()
	
	if (MQ101.IsRunning() && !MQ101.IsCompleted())
		; intro -- wait until later
		return

	elseIf (MQ102.IsRunning() && MQ102.GetStageDone(10) == 0)
		; still in vault 111
		return
	endIf
	
	; edit for checkDOW - some users pre-1.12 may be missing property
	if (Seasons_DOW != None)
		checkDOW = Seasons_DOW.GetValueInt()
	else
		checkDOW = CurrentDOWVal
	endIf
	
	; ---- Day-of-Week (DOW) - v1.10 -- edited v1.14
	;
	if (checkDOW < 0 || lastDOWUpdateDay < 0 || checkDOW > 6)
	
		; register menu to update DOW to handle case after midnight
		;
		RegisterForMenuOpenCloseEvent("PipboyMenu")

		; force all checks now
		hasShownReminderDay = -2
		lastCheckedDay = -1
		lastDOWUpdateDay = -1
	endIf
	
	CheckDayForDOW()
	; --------------
	
	
	
	; check notification setting here at end so may short-circuit to reset flags
	;
	if (gTime > 0.9 && hasShownReminderDay <= 0 && lastCheckedDay != day && Seasons_SettingShowReminder.GetValueInt() > 0)
		
		if (Seasons_SettingHolidaysEnabled.GetValueInt() > 0 && month == 1 && day == 1)
			ShowReminder(Seasons_RemindNewYearMsg, day)
		elseIf (month == 2 && day == 14)
			ShowReminder(Seasons_RemindValentineDayMsg, day)
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
			elseIf (day == 23 && Seasons_SettingHolidaysEnabled.GetValueInt() > 0)
				ShowReminder(Seasons_RemindGreatWarMsg, day)
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

; 0 = Sunday ... 6 = Saturday
int Function DayOfWeek()

	; Zeller's Rule
	; f = k + [(13*m-1)/5] + D + [D/4] + [C/4] - 2*C.
	
	int k = GameDay.GetValueInt()
	int m = GameMonth.GetValueInt() - 2  ; march = 1 for convenience after leap-year
	int C = 22  ; first 2 digits of year
	int D = 0
	if (GameYear != None)
		D = GameYear.GetValueInt() ; 3 digits
		D -= 200 ; last 2 digits
	endIf 
	
	if (m <= 0)
		m += 12
		D -= 1	; previous year
	endIf
	
	if (D < 87)
		D = 87
		float gameTimeDay = Utility.GetCurrentGameTime()
		if (gameTimeDay > 69.0 && gameTimeDay < 436.0)
			; a leap-year - 366 days
			D = 88
		elseIf (gameTimeDay < 801.0)
			D = 89
		else
			D = 90 + Math.Floor((gameTimeDay - 800.0) / 365.24)
		endIf
	endIf
	
	
	int f = k + ((13 * m - 1) / 5) as int + D + (D / 4) as int + (C / 4) as int - 2 * C
	
	int div7 = f / 7
	int remainder = f - (7 * div7)
	if (remainder < 0)
		remainder += 7
	endIf
	
	;Debug.Trace("[Seasons] D = " + D + ", f = " + f + ", r = " + remainder)
	
	return remainder 
endFunction


Function ShowReminder(Message msg, int flagVal)
		
	msg.Show()
	hasShownReminderDay = flagVal
endFunction