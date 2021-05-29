

/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
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

    function renamePlayPageTitle(teStatus) {
        if(nameTextEdit.focus !== teStatus){
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
        width: parent.width
        height: titleHeight
        color: "#00000000"

        MouseArea {
            anchors.fill: parent
//            hoverEnabled: true
            onClicked: {
                nameTextEdit.enabled = true
                nameTextEdit.focus = true
            }
//            onEntered: {
//                nameTextEdit.enabled = true
//                nameTextEdit.focus = true
//            }
//            onExited: {

//            }
        }

        Controls.TextField {
            id: nameTextEdit

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            width: parent.width - parent.width / 10
            enabled: true
            text: titleContent
            activeFocusOnPress: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            maximumLength: 40
            //black #FFFFFF
            color: "#3C3F48"
            font.pixelSize: defaultFontSize + 9

//            style: TextFieldStyle {
//                id: ts
//                //black #FFFFFF
//                textColor: "#3C3F48"
//                font.pixelSize: defaultFontSize + 15
//                background: Rectangle {
//                    color: "transparent"
//                }
//            }
            background: Rectangle{
             color: "transparent"
             anchors.fill: parent
            }

            cursorDelegate: Rectangle{
                id: cursorRect
                anchors.verticalCenter: parent.verticalCenter
                color: "#E95B4E"
                width: 4 * appScaleSize
                radius: width/2
                Timer{
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
            width: nameText.width
            height: parent.height
            clip: true
            visible: false
            color: "#00000000"

            Text {
                id: nameText

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                }
                color: "#000000"
                font.pixelSize: defaultFontSize + 9
                clip: true
                verticalAlignment: Text.AlignVCenter
                visible: !nameTextEdit.visible
                text: titleContent

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
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
            topMargin: 7 * appScaleSize
        }
        width: currentDateText.contentWidth + 20
        height: parent.height * (CSJ.PlayPageView.playpage_title_name_height
                                 / CSJ.PlayPageView.playpage_title_height)
        color: "#00000000"

        Text {
            id: currentDateText

            color: "#3C3F48"
            font.pixelSize: defaultFontSize + 30
            anchors.verticalCenter: parent.verticalCenter
            text: currentDateContent === "" ? "00:00.0" : currentDateContent
        }
    }

    Rectangle {
        id: dateLengthRect

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: currentDateRect.bottom
            topMargin: 14 * lastAppScaleSize //parent.height * (CSJ.PlayPageView.playpage_title_date_length_topmargin/ CSJ.PlayPageView.playpage_title_height)
        }
        width: dateText.contentWidth + lengthText.contentWidth + 20
        height: parent.height * (CSJ.PlayPageView.playpage_title_date_length_height
                                 / CSJ.PlayPageView.playpage_title_height)
        color: "#00000000"

        Text {
            id: lengthText

            anchors.verticalCenter: parent.verticalCenter
            //black #A29BA9
            color: "#993C3F48"
            font.pixelSize: defaultFontSize - 3
            text: lengthContent
        }
        Text {
            id: dateText

            anchors {
                left: lengthText.right
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            color: "#993C3F48"
            font.pixelSize: defaultFontSize - 3
            text: dateContent
        }
    }
}
