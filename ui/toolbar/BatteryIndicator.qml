import QtQuick          2.11
import QtQuick.Layouts  1.11
import QtGraphicalEffects 1.0

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0
import MAVLink                              1.0

//-------------------------------------------------------------------------
//-- Battery Indicator
Item {
    id:             _root
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          batteryIndicatorRow.width

    property bool showIndicator: true
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    Row {
        id:             batteryIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth * 0.5 // Increased spacing
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            color: qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0, 0, 0, 0.3) : Qt.rgba(1, 1, 1, 0.3)
            radius: 6
            samples: 13
        }

        Repeater {
            model: _activeVehicle ? _activeVehicle.batteries : 0

            Loader {
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                sourceComponent:    batteryVisual
                property var battery: object
            }
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked: {
            mainWindow.showIndicatorPopup(_root, batteryPopup)
        }
    }

    Component {
        id: batteryVisual

        Row {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            spacing:        ScreenTools.defaultFontPixelWidth * 0.25

            function getBatteryColor() {
                switch (battery.chargeState.rawValue) {
                case MAVLink.MAV_BATTERY_CHARGE_STATE_OK:
                    return qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0.3, 0.7, 0.3, 1) : Qt.rgba(0.1, 0.5, 0.1, 1) // Green for OK
                case MAVLink.MAV_BATTERY_CHARGE_STATE_LOW:
                    return qgcPal.colorOrange
                case MAVLink.MAV_BATTERY_CHARGE_STATE_CRITICAL:
                case MAVLink.MAV_BATTERY_CHARGE_STATE_EMERGENCY:
                case MAVLink.MAV_BATTERY_CHARGE_STATE_FAILED:
                case MAVLink.MAV_BATTERY_CHARGE_STATE_UNHEALTHY:
                    return qgcPal.colorRed
                default:
                    return qgcPal.text
                }
            }

            function getBatteryPercentageText() {
                if (!isNaN(battery.percentRemaining.rawValue)) {
                    if (battery.percentRemaining.rawValue > 98.9) {
                        return qsTr("100%")
                    } else {
                        return battery.percentRemaining.valueString + battery.percentRemaining.units
                    }
                } else if (!isNaN(battery.voltage.rawValue)) {
                    return battery.voltage.valueString + battery.voltage.units
                } else if (battery.chargeState.rawValue !== MAVLink.MAV_BATTERY_CHARGE_STATE_UNDEFINED) {
                    return battery.chargeState.enumStringValue
                }
                return ""
            }

            Rectangle {
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                width:              ScreenTools.defaultFontPixelHeight * 2.5 // Larger background
                color:              qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0.9, 0.96, 0.9, 0.5) : Qt.rgba(0.2, 0.4, 0.2, 0.5) // Green background
                radius:             4
                border.color:       qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0, 0.2, 0, 0.5) : Qt.rgba(0.8, 1, 0.8, 0.5) // Greenish border
                border.width:       1

                Row {
                    anchors.centerIn: parent
                    spacing: ScreenTools.defaultFontPixelWidth * 0.25

                    QGCColoredImage {
                        anchors.top:        parent.top
                        anchors.bottom:     parent.bottom
                        width:              ScreenTools.defaultFontPixelHeight * 1.5 // Larger icon
                        sourceSize.width:   width
                        source:             "/qmlimages/Battery.svg"
                        fillMode:           Image.PreserveAspectFit
                        color:              getBatteryColor()

                        // Smooth color transition
                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }

                    QGCLabel {
                        text:                   getBatteryPercentageText()
                        font.pointSize:         ScreenTools.isMobile ? ScreenTools.mediumFontPointSize : ScreenTools.largeFontPointSize // Responsive font
                        font.bold:              true // Bold text
                        color:                  getBatteryColor()
                        anchors.verticalCenter: parent.verticalCenter

                        // Smooth color transition
                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: batteryValuesAvailableComponent

        QtObject {
            property bool functionAvailable:        battery.function.rawValue !== MAVLink.MAV_BATTERY_FUNCTION_UNKNOWN
            property bool temperatureAvailable:     !isNaN(battery.temperature.rawValue)
            property bool currentAvailable:         !isNaN(battery.current.rawValue)
            property bool mahConsumedAvailable:     !isNaN(battery.mahConsumed.rawValue)
            property bool timeRemainingAvailable:   !isNaN(battery.timeRemaining.rawValue)
            property bool chargeStateAvailable:     battery.chargeState.rawValue !== MAVLink.MAV_BATTERY_CHARGE_STATE_UNDEFINED
        }
    }

    Component {
        id: batteryPopup

        Rectangle {
            width:          mainLayout.width   + mainLayout.anchors.margins * 2
            height:         mainLayout.height  + mainLayout.anchors.margins * 2
            radius:         ScreenTools.defaultFontPixelHeight / 2
            color:          qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0.9, 0.96, 0.9, 1) : Qt.rgba(0.2, 0.4, 0.2, 1) // Green background
            border.color:   qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0, 0.2, 0, 0.5) : Qt.rgba(0.8, 1, 0.8, 0.5) // Greenish border
            border.width:   1
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                color: qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0, 0, 0, 0.3) : Qt.rgba(1, 1, 1, 0.3)
                radius: 6
                samples: 13
            }

            ColumnLayout {
                id:                 mainLayout
                anchors.margins:    ScreenTools.defaultFontPixelWidth * 1.5 // Increased margins
                anchors.top:        parent.top
                anchors.right:      parent.right
                spacing:            ScreenTools.defaultFontPixelHeight

                QGCLabel {
                    Layout.alignment:   Qt.AlignCenter
                    text:               qsTr("Battery Status")
                    font.family:        ScreenTools.demiboldFontFamily
                    font.pointSize:     ScreenTools.isMobile ? ScreenTools.mediumFontPointSize : ScreenTools.largeFontPointSize * 1.2 // Responsive font
                    font.bold:          true
                    color:              qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0, 0.3, 0, 1) : Qt.rgba(0.8, 1, 0.8, 1) // Green text
                }

                RowLayout {
                    spacing: ScreenTools.defaultFontPixelWidth * 1.5 // Increased spacing

                    ColumnLayout {
                        Repeater {
                            model: _activeVehicle ? _activeVehicle.batteries : 0

                            ColumnLayout {
                                spacing: ScreenTools.defaultFontPixelHeight * 0.5

                                property var batteryValuesAvailable: nameAvailableLoader.item

                                Loader {
                                    id:                 nameAvailableLoader
                                    sourceComponent:    batteryValuesAvailableComponent
                                    property var battery: object
                                }

                                QGCLabel {
                                    text: qsTr("Battery %1").arg(object.id.rawValue)
                                    color: qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0, 0.3, 0, 1) : Qt.rgba(0.8, 1, 0.8, 1)
                                    font.bold: true
                                }
                                QGCLabel { text: qsTr("Charge State"); visible: batteryValuesAvailable.chargeStateAvailable }
                                QGCLabel { text: qsTr("Remaining"); visible: batteryValuesAvailable.timeRemainingAvailable }
                                QGCLabel { text: qsTr("Remaining") }
                                QGCLabel { text: qsTr("Voltage") }
                                QGCLabel { text: qsTr("Consumed"); visible: batteryValuesAvailable.mahConsumedAvailable }
                                QGCLabel { text: qsTr("Temperature"); visible: batteryValuesAvailable.temperatureAvailable }
                                QGCLabel { text: qsTr("Function"); visible: batteryValuesAvailable.functionAvailable }
                            }
                        }
                    }

                    ColumnLayout {
                        Repeater {
                            model: _activeVehicle ? _activeVehicle.batteries : 0

                            ColumnLayout {
                                spacing: ScreenTools.defaultFontPixelHeight * 0.5

                                property var batteryValuesAvailable: valueAvailableLoader.item

                                Loader {
                                    id:                 valueAvailableLoader
                                    sourceComponent:    batteryValuesAvailableComponent
                                    property var battery: object
                                }

                                QGCLabel { text: "" }
                                QGCLabel {
                                    text: object.chargeState.enumStringValue
                                    visible: batteryValuesAvailable.chargeStateAvailable
                                    color: object.chargeState.rawValue === MAVLink.MAV_BATTERY_CHARGE_STATE_OK ?
                                           (qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(0, 0.3, 0, 1) : Qt.rgba(0.8, 1, 0.8, 1)) :
                                           (object.chargeState.rawValue === MAVLink.MAV_BATTERY_CHARGE_STATE_LOW ? qgcPal.colorOrange : qgcPal.colorRed)
                                }
                                QGCLabel { text: object.timeRemainingStr.value; visible: batteryValuesAvailable.timeRemainingAvailable }
                                QGCLabel { text: object.percentRemaining.valueString + " " + object.percentRemaining.units }
                                QGCLabel { text: object.voltage.valueString + " " + object.voltage.units }
                                QGCLabel { text: object.mahConsumed.valueString + " " + object.mahConsumed.units; visible: batteryValuesAvailable.mahConsumedAvailable }
                                QGCLabel { text: object.temperature.valueString + " " + object.temperature.units; visible: batteryValuesAvailable.temperatureAvailable }
                                QGCLabel { text: object.function.enumStringValue; visible: batteryValuesAvailable.functionAvailable }
                            }
                        }
                    }
                }
            }

            // Hover effect
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: parent.opacity = 0.9
                onExited: parent.opacity = 1.0
            }
        }
    }
}
