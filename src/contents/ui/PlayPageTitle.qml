
/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
 */
import QtQuick 2.2
import "commonsize.js" as CSJ
import KRecorder 1.0
import QtQuick.Controls 2.14 as Controls
import QtQuick.Controls.Styles 1.4
import org.kde.kirigami 2.15 as Kirigami

Rectangle {
    id: playpageTitle

    property var titleContent
    property var dateContent
    property var currentDateContent
    property var lengthContent
    property var textChangeContent: titleContent
    property double scaleHeightSize: CSJ.LeftView.left_title_height / CSJ.ScreenCurrentHeight
    property int titleHeight: root.height * scaleHeightSize

    signal renameClicked(var isFileNameEdit, var newFileName)

    width: parent.width
    height: root.height * (CSJ.PlayPageView.playpage_title_height / CSJ.ScreenCurrentHeight)
    color: "#00000000"
    clip: true

    onTitleContentChanged: {
        textChangeContent = titleContent
    }

    function renamePlayPageTitle(teStatus) {
        if (nameTextEdit.focus !== teStatus) {
            nameTextEdit.focus = teStatus
            nameTextEdit.cursorVisible = teStatus
        }
    }

    Rectangle {
        id: nameRect

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
        width: nameTextEdit.width
        height: titleHeight
        color: "#00000000"
        clip: true

        MouseArea {
            anchors.fill: parent
            onClicked: {
                nameTextEdit.enabled = true
                nameTextEdit.focus = true
            }
        }

        Controls.TextField {
            id: nameTextEdit

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            width: (playpageTitle.width - contentWidth)
                   < 50 ? (playpageTitle.width
                           - 20) : (contentWidth + 15) //parent.width - parent.width / 10
            height: parent.height
            enabled: true
            text: titleContent
            activeFocusOnPress: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            maximumLength: 50
            color: Kirigami.JTheme.majorForeground //"#3C3F48"
            font.pixelSize: defaultFontSize + 9 * appFontSize
            clip: true
            visible: focus

            background: Rectangle {
                color: "transparent"
                anchors.fill: parent
            }

            cursorDelegate: Rectangle {
                id: cursorRect
                anchors.verticalCenter: parent.verticalCenter
                color: Kirigami.JTheme.highlightRed
                width: 4 * lastAppScaleSize
                radius: width / 2
                Timer {
                    id: cursorTimer
                    interval: 700
                    running: nameTextEdit.focus
                    repeat: true
                    onTriggered: {
                        cursorRect.visible = !cursorRect.visible
                    }
                    onRunningChanged: {
                        cursorRect.visible = running
                    }
                }
            }

            onAccepted: {
                nameTextEdit.focus = false
                renameClicked(true, nameTextEdit.text)
            }
            onTextChanged: {
                nameTextEdit.horizontalAlignment = Text.AlignHCenter
                nameTextEdit.verticalAlignment = Text.AlignVCenter
                if (nameTextEdit.visible) {
                    textChangeContent = nameTextEdit.text
                }
            }
        }

        Rectangle {
            id: rtText

            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width
            height: parent.height
            clip: true
            visible: !nameTextEdit.visible
            color: "#00000000"

            Text {
                id: nameText

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                }
                color: Kirigami.JTheme.majorForeground
                font.pixelSize: defaultFontSize + 9 * appFontSize
                clip: true
                verticalAlignment: Text.AlignVCenter
                text: titleContent
                elide: Text.ElideRight
                width: parent.width

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        nameTextEdit.focus = true
                    }
                }
            }
        }
    }

    Rectangle {
        id: currentDateRect

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: nameRect.bottom
            topMargin: 7 * lastAppScaleSize
        }
        width: currentDateText.contentWidth + 20 * lastAppScaleSize
        height: parent.height * (CSJ.PlayPageView.playpage_title_name_height
                                 / CSJ.PlayPageView.playpage_title_height)
        color: "#00000000"

        Text {
            id: currentDateText

            color: Kirigami.JTheme.majorForeground
            font.pixelSize: defaultFontSize + 30 * appFontSize
            anchors.verticalCenter: parent.verticalCenter
            text: currentDateContent === "" ? "00:00.0" : currentDateContent
        }
    }

    Rectangle {
        id: dateLengthRect

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: currentDateRect.bottom
            topMargin: 14 * lastAppScaleSize
        }
        width: dateText.contentWidth + lengthText.contentWidth + 20 * lastAppScaleSize
        height: parent.height * (CSJ.PlayPageView.playpage_title_date_length_height
                                 / CSJ.PlayPageView.playpage_title_height)
        color: "#00000000"

        Text {
            id: lengthText

            anchors.verticalCenter: parent.verticalCenter
            color: Kirigami.JTheme.minorForeground
            font.pixelSize: defaultFontSize - 3 * appFontSize
            text: lengthContent
        }
        Text {
            id: dateText

            anchors {
                left: lengthText.right
                leftMargin: 10 * lastAppScaleSize
                verticalCenter: parent.verticalCenter
            }
            color: Kirigami.JTheme.minorForeground
            font.pixelSize: defaultFontSize - 3 * appFontSize
            text: dateContent
        }
    }
}
