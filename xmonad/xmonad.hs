import IO
import XMonad
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.LayoutHints
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Layout.ThreeColumns
import XMonad.Util.Run

workspaceName "1" = "1-main"
workspaceName "2" = "2-aux"
workspaceName "3" = "3-term"
workspaceName "4" = "4-write"
workspaceName "5" = "5-media"
workspaceName "6" = "6-comm"
workspaceName "7" = "7-mail"
workspaceName "8" = "8-winxp"
workspaceName "9" = "9-temp"
workspaceName x   = x

isSplash =
    isInProperty "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_SPLASH"

main = do
    xmobar <- spawnPipe "xmobar ~/.xmobarrc"

    xmonad $ ewmh defaultConfig
        { terminal        = "gnome-terminal"
        , layoutHook      = layoutHintsWithPlacement (0.5, 0.5) $
                            spacing 3 $
                            avoidStruts $
                            smartBorders $
                            Tall 1 (3 / 100) (59 / 100)
                        ||| Tall 1 (3 / 100) (1 / 2)
                        ||| Mirror (Tall 1 (3 / 100) (1 / 2))
                        ||| ThreeCol 1 (3 / 100) (-1 / 3)
        , manageHook      = (className =? "Bsnes" --> doCenterFloat)
                        <+> (className =? "Gcalctool" -->doCenterFloat)
                        <+> (className =? "stalonetray" --> doIgnore)
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
                                , ppTitle           = xmobarColor "green" ""
                                                    . shorten 255
                                , ppOutput          = hPutStrLn xmobar }
                         >> setWMName "LG3D"
                         >> logHook defaultConfig
        , startupHook     = gnomeRegister }
