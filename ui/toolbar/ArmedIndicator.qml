import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QtGraphicalEffects 1.0

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

QGCComboBox {
    id:                     armedIndicator
    anchors.verticalCenter: parent.verticalCenter
    alternateText:          _armed ? qsTr("Armed") : qsTr("Disarmed")
    model:                  [ qsTr("Arm"), qsTr("Disarm") ]
    font.pointSize:         ScreenTools.isMobile ? ScreenTools.mediumFontPointSize : ScreenTools.largeFontPointSize // Responsive font
    font.bold:              true // Bold text
    sizeToContents:         true
    currentIndex:           -1
    property bool showIndicator: true
    property var    _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property bool   _armed:         _activeVehicle ? _activeVehicle.armed : false

    // Custom background with greenery theme
    background: Rectangle {
        color: _armed ? Qt.rgba(0.3, 0.7, 0.3, 1) : Qt.rgba(0.7, 0.2, 0.2, 1) // Green when armed, red when disarmed
        radius: 6 // Rounded corners
        border.color: qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0, 0.2, 0, 0.5) : Qt.rgba(0.8, 1, 0.8, 0.5) // Greenish border
        border.width: 1
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0, 0, 0, 0.3) : Qt.rgba(1, 1, 1, 0.3)
            radius: 6
            samples: 13
        }
    }

    // Custom text color
    contentItem: Row {
        spacing: ScreenTools.defaultFontPixelWidth * 0.5
        Rectangle {
            width:  ScreenTools.defaultFontPixelHeight * 0.75
            height: width
            radius: width * 0.5
            color:  _armed ? Qt.rgba(0.1, 0.5, 0.1, 1) : Qt.rgba(0.8, 0.2, 0.2, 1) // Green/red indicator dot
            anchors.verticalCenter: parent.verticalCenter
        }
        QGCLabel {
            text:   armedIndicator.alternateText
            color:  qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0, 0.3, 0, 1) : Qt.rgba(0.8, 1, 0.8, 1) // Dark/light green text
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Custom dropdown styling
    popup: Popup {
        y: armedIndicator.height
        width: armedIndicator.width
        padding: ScreenTools.defaultFontPixelWidth * 0.5
        contentItem: ListView {
            clip: true
            model: armedIndicator.model
            currentIndex: armedIndicator.currentIndex
            delegate: ItemDelegate {
                width: parent.width
                text: modelData
                highlighted: hovered
                contentItem: Text {
                    text: modelData
                    color: highlighted ? Qt.rgba(0, 0.5, 0, 1) : qgcPal.text // Dark green on hover
                    font: armedIndicator.font
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: highlighted ? Qt.rgba(0.9, 0.96, 0.9, 1) : qgcPal.window // Light green on hover
                }
            }
        }
        background: Rectangle {
            color: qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0.9, 0.96, 0.9, 1) : Qt.rgba(0.2, 0.4, 0.2, 1) // Green background
            border.color: qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0, 0.2, 0, 0.5) : Qt.rgba(0.8, 1, 0.8, 0.5)
            border.width: 1
            radius: 6
        }
    }

    // Hover and click animations
    scale: pressed ? 0.95 : (hovered ? 1.05 : 1.0)
    Behavior on scale {
        NumberAnimation { duration: 100 }
    }

    onActivated: {
        if (index == 0) {
            mainWindow.armVehicleRequest()
        } else {
            mainWindow.disarmVehicleRequest()
        }
        currentIndex = -1
    }
}
