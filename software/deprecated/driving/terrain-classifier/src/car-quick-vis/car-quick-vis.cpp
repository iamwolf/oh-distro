// Publish a car affordance mesage relative to the robot's pelvis
//
// 


#include <stdio.h>
#include <inttypes.h>
#include <iostream>
#include <Eigen/Dense>

#include <lcm/lcm-cpp.hpp>

#include <bot_frames/bot_frames.h>
#include <bot_param/param_client.h>
#include <bot_frames_cpp/bot_frames_cpp.hpp>

#include "lcmtypes/bot_core.hpp"
#include <lcmtypes/drc_lcmtypes.hpp>

#include <ConciseArgs>

using namespace std;
using namespace Eigen;

class Pass{
  public:
    Pass(boost::shared_ptr<lcm::LCM> &lcm_);
    
    ~Pass(){
    }    
  private:
    boost::shared_ptr<lcm::LCM> lcm_;
    
    void affordanceHandler(const lcm::ReceiveBuffer* rbuf, 
                             const std::string& channel, const  drc::affordance_collection_t* msg);
    void utimeHandler(const lcm::ReceiveBuffer* rbuf, 
                             const std::string& channel, const  drc::utime_t* msg);
    BotParam* botparam_;
    BotFrames* botframes_;
    bot::frames* frames_cpp_;
    
    void setXYZRPYFromIsometry3d(double xyz[3], double rpy[3], 
                   Eigen::Isometry3d &pose);

    drc::affordance_t last_affordance_msg_; // The last update of the affordance msg:
    int64_t recent_utime_;
};

Pass::Pass(boost::shared_ptr<lcm::LCM> &lcm_):
    lcm_(lcm_){
  botparam_ = bot_param_new_from_server(lcm_->getUnderlyingLCM(), 0);
  botframes_= bot_frames_get_global(lcm_->getUnderlyingLCM(), botparam_);
  lcm_->subscribe("AFFORDANCE_COLLECTION",&Pass::affordanceHandler,this);
  lcm_->subscribe("ROBOT_UTIME",&Pass::utimeHandler,this);
  
  cout << "Finished setting up\n";
}

/// This function replicates one in pointcloud_math. But does a function exist in Eigen?
void quat_to_euler(Eigen::Quaterniond q, double& yaw, double& pitch, double& roll) {
  const double q0 = q.w();
  const double q1 = q.x();
  const double q2 = q.y();
  const double q3 = q.z();
  roll = atan2(2*(q0*q1+q2*q3), 1-2*(q1*q1+q2*q2));
  pitch = asin(2*(q0*q2-q3*q1));
  yaw = atan2(2*(q0*q3+q1*q2), 1-2*(q2*q2+q3*q3));
}


void Pass::setXYZRPYFromIsometry3d(double xyz[3], double rpy[3], 
                   Eigen::Isometry3d &pose){
  Eigen::Quaterniond r(pose.rotation());
  double yaw, pitch, roll;
  quat_to_euler(r, yaw, pitch, roll);  

  xyz[0] = pose.translation().x();
  xyz[1] = pose.translation().y();
  xyz[2] = pose.translation().z();
  
  
  rpy[0] = roll;
  rpy[1] = pitch;
  rpy[2] = yaw;
}  

/// Required because timestamp in affordance_collection_t is currently junk
void Pass::utimeHandler(const lcm::ReceiveBuffer* rbuf, 
                             const std::string& channel, const  drc::utime_t* msg){
  recent_utime_ = msg->utime;
}

void Pass::affordanceHandler(const lcm::ReceiveBuffer* rbuf, 
                             const std::string& channel, const  drc::affordance_collection_t* msg){
  for (size_t i=0; i < msg->affs.size() ; i++){
    drc::affordance_t a = msg->affs[i];

    if (a.otdf_type == "car"){
      last_affordance_msg_ = a;
      last_affordance_msg_.aff_store_control =  drc::affordance_t::UPDATE;
      
      Eigen::Isometry3d local_to_body= frames_cpp_->get_trans_with_utime( botframes_ ,  "body", "local", recent_utime_);
      
      // This is related to the pinned link but i can't find the exact conversion
      // its probably calculated correctly in the DRCSIM plugin in VRCPlugin.cpp
      Eigen::Isometry3d body_to_car = Eigen::Isometry3d::Identity();
      body_to_car.translation()  << 0.06, -0.3, -1.115;    

      Eigen::Isometry3d local_to_car = local_to_body* body_to_car;

      setXYZRPYFromIsometry3d( (last_affordance_msg_.origin_xyz), (last_affordance_msg_.origin_rpy),  local_to_car );
      lcm_->publish("AFFORDANCE_TRACK", &last_affordance_msg_);
      

    }
  }
}


int main( int argc, char** argv ){
  boost::shared_ptr<lcm::LCM> lcm(new lcm::LCM);
  if(!lcm->good()){
    std::cerr <<"ERROR: lcm is not good()" <<std::endl;
  }
  
  Pass app(lcm);
  cout << "Go ============================" << endl;
  while(0 == lcm->handle());
  return 0;
}