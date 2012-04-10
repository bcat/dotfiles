import Data.Monoid
import DBus.Client.Simple
import System.Taffybar.XMonadLog

import XMonad
import XMonad.Config.Desktop
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ICCCMFocus
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Fullscreen
import XMonad.Layout.Grid
import XMonad.Layout.IM
import XMonad.Layout.LayoutHints
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.Renamed
import XMonad.Layout.Spiral
import XMonad.Layout.ThreeColumns
import XMonad.Util.SpawnOnce

import qualified XMonad.StackSet as W

-- Helper functions
gimpToolbox = Role "gimp-toolbox"
gimpDock    = Role "gimp-dock"

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
workspaceName "8" = "8-virt"
workspaceName "9" = "9-temp"
workspaceName x   = x

-- Layout settings
tallLayout     = renamed [ Replace "tall" ] $ Tall 1 (1 / 100) (59 / 100)
spiralLayout   = renamed [ Replace "sprl" ] $ spiral (9 / 10)
threeColLayout = renamed [ Replace "3col" ] $ ThreeCol 1 (3 / 100) (-1 / 3)
gridLayout     = renamed [ Replace "grid" ] $ GridRatio 1
fullLayout     = renamed [ Replace "full" ] $ Full

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

manageIgnores = composeOne $ map (-?> doIgnore)
    [ isSplash,
      className =? "stalonetray" ]
manageFloats  = composeOne $ map (-?> doCenterFloat)
    [ isDialog
    , className =? "Gcalctool"
    , className =? "Phoenix"
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
    [ className =? "Gajim"
    , className =? "Skype" ]

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
                        ||| spiralLayout
                        ||| threeColLayout
                        ||| gridLayout
                        ||| fullLayout
        , manageHook      = composeAll [ manageIgnores
                                       , manageFloats
                                       , manageSinks
                                       , manageGimp
                                       , manageMedia
                                       , manageChat
                                       , fullscreenManageHook ]
                        <+> manageHook gnomeConfig
        , handleEventHook = fullscreenEventHook
                        <+> hintsEventHook
                        <+> handleEventHook gnomeConfig
        , modMask         = mod4Mask
        , logHook         = taffybarLogHook dbusClient
                         >> setWMName "LG3D" {- Nasty hack for Java Swing -}
                         >> takeTopFocus
                         >> logHook gnomeConfig
        , startupHook     = spawnOnce "compton"
                         >> spawnOnce "taffybar"
                         >> startupHook gnomeConfig }
