/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
Item {

    property int index
    property int imageHeight
    property var imageSource;
    property var textContent;

    signal bottomItemclicked()

    clip: true
    Image {
        id: itemImage

        height: imageHeight
        width: height
        anchors.centerIn: parent
        source: imageSource === "" ? "qrc:/assets/cancel.png": imageSource
    }
    Controls.Label {
        id: itemText

        anchors.top: itemImage.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        Layout.alignment: Qt.AlignHCenter
        text: textContent
        font.pointSize: Kirigami.Theme.defaultFont.pointSize
    }
    MouseArea{
        anchors.fill: parent
        onClicked: {
            bottomItemclicked()
        }
    }

}
