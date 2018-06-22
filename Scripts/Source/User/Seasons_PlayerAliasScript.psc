Scriptname Seasons_PlayerAliasScript extends ReferenceAlias


; Seasons Reminder
; by Dracotorre
;
; Watches load game event and location change to call main script.

Quest property Seasons_ReminderQuest auto

Event OnPlayerLoadGame()
	
	
	StartTimer(3.0, 103)
EndEvent

Event OnTimer(int aiTimerID)
	if (aiTimerID == 103)
		
		(Seasons_ReminderQuest as Seasons_ReminderQuestScript).CheckDayForReminder()
	endIf
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	StartTimer(3.0, 103)
endEvent

