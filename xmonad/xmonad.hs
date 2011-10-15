import Data.Monoid
import IO

import XMonad
import XMonad.Config.Desktop
import XMonad.Config.Gnome
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ICCCMFocus
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.LayoutHints
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.Spiral
import XMonad.Layout.ThreeColumns
import XMonad.Util.Run

import qualified XMonad.StackSet as W

-- Helper functions
gimpToolbox = Role "gimp-toolbox"
gimpDock = Role "gimp-dock"

gajimRoster = Role "roster"
skypeRoster = Title "Skype™ 2.1 (Beta) for Linux"
         `Or` Title "bcat24 - Skype™ (Beta)"

doSink   = ask >>= doF . W.sink
isSplash = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_SPLASH"

workspaceName "1" = "1-uno"
workspaceName "2" = "2-dos"
workspaceName "3" = "3-tres"
workspaceName "4" = "4-gimp"
workspaceName "5" = "5-media"
workspaceName "6" = "6-chat"
workspaceName "7" = "7-bkrg"
workspaceName "8" = "8-winxp"
workspaceName "9" = "9-temp"
workspaceName x   = x

-- Layout settings
tallLayout     = named "tall" $ Tall 1 (1 / 100) (59 / 100)
spiralLayout   = named "sprl" $ spiral (9 / 10)
threeColLayout = named "3col" $ ThreeCol 1 (3 / 100) (-1 / 3)
gridLayout     = named "grid" $ GridRatio 1
fullLayout     = named "full" $ Full

gimpLayout = named "gimp"
           $ withIM (15 / 100) gimpToolbox
           $ reflectHoriz
           $ withIM (15 / 85) gimpDock
           $ reflectHoriz
           $ Grid

chatLayout = named "chat"
           $ withIM (15 / 100) gajimRoster
           $ reflectHoriz
           $ withIM (15 / 85) skypeRoster
           $ reflectHoriz
           $ Grid

-- Manage hooks

manageIgnores = composeOne $ map (-?> doIgnore)
    [ isSplash,
      className =? "stalonetray" ]
manageFloats  = composeOne $ map (-?> doCenterFloat)
    [ isDialog
    , className =? "Bsnes-accuracy"
    , className =? "Bsnes-compatibility"
    , className =? "Bsnes-performance"
    , className =? "Gcalctool"
    , className =? "Totem"
    , title     =? "glxgears" ]
manageSinks   = composeOne $ map (-?> doSink)
    [ className =? "Skype" {- A bit too general, but OK for now -} ]
manageGimp    = composeOne $ map (-?> doShift "4")
    [ className =? "Gimp-2.6" ]
manageMedia   = composeOne $ map (-?> doShift "5")
    [ className =? "Quodlibet"
    , className =? "Totem" ]
manageChat    = composeOne $ map (-?> doShift "6")
    [ className =? "Gajim.py"
    , className =? "Skype" ]

-- Log hooks
xmobarLogHook xmobar = dynamicLogWithPP xmobarPP
        { ppCurrent         = xmobarColor "yellow" ""
                            . wrap "[" "]"
                            . workspaceName
        , ppVisible         = xmobarColor "yellow" ""
                            . wrap "(" ")"
                            . workspaceName
        , ppHidden          = xmobarColor "white" ""
                            . wrap "{" "}"
                            . workspaceName
        , ppHiddenNoWindows = wrap "<" ">"
                            . workspaceName
        , ppUrgent          = xmobarColor "yellow" "red"
                            . wrap "*" "*"
                            . workspaceName
        , ppTitle           = xmobarColor "green" ""
                            . shorten 255
        , ppOutput          = hPutStrLn xmobar }

-- Main configuration
main = do
    spawn "xcompmgr-xmonad"
    xmobar <- spawnPipe "xmobar ~/.xmobarrc"
    spawn "stalonetray-xmonad"

    xmonad $ withUrgencyHook NoUrgencyHook $ gnomeConfig
        { terminal        = "urxvt"
        , layoutHook      = nameTail
                          $ layoutHintsWithPlacement (0.5, 0.5)
                          $ desktopLayoutModifiers
                          $ smartBorders
                          $ onWorkspace "4" gimpLayout
                          $ onWorkspace "6" chatLayout
                          $ tallLayout
                        ||| spiralLayout
                        ||| threeColLayout
                        ||| gridLayout
                        ||| fullLayout
        , manageHook      = composeAll [ manageIgnores
                                       , manageFloats
                                       , manageSinks
                                       , manageGimp
                                       , manageMedia
                                       , manageChat ]
                        <+> manageHook gnomeConfig
        , handleEventHook = mappend fullscreenEventHook
                          $ handleEventHook gnomeConfig
        , modMask         = mod4Mask
        , logHook         = xmobarLogHook xmobar
                         >> setWMName "LG3D" {- Nasty hack for Java Swing -}
                         >> takeTopFocus
                         >> logHook gnomeConfig }
