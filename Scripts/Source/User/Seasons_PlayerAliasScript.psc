Scriptname Seasons_PlayerAliasScript extends ReferenceAlias

GlobalVariable property Seasons_DOW auto		; added v1.14 to patch missing property connection in ESL

; Seasons Reminder
; by Dracotorre
;
; Watches load game event and location change to call main script.

Quest property Seasons_ReminderQuest auto

Event OnPlayerLoadGame()
	
	(Seasons_ReminderQuest as Seasons_ReminderQuestScript).CurrentDOWVal = -2	; force reset
	
	StartTimer(3.0, 103)
EndEvent

Event OnTimer(int aiTimerID)
	if (aiTimerID == 103)
		
		(Seasons_ReminderQuest as Seasons_ReminderQuestScript).CheckDayForReminder()
		VerifyDOW()
	endIf
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	StartTimer(3.0, 103)
endEvent

Function VerifyDOW()
	if (Seasons_DOW != None)
	
		if (Seasons_DOW.GetValueInt() < 0 || (Seasons_ReminderQuest as Seasons_ReminderQuestScript).DOWInvalid)
		
			int dow = (Seasons_ReminderQuest as Seasons_ReminderQuestScript).CurrentDOWVal
			
			if (dow >= 0 && dow <= 6)
				Seasons_DOW.SetValueInt(dow)
			endIf
		endIf
	endIf
endFunction