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

-- Helper functions
gimpToolbox = Role "gimp-toolbox"
gimpDock    = Role "gimp-dock"

isSplash = isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_SPLASH"

-- Layout settings
tallLayout     = renamed [ Replace "tall" ] $ Tall 1 (1 / 100) (6 / 10)
fullLayout     = renamed [ Replace "full" ] $ Full
dishLayout     = renamed [ Replace "dish" ]
               $ magnifiercz' 1.333
               $ Dishes 2 (1 / 5)
spiralLayout   = renamed [ Replace "sprl" ]
               $ magnifiercz' 1.333
               $ spiral (5 / 6)
gridLayout     = renamed [ Replace "grid" ] $ GridRatio 1

gimpLayout = renamed [ Replace "gimp" ]
           $ withIM (15 / 100) gimpToolbox
           $ reflectHoriz
           $ withIM (15 / 85) gimpDock
           $ reflectHoriz
           $ Grid

-- Manage hooks
manageMedia   = composeOne $ map (-?> doShift "5")
    [ className =? "Pithos"
    , className =? "Quodlibet"
    , className =? "Totem" ]
manageGimp    = composeOne $ map (-?> doShift "4")
    [ className =? "Gimp-2.6" ]
manageFloats  = composeOne $ map (-?> doCenterFloat)
    [ isDialog
    , className =? "Gcalctool"
    , className =? "Gitk"
    , className =? "Phoenix"
    , className =? "Totem"
    , title     =? "glxgears" ]
manageIgnores = composeOne $ map (-?> doIgnore)
    [ isSplash ]

-- Main configuration
main = do
    xmonad $ withUrgencyHook NoUrgencyHook $ pagerHints $ gnomeConfig
        { terminal        = "urxvt"
        , layoutHook      = renamed [ CutWordsLeft 1 ]
                          $ fullscreenFull
                          $ layoutHintsWithPlacement (0.5, 0.5)
                          $ desktopLayoutModifiers
                          $ smartBorders
                          $ onWorkspace "4" gimpLayout
                          $ tallLayout
                        ||| fullLayout
                        ||| dishLayout
                        ||| spiralLayout
                        ||| gridLayout
        , manageHook      = composeAll [ fullscreenManageHook
                                       , manageMedia
                                       , manageGimp
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
