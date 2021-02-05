

/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.12
import org.kde.kirigami 2.15
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import "commonsize.js" as CSJ

Item {
    id: leftTitleView

    property var titleText
    property bool isEditShow: false
    property var editTextContent: "Edit"
    property int checkboxHeight: root.height * (CSJ.Left_View_Cancel_Height
                                                / CSJ.ScreenCurrentHeight)
    property var colorRow: "#00000000"
    property RecordCheckBox allCheckBox: itemCheckBox

    signal editClicked
    signal cancelClicked
    signal deleteClicked
    signal allChecked(var status)

    width: parent.width
    height: 40

    Rectangle {
        id: checkboxHideRect

        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            rightMargin: 50
            leftMargin: (root.width * CSJ.LeftView.ListItemMargin / CSJ.ScreenCurrentWidth) / 2 + 19
        }
        width: parent.width
        height: parent.height
        visible: !isEditShow
        color: "#00000000"

        Image {
            id: icon

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            width: height
            height: parent.height * (CSJ.Left_View_Icon_Height / CSJ.LeftView.left_title_height)
            source: "qrc:/assets/icon.svg"
        }

        Controls.Label {
            id: timeText

            anchors {
                bottom: parent.bottom
                left: icon.right
                leftMargin: 21
                verticalCenter: icon.verticalCenter
            }
            color: "#FFFFFF"
            text: titleText
            font.pointSize: defaultFontSize + 18
            font.bold: true
        }
    }

    Rectangle {
        id: checkboxshowRect

        property int immwidth: 20

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            rightMargin: (root.width * CSJ.LeftView.ListItemMargin
                          / CSJ.ScreenCurrentWidth) * 2 + 19
            leftMargin: (root.width * CSJ.LeftView.ListItemMargin / CSJ.ScreenCurrentWidth) / 2 + 19
        }
        width: parent.width
        height: parent.height
        visible: isEditShow
        color: "#00000000"

        RowLayout {
            id: rowLayout

            anchors {
                right: parent.right
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.minimumHeight: checkboxHeight
                Layout.minimumWidth: (checkboxshowRect.width - checkboxshowRect.immwidth) / 4
                color: "#00000000"

                RecordCheckBox {
                    id: itemCheckBox

                    anchors {
                        left: parent.left
                    }
                    width: checkboxHeight
                    height: width
                    imageSourceDefault: leftAllView.itemSelectCount !== leftAllView.leftItemCount
                                        && leftAllView.itemSelectCount > 0 ? "qrc:/assets/select_one.svg" : "qrc:/assets/checkbox_default.png"
                    checked: leftAllView.itemSelectCount == leftAllView.leftItemCount

                    MouseArea {
                        anchors.centerIn: parent
                        width: itemCheckBox.width + 40
                        height: itemCheckBox.height + 40
                        onClicked: {
                            allChecked(!itemCheckBox.checked)
                        }
                    }
                }
                Text {
                    id: ltTextView

                    text: editTextContent
                    anchors {
                        verticalCenter: itemCheckBox.verticalCenter
                        left: itemCheckBox.right
                        leftMargin: 16
                    }
                    color: "#FFFFFF"
                    font.pointSize: defaultFontSize + 2
                }
            }

            Rectangle {
                color: colorRow
                Layout.fillWidth: true
                Layout.minimumHeight: checkboxHeight
                Layout.minimumWidth: (checkboxshowRect.width - checkboxshowRect.immwidth) / 4
                JIconButton {
                    id: foldersImage

                    width: height
                    height: checkboxHeight + 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "qrc:/assets/folders.png" //leftAllView.itemSelectCount <= 0 ? "qrc:/assets/folders.png" : "qrc:/assets/folders_select.png"
                }
            }

            Rectangle {
                color: colorRow
                Layout.fillWidth: true
                Layout.minimumHeight: checkboxHeight
                Layout.minimumWidth: (checkboxshowRect.width - checkboxshowRect.immwidth) / 4

                JIconButton {
                    id: deleteImage

                    width: height
                    height: checkboxHeight + 10
                    anchors {
                        right: parent.right
                        rightMargin: parent.width * 1 / 4
                    }
                    source: leftAllView.itemSelectCount <= 0 ? "qrc:/assets/delete_default.png" : "qrc:/assets/delete_select.png"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        deleteClicked()
                    }
                }
            }
            Rectangle {
                color: colorRow
                Layout.fillWidth: true
                Layout.minimumHeight: checkboxHeight
                Layout.minimumWidth: (checkboxshowRect.width - checkboxshowRect.immwidth) / 4

                JIconButton {
                    id: cancelChecked

                    width: height
                    height: checkboxHeight + 10
                    anchors.right: parent.right
                    source: "qrc:/assets/back.png"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        cancelClicked()
                    }
                }
            }
        }
    }
}
