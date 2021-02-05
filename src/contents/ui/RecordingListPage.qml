

/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick 2.15
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.2
import QtGraphicalEffects 1.12
import KRecorder 1.0
import "commonsize.js" as CSJ

Rectangle {
    id: recordLeftFileView

    property int mainwidth: parent.width
    property bool isCheckboxShow: false
    property bool isCheckboxChecked: false
    property int itemCount: recordFileList.count
    property Recording currentRecordingToEdit

    signal itemLongClicked
    signal checkboxSelectedChanged(bool checked)

    color: "#00000000"

    function cancelAllChecked() {
        RecordingModel.setAllItemCheck(false)
    }

    function selectAllChecked(status) {
        RecordingModel.setAllItemCheck(status)
    }

    Connections {
        target: RecordingModel

        onInsertNewRecordFile: {
            recordFileList.itemIndex = 0
            leftAllView.itemClicked(RecordingModel.firstRecording())
        }
        onRecorderCheckedChange: {
            recordLeftFileView.checkboxSelectedChanged(checked)
        }

        function onError(error) {
            console.warn("Error on the recorder", error)
        }
    }

    GridView {
        id: recordFileList

        property int itemIndex

        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: parent.height
        cellHeight: parent.height / 5
        cellWidth: parent.width / 2 - (root.width * CSJ.LeftView.ListItemMargin
                                       / CSJ.ScreenCurrentWidth)
        model: RecordingModel
        focus: true
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
            id: listItem

            property Recording recording: model.modelData
            property bool itemHoverd
            property bool separatorVisible: true
            property var backgroundColor: "transparent"
            property var activeBackgroundColor: itemBackground.lineLeftMargin
                                                > 0 ? "transparent" : "#E95B4E"
            property var activeTextColor: "#FFFFFF"
            property var textColor: "#FFFFFF"
            property var item_date_lengh_text_select_color: itemBackground.lineLeftMargin
                                                            > 0 ? "#FFFFFF" : "#FFFFFF"
            property var item_date_lengh_text_notselect_color: "#FFFFFF"

            height: recordFileList.cellHeight
            width: recordFileList.cellWidth
            color: "#00000000"

            GridView.onRemove: SequentialAnimation {
                PropertyAction {
                    target: listItem
                    property: "GridView.delayRemove"
                    value: true
                }
                NumberAnimation {
                    target: listItem
                    property: "scale"
                    to: 0
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
                PropertyAction {
                    target: listItem
                    property: "GridView.delayRemove"
                    value: false
                }
            }

            Rectangle {
                width: parent.width
                height: parent.height
                visible: listItem.itemHoverd
                color: "#2E747480"
                radius: CSJ.LeftView.ListItemRadius
            }

            Rectangle {
                id: itemBR

                property int imageX: (index % 2 === 0) ? 74 : itemBR.width + 74
                property int imageY: (index % 12) / 2 * (itemBR.height) + 24
                property var gContentY: recordFileList.y

                anchors {
                    fill: parent
                    margins: (root.width * CSJ.LeftView.ListItemMargin / CSJ.ScreenCurrentWidth) / 2
                }
                width: parent.width
                height: parent.height
                radius: CSJ.LeftView.ListItemRadius
                color: "transparent"
                clip: true

                Rectangle {
                    width: parent.width
                    height: parent.height
                    color: "#40000000"
                    radius: CSJ.LeftView.ListItemRadius
                }

                ListFileItem {
                    id: itemBackground

                    width: itemBR.width
                    height: itemBR.height
                    defaultIndex: index
                    lineLeftMargin: itemCheckBox.visible ? itemCheckBox.width : 0
                    itemRadius: CSJ.LeftView.ListItemRadius
                }

                DeleteDialog {
                    id: deleteDialog

                    selectCount: leftAllView.itemSelectCount
                    onDialogLeftClicked: {
                        deleteDialog.close()
                    }
                    onDialogRightClicked: {
                        if (leftTitleView.isEditShow) {
                            RecordingModel.deleteAllCheck()
                        } else {
                            leftAllView.deleteClicked(index)
                        }
                        deleteDialog.close()
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    onEntered: {
                        listItem.itemHoverd = true
                    }
                    onExited: {
                        listItem.itemHoverd = false
                    }

                    EditDialogView {
                        id: editMenu

                        onBulkClicked: {
                            recordLeftFileView.itemLongClicked()
                        }
                        onDeleteClicked: {
                            if (leftTitleView.isEditShow) {
                                if (leftAllView.itemSelectCount > 0) {
                                    deletCheckDialog.open()
                                }
                            } else {
                                deleteDialog.open()
                            }
                        }
                        onRenameClicked: {
                            leftAllView.renameClicked(index)
                        }
                        onSaveClicked: {

                        }
                    }

                    onPressAndHold: {
                        AudioPlayer.stop()
                        if (!editMenu.opened) {
                            recordFileList.itemIndex = index
                            leftAllView.itemClicked(recording)
                            var jx = mapToItem(recordMainView, mouse.x, mouse.y)
                            editMenu.mouseX = jx.x
                            editMenu.mouseY = jx.y

                            if (isCheckboxShow) {
                                editMenu.rmBulkAction()
                            } else {
                                editMenu.addBulkAction()
                            }
                            editMenu.popup(recordMainView, jx.x, jx.y)
                        }
                    }

                    onClicked: {
                        if (mouse.button === Qt.RightButton) {
                            AudioPlayer.stop()
                            if (!editMenu.opened) {
                                var jx = mapToItem(recordMainView,
                                                   mouse.x, mouse.y)
                                editMenu.mouseX = jx.x
                                editMenu.mouseY = jx.y

                                if (isCheckboxShow) {
                                    editMenu.rmBulkAction()
                                } else {
                                    editMenu.addBulkAction()
                                }
                                editMenu.popup(listItem)
                            }
                        } else {
                            if (isCheckboxShow) {
                                recording.itemChecked = !recording.itemChecked
                            }
                        }
                        if (!isCheckboxShow) {
                            recordFileList.itemIndex = index
                            leftAllView.itemClicked(recording)
                        }
                    }
                }

                Item {
                    id: leftFileRect

                    width: parent.width
                    height: parent.height

                    RecordCheckBox {
                        id: itemCheckBox

                        width: leftTitleView.checkboxHeight

                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                            bottomMargin: CSJ.Left_View_CheckBox_Margin
                            rightMargin: CSJ.Left_View_CheckBox_Margin
                        }
                        visible: isCheckboxShow
                        checked: recording.itemChecked
                        enabled: false
                    }
                    Item {
                        id: leftColumn

                        property int lengthDateFontSize: defaultFontSize - 5

                        anchors {
                            left: parent.left
                            right: parent.right
                            leftMargin: CSJ.LeftView.ListItemMargin
                            top: parent.top
                            topMargin: CSJ.LeftView.ListItemMargin
                            bottom: parent.bottom
                        }
                        width: parent.width
                        height: leftFileRect.height

                        Text {
                            id: itemFileName

                            anchors {
                                left: leftColumn.left
                                bottom: itemLeft.top
                                top: parent.top
                            }
                            width: parent.width - CSJ.LeftView.ListItemMargin
                            Layout.fillHeight: true
                            lineHeight: 0.7
                            color: !itemCheckBox.visible ? (recordFileList.itemIndex === index ? listItem.activeTextColor : listItem.textColor) : (listItem.isCurrentItem || (listItem.pressed && !listItem.checked && !listItem.sectionDelegate) ? listItem.activeTextColor : listItem.textColor)
                            text: recording.fileName
                            font {
                                pointSize: defaultFontSize + 2
                            }
                            font.bold: true
                            wrapMode: Text.WrapAnywhere
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            clip: true
                        }
                        Rectangle {
                            id: itemLeft

                            anchors {
                                bottom: parent.bottom
                                bottomMargin: 12
                                right: parent.right
                                rightMargin: 24
                                left: leftColumn.left
                            }
                            width: parent.width
                            height: 0
                            color: "transparent"
                            Image {
                                id: clock

                                anchors {
                                    left: itemLeft.left
                                    bottom: labelDate.top
                                    bottomMargin: 8
                                }
                                width: CSJ.Left_View_Clock_Width
                                height: width
                                source: "qrc:/assets/clock.png"
                            }
                            Text {
                                id: lableLength

                                anchors {
                                    verticalCenter: clock.verticalCenter
                                    left: clock.right
                                    leftMargin: 8
                                }
                                color: "#99FFFFFF"
                                text: getText()
                                font.bold: true

                                font {
                                    pointSize: leftColumn.lengthDateFontSize
                                }
                                function getText() {
                                    return recording.recordingLength
                                }
                            }
                            Text {
                                id: labelDate

                                anchors {
                                    right: itemLeft.right
                                    left: itemLeft.left
                                    bottom: parent.bottom
                                }
                                color: "#99FFFFFF"
                                text: itemBackxY()

                                function itemBackxY() {
                                    return recording.recordDate
                                }
                                elide: Text.ElideRight
                                font {
                                    pointSize: leftColumn.lengthDateFontSize - 2
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
