#include "backend.h"

#include <QCoreApplication>
#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

namespace {
const char *kBackendPath = "/usr/lib/zengos/zeng-install-backend";

struct DemoStep {
    double progress;
    const char *message;
};

const DemoStep kDemoSteps[] = {
    {0.04, "Preparing the disk"},
    {0.12, "Creating partitions"},
    {0.20, "Formatting"},
    {0.30, "Installing the base system"},
    {0.55, "Installing the Zolt desktop"},
    {0.72, "Installing your apps"},
    {0.82, "Creating your account"},
    {0.92, "Setting up the bootloader"},
    {1.00, "Done"},
};
} // namespace

Backend::Backend(QObject *parent) : QObject(parent) {
#ifndef Q_OS_LINUX
    m_demo = true;
#endif
    m_demoTimer.setInterval(1100);
    connect(&m_demoTimer, &QTimer::timeout, this, &Backend::demoTick);
    // Which optional add-ons this ISO actually carries (written at build time).
    QFile f(QStringLiteral("/usr/share/zengos/addons.json"));
    if (f.open(QIODevice::ReadOnly))
        m_addons = QJsonDocument::fromJson(f.readAll()).object().toVariantMap();
    else
        m_addons = {{"zengav", true}, {"zengsuite", false}};
    refreshDisks();
}

void Backend::refreshDisks() {
    m_disks.clear();
    if (m_demo) {
        m_disks << QVariantMap{{"path", "/dev/nvme0n1"}, {"name", "Samsung SSD 990 PRO"}, {"size", 1000204886016LL}, {"removable", false}}
                << QVariantMap{{"path", "/dev/sda"}, {"name", "Crucial MX500"}, {"size", 500107862016LL}, {"removable", false}};
        emit disksChanged();
        return;
    }

    QProcess lsblk;
    lsblk.start("lsblk", {"-J", "-b", "-d", "-e", "7,11", "-o", "PATH,SIZE,MODEL,TYPE,RM"});
    if (!lsblk.waitForFinished(5000)) {
        emit disksChanged();
        return;
    }
    const auto doc = QJsonDocument::fromJson(lsblk.readAllStandardOutput());
    for (const auto &entry : doc.object().value("blockdevices").toArray()) {
        const auto d = entry.toObject();
        if (d.value("type").toString() != "disk")
            continue;
        m_disks << QVariantMap{{"path", d.value("path").toString()},
                               {"name", d.value("model").toString().trimmed().isEmpty() ? QStringLiteral("Disk") : d.value("model").toString().trimmed()},
                               {"size", d.value("size").toVariant()},
                               {"removable", d.value("rm").toBool()}};
    }
    emit disksChanged();
}

void Backend::install(const QVariantMap &config) {
    if (m_running)
        return;
    m_running = true;
    m_finished = false;
    m_progress = 0;
    m_message = QStringLiteral("Starting");
    m_error.clear();
    emit runningChanged();
    emit finishedChanged();
    emit progressChanged();
    emit errorChanged();

    if (m_demo) {
        m_demoStep = 0;
        m_demoTimer.start();
        return;
    }

    m_process = new QProcess(this);
    m_process->setProgram(QStringLiteral("python3"));
    m_process->setArguments({kBackendPath, "--json"});
    connect(m_process, &QProcess::readyReadStandardOutput, this, [this] {
        m_buffer += m_process->readAllStandardOutput();
        int nl;
        while ((nl = m_buffer.indexOf('\n')) >= 0) {
            handleLine(m_buffer.left(nl));
            m_buffer.remove(0, nl + 1);
        }
    });
    connect(m_process, &QProcess::finished, this, [this](int code, QProcess::ExitStatus) {
        if (code != 0 && m_error.isEmpty())
            fail(QStringLiteral("The installer stopped unexpectedly (exit %1).").arg(code));
    });
    m_process->start();
    m_process->write(QJsonDocument(QJsonObject::fromVariantMap(config)).toJson(QJsonDocument::Compact));
    m_process->closeWriteChannel();
}

void Backend::handleLine(const QByteArray &line) {
    const auto obj = QJsonDocument::fromJson(line).object();
    if (obj.isEmpty())
        return;
    if (obj.contains("error")) {
        fail(obj.value("error").toString());
        return;
    }
    m_progress = obj.value("progress").toDouble(m_progress);
    m_message = obj.value("message").toString(m_message);
    emit progressChanged();
    if (obj.value("done").toBool()) {
        m_running = false;
        m_finished = true;
        emit runningChanged();
        emit finishedChanged();
    }
}

void Backend::demoTick() {
    const auto &step = kDemoSteps[m_demoStep++];
    m_progress = step.progress;
    m_message = QString::fromUtf8(step.message);
    emit progressChanged();
    if (m_demoStep >= int(sizeof(kDemoSteps) / sizeof(kDemoSteps[0]))) {
        m_demoTimer.stop();
        m_running = false;
        m_finished = true;
        emit runningChanged();
        emit finishedChanged();
    }
}

void Backend::fail(const QString &text) {
    m_demoTimer.stop();
    m_running = false;
    m_error = text;
    emit runningChanged();
    emit errorChanged();
}

void Backend::reboot() {
    if (!m_demo)
        QProcess::startDetached("systemctl", {"reboot"});
    else
        quit();
}

void Backend::quit() { QCoreApplication::quit(); }
