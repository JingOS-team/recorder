/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.12
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2

Rectangle {
    id: leftTitlesView

    signal cancelClicked
    property int selectCount

    width: parent.width
    height: 40

    Image {
        id: cancelView

        anchors {
            verticalCenter: parent.verticalCenter
            margins: 10
        }
        height: 30
        width: height
        source: "qrc:/assets/cancel.png"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                cancelClicked()
                selectCount = 0
            }
        }
    }
    Controls.Label {
        id: selectText

        anchors.left: cancelView.right
        Layout.alignment: Qt.AlignHCenter
        anchors.verticalCenter: parent.verticalCenter
        text: selectCount > 0 ? ("selected " + selectCount) : "not selected"
        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.5
    }
}
