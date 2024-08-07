# Notice
Development of this project has more or less resumed. Help is always wanted and appreciated, however.  
I'm struggling with burn out at the moment. I'm hoping to return to the project soon but I need to get that under control.  
Currently I'm almost done with the overhauls of indicators which should finalize the Plasma 5 version of this plasmoid. Once that is completed, Plasma 5 will be split into its own fork and the main branch will be for Plasma 6. Any new features and code improvements the plasma 6 widget offers will be back ported in. I'm also in the process of modularizing the FancyTasks additions in order to make development simpler. 

# Contact
You can reach me at ideas@alexankitty.com, by putting an issue on this github, by commenting on the [AUR package](https://aur.archlinux.org/packages/fancytasks), by commenting on the kde-look page, or on the [FancyTasks KDE Reddit community](https://www.reddit.com/r/fancytaskskde/).

# FancyTasks

![Fancy Tasks Icon](https://github.com/alexankitty/FancyTasks/blob/main/package/FancyTasks.png?raw=true)

## Installing

If your distro does not include kirigami2, install it now. It's required for the settings, and used for the dominant icon color effect. Python3 is required for installing.

1. Clone this repository with the following command `git clone https://github.com/alexankitty/FancyTasks`
2. CD into the folder and run the script `install.sh`, you may need to chmod +x or prepend your shell before the script in order to run it
3. Right click your panel, click add widgets and search for fancy tasks.
4. Right click the new task panel and click Configure Fancy Tasks... - everything you will want to configure to enable the new features will be in there. Default features are based on the KDE's team existing vision.

(Alternatively you should be able to double click the shell script to run it)

(This package is also on the AUR and can be installed from there)

## Updating

1. Run the update.sh script, it will automatically stop and restart plasma to make sure the new changes get loaded in.
2. It is recommended you log out and back into your session. plasmashell seems to exhibit some odd behaviors if the plasmoid is updated without clearing the session.

## Features

Features improvements tweaks and options to the original task manager plasmoid made by Eike Hein, licensed under GPL V2.0: [link](https://github.com/KDE/plasma-desktop/tree/master/applets/taskmanager).

* Implemented adjustable task width.
* Implemented switching between taskbar types.
* Indicators based on dash to panel styles from gnome, using [latte-indicator-dashtopanel](https://github.com/psifidotos/latte-indicator-dashtopanel) as the reference implementation.
* Customizable indicator locations and colorizing of plasma. Note: not every plasma theme will color in a pleasant way as it depends on how the SVGs are made. General rule of thumb is bright white does not colorize well.
* Animations (Thanks ziomek64!)
* Growing/Shrinking and desaturation of indicators on minimize (Thanks ziomek64!)
* Customization of number of indicators displayed - limit 10.


## Known Issues
* Does not support LTS currently! (fix me pls)

## To Do
* Fix LTS support
* Correct Metro to have *no* spacing (the multi app running indicator doesn't have a spacing in win10 and I apparently missed this)
* Allow customization of the space between indicators (may have dangerous implications, required for presets)
* Allow changing of animation duration, and possibly animating of button color and frame transitions.
* Change styles (Metro, Ciliora, Dashes) to presets, switch preset to custom when modifying settings. Add in Dots as a preset.
* Fix naming conventions to be more clear to users.

## Translation Help Wanted!
Information regarding submitting translations is available [here](https://github.com/alexankitty/FancyTasks/blob/main/package/translate/ReadMe.md).  
Important note: Any time an update to strings is made, the translations need to be merged and a new po template needs to be created.  
Finally, the metadata.json is done separately.

## Pictures
Colorful Tasks  

![Colorful tasks](https://github.com/alexankitty/FancyTasks/blob/main/docs/colorfulicons%20crop.png?raw=true)

Metro  

![Metro](https://github.com/alexankitty/FancyTasks/blob/main/docs/metro.png?raw=true)

Ciliora  

![Ciliora](https://github.com/alexankitty/FancyTasks/blob/main/docs/ciliora.png?raw=true)

Dashes  

![Dashes](https://github.com/alexankitty/FancyTasks/blob/main/docs/dashes.png?raw=true)

Dots  

![Dots](https://github.com/alexankitty/FancyTasks/blob/main/docs/dots.png?raw=true)

Desaturate minimized tasks  

![Desaturated Minimized Tasks](https://github.com/alexankitty/FancyTasks/blob/main/docs/desaturate%20crop.png?raw=true)

Minimized task shrinking  

![Minimized task shrinking](https://github.com/alexankitty/FancyTasks/blob/main/docs/shrink%20crop.png?raw=true)

## Extra Notes
I'm a solo developer working on this project in my free time so it may take me a bit of time to work on issues. You can help me out by either doing a PR with fixes and I'll validate that they work in the code, or put in an issue for things that need to be changed.
Especially helpful will be settings names to make them more clear. I have a code bias unfortunately so it does make it exceedingly difficult to convey what everything does.
Lastly any feedback is appreciated, and I'll try to implement it as soon as I can.

## Supporters
catraxx  
Kloud  

If you want to support the project and have your name added to the readme, you may do so below.  
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Q5Q4IFNAO)
