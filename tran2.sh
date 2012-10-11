#!/bin/sh
ibtool --strings-file Japanese.lproj/MainMenu.strings --write Japanese.lproj/MainMenu.nib English.lproj/MainMenu.nib

ibtool --strings-file zh_TW.lproj/MainMenu.strings --write zh_TW.lproj/MainMenu.nib English.lproj/MainMenu.nib

ibtool --strings-file Italian.lproj/MainMenu.strings --write Italian.lproj/MainMenu.nib English.lproj/MainMenu.nib

ibtool --strings-file French.lproj/MainMenu.strings --write French.lproj/MainMenu.nib English.lproj/MainMenu.nib

ibtool --strings-file Portuguese.lproj/MainMenu.strings --write Portuguese.lproj/MainMenu.nib English.lproj/MainMenu.nib
