/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.2 as Controls
import QtMultimedia 5.12
import KRecorder 1.0
import QtQuick.Layouts 1.2
import QtQml 2.14
import "commonsize.js" as CSJ

Kirigami.ApplicationWindow {
    id: root

    property int defaultFontSize : theme.defaultFont.pointSize

    width:  root.screen.width
    height: root.screen.height
    pageStack.globalToolBar.style: Kirigami.ApplicationHeaderStyle.None
    fastBlurMode:true
    fastBlurOpacity:0.8
    fastBlurColor:"#00000000"


    pageStack.initialPage: RecordMain {

    }
}

