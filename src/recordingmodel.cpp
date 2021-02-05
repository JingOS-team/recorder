/*
 * SPDX-FileCopyrightText: 2020 Jonah Brüchert <jbb@kaidan.im>
 * SPDX-FileCopyrightText: 2021 Wang Rui <wangrui@jingos.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include "recordingmodel.h"

#include <QFile>
#include <QStandardPaths>
#include <QJsonObject>
#include <QDebug>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDebug>
#include <QDir>
#include <math.h>
#include "taglib/tag.h"
#include "taglib/fileref.h"
#include "utils.h"
#include <QException>

const QString DEF_RECORD_PREFIX = "clip";

/* ~ Recording ~ */

Recording::Recording(QObject* parent, const QString &filePath, const QString &fileName, QDateTime recordDate, int recordingLength,QList<RecordingTag*> tagsList)
    : QObject(parent)
    ,m_itemChecked(false)
    , m_filePath(filePath)
    , m_fileName(fileName)
    , m_recordDate(recordDate)
    , m_recordingLength(recordingLength)
    , m_recordingTag(tagsList)
{
}

Recording::Recording(const QJsonObject &obj)
    : m_itemChecked(false)
    , m_filePath(obj["filePath"].toString())
    , m_fileName(obj["fileName"].toString())
    , m_recordDate(QDateTime::fromString(obj["recordDate"].toString(), dateFormatString))
    , m_recordingLength(obj["recordingLength"].toInt())
{}

Recording::~Recording()
{
}

QJsonObject Recording::toJson() const
{
    QJsonObject obj;
    obj["filePath"] = m_filePath;
    obj["fileName"] = m_fileName;
    obj["recordDate"] = m_recordDate.toString(dateFormatString);
    obj["recordingLength"] = m_recordingLength;
    return obj;
}

QString Recording::recordingLengthPretty() const
{
    const int hours = m_recordingLength / 60 / 60;
    const int min = m_recordingLength / 60 - hours * 60;
    const int sec = m_recordingLength - min * 60 - hours * 60 * 60;
    return QStringLiteral("%1:%2").arg(min, 2, 10, QLatin1Char('0')).arg(sec, 2, 10, QLatin1Char('0'));
}

void Recording::setItemChecked(bool checked)
{
    if (m_itemChecked != checked) {
        m_itemChecked = checked;
        emit checkedChanged();
        emit RecordingModel::instance()->recorderCheckedChange(checked);
    }
}

void Recording::setFilePath(const QString &filePath)
{
    QFile(m_filePath).rename(filePath);
    m_filePath = filePath;

    QStringList spl = filePath.split("/");
    m_fileName = spl[spl.size()-1].split(".")[0];

    emit propertyChanged();
}

void Recording::setFileName(const QString &fileName)
{
    QString oldPath = m_filePath;

    m_filePath.replace(QRegExp(m_fileName + "(?!.*" + m_fileName + ")"), fileName);
    QFile(oldPath).rename(m_filePath);

    m_fileName = fileName;
    emit propertyChanged();
}

void Recording::setRecordDate(const QDateTime &date)
{
    m_recordDate = date;
    emit propertyChanged();
}

void Recording::setRecordingLength(int recordingLength)
{
    m_recordingLength = recordingLength;
    emit propertyChanged();
}

void Recording::setTags(QList<RecordingTag*> tags)
{
    m_recordingTag = tags;
    saveTags();
    emit tagsChanged();
}

void Recording:: addTags(QString &tagName,QString &tagDate)
{
    RecordingTag *nTag = new RecordingTag(this,tagName,tagDate);
    m_recordingTag.append(nTag);
    emit tagsChanged();

    saveTags();
}

void Recording::removeTags(int index)
{
    if (m_recordingTag.size()>0) {
        m_recordingTag.removeAt(index);
    }
    emit tagsChanged();

    saveTags();
}

void Recording::saveTags()
{
    QJsonArray arr;

    const auto recordings = qAsConst(m_recordingTag);
    std::transform(recordings.begin(), recordings.end(), std::back_inserter(arr), [](const RecordingTag *recording) {
        return QJsonValue(recording->toJson());
    });

    RecordingModel::instance()->m_settings->setValue(m_fileName, QString(QJsonDocument(arr).toJson(QJsonDocument::Compact)));
}

