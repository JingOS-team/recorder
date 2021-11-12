/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Zhang He Gang <zhanghegang@jingos.com>
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
import jingos.display 1.0

Kirigami.ApplicationWindow {
    id: root

    property int defaultFontSize: 14 * appFontSize
    property var appScaleSize: JDisplay.dp(1.0)
    property var lastAppScaleSize: JDisplay.dp(1.0)
    property var appFontSize: JDisplay.sp(1.0)
    property bool isDarkTheme: {
        Kirigami.JTheme.colorScheme === "jingosDark"
    }

    width: root.screen.width
    height: root.screen.height
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.None
    fastBlurMode: false
    color: Kirigami.JTheme.background
    onActiveChanged: {
        RecordingModel.isForeground = active
    }
    QQC2.StackView {
        id: mainStackView
        anchors.fill: parent
        Component.onCompleted: {
            mainStackView.push(mainComponent)
        }
    }

    Timer {
        id: loadTimer
        interval: 1
        onTriggered: {
            mainStackView.push(mainComponent)
        }
    }

    Component {
        id: mainComponent
        RecordMain {
            width: root.width
            height: root.height
            Component.onCompleted: {
                console.log("  loadtime:: qml load end time:" + (new Date().getTime(
                                                                     ) - MainStartTime))
            }
        }
    }

    Component {
        id: recordComponent
        RecordPage {}
    }

    function pushRecordView(playPagewidth) {
        mainStackView.push(recordComponent, {
                               "playPageWidth": playPagewidth
                           })
    }

    function popView() {
        mainStackView.pop()
    }
}
