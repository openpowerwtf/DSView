##
## This file is part of the PulseView project.
##
## Copyright (C) 2013-2020 Uwe Hermann <uwe@hermann-uwe.de>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.
##


# Include the "Modern UI" header, which gives us the usual Windows look-n-feel.
!include "MUI2.nsh"

# Include the file association header so that we can register file extensions.
!include "FileAssociation.nsh"


# --- Global stuff ------------------------------------------------------------

# Installer/product name.
Name "WTFDSView"

# Filename of the installer executable.
OutFile "wtf-dsview-0.5.0-git-105ecff-installer.exe"

# Where to install the application.
!ifdef PE64
	InstallDir "$PROGRAMFILES64\wtf\DSView"
!else
	InstallDir "$PROGRAMFILES\wtf\DSView"
!endif

# Request admin privileges for Windows Vista and Windows 7.
# http://nsis.sourceforge.net/Docs/Chapter4.html
RequestExecutionLevel admin

# Local helper definitions.
!define REGSTR "Software\Microsoft\Windows\CurrentVersion\Uninstall\WTFDSView"


# --- MUI interface configuration ---------------------------------------------

# Use the following icon for the installer EXE file.
!define MUI_ICON "../logo-win.ico"

# Show a nice image at the top of each installer page.
!define MUI_HEADERIMAGE

# Don't automatically go to the Finish page so the user can check the log.
!define MUI_FINISHPAGE_NOAUTOCLOSE

# Upon "cancel", ask the user if he really wants to abort the installer.
!define MUI_ABORTWARNING

# Don't force the user to accept the license, just show it.
# Details: http://trac.videolan.org/vlc/ticket/3124
!define MUI_LICENSEPAGE_BUTTON $(^NextBtn)
!define MUI_LICENSEPAGE_TEXT_BOTTOM "Click Next to continue."

# Path where the cross-compiled sigrok tools and libraries are located.
# Change this to where-ever you installed libsigrok.a and so on.
!define CROSS "/dsview/dsview_win64_release_64"

# Defines for WinAPI SHChangeNotify call.
!define SHCNE_ASSOCCHANGED 0x8000000
!define SHCNF_IDLIST 0


# --- Functions/Macros --------------------------------------------------------

Function register_sr_files
	${registerExtension} "$INSTDIR\DSView.exe" ".sr" "sigrok session file"

	# Force Windows to update the icon cache so that the icon for .sr files shows up.
	System::Call 'Shell32::SHChangeNotify(i ${SHCNE_ASSOCCHANGED}, i ${SHCNF_IDLIST}, i 0, i 0)'
FunctionEnd

# Inspired by http://nsis.sourceforge.net/Create_Internet_Shorcuts_during_installation
!Macro "CreateURL" "URLFile" "URLSite" "URLDesc"
	WriteINIStr "$INSTDIR\${URLFile}.URL" "InternetShortcut" "URL" "${URLSite}"
	CreateShortCut "$SMPROGRAMS\wtf\DSView\${URLFile}.lnk" "$INSTDIR\${URLFile}.url" "" \
		"$INSTDIR\DSView.exe" 0 "SW_SHOWNORMAL" "" "${URLDesc}"
!MacroEnd

# --- MUI pages ---------------------------------------------------------------

# Show a nice "Welcome to the ... Setup Wizard" page.
!insertmacro MUI_PAGE_WELCOME

# Show the license of the project.
!insertmacro MUI_PAGE_LICENSE "../COPYING"

# Show a screen which allows the user to select which components to install.
!insertmacro MUI_PAGE_COMPONENTS

# Allow the user to select a different install directory.
!insertmacro MUI_PAGE_DIRECTORY

# Perform the actual installation, i.e. install the files.
!insertmacro MUI_PAGE_INSTFILES

