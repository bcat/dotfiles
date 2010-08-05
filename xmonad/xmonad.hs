import IO
import XMonad
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
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
import XMonad.Layout.Spacing
import XMonad.Layout.ThreeColumns
import XMonad.Util.Run

workspaceName "1" = "1-uno"
workspaceName "2" = "2-dos"
workspaceName "3" = "3-tres"
workspaceName "4" = "4-write"
workspaceName "5" = "5-media"
workspaceName "6" = "6-im"
workspaceName "7" = "7-mail"
workspaceName "8" = "8-winxp"
workspaceName "9" = "9-temp"
workspaceName x   = x

isSplash =
    isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_SPLASH"

main = do
    xmobar <- spawnPipe "xmobar ~/.xmobarrc"

    xmonad $ withUrgencyHook NoUrgencyHook $ ewmh defaultConfig
        { terminal        = "gnome-terminal"
        , layoutHook      = (nameTail . nameTail . nameTail) $
                            layoutHintsWithPlacement (0.5, 0.5) $
                            spacing 2 $
                            avoidStruts $
                            smartBorders $
                            onWorkspace "6" (gridIM (15 / 100) (Role "roster")) $
                            Tall 1 (1 / 100) (59 / 100)
                        ||| named "Wide" (Mirror (Tall 1 (1 / 100) (1 / 2)))
                        ||| ThreeCol 1 (3 / 100) (-1 / 3)
                        ||| named "Grid" (GridRatio 1)
                        ||| Full
        , manageHook      = (className =? "Bsnes" --> doCenterFloat)
                        <+> (className =? "Gajim.py" --> doShift "6")
                        <+> (className =? "Gcalctool" -->doCenterFloat)
                        <+> (className =? "stalonetray" --> doIgnore)
                        <+> (className =? "Thunderbird" --> doShift "7")
                        <+> (className =? "Totem" --> doCenterFloat)
                        <+> (title =? "glxgears" --> doCenterFloat)
                        <+> (isSplash --> doIgnore)
                        <+> manageDocks
                        <+> (manageHook defaultConfig)
        , handleEventHook = fullscreenEventHook
                        <+> handleEventHook defaultConfig
        , modMask         = mod4Mask
        , logHook         = dynamicLogWithPP xmobarPP
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
                         >> setWMName "LG3D"
                         >> logHook defaultConfig
        , startupHook     = gnomeRegister }
