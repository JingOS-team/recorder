/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import org.kde.kirigami 2.0 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtQuick.Layouts 1.2
import KRecorder 1.0
import QtGraphicalEffects 1.0
import "commonsize.js" as CSJ

Kirigami.Page {
    id:recordMainView

    property int rightWidth: parent.width - mainLeftView.width
    property bool rightDefaultShow : !rightViewPlayer.visible

    leftPadding: 0
    topPadding: 0
    bottomPadding: 0
    rightPadding: 0

    background: Rectangle{
        color: "#B3000000"
    }

    RecordMainLeftView{
        id: mainLeftView

        anchors{
            top: parent.top
            bottom: parent.bottom
            bottomMargin: parent.height/20
        }
        width:parent.width *(CSJ.LeftView.left_view_width/CSJ.ScreenCurrentWidth)
        height: parent.height
        color: "transparent"

        onItemClicked:{
            rightViewPlayer.ppTitle.renamePlayPageTitle(false)
            rightViewPlayer.setFileName()
            if(AudioPlayer.state === AudioPlayer.PlayingState){
                AudioPlayer.stop()
            }
            AudioPlayer.setVolume(100);
            AudioPlayer.setMediaPath(recording.filePath)
            recording.getTags()
            rightViewPlayer.recording = recording
        }

        onRecordImageClicked: {
            AudioPlayer.stop()
            pageStack.layers.push("qrc:/RecordPage.qml",{currentVX:0});
        }

        onItemLongClicked: {
        }

        onDeleteClicked: {
            RecordingModel.deleteRecording(index);
            AudioPlayer.stop()
            AudioPlayer.clearVolumnList()
            rightViewPlayer.recording = RecordingModel.firstRecording()
        }

        onRenameClicked: {
            rightViewPlayer.ppTitle.renamePlayPageTitle(true)
        }

    }

    PlayerPage{
        id:rightViewPlayer

        anchors{
            left: mainLeftView.right
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            bottomMargin: recordMainView.height/20
            rightMargin: root.width * (CSJ.playPage_Bottom_Left_right_margin/CSJ.ScreenCurrentWidth)
            leftMargin:root.width* (CSJ.playPage_Bottom_Left_right_margin/CSJ.ScreenCurrentWidth)
        }
        width: parent.width - mainLeftView.width
        height: parent.height
        color: "transparent"
    }
    Rectangle{
        id:rightDefaultView

        anchors.left: mainLeftView.right
        visible: !mainLeftView.titleIsEdit
        color:"#801C1C1C"
        width: parent.width - mainLeftView.width
        height: parent.height
        MouseArea{
            anchors.fill: parent
            onClicked: {
                mainLeftView.checkBoxHide()
            }
        }
    }



}
