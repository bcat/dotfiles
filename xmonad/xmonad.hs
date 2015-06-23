import Data.Monoid

import System.Taffybar.Hooks.PagerHints
import System.Taffybar.TaffyPager

import XMonad
import XMonad.Actions.GridSelect
import XMonad.Config.Desktop
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Fullscreen
import XMonad.Layout.Grid
import XMonad.Layout.LayoutHints
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ThreeColumns
import XMonad.Util.EZConfig
import XMonad.Util.SpawnOnce

isSplash = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_SPLASH"

tallLayout     = renamed [ Replace "tall" ] $ Tall 1 (1 / 100) (6 / 10)
wideLayout     = renamed [ Replace "wide" ] $ Mirror $ Tall 1 (1 / 100) (6 / 10)
fullLayout     = renamed [ Replace "full" ] $ Full
threeColLayout = renamed [ Replace "3col" ] $ ThreeColMid 1 (1 / 100) (1 / 2)
gridLayout     = renamed [ Replace "grid" ] $ GridRatio 1

manageMedia   = composeOne $ map (-?> doShift "5")
    [ className =? "Pithos"
    , className =? "Quodlibet"
    , className =? "Totem" ]
manageFloats  = composeOne $ map (-?> doCenterFloat)
    [ isDialog
    , className =? "Gcalctool"
    , className =? "Gitk"
    , className =? "Phoenix"
    , className =? "Totem"
    , title     =? "glxgears" ]
manageIgnores = composeOne $ map (-?> doIgnore)
    [ isSplash ]

main = do
    xmonad $ withUrgencyHook NoUrgencyHook $ pagerHints $ gnomeConfig
        { terminal        = "urxvt"
        , layoutHook      = renamed [ CutWordsLeft 1 ]
                          $ fullscreenFull
                          $ layoutHintsWithPlacement (0.5, 0.5)
                          $ desktopLayoutModifiers
                          $ smartBorders
                          $ tallLayout
                        ||| wideLayout
                        ||| fullLayout
                        ||| threeColLayout
                        ||| gridLayout
        , manageHook      = composeAll [ fullscreenManageHook
                                       , manageMedia
                                       , manageFloats
                                       , manageIgnores ]
                        <+> manageHook gnomeConfig
        , handleEventHook = fullscreenEventHook
                        <+> hintsEventHook
                        <+> handleEventHook gnomeConfig
        , modMask         = mod4Mask
        , startupHook     = spawnOnce "taffybar"
                         >> spawnOnce "compton"
                         >> startupHook gnomeConfig }
        `additionalKeysP` [ ("M-g", goToSelected defaultGSConfig) ]
