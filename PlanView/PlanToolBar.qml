import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QtQuick.Dialogs  1.2

import QGroundControl                   1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Controls          1.0
import QGroundControl.FactControls      1.0
import QGroundControl.Palette           1.0

/Rectangle {
    id: _root
    width: parent.width * 0.95      // not full width, 95% of parent
    height: 50                      // fixed height for toolbar
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    radius: 12
    color: qgcPal.globalTheme === QGCPalette.Light
           ? Qt.rgba(1,1,1,0.9)
           : Qt.rgba(0.1,0.1,0.1,0.85)
    border.color: qgcPal.text
    border.width: 1

    layer.enabled: true
    layer.effect: DropShadow {
        horizontalOffset: 0
        verticalOffset: 3
        radius: 12
        samples: 16
        color: Qt.rgba(0,0,0,0.4)
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 12

        QGCToolBarButton {
            icon.source: "/qmlimages/PaperPlane.svg"
            icon.width: 28
            icon.height: 28
        }

        Loader {
            source: "PlanToolBarIndicators.qml"
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
