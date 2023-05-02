/*
	Autor: MisterCreator74
	Version: 1.1.4
	Beschreibung:
	Beinhaltet alle grundlegenden Einstellungen für Arma 3 Advanced Scripts.
	
*/

_Version = "1.1.5 stable, unfinished alpha";;

// 1.Debug Settings:
show_debug_hints = false;
debug_hint_time = 5;
repeat_Array_hints = false;


//2. Project CombinedArms:
use_project_combinedarms = true;
startup_delay = 15;
use_AICombat = true;
use_AIOrders = true;				//requieres use_AICombat = true
use_AI = true;						//requieres use_AICombat = true
use_CaptureMarkers = true; 

// Kicks Player on friendly fire
serverPassword = "";
use_playerKick = true;

//3. Random Events:
use_random_events = false;


//4. Addons:
//4.1 Dynamic Ressources:
use_dynamic_ressources = false;

//4.2 Advanced Garbage Collector
use_advanced_garbagecollector = false;









//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
// Starten der Scripte nach Spielerwunsch
// Hier NICHTS verändern!!!
//Anzeigen der Debug Hinweise:
if (show_debug_hints == true) then 
	{	
		settingsArray = [show_debug_hints, use_project_combinedarms, use_AICombat, use_AIOrders, use_AI, use_playerKick, use_CaptureMarkers, use_dynamic_ressources, use_random_events];

		{if (_x == true) then
			{
				settingsArray set [_forEachIndex, parseText format ["<t color='#008000'>true</t>"]];
			} 
			else
			{
				settingsArray set [_forEachIndex, parseText "<t color='#FF0000'>false</t>"];
			};
		}foreach settingsArray;
		
		_head = parseText "<t size='2.0'>Debugmenu:</t>";
		_ver = parseText "<br/><t color='#0088ff'>Version:  </t>";
		_separator = parseText "<br/>--------------------------------------------------------<br/>";
		_text1 = parseText "<br/><br/>Debug Hints:                                                 ";
		_text2 = parseText "<br/>Project CombinedArms (main project):  ";
		_text3 = parseText "<br/>enable combat (Array scripts):                 ";
		_text4 = parseText "<br/>enable orders (order scripts):                    ";
		_text5 = parseText "<br/>enable bots (spawning them):                   ";
		_text6 = parseText "<br/>enable PlayerKick (friendly fire addon): ";
		_text7 = parseText "<br/>enable capture markers (map addon):   ";
		_text8 = parseText "<br/>enable dynamic ressources (addon):     ";
		_text9 = parseText "<br/>enable Random Events:                             ";
		_debugMenu = composeText [_head, _ver,_Version, _separator, "Settings can be made in main_settings.sqf",_text1, settingsArray select 0 , _text2, settingsArray select 1, _text3, settingsArray select 2,
									_text4, settingsArray select 3, _text5, settingsArray select 4, _text6, settingsArray select 5, _text7, settingsArray select 6, _text8, settingsArray select 7, _text9, settingsArray select 8];

		hint _debugMenu;
		sleep debug_hint_time;
		
		hint "";
	};
	

if (use_project_combinedarms == true) then 
		{
			[] execVM "ProjectCombinedArms\Settings\AICombat_settings.sqf";
			[] execVM "ProjectCombinedArms\BigBossSkripts\CityTrigger.sqf";
			if (use_CaptureMarkers == true) then
				{
					[] execVM "ProjectCombinedArms\AdditionalContent\CaptureMarkers.sqf";
				};
			
			if (use_AICombat == true) then 
			{
				[] execVM "ProjectCombinedArms\BigBossSkripts\SideArraySorting.sqf";
				[] execVM "ProjectCombinedArms\BigBossSkripts\GroupArrayVariablen.sqf";
				
				
				if (use_AI == true) then
				{
					[] execVM "ProjectCombinedArms\BigBossSkripts\SpawnAI.sqf";
				};
				if (use_AIOrders)then
				{
					[] execVM "ProjectCombinedArms\BigBossSkripts\AIOrderVariablen.sqf";
				};
			};
			
			
		};
		
if (use_playerKick == true) then 
		{
			[] execVM "ProjectCombinedArms\AdditionalContent\PlayerKick.sqf";
		};

if (use_random_events == true) then 
		{
			
		};
if (use_dynamic_ressources == true) then 
		{
			
		};
if (use_advanced_garbagecollector == true) then 
		{
			[] execVM "ProjectCombinedArms\AdditionalContent\Garbage Collector.sqf";
		};