# Insert the "Show Readme" button in the finish dialog. We repurpose it for
# registering the .sr file extension. This way, we don't need to add in-depth
# modifications to the finish page.
!define MUI_FINISHPAGE_SHOWREADME ""
!define MUI_FINISHPAGE_SHOWREADME_CHECKED
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Register .sr files with DSView"
!define MUI_FINISHPAGE_SHOWREADME_FUNCTION register_sr_files

# Show a final "We're done, click Finish to close this wizard" message.
!insertmacro MUI_PAGE_FINISH

# Pages used for the uninstaller.
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH


# --- MUI language files ------------------------------------------------------

# Select an installer language (required!).
!insertmacro MUI_LANGUAGE "English"


# --- Default section ---------------------------------------------------------

Section "DSView (required)" Section1
	# This section is gray (can't be disabled) in the component list.
	SectionIn RO

	# Install the file(s) specified below into the specified directory.
	SetOutPath "$INSTDIR"

	# License file.
	File "../COPYING"

	# DSView (statically linked, includes all libs).
	File "${CROSS}/bin/DSView.exe"

	# Zadig (used for installing WinUSB drivers).
	File "${CROSS}/zadig.exe"
	File "${CROSS}/zadig_xp.exe"

	# Python
	File "${CROSS}/python34.dll"
	File "${CROSS}/python34.zip"
	File "${CROSS}/*.pyd"

	SetOutPath "$INSTDIR\share"

	# Protocol decoders.
	File /r /x "__pycache__" /x "*.pyc" "${CROSS}/share/libsigrokdecode"

	# Firmware files.
	File /r "${CROSS}/share/sigrok-firmware"

	# Generate the uninstaller executable.
	WriteUninstaller "$INSTDIR\Uninstall.exe"

	# Create a sub-directory in the start menu.
	CreateDirectory "$SMPROGRAMS\wtf"
	CreateDirectory "$SMPROGRAMS\wtf\DSView"

	# Create a shortcut for the DSView application.
	SetOutPath "$INSTDIR"
	CreateShortCut "$SMPROGRAMS\wtf\DSView\DSView.lnk" \
		"$INSTDIR\DSView.exe" "" "$INSTDIR\DSView.exe" \
		0 SW_SHOWNORMAL \
		"" "Open-source, portable sigrok GUI"

	# Create a shortcut for the DSView application in "safe mode".
	CreateShortCut "$SMPROGRAMS\wtf\DSView\DSView (Safe Mode).lnk" \
		"$INSTDIR\DSView.exe" "-c -D" "$INSTDIR\DSView.exe" \
		0 SW_SHOWNORMAL \
		"" "Open-source, portable sigrok GUI (Safe Mode)"

	# Create a shortcut for the DSView application running in debug mode.
	CreateShortCut "$SMPROGRAMS\wtf\DSView\DSView (Debug).lnk" \
		"$INSTDIR\DSView.exe" "-l 5" "$INSTDIR\DSView.exe" \
		0 SW_SHOWNORMAL \
		"" "Open-source, portable sigrok GUI (debug log level)"

	# Create a shortcut for the uninstaller.
	CreateShortCut "$SMPROGRAMS\wtf\DSView\Uninstall DSView.lnk" \
		"$INSTDIR\Uninstall.exe" "" "$INSTDIR\Uninstall.exe" 0 \
		SW_SHOWNORMAL "" "Uninstall DSView"

	# Create a shortcut for the Zadig executable.
	CreateShortCut "$SMPROGRAMS\wtf\DSView\Zadig (DSView).lnk" \
		"$INSTDIR\zadig.exe" "" "$INSTDIR\zadig.exe" 0 \
		SW_SHOWNORMAL "" "Zadig (DSView)"

	# Create a shortcut for the Zadig executable (for Win XP).
	CreateShortCut "$SMPROGRAMS\wtf\DSView\Zadig (DSView, Win XP).lnk" \
		"$INSTDIR\zadig_xp.exe" "" "$INSTDIR\zadig_xp.exe" 0 \
		SW_SHOWNORMAL "" "Zadig (DSView, Win XP)"

	# Create shortcuts to the HTML and PDF manuals, respectively.
	#!InsertMacro "CreateURL" "PulseView HTML manual" "https://sigrok.org/doc/pulseview/unstable/manual.html" "PulseView HTML manual"
	#!InsertMacro "CreateURL" "PulseView PDF manual" "https://sigrok.org/doc/pulseview/unstable/manual.pdf" "PulseView PDF manual"

	# Create registry keys for "Add/remove programs" in the control panel.
	WriteRegStr HKLM "${REGSTR}" "DisplayName" "DSView"
	WriteRegStr HKLM "${REGSTR}" "UninstallString" \
		"$\"$INSTDIR\Uninstall.exe$\""
	WriteRegStr HKLM "${REGSTR}" "InstallLocation" "$\"$INSTDIR$\""
	WriteRegStr HKLM "${REGSTR}" "DisplayIcon" \
		"$\"$INSTDIR\DSView.ico$\""
	WriteRegStr HKLM "${REGSTR}" "Publisher" "sigrok"
	#WriteRegStr HKLM "${REGSTR}" "HelpLink" \
   #	"http://sigrok.org/wiki/PulseView"
	WriteRegStr HKLM "${REGSTR}" "URLUpdateInfo" \
		"http://sigrok.org/wiki/Downloads"
	WriteRegStr HKLM "${REGSTR}" "URLInfoAbout" "http://sigrok.org"
	WriteRegStr HKLM "${REGSTR}" "DisplayVersion" "0.5.0-git-105ecff"
	WriteRegStr HKLM "${REGSTR}" "Contact" \
		"sigrok-devel@lists.sourceforge.org"
	WriteRegStr HKLM "${REGSTR}" "Comments" \
		"This is a Qt based sigrok GUI."

	# Display "Remove" instead of "Modify/Remove" in the control panel.
	WriteRegDWORD HKLM "${REGSTR}" "NoModify" 1
	WriteRegDWORD HKLM "${REGSTR}" "NoRepair" 1
