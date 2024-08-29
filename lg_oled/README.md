# LG OLED & LCD Service Menu + Tips

### Warning For The Squeamish
My tv is a refurb so I am not concerned with the warranty.<br>
However, there is a chance that using the service menu "could" void your warranty.<br>
You have been warned.

### Includes
- Initial setup tips to minimize data sharing and ads
- Full Service Menu on C3 & G3 without using power only or factory mode
- How to connect tv to Windows for use with [ColorControl](https://github.com/Maassoft/ColorControl "ColorControl")
- How to disable Dimming, TPC, and GSR
	- Visit [TFT Central](https://tftcentral.co.uk/articles/oled-dimming-confusion-apl-abl-asbl-tpc-and-gsr-explained "TFT Central") to explain the acronyms above
- Useful hidden menu to hide lg logo and/or no signal wallpaper

### Problems
- C3 & G3 (Maybe x4 series as well?) OLED TVs have a limited service menu by default
<br>![Limited Service Menu](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/limited_menu.jpg "Limited Service Menu")
- Using P-Only (Power Only) mode causes Factory Mode message when powered on
<br>![Factory Mode](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/factory_mode.jpg "Factory Mode")

### Recommended
- Have a computer on the same network as the tv
- Reset the tv to have a common clean starting place
	- Currently have the Factory Mode screen?
		- Simply follow the onscreen message to reset

### Initial Setup
1. When doing the first time setup one can skip the second half
	- Select Exit First Use when at the How to set up the TV screen
<br>![Skip First Use](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/skip_first_use.jpg "Skip First Use")
1. Change the LG Services Country to Others
	- Settings -> General -> System -> Location -> LG Services Country
	- Unselect Set Automatically first then select Others
<br>![Country Others](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/set_country_others.jpg "Country Others")
1. Disable Screen Saver Promotion
	- Settings -> General -> System -> Additional Settings
	- Disable Screen Saver Promotion
<br>![Disable Screen Saver Promotion](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/disable_ads_03-screen_saver_promo.jpg "Disable Screen Saver Promotion")
1. Disable Home Promotion and Content Recommendation
	- Settings -> General -> System -> Additional Settings -> Home Settings
	- Disable Home Promotion and Content Recommendation
<br>![Disable Home Promotion and Content Recommendation](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/disable_ads_04-home_promo_content.jpg "Disable Home Promotion and Content Recommendation")
1. Disable AI Recommendation Smart Tips
	- Settings -> General -> AI Service -> AI Recommendation
	- Disable Smart Tips
<br>![Disable Smart Tips](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/disable_ads_01-smart_tips.jpg "Disable Smart Tips")
1. Disable OLED Panel Care Recommendations
	- Settings -> General -> OLED Care -> OLED Panel Care
	- Disable Care Recommendations
<br>![Disable Care Recommendations](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/disable_ads_02-care_tips.jpg "Disable Care Recommendations")

### Disable LG Logo and No Signal Wallpaper
1. Using the original tv remote close any tv menus
1. Press the mute button 5 times
1. This should open the hidden menu
	- Auto Power Sync controls whether the tv will turn on when external devices are powered
	- Show LG logo when turning off the TV controls whether the LG logo on shutdown is shown
	- No Signal Image controls whether the no signal wallpaper is shown
<br>![Hidden Menu](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/disable_logo_wallpaper.jpg "Hidden Menu")

### Enabling Full Service Menu
1. Enable Remote Control Service on tv
	- Settings -> General -> External Devices -> TV On With Mobile
	- Enable Turn on via Wi-Fi (this includes lan connections)
<br>![Turn on via Wi-Fi](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/enable_remote_control.jpg "Turn on via Wi-Fi")
1. Be sure tv is connected to same network as Windows
	- On Windows test connection in browser via https://tv_ip_goes_here:3001
		- Should see Hello world
1. Adding the tv to Windows 11
	- Open Windows Settings -> Bluetooth & devices -> Devices -> More devices and printer settings (bottom of page)
	- Click Add Device (top left)
	- Look for tv [LG] webOS TV xxxxxxxx
		- Select the entertainment device if multiple entries
	- Wait for install
<br>![Add Device](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/add_tv_windows.jpg "Add Device")
1. Download latest [ColorControl](https://github.com/Maassoft/ColorControl "ColorControl")
	- Extract it someplace
	- Right click ColorControl.exe -> Properties
	- Compatibility tab -> Run this program as administrator
	- Click Apply -> Ok
<br>![Run As Admin](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/cc_01-set_run_as_admin.jpg "Run As Admin")
1. Run ColorControl
	- Verify that it is running as administrator
		- It may complain that it cannot detect a LG tv
<br>![Ran As Admin](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/cc_02-verify_run_as_admin.jpg "Ran As Admin")
	- Goto the Options tab and for this guide enable only the LG controller Module
<br>![CC Options](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/cc_03-options.jpg "CC Options")
1. Close & relaunch ColorControl
1. Goto LG controller tab
	- If device is NOT auto-detected
		- Try removing the device filter
			- Hit Refresh and check the Device dropdown
		- Try visiting https://tv_ip_goes_here:3001
			- Should see Hello world
			- If not check tv settings, connection and if same network
<br>![CC LG Controller](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/cc_04-lg_controller.jpg "CC LG Controller")
1. Be sure to allow ColorControl access on the tv
	- A message box will pop up
<br>![Allow Device](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/allow_device.jpg "Allow Device")
	- Confirm its working by using Settings... -> Test power off/on
<br>![Test Power off/on](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/cc_06-lg_test.jpg "Test Power off/on")
1. Assuming tv is detected and successful power test, continue
1. Click Settings... -> Settings on the LG controller tab
<br>![LG Settings](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/cc_07-lg_set_settings.jpg "LG Settings")
	- Enable Show advanced actions under the Expert-button
	- Click ok
<br>![Advanced Settings](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/cc_08-lg_settings.jpg "Advanced Settings")
1. Click Expert... -> Enable Full Service Menu -> Enable
	- Click yes to accept
<br>![Enable Full Service Menu](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/cc_09-enable_full_service_menu.jpg "Enable Full Service Menu")
1. Have a service remote?
	- Pressing InStart button will now open the full service menu
	- Password 0413
1. If you dont have the remote
	- Expert... -> InStart
		- This will enter the code 0413 automatically
<br>![InStart](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/cc_10-open_service_menu.jpg "InStart")
1. Service Menu is now permanantly unlocked
	- Any settings changed will remain after reboot
	- No Factory Mode messages

### Disable Dimming, TPC & GSR
1. Once in the full Service Menu
	- Use the original tv remote as usual once the menu is open
	- Using the service remote, InStart is the back button
1. Goto OLED
	- Set TPC Enable to Off
<br>![TPC](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/service_menu_01-oled_tpc.jpg "TPC")
	- Set GSR Enable to Off
<br>![GSR](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/service_menu_02-oled_gsr.jpg "GSR")
1. Goto System 1
	- I left this one on as it seems to disable control of the screen brightness and locks it to 100%
	- Set Dimming to Off
<br>![Dimming](https://raw.githubusercontent.com/fritolays/notes/main/lg_oled/images/service_menu_03-system1_dimming.jpg "Dimming")
1. Now just exit the Service Menu
	- Home button on the original tv remote
	- Exit on the service remote

### Sources
- https://www.reddit.com/r/OLED_Gaming/comments/sbords/how_to_access_lg_service_menu_without_the_service/
- https://www.reddit.com/r/OLED_Gaming/comments/14q96i4/huge_update_for_gamers_lg_g3c3_oled_still_can/
- https://www.youtube.com/watch?v=yhunCUzlDOQ
- https://www.reddit.com/r/OLED_Gaming/comments/17n7nt9/getting_an_lg_c3_is_the_auto_dimming_problem/
- https://www.reddit.com/r/LGOLED/comments/14k0hj2/turning_tpc_gsr_off_on_lg_c3/
- https://www.reddit.com/r/OLED_Gaming/comments/1bsz17k/shortened_service_menu_after_lg_c2_upgrade_to/
