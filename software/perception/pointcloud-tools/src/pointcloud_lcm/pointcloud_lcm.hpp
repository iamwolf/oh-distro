#ifndef POINTCLOUD_LCM_HPP_
#define POINTCLOUD_LCM_HPP_

#include <iostream>
#include <vector>
#include <algorithm>

#include <Eigen/Dense>
#include <Eigen/StdVector>

#include <pcl/io/pcd_io.h>
#include <pcl/point_types.h>

#include <opencv/cv.h>
#include <opencv/highgui.h>

#include <lcm/lcm.h>
#include <bot_core/bot_core.h>
#include <image_utils/jpeg.h>
#include <kinect/kinect-utils.h>

#include <lcmtypes/kinect_frame_msg_t.h>
#include <lcmtypes/pointcloud_tools.h>
#include <lcmtypes/pointcloud_tools.hpp>
#include <lcmtypes/multisense.h>
#include <lcmtypes/multisense.hpp>

using namespace pcl;
using namespace pcl::io;

class pointcloud_lcm {
  public:
    pointcloud_lcm (lcm_t* publish_lcm);

    void unpack_pointcloud2(const ptools_pointcloud2_t *msg,
          pcl::PointCloud<pcl::PointXYZRGB>::Ptr &cloud);
    
    void unpack_pointcloud2(const ptools::pointcloud2_t *msg,
          pcl::PointCloud<pcl::PointXYZRGB>::Ptr &cloud);

    void unpack_kinect_frame(const kinect_frame_msg_t *msg, uint8_t* rgb_data,
          pcl::PointCloud<pcl::PointXYZRGB>::Ptr &cloud);

    ////////////////////////////////////////////////////////////////////////
    void unpack_multisense(const uint8_t* depth_data, const uint8_t* color_data, int height, int width, cv::Mat_<double> repro_matrix, 
                                       pcl::PointCloud<pcl::PointXYZRGB>::Ptr &cloud, bool is_rgb = true);
    
    void unpack_multisense(const multisense_images_t *msg, cv::Mat_<double> repro_matrix,
          pcl::PointCloud<pcl::PointXYZRGB>::Ptr &cloud);
    
    void unpack_multisense(const multisense::images_t *msg, cv::Mat_<double> repro_matrix, 
                                       pcl::PointCloud<pcl::PointXYZRGB>::Ptr &cloud);
    
    // set an integer decimation factor:
    void set_decimate(int decimate_in){ decimate_ = decimate_in; };

  private:
    lcm_t *publish_lcm_; 

    KinectCalibration* kcal;
    int decimate_;
    
    // Multisense Compress:
    mutable std::vector<float> disparity_buf_;
    mutable std::vector<cv::Vec3f> points_buf_;    
};


inline void
convertLidar(const float * ranges, int numPoints, double thetaStart,
        double thetaStep,
        pcl::PointCloud<pcl::PointXYZRGB>::Ptr &cloud,
	double minRange = 0., double maxRange = 1e10,
	double validRangeStart = -1000, double validRangeEnd = 1000)
{
  int count = 0;
  double theta = thetaStart;

  cloud->width   = numPoints;
  cloud->height   = 1;
  cloud->points.resize (numPoints);

  // minRange was 0.1 until march 2013
  for (int i = 0; i < numPoints; i++) {
      if (ranges[i] > minRange && ranges[i] < maxRange && theta > validRangeStart
              && theta < validRangeEnd) { 
          //hokuyo driver seems to report maxRanges as .001 :-/
          //project to body centered coordinates
          cloud->points[count].x = ranges[i] * cos(theta);
          cloud->points[count].y = ranges[i] * sin(theta);
          count++;
      }
      theta += thetaStep;
  }
  // Resize outgoing cloud
  cloud->width   = count;
  cloud->points.resize (count);
}


inline void
convertLidar(std::vector< float > ranges, int numPoints, double thetaStart,
        double thetaStep,
        pcl::PointCloud<pcl::PointXYZRGB>::Ptr &cloud,
        double minRange = 0., double maxRange = 1e10,
        double validRangeStart = -1000, double validRangeEnd = 1000){
  int count = 0;
  double theta = thetaStart;

  cloud->width   = numPoints;
  cloud->height   = 1;
  cloud->points.resize (numPoints);

  // minRange was 0.1 until march 2013
  for (int i = 0; i < numPoints; i++) {
      if (ranges[i] > minRange && ranges[i] < maxRange && theta > validRangeStart
              && theta < validRangeEnd) { 
          //hokuyo driver seems to report maxRanges as .001 :-/
          //project to body centered coordinates
          cloud->points[count].x = ranges[i] * cos(theta);
          cloud->points[count].y = ranges[i] * sin(theta);
          count++;
      }
      theta += thetaStep;
  }
  // Resize outgoing cloud
  cloud->width   = count;
  cloud->points.resize (count);
}

#endif