void Recording::getTags()
{
    QVariant qv = RecordingModel::instance()->m_settings->value(m_fileName);
    if ( !qv.isValid() || qv.isNull()) {
        return;
    }
    QJsonDocument doc = QJsonDocument::fromJson(qv.toString().toUtf8());
    const auto array = doc.array();

    std::transform(array.begin(), array.end(), std::back_inserter(m_recordingTag), [](QJsonValue vObj) {
        return new RecordingTag(vObj.toObject());
    });
}

/* RecordingTag*/
RecordingTag::RecordingTag(QObject* parent,const QString &tagName, const QString &tagDate)
    : QObject(parent)
    , m_tagName(tagName)
    , m_tagDate(tagDate)
{}

RecordingTag::RecordingTag(const QJsonObject obj):
    m_tagName(obj["tagName"].toString())
    , m_tagDate(obj["tagDate"].toString())
{
}

RecordingTag::~RecordingTag()
{
}

QJsonObject RecordingTag::toJson() const
{
    QJsonObject obj;
    obj["tagName"] = m_tagName;
    obj["tagDate"] = m_tagDate;
    return obj;

}

void RecordingTag::setTagName(const QString &tagName)
{

    m_tagName = tagName;
    emit propertyChanged();
}

void RecordingTag::setTagDate(const QString &date)
{
    m_tagDate = date;
    emit propertyChanged();
}

/* ~ RecordingModel ~ */

RecordingModel::RecordingModel(QObject *parent) : QAbstractListModel(parent)
{
    m_settings = new QSettings(parent);
    load();
}

RecordingModel::~RecordingModel()
{
    save();
    delete m_settings;
    qDeleteAll(m_recordings);
}

QJsonArray RecordingModel::loadFromFiles()
{
    //+"/record"
    QString path =  QStandardPaths::writableLocation(QStandardPaths::MusicLocation);
    QDir dir(path);
    if (!dir.exists()) {
        bool isSuc = dir.mkpath(path);
        if (!isSuc) {
            return {};
        }
    }
    QStringList nameFilters;
    nameFilters <<"*.wav";
    QFileInfoList files =  dir.entryInfoList(nameFilters,QDir::Files|QDir::Readable,QDir::Time);
    if (files.size() > 0) {
        QJsonArray array;
        foreach (QFileInfo file,files) {
            QString fileName = file.baseName();
            //Qt::DateFormat::RFC2822Date
            QString dateTime = file.birthTime().toString(dateFormatString);
            QString filePath = file.filePath();
            int size = file.size();
            int duration =  getAudioTime(filePath);
            QJsonObject obj;
            obj["filePath"] = filePath;
            obj["fileName"] = fileName;
            obj["recordDate"] =dateTime;
            obj["recordingLength"] = duration;
            array.append(obj);
        }
        return array;
    }
    return {};
}

qint64 RecordingModel::getAudioTime(const QString &filePath)
{
    TagLib::FileRef *fileRef  = new TagLib::FileRef(TagLib::FileName(filePath.toUtf8()));
    if (fileRef->audioProperties()) {
        int duration =  fileRef->audioProperties()->length();
        return duration;
    }
    return 0;
}

int RecordingModel::getPcmDB( char *pcmdata, int size)
{
    int db = 0;
    short int value = 0;
    double sum = 0;
    for (int i = 0; i < size; i += 2) {
        memcpy(&value, pcmdata+i, 2);
        sum += abs(value);
    }
    sum = sum / (size / 2);
    if (sum > 0) {
        db = (int)(20.0*log10(sum));
    }
    return db;
}

void RecordingModel::load()
{
    if (m_recordings.size() >0) {
        foreach (auto item, m_recordings) {
            m_recordings.removeOne(item);
        }
    }

    QJsonArray filesArray = loadFromFiles();

    if (filesArray.count() > 0) {
        std::transform(filesArray.begin(), filesArray.end(), std::back_inserter(m_recordings), [](const QJsonValue &rec) {
            return new Recording(rec.toObject());
        });
    }
}

void RecordingModel::setAllItemCheck(bool state)
{
    foreach (auto item,m_recordings) {
        item->setItemChecked(state);
    }
}

