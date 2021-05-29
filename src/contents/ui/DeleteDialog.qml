/*
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import QtQuick 2.12
import org.kde.kirigami 2.15 as Kirigami
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.2
import "commonsize.js" as CSJ

Kirigami.JDialog{
    id:dialog

    property var titleContent
    property int selectCount
    property var msgContent:selectCount > 1 ? filesContent :fileContent
    property var fileContent:i18n("Are you sure you want to delete this recording?")
    property var filesContent:i18n("Are you sure you want to delete these recordings?")

    signal dialogRightClicked
    signal dialogLeftClicked

    title: i18n("Delete")
    text: msgContent
    rightButtonText: i18n("Delete")
    leftButtonText: i18n("Cancel")

    onRightButtonClicked:{
        dialogRightClicked()
    }
    onLeftButtonClicked:{
        dialogLeftClicked()
    }
}
