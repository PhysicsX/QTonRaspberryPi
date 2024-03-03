// MyObject.h

#ifndef MYOBJECT_H
#define MYOBJECT_H

#include <QObject>
#include <QDebug>

class MyObject : public QObject
{
    Q_OBJECT
public:
    explicit MyObject(QObject *parent = nullptr) : QObject(parent) {}

public slots:
    void onButtonClicked() {
        qDebug() << "Button clicked!";
    }
};

#endif // MYOBJECT_H