bool RecordingModel::deleteAllCheck()
{
    if (m_recordings.size()<= 0) {
        return false;
    }
    QList<Recording*> needDeletedRecordings;
    for (int i = 0; i < m_recordings.size(); i++ ) {
        Recording* item = m_recordings.at(i);
        if (item->itemChecked()) {
            needDeletedRecordings.append(item);
        }
    }
    beginResetModel();
    foreach (auto item,needDeletedRecordings) {
        deleteRecordingByItem(item);
    }
    endResetModel();
    return true;
}

Recording* RecordingModel::firstRecording()
{

    if (m_recordings.size()<=0) {
        return NULL;
    }
    return m_recordings.first();
}

int RecordingModel::getScreenWidth()
{
    QScreen *screen=QGuiApplication::primaryScreen ();
    QRect mm=screen->availableGeometry() ;
    m_screenWidth =  mm.width();
    return m_screenWidth;

}

int RecordingModel::getScreenHeight()
{
    QScreen *screen=QGuiApplication::primaryScreen ();
    QRect mm=screen->availableGeometry() ;
    m_screenHeight = mm.height();
    return m_screenHeight;

}

void RecordingModel::loadByContent(const QString &content)
{
    if (!content.isEmpty()) {
        load();
        QList<Recording*> notContainsList;

        foreach (auto item,m_recordings) {
            QString a_fileName = item->fileName();
            bool isContains =  a_fileName.contains(content);
            if (!isContains) {
                notContainsList.append(item);
            }
        }

        beginResetModel();
        foreach (auto item,notContainsList) {
            m_recordings.removeOne(item);
        }
        endResetModel();
    } else {
        beginResetModel();
        load();
        endResetModel();
    }
    m_searchContent = content;
}

void RecordingModel::save()
{
    QJsonArray arr;

    const auto recordings = qAsConst(m_recordings);
    std::transform(recordings.begin(), recordings.end(), std::back_inserter(arr), [](const Recording *recording) {
        return QJsonValue(recording->toJson());
    });

    m_settings->setValue(QStringLiteral("recordings"), QString(QJsonDocument(arr).toJson(QJsonDocument::Compact)));
}

QHash<int, QByteArray> RecordingModel::roleNames() const
{
    return {{Roles::RecordingRole, "recording"}};
}

QVariant RecordingModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_recordings.count() || index.row() < 0)
        return {};

    auto *recording = m_recordings.at(index.row());
    if (role == Roles::RecordingRole)
        return QVariant::fromValue(recording);

    return {};
}

int RecordingModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_recordings.count();
}

QString RecordingModel::nextDefaultRecordingName()
{
    QSet<QString> s;

    for (const auto &rec : qAsConst(m_recordings)) {
        s.insert(rec->fileName());
    }

    // determine valid clip name (ex. clip_0001, clip_0002, etc.)

    int num = 1;
    QString build = "0001";

    while (s.contains(DEF_RECORD_PREFIX + "_" + build)) {
        num++;
        build = QString::number(num);
        while (build.length() < 4) {
            build = "0" + build;
        }
    }

    return DEF_RECORD_PREFIX + "_" + build;
}


void RecordingModel::insertRecording(QString filePath, QString fileName, QDateTime recordDate, int recordingLength)
{
    if (m_searchContent.isEmpty() || fileName.contains(m_searchContent)) {
        beginInsertRows({}, 0, 0);
        Recording *rd = new Recording(this, filePath, fileName, recordDate, recordingLength);
        m_recordings.insert(0,rd);
        endInsertRows();
        emit insertNewRecordFile();
        rd->setTags(m_recordingTag);
        m_recordingTag.clear();
        save();
    }

}

void RecordingModel::deleteRecording(const int index)
{
    QFile::remove(m_recordings[index]->filePath());
    beginRemoveRows({}, index, index);
    m_recordings.removeAt(index);
    endRemoveRows();

    save();
}

void RecordingModel:: addTags(QString tagName,QString tagDate)
{
    RecordingTag *nTag = new RecordingTag(this,tagName,tagDate);
    m_recordingTag.append(nTag);
    emit tagsChanged();

}

void RecordingModel::removeTags(int index)
{
    if (m_recordingTag.size()>0) {
        m_recordingTag.removeAt(index);
    }
    emit tagsChanged();
}

void RecordingModel::deleteRecordingByItem(Recording* item)
{
    qDebug() << "deleteRecordingByItem recording " << item->filePath();
    QFile::remove(item->filePath());
    m_recordings.removeOne(item);

    if (m_settings->contains(item->fileName())) {
        m_settings->remove(item->fileName());
    }
}

