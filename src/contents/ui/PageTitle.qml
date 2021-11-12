
/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 *
 * Authors:
 * Zhang He Gang <zhanghegang@jingos.com>
 *
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
    property var editTextContent: i18n("Edit")
    property int skillHeight: 32 * lastAppScaleSize
    property int checkboxHeight: 22 * lastAppScaleSize
    property var colorRow: "#00000000"
    property RecordCheckBox allCheckBox: itemCheckBox

    signal editClicked
    signal cancelClicked
    signal deleteClicked
    signal allChecked(var status)

    width: parent.width
    height: 40 * lastAppScaleSize

    Rectangle {
        id: checkboxHideRect

        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            rightMargin: 50 * lastAppScaleSize
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
            width: visible ? height : 0
            height: parent.height * (CSJ.Left_View_Icon_Height / CSJ.LeftView.left_title_height)
            source: "qrc:/assets/icon.svg"
            visible: false
        }

        Controls.Label {
            id: timeText

            anchors {
                bottom: parent.bottom
                left: icon.right
                verticalCenter: icon.verticalCenter
            }
            //black #FFFFFF
            color: JTheme.majorForeground //"#3C3F48"
            text: titleText
            font.pixelSize: defaultFontSize + 11 * appFontSize
            font.bold: true
        }
    }

    Rectangle {
        id: checkboxshowRect

        property int immwidth: 20 * lastAppScaleSize

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
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
                Layout.minimumHeight: skillHeight
                Layout.minimumWidth: (checkboxshowRect.width - checkboxshowRect.immwidth) / 3
                color: "#00000000"

                JIconButton {
                    id: jicon
                    color: JTheme.majorForeground
                    anchors {
                        left: itemCheckBox.left
                        leftMargin: -4 * lastAppScaleSize
                        verticalCenter: parent.verticalCenter
                    }
                    width: checkboxHeight + 6 * lastAppScaleSize
                    height: checkboxHeight + 6 * lastAppScaleSize
                    visible: leftAllView.itemSelectCount !== leftAllView.leftItemCount
                    source: leftAllView.itemSelectCount !== leftAllView.leftItemCount
                            && leftAllView.itemSelectCount
                            > 0 ? "qrc:/assets/select_one.svg" : "qrc:/assets/checkbox_default.png"
                    MouseArea {
                        width: itemCheckBox.width + 10 * lastAppScaleSize
                        height: itemCheckBox.height + 10 * lastAppScaleSize
                        anchors.centerIn: jicon
                        onClicked: {
                            allChecked(!itemCheckBox.checked)
                        }
                    }
                }
                RecordCheckBox {
                    id: itemCheckBox

                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                    visible: !jicon.visible
                    width: checkboxHeight
                    height: width
                    imageSourceDefault: leftAllView.itemSelectCount !== leftAllView.leftItemCount
                                        && leftAllView.itemSelectCount > 0 ? "qrc:/assets/select_one.svg" : "qrc:/assets/checkbox_default.png"
                    checked: leftAllView.itemSelectCount == leftAllView.leftItemCount

                    MouseArea {
                        anchors.centerIn: parent
                        width: itemCheckBox.width + 10 * lastAppScaleSize
                        height: itemCheckBox.height + 10 * lastAppScaleSize
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
                        leftMargin: 5 * lastAppScaleSize
                    }
                    verticalAlignment: Text.AlignBottom
                    //black #FFFFFF
                    color: JTheme.majorForeground //"#3C3F48"
                    font.pixelSize: defaultFontSize
                }
            }

            Rectangle {
                color: colorRow
                Layout.fillWidth: true
                Layout.minimumHeight: skillHeight
                Layout.minimumWidth: (checkboxshowRect.width - checkboxshowRect.immwidth) / 3

                JIconButton {
                    id: deleteImage

                    width: height
                    height: skillHeight
                    anchors {
                        right: parent.right
                        rightMargin: parent.width * 1 / 4
                    }
                    opacity: leftAllView.itemSelectCount <= 0 ? 0.3 : 1.0
                    source: "qrc:/assets/delete_select.png"
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
                Layout.minimumHeight: skillHeight
                Layout.minimumWidth: (checkboxshowRect.width - checkboxshowRect.immwidth) / 3

                JIconButton {
                    id: cancelChecked

                    width: height
                    height: skillHeight
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
