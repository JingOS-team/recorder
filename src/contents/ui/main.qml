/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.2 as QQC2
import QtMultimedia 5.12
import KRecorder 1.0
import QtQuick.Layouts 1.2
import QtQml 2.14
import "commonsize.js" as CSJ

Kirigami.ApplicationWindow {
    id: root

    property int defaultFontSize : 14//theme.defaultFont.pointSize
    property var appScaleSize : width / 1920
    property var lastAppScaleSize: width / 888

    width:  root.screen.width
    height: root.screen.height
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.None
    fastBlurMode:false
    //    fastBlurOpacity:0.8
    //black #1C1C21
    //    fastBlurColor:"#E8EFFF"
    onActiveChanged: {
      RecordingModel.isForeground = active
    }
    QQC2.StackView{
        id:mainStackView
        anchors.fill: parent
        Component.onCompleted: {
            mainStackView.push(mainComponent)
        }
    }

    Component{
        id:mainComponent
        RecordMain {
            width: root.width
            height: root.height
            Component.onCompleted: {
            }
        }
    }

    Component{
        id:recordComponent
        RecordPage{
        }
    }

    function pushRecordView(){
        mainStackView.push(recordComponent)
    }

    function popView() {
        mainStackView.pop()
    }

    //        pageStack.initialPage:RecordMain {
    //        width: parent.width
    //        height: parent.height
    //        Component.onCompleted: {
    //          console.log("  loadtime:: qml load end time:" + (new Date().getTime() - MainStartTime))
    //        }
    //    }
}

