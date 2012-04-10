import System.Taffybar
import System.Taffybar.SimpleClock
import System.Taffybar.Systray
import System.Taffybar.XMonadLog

main = do
    let log  = xmonadLogNew
        tray = systrayNew
        time = textClockNew Nothing "<span color='#d5fac8'>%l:%M %p</span> " 1

    defaultTaffybar defaultTaffybarConfig
        { startWidgets = [ log ]
        , endWidgets   = [ time, tray ] }