SectionEnd

Section /o "Example data" Section2
	# Example *.sr files.
	SetOutPath "$INSTDIR\examples"

	File "${CROSS}/share/sigrok-dumps/arm_trace/stm32f105/trace_example.sr"
	File "${CROSS}/share/sigrok-dumps/am230x/am2301/am2301_1mhz.sr"
	File "${CROSS}/share/sigrok-dumps/avr_isp/atmega88/isp_atmega88_erase_chip.sr"
	File "${CROSS}/share/sigrok-dumps/can/microchip_mcp2515dm-bm/mcp2515dm-bm-125kbits_msg_222_5bytes.sr"
	File "${CROSS}/share/sigrok-dumps/dcf77/pollin_dcf1_module/dcf77_120s.sr"
	File "${CROSS}/share/sigrok-dumps/i2c/eeprom_24xx/microchip_24lc02b/hantek_6022be_powerup.sr"
	File "${CROSS}/share/sigrok-dumps/i2c/eeprom_24xx/microchip_24lc64/sainsmart_dds120_powerup_scl_sda_analog.sr"
	File "${CROSS}/share/sigrok-dumps/i2c/potentiometer/analog_devices_ad5258/ad5258_read_once_write_continuously_triangle.sr"
	File "${CROSS}/share/sigrok-dumps/mdio/lan8720a/lan8720a_read_write_read.sr"
	File "${CROSS}/share/sigrok-dumps/onewire/owfs/ds28ea00.sr"
	File "${CROSS}/share/sigrok-dumps/sdcard/sd_mode/rcar-h2/cmd23_cmd18.sr"
	File "${CROSS}/share/sigrok-dumps/spi/mx25l1605d/mx25l1605d_read.sr"
	File "${CROSS}/share/sigrok-dumps/uart/gps/mtk3339/mtk3339_8n1_9600.sr"
	File "${CROSS}/share/sigrok-dumps/usb/hid/mouse/olimex_stm32-h103_usb_hid/olimex_stm32-h103_usb_hid.sr"
	File "${CROSS}/share/sigrok-dumps/z80/kc85/kc85-20mhz.sr"

	# Create a shortcut for the example data folder.
	CreateShortCut "$SMPROGRAMS\wtf\DSView\Examples (DSView).lnk" \
		"$INSTDIR\examples" "" "$INSTDIR\examples" 0 \
		SW_SHOWNORMAL "" ""
