/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
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
import QtGraphicalEffects 1.0
import "commonsize.js" as CSJ

Rectangle {
    id:rightPage

    property bool isStopped: AudioRecorder.state === AudioRecorder.StoppedState
    property bool isPaused: AudioRecorder.state === AudioRecorder.PausedState
    property bool isRecording: AudioRecorder.state === AudioRecorder.RecordingState
    property int parentHeight:rightPage.height
    property int currentVX

    color: "#B3000000"

    PlayPageTitle{
        id:recordPageTitle

        titleContent: "Record"
        dateContent: AudioRecorder.currentTime
        currentDateContent: getCurrentDateContent()
        function getCurrentDateContent(){
            return  isStopped ? "00:00:00" : Utils.formatTime(AudioRecorder.duration)
        }
        onRenameClicked: {
            if(isFileNameEdit){
                titleContent = newFileName
            }
        }

    }

    Connections {
        target: AudioRecorder
        function onError(error) {
            console.warn("Error on the recorder", error)
        }
    }
    
    Visualization {
        id:vzAudioView

        anchors{
            top: recordPageTitle.bottom
            bottom: recordPageBottom.top
            right: recordPageBottom.right
            rightMargin: recordPageBottom.width * (CSJ.playPage_Bottom_Left_right_margin/CSJ.ScreenCurrentWidth)
            left: recordPageBottom.left
            leftMargin:recordPageBottom.width * (CSJ.playPage_Bottom_Left_right_margin/CSJ.ScreenCurrentWidth)

        }
        width: parent.width
        height: rightPage.height- recordPageTitle.height - recordPageBottom.height
        Layout.fillWidth: false
        isListMove: true
        audiouiColor: "#FF4444"
        centerLienColor: "#FF3030"
        showHorizontalLine:true
        maxBarHeight: height/2
        animationIndex: AudioRecorder.prober.animationIndex
        currentFliickableX: currentVX
        isPlayPage: false
        volumes: AudioRecorder.prober.volumesList
    }

    PlayPageBottom{
        id:recordPageBottom

        anchors{
            bottom: parent.bottom
            bottomMargin:parent.height/10
        }
        isPlayPage: false
        isAnimImage: AudioRecorder.state === AudioRecorder.RecordingState
        defaultSource: (isStopped || isPaused) ? playSource  : pauseSource
        onPlayClicked: {
            stopRecordingPlay()
            if(isStopped || isPaused) {
                AudioRecorder.record()
            }else{
                AudioRecorder.pause()
            }

        }
        onPauseClicked: {
            if(isStopped || isPaused) {
                AudioRecorder.record()
            }else{
                AudioRecorder.pause()
            }
            var path = AudioRecorder.getFilePath()
            AudioPlayer.stop()
            AudioPlayer.setVolume(100);
            AudioPlayer.setMediaPath(path)
            vzAudioView.isRecordPlay = true
        }
        onDoneClicked: {
            AudioRecorder.setRecordingName(recordPageTitle.textChangeContent);
            if(AudioRecorder.state === AudioRecorder.RecordingState){
                AudioRecorder.pause();
            }
            stopRecordingPlay();

            AudioRecorder.stop();
            pageStack.layers.pop();
        }
        onContinueClicked: {
            RecordingModel.addTags(recordPageTitle.titleContent,recordPageTitle.currentDateContent)
        }

    }

    Component.onCompleted: {
        if(isStopped || isPaused) {
            AudioRecorder.record()
        }
    }

    function stopRecordingPlay(){
        vzAudioView.isRecordPlay = false
        vzAudioView.isStartPlayRecord = false
        AudioRecorder.deleteFilePath()
        if(AudioPlayer.state !== AudioPlayer.StoppedState){
            AudioPlayer.stop()
        }

    }
}
