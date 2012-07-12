import Data.Monoid
import DBus.Client.Simple
import System.Taffybar.XMonadLog

import XMonad
import XMonad.Actions.GridSelect
import XMonad.Config.Desktop
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ICCCMFocus
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Dishes
import XMonad.Layout.Fullscreen
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.LayoutHints
import XMonad.Layout.Magnifier
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.Renamed
import XMonad.Layout.Spiral
import XMonad.Layout.ThreeColumns
import XMonad.Util.EZConfig
import XMonad.Util.SpawnOnce

import qualified XMonad.StackSet as W

-- Helper functions
gimpToolbox = Role "gimp-toolbox"
gimpDock    = Role "gimp-dock"

gajimRoster = Role "roster"
skypeRoster = Title "Skype™ 4.0 for Linux"
         `Or` Title "bcat24 - Skype™"

doSink   = ask >>= doF . W.sink
isSplash = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_SPLASH"

workspaceName "1" = "1-uno"
workspaceName "2" = "2-dos"
workspaceName "3" = "3-tres"
workspaceName "4" = "4-gimp"
workspaceName "5" = "5-media"
workspaceName "6" = "6-chat"
workspaceName "7" = "7-bkrg"
workspaceName "8" = "8-virt"
workspaceName "9" = "9-temp"
workspaceName x   = x

-- Layout settings
tallLayout     = renamed [ Replace "tall" ] $ Tall 1 (1 / 100) (59 / 100)
fullLayout     = renamed [ Replace "full" ] $ Full
dishLayout     = renamed [ Replace "dish" ] $ magnifiercz' 1.333 $ Dishes 2 (1 / 5)
spiralLayout   = renamed [ Replace "sprl" ] $ magnifiercz' 1.333 $ spiral (5 / 6)
gridLayout     = renamed [ Replace "grid" ] $ GridRatio 1

gimpLayout = renamed [ Replace "gimp" ]
           $ withIM (15 / 100) gimpToolbox
           $ reflectHoriz
           $ withIM (15 / 85) gimpDock
           $ reflectHoriz
           $ Grid

chatLayout = renamed [ Replace "chat" ]
           $ withIM (15 / 100) gajimRoster
           $ reflectHoriz
           $ withIM (15 / 85) skypeRoster
           $ reflectHoriz
           $ Grid

-- Manage hooks
manageChat    = composeOne $ map (-?> doShift "6")
    [ className =? "Gajim"
    , className =? "Gajim.py"
    , className =? "Skype" ]
manageMedia   = composeOne $ map (-?> doShift "5")
    [ className =? "Quodlibet"
    , className =? "Totem" ]
manageGimp    = composeOne $ map (-?> doShift "4")
    [ className =? "Gimp-2.6" ]
manageSinks   = composeOne $ map (-?> doSink)
    [ className =? "Skype" {- A bit too general, but OK for now -} ]
manageFloats  = composeOne $ map (-?> doCenterFloat)
    [ isDialog
    , className =? "Gcalctool"
    , className =? "Phoenix"
    , className =? "Totem"
    , title     =? "glxgears" ]
manageIgnores = composeOne $ map (-?> doIgnore)
    [ isSplash ]

-- Log hooks
taffybarLogHook client = dbusLogWithPP client taffybarDefaultPP
        { ppCurrent         = wrap "<b>" "</b>"
                            . taffybarColor "#8ccdf0" ""
                            . wrap "[" "]"
                            . workspaceName
        , ppVisible         = wrap "<b>" "</b>"
                            . taffybarColor "#8ccdf0" ""
                            . wrap "(" ")"
                            . workspaceName
        , ppHidden          = wrap "<b>" "</b>"
                            . taffybarEscape
                            . wrap "{" "}"
                            . workspaceName
        , ppHiddenNoWindows = wrap "<b>" "</b>"
                            . taffybarColor "#816749" ""
                            . wrap "<" ">"
                            . workspaceName
        , ppUrgent          = wrap "<b>" "</b>"
                            . taffybarColor "#1f1912" "#ec6c99"
                            . wrap "*" "*"
                            . workspaceName
        , ppTitle           = taffybarColor "#94d900" ""
                            . shorten 255 }

-- Main configuration
main = do
    dbusClient <- connectSession

    xmonad $ withUrgencyHook NoUrgencyHook $ gnomeConfig
        { terminal        = "urxvt"
        , layoutHook      = renamed [ CutWordsLeft 1 ]
                          $ fullscreenFull
                          $ layoutHintsWithPlacement (0.5, 0.5)
                          $ desktopLayoutModifiers
                          $ smartBorders
                          $ onWorkspace "4" gimpLayout
                          $ onWorkspace "6" chatLayout
                          $ tallLayout
                        ||| fullLayout
                        ||| dishLayout
                        ||| spiralLayout
                        ||| gridLayout
        , manageHook      = composeAll [ fullscreenManageHook
                                       , transience'
                                       , manageChat
                                       , manageMedia
                                       , manageGimp
                                       , manageSinks
                                       , manageFloats
                                       , manageIgnores ]
                        <+> manageHook gnomeConfig
        , handleEventHook = fullscreenEventHook
                        <+> hintsEventHook
                        <+> handleEventHook gnomeConfig
        , modMask         = mod4Mask
        , logHook         = taffybarLogHook dbusClient
                         >> takeTopFocus
                         >> logHook gnomeConfig
        , startupHook     = spawnOnce "taffybar"
                         >> spawnOnce "compton"
                         >> startupHook gnomeConfig }
        `additionalKeysP` [ ("M-g", goToSelected defaultGSConfig) ]
