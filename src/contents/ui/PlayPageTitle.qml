

/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.12
import "commonsize.js" as CSJ
import KRecorder 1.0
import QtQuick.Controls 1.4 as Controls
import QtQuick.Controls.Styles 1.4

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
        nameTextEdit.focus = teStatus
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
            hoverEnabled: true
            onEntered: {
                nameTextEdit.enabled = true
                nameTextEdit.focus = true
            }
            onExited: {

            }
        }
        Controls.TextField {
            id: nameTextEdit

            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
            }
            width: parent.width - parent.width / 10
            height: parent.height
            enabled: true
            text: titleContent
            activeFocusOnPress: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            maximumLength: 40

            style: TextFieldStyle {
                id: ts
                textColor: "#FFFFFF"
                font.pointSize: defaultFontSize + 15
                background: Rectangle {
                    color: "transparent"
                }
            }

            onAccepted: {
                nameTextEdit.focus = false
                renameClicked(true, nameTextEdit.text)
            }
            onTextChanged: {
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
                color: "#FFFFFF"
                font.pointSize: defaultFontSize + 15
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
        }
        width: currentDateText.contentWidth + 20
        height: parent.height * (CSJ.PlayPageView.playpage_title_name_height
                                 / CSJ.PlayPageView.playpage_title_height)
        color: "#00000000"

        Text {
            id: currentDateText

            color: "#FFFFFF"
            font.pointSize: defaultFontSize + 48
            anchors.verticalCenter: parent.verticalCenter
            text: currentDateContent === "" ? "00:00.0" : currentDateContent
        }
    }

    Rectangle {
        id: dateLengthRect

        anchors {
            horizontalCenter: parent.horizontalCenter
            top: currentDateRect.bottom
            topMargin: parent.height * (CSJ.PlayPageView.playpage_title_date_length_topmargin
                                        / CSJ.PlayPageView.playpage_title_height)
        }
        width: dateText.contentWidth + lengthText.contentWidth + 20
        height: parent.height * (CSJ.PlayPageView.playpage_title_date_length_height
                                 / CSJ.PlayPageView.playpage_title_height)
        color: "#00000000"

        Text {
            id: dateText

            anchors.verticalCenter: parent.verticalCenter
            color: "#A29BA9"
            font.pointSize: defaultFontSize - 3
            text: dateContent
        }
        Text {
            id: lengthText

            anchors {
                left: dateText.right
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            color: "#A29BA9"
            font.pointSize: defaultFontSize - 3
            text: lengthContent
        }
    }
}
