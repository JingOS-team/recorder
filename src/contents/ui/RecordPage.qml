/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2020 Devin Lin <espidev@gmail.com>
 * SPDX-FileCopyrightText: 2021 Zhang He Gang <zhanghegang@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import org.kde.kirigami 2.15 as Kirigami
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
    property var recordTimeLength : 0
    property var playPageWidth

    color: Kirigami.JTheme.background

    Kirigami.JToolTip{
        id:toastShow
        font.pixelSize: 17 * appFontSize
    }

    function showToast(tips)
     {
        toastShow.text = tips
        toastShow.show(tips, 1500)
     }

    function switchPR() {
        var isTimeout = vzAudioView.currentRecordTime > (15 * 60 * 1000)
        var path = AudioRecorder.getFilePath(isTimeout)
        if(!isTimeout){
            AudioPlayer.stop()
            AudioPlayer.setVolume(100);
            AudioPlayer.setMediaPath(path)
            vzAudioView.isRecordPlay = true
        }
    }

    PlayPageTitle{
        id:recordPageTitle
        property var defaultFileName: getRecordDefaultFileName()
        property var cacheDefaultFileName: ""

        function getRecordDefaultFileName(){
            var cacheName = AudioRecorder.getRecordingName(i18n("New Recordings"))
            cacheDefaultFileName = cacheName
            return cacheName
        }
        anchors{
         top: parent.top
         topMargin: 20 * lastAppScaleSize
         horizontalCenter: parent.horizontalCenter
        }
        width: playPageWidth

        titleContent: defaultFileName
        dateContent: AudioRecorder.currentTime
        currentDateContent: getCurrentDateContent()
        function getCurrentDateContent(){
            return  isStopped ? "00:00:00" : Utils.formatTime(vzAudioView.currentRecordTime)
        }
        onRenameClicked: {
            if((newFileName.indexOf(".") !== -1)
                    || (newFileName.indexOf("/") !== -1)
                    )
            {
                newFileName = cacheDefaultFileName
                titleContent = newFileName
                showToast(i18n("The file name cannot contain the following characters . /"))
                return
            }else if(newFileName.startsWith("."))
            {
                newFileName = cacheDefaultFileName
                titleContent = newFileName
                showToast(i18n("Cannot start with a symbol as a file name"))
                return
            } else if (newFileName === ""){
                newFileName = cacheDefaultFileName
                titleContent = newFileName
                showToast(i18n("The file name cannot be empty."))
                return
            }
            var fileExists = AudioRecorder.setRecordingName(recordPageTitle.textChangeContent);
            if(fileExists){
                newFileName = cacheDefaultFileName
                showToast(i18n("The current file name is in use. Please rename it."))
            }
            if(isFileNameEdit){
                titleContent = newFileName
                recordPageTitle.cacheDefaultFileName = newFileName
            }
        }
    }

    Connections {
        target: AudioRecorder
        function onError(error) {
            console.warn("Error on the recorder", error)
        }
    }
    
    Connections {
        target: RecordingModel
        onQuitApp:{
            console.log("onQuitApp ing....")
        }
        function onError(error) {
            console.warn("Error on the RecordingModel", error)
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
            bottomMargin:29 * lastAppScaleSize
        }
        isPlayPage: false
        isAnimImage: AudioRecorder.state === AudioRecorder.RecordingState
        defaultSource: (isStopped || isPaused) ? playSource  : whitePauseSource
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
            switchPR()
        }
        onDoneClicked: {
            if((recordPageTitle.textChangeContent.indexOf(".") !== -1)
                    || (recordPageTitle.textChangeContent.indexOf("/") !== -1)
                    )
            {  
                recordPageTitle.titleContent = recordPageTitle.cacheDefaultFileName
                showToast(i18n("The file name cannot contain the following characters . /"))
                AudioRecorder.pause();
                switchPR()
                return
            }else if(recordPageTitle.textChangeContent.startsWith("."))
            {
                recordPageTitle.titleContent = recordPageTitle.cacheDefaultFileName
                showToast(i18n("Cannot start with a symbol as a file name"))
                AudioRecorder.pause();
                switchPR()
                return
            } else if (recordPageTitle.textChangeContent === ""){
                recordPageTitle.titleContent = recordPageTitle.cacheDefaultFileName
                showToast(i18n("The file name cannot be empty."))
                AudioRecorder.pause();
                switchPR()
                return
            }

            if(AudioRecorder.state === AudioRecorder.RecordingState){
                AudioRecorder.pause();
            }

            var fileExists = AudioRecorder.setRecordingName(recordPageTitle.textChangeContent);
            if(!fileExists){
                stopRecordingPlay();
                AudioRecorder.stop();
                mainStackView.pop()
            } else {
                recordPageTitle.renamePlayPageTitle(true)
                recordPageTitle.titleContent = recordPageTitle.cacheDefaultFileName
                showToast(i18n("The current file name is in use. Please rename it."))
            }
        }
        onContinueClicked: {
            RecordingModel.addTags(recordPageTitle.titleContent,recordPageTitle.currentDateContent)
        }

    }

    Component.onCompleted: {
        recordTimeLength = 0
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
