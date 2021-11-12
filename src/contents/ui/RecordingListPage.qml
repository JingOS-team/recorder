

/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 * SPDX-FileCopyrightText: 2021  Zhang He Gang <zhanghegang@jingos.com>
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
            leftAllView.insertRecordItem(RecordingModel.firstRecording())
        }
        onRecorderCheckedChange: {
            recordLeftFileView.checkboxSelectedChanged(checked)
        }
        onShowTipText: {
            recordMainView.showToast(tipText)
        }

        function onError(error) {
            console.warn("Error on the recorder", error)
        }
    }

    Timer {
        id: rectgetFocusTimer
        interval: 300
        onTriggered: {
            recordLeftFileView.forceActiveFocus()
        }
    }

    Component.onCompleted: {
        rectgetFocusTimer.start()
    }
    focus: true
    Keys.onPressed: {
        switch (event.key) {
        case Qt.Key_Escape:
            break
        case Qt.Key_Left:
        case Qt.Key_Right:
        case Qt.Key_Down:
        case Qt.Key_Up:
            recordFileList.forceActiveFocus()
            recordFileList.currentIndex = 0
            break
        default:
            break
        }
    }

    GridView {
        id: recordFileList

        property int itemIndex
        property int rectRadius: 10 * lastAppScaleSize

        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: parent.height
        cellHeight: parent.height / 5 + 10 * lastAppScaleSize
        cellWidth: parent.width / 2
        model: RecordingModel
        focus: true
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        highlight: Rectangle {
            color: Kirigami.JTheme.hoverBackground
            radius: recordFileList.rectRadius
            visible: recordFileList.activeFocus
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
                    leftAllView.deleteClicked(recordFileList.itemIndex)
                }
                deleteDialog.close()
            }
        }

        EditDialogView {
            id: editMenu
            modal: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            Overlay.modal: Rectangle {
                color: "#00000000"
            }

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
                leftAllView.renameClicked(recordFileList.itemIndex)
            }
            onSaveClicked: {

            }
        }

        delegate: Rectangle {
            id: listItem

            property Recording recording: model.modelData
            property bool itemHoverd
            property bool separatorVisible: true
            property var backgroundColor: "transparent"
            property var activeBackgroundColor: itemBackground.lineLeftMargin > 0 ? "transparent" : Kirigami.JTheme.highlightRed //"#E95B4E"
            property var activeTextColor: "#FFFFFF"
            property var textColor: Kirigami.JTheme.majorForeground
            property var item_date_lengh_text_select_color: itemBackground.lineLeftMargin > 0 ? Kirigami.JTheme.disableForeground : "#99FFFFFF"
            property var item_date_lengh_text_notselect_color: Kirigami.JTheme.disableForeground

            height: recordFileList.cellHeight
            width: recordFileList.cellWidth
            color: "#00000000"
            focus: true

            Keys.onPressed: {
                switch (event.key) {
                case Qt.Key_Enter:
                case Qt.Key_Return:
                    recordFileList.itemIndex = recordFileList.currentIndex

                    if (isCheckboxShow) {
                        recording.itemChecked = !recording.itemChecked
                    }

                    if (!isCheckboxShow) {
                        recordFileList.itemIndex = index
                        leftAllView.itemClicked(recording)
                    }
                    break
                default:
                    break
                }
            }

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
                    duration: 200
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
                color: Kirigami.JTheme.hoverBackground
                radius: recordFileList.rectRadius
            }

            Rectangle {
                id: itemBR

                property int imageX: (index % 2 === 0) ? 74 : itemBR.width + 74
                property int imageY: (index % 12) / 2 * (itemBR.height) + 24
                property var gContentY: recordFileList.y
                property string shadowColor: "#80C3C9D9"

                anchors {
                    fill: parent
                    margins: 10 * lastAppScaleSize / 2
                }
                width: parent.width
                height: parent.height
                radius: height / 10
                color: Kirigami.JTheme.cardBackground
                clip: true
                border {
                    width: 0
                    color: Kirigami.JTheme.buttonBorder
                }

                ListFileItem {
                    id: itemBackground

                    width: itemBR.width
                    height: itemBR.height
                    defaultIndex: index
                    lineLeftMargin: itemCheckBox.visible ? itemCheckBox.width : 0
                    itemRadius: recordFileList.rectRadius
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
                                editMenu.popup(recordMainView, jx.x, jx.y)
                            }
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
                                    editMenu.popup(recordMainView, jx.x, jx.y)
                                }
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

                    Image {
                        id: itemCheckBox
                        property string defaultImage: isDarkTheme ? "qrc:/assets/checkbox_default_black.png" : "qrc:/assets/checkbox_default.png"

                        width: leftTitleView.checkboxHeight
                        height: width

                        anchors {
                            bottom: parent.bottom
                            right: parent.right
                            bottomMargin: CSJ.LeftView.ListItemMargin * lastAppScaleSize
                            rightMargin: CSJ.LeftView.ListItemMargin * lastAppScaleSize
                        }
                        visible: isCheckboxShow
                        source: recording.itemChecked ? "qrc:/assets/checkbox_ok.png" : defaultImage
                        enabled: false
                    }
                    Item {
                        id: leftColumn

                        property int lengthDateFontSize: defaultFontSize - 4 * appFontSize

                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: parent.width
                        height: leftFileRect.height

                        Text {
                            id: itemFileName

                            anchors {
                                left: leftColumn.left
                                leftMargin: CSJ.LeftView.ListItemMargin * lastAppScaleSize
                                right: itemLeft.right
                                bottom: itemLeft.top
                                top: parent.top
                                topMargin: CSJ.LeftView.ListItemMargin * lastAppScaleSize
                            }
                            width: parent.width - CSJ.LeftView.ListItemMargin
                            Layout.fillHeight: true
                            color: !itemCheckBox.visible ? (recordFileList.itemIndex === index ? listItem.activeTextColor : listItem.textColor) : (listItem.isCurrentItem || (listItem.pressed && !listItem.checked && !listItem.sectionDelegate) ? listItem.activeTextColor : listItem.textColor)
                            text: recording.fileName
                            font {
                                pixelSize: defaultFontSize
                            }
                            wrapMode: Text.WrapAnywhere
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            clip: true
                        }
                        Rectangle {
                            id: itemLeft

                            anchors {
                                bottom: parent.bottom
                                bottomMargin: CSJ.LeftView.ListItemMargin * lastAppScaleSize
                                right: parent.right
                                rightMargin: CSJ.LeftView.ListItemMargin * lastAppScaleSize
                                left: leftColumn.left
                                leftMargin: CSJ.LeftView.ListItemMargin * lastAppScaleSize
                            }
                            width: parent.width
                            height: 0
                            color: "transparent"
                            Kirigami.Icon {
                                id: clock

                                anchors {
                                    left: itemLeft.left
                                    bottom: labelDate.top
                                    bottomMargin: 2 * lastAppScaleSize
                                }
                                width: CSJ.Left_View_Clock_Width * lastAppScaleSize
                                height: width
                                color: itemFileName.color
                                source: lableLength.color == listItem.item_date_lengh_text_notselect_color ? "qrc:/assets/clock_normal.png" : "qrc:/assets/clock.png"
                            }
                            Text {
                                id: lableLength

                                anchors {
                                    verticalCenter: clock.verticalCenter
                                    left: clock.right
                                    leftMargin: 2 * lastAppScaleSize
                                }
                                color: recordFileList.itemIndex === index ? listItem.item_date_lengh_text_select_color : listItem.item_date_lengh_text_notselect_color
                                text: getText()

                                font {
                                    pixelSize: leftColumn.lengthDateFontSize
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
                                color: recordFileList.itemIndex === index ? listItem.item_date_lengh_text_select_color : listItem.item_date_lengh_text_notselect_color
                                text: itemBackxY()

                                function itemBackxY() {
                                    return recording.recordDate
                                }
                                elide: Text.ElideRight
                                font {
                                    pixelSize: leftColumn.lengthDateFontSize
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
