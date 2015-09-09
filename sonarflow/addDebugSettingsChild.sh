#!/bin/sh

# addDebugSettingsChild.sh
#
# Simple script to inject a Debug menu in an iPhone Settings plist.
#
# created 10.15.2008 by Andy Mroczkowski, mrox.net

THIS="`basename $0`"
PLISTBUDDY="/usr/libexec/PlistBuddy -x"

set -e

if [ -z "$1" ]; then
	echo "Usage:"
	echo "   $THIS plist_file [child_pane_name]"
	echo "   - If unspecified, child_pane_name is 'Debug'"
	exit 1
fi

if [ ! -e "$1" ]; then
	echo "[$THIS] file not found: '$1'"
	exit 2
fi

if [ ! -z "$2" ]; then
	CHILD_PANE_NAME="$2"
else
	CHILD_PANE_NAME="Debug"
fi

TARGET="$1"
echo "[$THIS] adding '$CHILD_PANE_NAME' child to: $TARGET"

$PLISTBUDDY -c "Add PreferenceSpecifiers:0 dict" "$TARGET"
$PLISTBUDDY -c "Add PreferenceSpecifiers:0:Type string 'PSGroupSpecifier'" "$TARGET"

$PLISTBUDDY -c "Add PreferenceSpecifiers:1 dict" "$TARGET"
$PLISTBUDDY -c "Add PreferenceSpecifiers:1:Type string 'PSChildPaneSpecifier'" "$TARGET"
$PLISTBUDDY -c "Add PreferenceSpecifiers:1:Title string '$CHILD_PANE_NAME Settings'" "$TARGET"
$PLISTBUDDY -c "Add PreferenceSpecifiers:1:File string '$CHILD_PANE_NAME'" "$TARGET"
