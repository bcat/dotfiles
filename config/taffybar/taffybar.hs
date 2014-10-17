import System.Taffybar
import System.Taffybar.Pager
import System.Taffybar.SimpleClock
import System.Taffybar.Systray
import System.Taffybar.TaffyPager

main = do
    let workspaceName "1" = "1-uno"
        workspaceName "2" = "2-dos"
        workspaceName "3" = "3-tres"
        workspaceName "4" = "4-gimp"
        workspaceName "5" = "5-media"
        workspaceName "6" = "6-chat"
        workspaceName "7" = "7-bkrg"
        workspaceName "8" = "8-virt"
        workspaceName "9" = "9-temp"
        workspaceName x   = x

    let pager = taffyPagerNew defaultPagerConfig
            { activeWindow     = colorize "#94d900" ""
                               . escape
                               . shorten 255
            , activeWorkspace  = wrap "<b>" "</b>"
                               . colorize "#8ccdf0" ""
                               . escape
                               . wrap "[" "]"
                               . workspaceName
            , hiddenWorkspace  = wrap "<b>" "</b>"
                               . escape
                               . wrap "{" "}"
                               . workspaceName
            , emptyWorkspace   = wrap "<b>" "</b>"
                               . colorize "#816749" ""
                               . escape
                               . wrap "<" ">"
                               . workspaceName
            , visibleWorkspace = wrap "<b>" "</b>"
                               . colorize "#8ccdf0" ""
                               . escape
                               . wrap "(" ")"
                               . workspaceName
            , urgentWorkspace  = wrap "<b>" "</b>"
                               . colorize "#1f1912" "#ec6c99"
                               . escape
                               . wrap "*" "*"
                               . workspaceName }
        tray  = systrayNew
        time  = textClockNew Nothing "<span color='#d5fac8'>%l:%M %p</span> " 1

    defaultTaffybar defaultTaffybarConfig
        { startWidgets = [ pager ]
        , endWidgets   = [ time, tray ] }
