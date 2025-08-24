/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/
import QtQuick          2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts  1.11
import QtQuick.Dialogs  1.3
import QtGraphicalEffects 1.0

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.Palette               1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Controllers           1.0

Rectangle {
    id:     _root
    color:  qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0.93, 0.98, 0.93, 1) : Qt.rgba(0.15, 0.35, 0.15, 1)
    radius: 6
    border.color: "#006400"
    border.width: 1

    layer.enabled: true
    layer.effect: DropShadow {
        transparentBorder: true
        color: qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0, 0, 0, 0.2) : Qt.rgba(1, 1, 1, 0.2)
        radius: 10
        samples: 24
        verticalOffset: 2
    }

    property int currentToolbar: flyViewToolbar
    readonly property int flyViewToolbar:   0
    readonly property int planViewToolbar:  1
    readonly property int simpleToolbar:    2

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0.4, 0.7, 0.4, 1) : Qt.rgba(0.1, 0.3, 0.1, 1)

    QGCPalette { id: qgcPal }

    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         1
        color:          qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0.1, 0.3, 0.1, 0.4) : Qt.rgba(0.9, 1, 0.9, 0.2)
    }

    Rectangle {
        anchors.fill:   viewButtonRow
        visible:        currentToolbar === flyViewToolbar

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: _mainStatusBGColor }
            GradientStop { position: currentButton.x + currentButton.width; color: _mainStatusBGColor }
            GradientStop { position: 1; color: _root.color }
        }
    }

    RowLayout {
        id:                     viewButtonRow
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        spacing:                ScreenTools.defaultFontPixelWidth * 1.5

        QGCToolBarButton {
            id:                     currentButton
            Layout.preferredHeight: viewButtonRow.height
            icon.source:            "/res/QGCLogoFull"
            logo:                   true
            onClicked:              mainWindow.showToolSelectDialog()
            scale:                  pressed ? 0.95 : 1.0
            Behavior on scale {
                NumberAnimation { duration: 100 }
            }
        }

        MainStatusIndicator {
            Layout.preferredHeight: viewButtonRow.height
            visible:                currentToolbar === flyViewToolbar
        }

        QGCButton {
            id:                 disconnectButton
            text:               qsTr("Disconnect")
            onClicked:          _activeVehicle.closeVehicle()
            visible:            _activeVehicle && _communicationLost && currentToolbar === flyViewToolbar

            background: Rectangle {
                color: disconnectButton.hovered ? "#B22222" : qgcPal.button
                radius: 10
                border.color: "#660000"
                border.width: 1
            }

            contentItem: Text {
                color: disconnectButton.hovered ? "white" : qgcPal.buttonText
                text: disconnectButton.text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    QGCFlickable {
        id:                     toolsFlickable
        anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * 2
        anchors.left:           viewButtonRow.right
        anchors.bottomMargin:   1
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.right:          parent.right
        contentWidth:           indicatorLoader.x + indicatorLoader.width
        flickableDirection:     Flickable.HorizontalFlick

        Loader {
            id:                 indicatorLoader
            anchors.left:       parent.left
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             currentToolbar === flyViewToolbar ?
                                    "qrc:/toolbar/MainToolBarIndicators.qml" :
                                    (currentToolbar == planViewToolbar ? "qrc:/qml/PlanToolBarIndicators.qml" : "")
        }
    }

    Image {
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.margins:        ScreenTools.defaultFontPixelHeight * 0.66
        visible:                currentToolbar !== planViewToolbar && _activeVehicle && !_communicationLost && x > (toolsFlickable.x + toolsFlickable.contentWidth + ScreenTools.defaultFontPixelWidth)
        fillMode:               Image.PreserveAspectFit
        source:                 _outdoorPalette ? _brandImageOutdoor : _brandImageIndoor
        mipmap:                 true
        width:                  ScreenTools.defaultFontPixelHeight * 3
        height:                 ScreenTools.defaultFontPixelHeight * 3

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "#228B22"
            border.width: 1
            radius: 6
            z: -1
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                color: "#444"
                radius: 8
                samples: 20
            }
        }

        property bool   _outdoorPalette:        qgcPal.globalTheme === QGCPalette.Light
        property bool   _corePluginBranding:    QGroundControl.corePlugin.brandImageIndoor.length != 0
        property string _userBrandImageIndoor:  QGroundControl.settingsManager.brandImageSettings.userBrandImageIndoor.value
        property string _userBrandImageOutdoor: QGroundControl.settingsManager.brandImageSettings.userBrandImageOutdoor.value
        property bool   _userBrandingIndoor:    _userBrandImageIndoor.length != 0
        property bool   _userBrandingOutdoor:   _userBrandImageOutdoor.length != 0
        property string _brandImageIndoor:      brandImageIndoor()
        property string _brandImageOutdoor:     brandImageOutdoor()

        function brandImageIndoor() {
            if (_userBrandingIndoor) return _userBrandImageIndoor
            if (_userBrandingOutdoor) return _userBrandImageOutdoor
            if (_corePluginBranding) return QGroundControl.corePlugin.brandImageIndoor
            return _activeVehicle ? _activeVehicle.brandImageIndoor : ""
        }

        function brandImageOutdoor() {
            if (_userBrandingOutdoor) return _userBrandImageOutdoor
            if (_userBrandingIndoor) return _userBrandImageIndoor
            if (_corePluginBranding) return QGroundControl.corePlugin.brandImageOutdoor
            return _activeVehicle ? _activeVehicle.brandImageOutdoor : ""
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        height:         _root.height * 0.1
        width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#4CAF50" }
            GradientStop { position: 1.0; color: "#2E7D32" }
        }
        visible:        !largeProgressBar.visible

        Behavior on width {
            NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
        }
    }

    Rectangle {
        id:             largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:         parent.height
        color:          qgcPal.window
        visible:        _showLargeProgress

        property bool _initialDownloadComplete: _activeVehicle ? _activeVehicle.initialConnectComplete : true
        property bool _userHide:                false
        property bool _showLargeProgress:       !_initialDownloadComplete && !_userHide && qgcPal.globalTheme === QGCPalette.Light

        Connections {
            target: QGroundControl.multiVehicleManager
            function onActiveVehicleChanged(activeVehicle) { largeProgressBar._userHide = false }
        }

        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#66BB6A" }
                GradientStop { position: 1.0; color: "#388E3C" }
            }
        }

        QGCLabel {
            anchors.centerIn: parent
            text: qsTr("Downloading")
            font.pointSize: ScreenTools.isMobile ? ScreenTools.mediumFontPointSize : ScreenTools.largeFontPointSize * 1.2
            font.bold: true
            color: "#003300"
        }

        QGCLabel {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: ScreenTools.defaultFontPixelWidth / 2
            text: qsTr("Click anywhere to hide")
            color: "#003300"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: largeProgressBar._userHide = true
        }
    }
}
