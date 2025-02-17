#include <QApplication>
#include <QLabel>
#include <QImage>
#include <QPixmap>
#include <opencv2/opencv.hpp>

// Convert OpenCV Mat to QImage
QImage MatToQImage(const cv::Mat &mat) {
    if (mat.type() == CV_8UC3) {
        return QImage(mat.data, mat.cols, mat.rows, mat.step, QImage::Format_RGB888).rgbSwapped();
    } else if (mat.type() == CV_8UC1) {
        return QImage(mat.data, mat.cols, mat.rows, mat.step, QImage::Format_Grayscale8);
    }
    return QImage();
}

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);

    // Create an OpenCV image with a red circle
    cv::Mat img = cv::Mat::zeros(400, 400, CV_8UC3);
    cv::circle(img, cv::Point(200, 200), 100, cv::Scalar(0, 0, 255), -1);  // Draw red circle

    // Convert to QImage
    QImage qimg = MatToQImage(img);
    
    // Display in QLabel
    QLabel label;
    label.setPixmap(QPixmap::fromImage(qimg));
    label.setFixedSize(qimg.size());
    label.show();

    return app.exec();
}