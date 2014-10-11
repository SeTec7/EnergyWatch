A mobile, configurable Energy/Focus/Mana/Rage/Runic Power bar with Combo Point/Holy Power/Soul Shard tracking

The text for the bar can be easily changed to suit your preference in the configuration menu.

EnergyWatch Reborn : Usage - /ew <option>
 Options:
  lock          : Locks Energy Watch bar's position
  unlock        : Locks Energy Watch bar's position
  config	: Open addon config menu (found in Addon tab in Blizzard's Interface menu)
  reset         : Resets bar scale, alpha and position to defaults


ChangeLog
6.0.0
------------------------
Added Death Knight Runes to the bar
Removed deprecated bar scale options
Switched to using Blizzard's IsStealthed() call
Updated TOC for 6.0


5.4.0
------------------------
Updated TOC for 5.4.0

5.3.0
------------------------
Configuration sliders now allow values to be entered by hand
Updated TOC for 5.3.0

5.2.0
------------------------
Updated TOC for 5.2.0

5.1.1
------------------------
Fixed tracking of Monk Chi points

5.1.0
------------------------
Updated TOC for 5.1.0

5.0.4.1
------------------------
Fixed bar not initializing properly in some situations.

5.0.4
------------------------
Updated addon for 5.0.4
Addon now works for Monks, tracking mana, energy, and Chi points
Made addon aware of Talent Specializations
Addon now tracks secondary powers for all 3 Warlock specs, Balance Druids, Shadow Priests
Added option to disable large number abbreviation

4.3.2
------------------------
Added ability to change bar texture
Gave bar text a thin outline to improve readability

4.3.1
------------------------
Modified bar text display to abbreviate large numbers a la boss health bars (i.e. 27.9 K instead of 27943)
Update TOC for 4.3

4.3.0
------------------------
Added Bar Height option
Added font and font size option
Added Bar lock option to configuration UI
Removed Bar Scale option (unnecessary with width and height controls)
Slight cleanup of config UI
Updated TOC for 4.2

4.2.1
------------------------
Updated TOC for 4.1

4.2.0
------------------------
Energy Watch bar now remembers it's location if it is disabled and re-enabled
New bar text replacement: &ep = percentage of max energy
New show option: Show when your energy is not at it's default level (0 for Rage/Runic Power, max for all others)

4.1.1
------------------------
Added ability to change the bar width
Moved bar appearance options to config sub-panel
Removed a debug print left in from last version (oops!)

4.1.0
------------------------
Energy Watch now works with any power type (Energy, Focus, Rage, Runic Power, Mana)
Soul Shards and Holy Power supported

4.0.2
------------------------
Bar no longer blocks clicks when locked

4.0.1
------------------------
Fixed scale and alpha not being applied on login
Fixed bug with config reset

4.0 
------------------------
Complete rewrite from scratch for WoW 4.0
GUI Config menu
Now supports hunters (Focus!)
Major efficiency improvements


Author
OneWingedAngel -- Entreri of Silvermoon

Original Concept
Vector- - Kerryn of Laughing Skull
Repent -- Shadoh of Laughing Skull
