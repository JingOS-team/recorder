/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


import QtQuick 2.12
import org.kde.kirigami 2.12 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import KRecorder 1.0
import "commonsize.js" as CSJ

Rectangle {
    id:leftAllView

    property double scaleHeightSize: CSJ.LeftView.left_title_height/ CSJ.ScreenCurrentHeight
    property int titleHeight: parent.height * scaleHeightSize
    property int bottomHeight: parent.height/10
    property bool titleIsEdit : true
    property int itemSelectCount
    property int leftItemCount: leftView.itemCount

    signal itemClicked(var recording)
    signal itemLongClicked()
    signal recordImageClicked
    signal deleteClicked(var index)
    signal renameClicked(var index)
    signal hideCheckStatusTitle()

    width: parent.width
    height: parent.height

    function checkBoxShow(){
        leftView.isCheckboxShow = true
        leftTitleView.isEditShow = true
        titleIsEdit = false
    }

    function checkBoxHide(){
        titleIsEdit = true
        itemSelectCount = 0
        leftTitleView.isEditShow = false
        leftView.isCheckboxShow = false
        leftView.cancelAllChecked()
    }

    PageTitle{
        id:leftTitleView

        anchors{
            top: parent.top
            topMargin: 20
        }
        height: titleHeight
        editTextContent:itemSelectCount
        titleText: "Sound Recording"

        onEditClicked: {
            if(AudioPlayer.state === AudioPlayer.PlayingState){
                AudioPlayer.pause()
            }
            titleIsEdit = false
            checkBoxShow()
        }
        onCancelClicked: {
            checkBoxHide()
        }
        onAllChecked: {
            leftView.selectAllChecked(status);
        }
        onDeleteClicked: {
            deletCheckDialog.open()
        }

    }

    DeleteDialog{
        id:deletCheckDialog

        selectCount: itemSelectCount

        onDialogLeftClicked: {
            deletCheckDialog.close()
        }
        onDialogRightClicked: {
            RecordingModel.deleteAllCheck();
            itemSelectCount = 0
            deletCheckDialog.close()
            checkBoxHide()
            rightViewPlayer.recording = RecordingModel.firstRecording()
        }
    }

    RecordingListPage{
        id: leftView

        anchors{
            bottom: parent.bottom
            top: leftTitleView.bottom
            topMargin: 15
            right: parent.right
            rightMargin: 19
            left: parent.left
            leftMargin: 19
        }
        width:parent.width

        onItemLongClicked: {
            checkBoxShow()
        }
        onCheckboxSelectedChanged: {
            if(!titleIsEdit){
                if(checked){
                    itemSelectCount ++
                }else{
                    itemSelectCount --
                }
            }
        }
    }


    Image {
        id: bottomImage

        anchors{
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            margins: parent.height * (CSJ.LeftView.left_bottom_parent_margin/CSJ.ScreenCurrentHeight)
        }
        width: height
        height:parent.height *(CSJ.LeftView.left_bottom_record_image_height / CSJ.ScreenCurrentHeight)
        visible: false
        source: "qrc:/assets/record.png"

        MouseArea{
            anchors.fill: parent
            onClicked: {
                leftAllView.recordImageClicked()
            }
        }
    }

}
