/*
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
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

Rectangle{
    id:playPageRect
    
    property Recording recording:RecordingModel.firstRecording()
    property PlayPageTitle ppTitle : playerPageTitle


    onRecordingChanged: {
        playVisualization.setSliderValue(0)
    }

    Connections {
        target: RecordingModel

        onInsertNewRecordFile:{
            playPageRect.recording = RecordingModel.firstRecording()
        }
        function onError(error) {
            console.warn("Error on the recorder", error)
        }
    }

    function setFileName(){
        if(recording.fileName !== playerPageTitle.textChangeContent){
            recording.fileName = playerPageTitle.textChangeContent
        }
    }

    PlayPageTitle{
        id:playerPageTitle

        anchors{
            top: parent.top
            topMargin: 20
        }
        titleContent: recording.fileName
        dateContent: recording.recordDate
        lengthContent: recording.recordingLength
        currentDateContent: AudioPlayer.state === AudioPlayer.StoppedState ? "00:00:00" : Utils.formatTime(Math.round(AudioPlayer.position/1000)*1000)
        onRenameClicked: {
            if(isFileNameEdit){
                recording.fileName = newFileName
            }
        }
    }

    Visualization {
        id:playVisualization

        anchors{
            left: palypageBottom.left
            right: palypageBottom.right
            top: playerPageTitle.bottom
            bottom: palypageBottom.top

        }
        width: parent.width
        height: playPageRect.height- playerPageTitle.height - palypageBottom.height
        Layout.fillWidth: false
        isListMove: true
        audiouiColor:"#FFAF0A"
        centerLienColor:"#FF9500"
        showLine: false
        showHorizontalLine:true
        currentFliickableX: recording.recordingLength
        maxBarHeight: height/2
        animationIndex: AudioPlayer.prober.animationInde
        volumes: AudioPlayer.prober.volumesList
        isPlayPage: true
    }

    onVisibleChanged: {
        playVisualization.playPageIsVisible = visible;
    }

    PlayPageBottom{
        id:palypageBottom
        isPlayPage: true
        color: "#00000000"
        defaultSource : playSource
        anchors.bottom: parent.bottom
        onPlayClicked: {
            AudioPlayer.stop()
            pageStack.layers.push("qrc:/RecordPage.qml",{currentVX:0});
        }
    }
}
