/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */

import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 1.4 as Controls
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.2
import KRecorder 1.0

Rectangle{
    id:recordSearch

    property var content:""

    color: "lightgrey"
    radius: height/2

    Connections {
        target: RecordingModel
        function onError(error) {
            console.warn("Error on the RecordingModel", error)
        }
    }

    Image {
        id: searchImage

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 20

        width: parent.height/2
        height: parent.height/2
        source: "qrc:/assets/search.png"
    }

    Controls.TextField {
        id:textSearch

        anchors.left: searchImage.right
        anchors.verticalCenter: recordSearch.verticalCenter

        width: parent.width - searchImage.width -20
        placeholderText: "searcg record files..."
        maximumLength: 20

        style: TextFieldStyle {
            textColor: "black"
            background: Rectangle {
                radius: recordSearch.height/2
                color: "lightgrey"
            }
        }

        onTextChanged:{
            recordSearch.content=textSearch.text
            RecordingModel.loadByContent(text)
        }
    }
}
