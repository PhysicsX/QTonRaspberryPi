#include <QCoreApplication>
#include <QDebug>

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);

    int var = 3;
    var = var + 1;
    qDebug()<<"Hello world" << var;
    return 0;
}