SectionEnd


# --- Uninstaller section -----------------------------------------------------

Section "Uninstall"
	# Always delete the uninstaller first (yes, this really works).
	Delete "$INSTDIR\Uninstall.exe"

	# Delete the application, the application data, and related libs.
	Delete "$INSTDIR\COPYING"
	Delete "$INSTDIR\DSView.exe"
	Delete "$INSTDIR\zadig.exe"
	Delete "$INSTDIR\zadig_xp.exe"
	Delete "$INSTDIR\python34.dll"
	Delete "$INSTDIR\python34.zip"
	Delete "$INSTDIR\*.pyd"

	# Delete all decoders and everything else in libsigrokdecode/.
	# There could be *.pyc files or __pycache__ subdirs and so on.
	RMDir /r "$INSTDIR\share\libsigrokdecode"

	# Delete the firmware files.
	RMDir /r "$INSTDIR\share\sigrok-firmware"

	# Delete the example *.sr files.
	RMDir /r "$INSTDIR\examples\*"

	# Delete the URL files for the manual.
	Delete "$INSTDIR\DSView HTML manual.url"
	Delete "$INSTDIR\DSView PDF manual.url"

	# Delete the install directory and its sub-directories.
	RMDir "$INSTDIR\share"
	RMDir "$INSTDIR\examples"
	RMDir "$INSTDIR"

	# Delete the links from the start menu.
	Delete "$SMPROGRAMS\wtf\DSView\DSView.lnk"
	Delete "$SMPROGRAMS\wtf\DSView\DSView (Safe Mode).lnk"
	Delete "$SMPROGRAMS\wtf\DSView\DSView (Debug).lnk"
	Delete "$SMPROGRAMS\wtf\DSView\Uninstall DSView.lnk"
	Delete "$SMPROGRAMS\wtf\DSView\Zadig (DSView).lnk"
	Delete "$SMPROGRAMS\wtf\DSView\Zadig (DSView, Win XP).lnk"
	Delete "$SMPROGRAMS\wtf\DSView\Examples (DSView).lnk"

	# Delete the links to the manual.
	Delete "$SMPROGRAMS\wtf\DSView\DSView HTML manual.lnk"
	Delete "$SMPROGRAMS\wtf\DSView\DSView PDF manual.lnk"

	# Delete the sub-directory in the start menu.
	RMDir "$SMPROGRAMS\wtf\DSView"
	RMDir "$SMPROGRAMS\wtf"

	# Delete the registry key(s).
	DeleteRegKey HKLM "${REGSTR}"

	# Unregister any previously registered file extension(s).
	${unregisterExtension} ".sr" "sigrok session file"

	# Force Windows to update the icon cache so that the icon for .sr files is reset.
	System::Call 'Shell32::SHChangeNotify(i ${SHCNE_ASSOCCHANGED}, i ${SHCNF_IDLIST}, i 0, i 0)'
SectionEnd


# --- Component selection section descriptions --------------------------------

LangString DESC_Section1 ${LANG_ENGLISH} "This installs the DSView sigrok GUI, some firmware files, the protocol decoders, and all required libraries."
LangString DESC_Section2 ${LANG_ENGLISH} "This installs some example files that you can use to try out the features sigrok has to offer."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${Section1} $(DESC_Section1)
	!insertmacro MUI_DESCRIPTION_TEXT ${Section2} $(DESC_Section2)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

