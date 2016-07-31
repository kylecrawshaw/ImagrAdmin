# ImagrAdmin

![ImagrAdminIcon](https://github.com/kylecrawshaw/ImagrAdmin/blob/master/ImagrAdmin/Assets.xcassets/AppIcon.appiconset/icon_256x256.png)

ImagrAdmin is a GUI application for macOS to update and create configuration plists
for [Imagr](https://github.com/grahamgilbert/imagr/). Imagr is built around the idea of
one main configuration file that contains workflows with a number of different components.
Before ImagrAdmin you would have to know what keys you could set for the different
workflow components. ImagrAdmin attempts to ease that process so you can focus on
creating great scripts and packages to be installed with Imagr.

### Imagr Workflow Components

##### Currently Supported Components
- [image](https://github.com/grahamgilbert/imagr/wiki/Workflow-Config#images)
- [package](https://github.com/grahamgilbert/imagr/wiki/Workflow-Config#packages) *
- [script](https://github.com/grahamgilbert/imagr/wiki/Workflow-Config#scripts)
- [included workflow](https://github.com/grahamgilbert/imagr/wiki/Workflow-Config#included-workflow)
- [computer_name](https://github.com/grahamgilbert/imagr/wiki/Workflow-Config#computer-name)
- [eraseVolume](https://github.com/grahamgilbert/imagr/wiki/Workflow-Config#erase-volume)
- [localize](https://github.com/grahamgilbert/imagr/wiki/Workflow-Config#localization)

*HTTP header support coming soon. Currently if you have a flat package that requires request headers it will not work.


##### Soon to be Supported Components
- [partition](https://github.com/grahamgilbert/imagr/wiki/Workflow-Config#partition)


## Todo
- [ ] Add support for HTTP headers for package components
- [ ] Add partition component
