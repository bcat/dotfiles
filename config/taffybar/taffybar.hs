import System.Taffybar
import System.Taffybar.MPRIS2
import System.Taffybar.Pager
import System.Taffybar.SimpleClock
import System.Taffybar.Systray
import System.Taffybar.TaffyPager

main = do
    let pager = taffyPagerNew defaultPagerConfig
            { activeWindow     = colorize "#94d900" ""
                               . escape
                               . shorten 255
            , activeWorkspace  = wrap "<b>" "</b>"
                               . colorize "#8ccdf0" ""
                               . escape
                               . wrap "[" "]"
            , hiddenWorkspace  = wrap "<b>" "</b>"
                               . escape
                               . wrap "{" "}"
            , emptyWorkspace   = wrap "<b>" "</b>"
                               . colorize "#816749" ""
                               . escape
                               . wrap "<" ">"
            , visibleWorkspace = wrap "<b>" "</b>"
                               . colorize "#8ccdf0" ""
                               . escape
                               . wrap "(" ")"
            , urgentWorkspace  = wrap "<b>" "</b>"
                               . colorize "#1f1912" "#ec6c99"
                               . escape
                               . wrap "*" "*" }
        music = mpris2New
        tray  = systrayNew
        time  = textClockNew Nothing "<span color='#d5fac8'>%l:%M %p</span> " 1

    defaultTaffybar defaultTaffybarConfig
        { startWidgets = [ pager ]
        , endWidgets   = [ time, tray, music ] }
