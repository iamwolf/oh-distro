/* Auto-generated by genmsg_cpp for file /home/sisir/sandia-hand/ros/sandia_hand_msgs/srv/SetJointLimitPolicy.srv */
#ifndef SANDIA_HAND_MSGS_SERVICE_SETJOINTLIMITPOLICY_H
#define SANDIA_HAND_MSGS_SERVICE_SETJOINTLIMITPOLICY_H
#include <string>
#include <vector>
#include <map>
#include <ostream>
#include "ros/serialization.h"
#include "ros/builtin_message_traits.h"
#include "ros/message_operations.h"
#include "ros/time.h"

#include "ros/macros.h"

#include "ros/assert.h"

#include "ros/service_traits.h"




namespace sandia_hand_msgs
{
template <class ContainerAllocator>
struct SetJointLimitPolicyRequest_ {
  typedef SetJointLimitPolicyRequest_<ContainerAllocator> Type;

  SetJointLimitPolicyRequest_()
  : policy()
  {
  }

  SetJointLimitPolicyRequest_(const ContainerAllocator& _alloc)
  : policy(_alloc)
  {
  }

  typedef std::basic_string<char, std::char_traits<char>, typename ContainerAllocator::template rebind<char>::other >  _policy_type;
  std::basic_string<char, std::char_traits<char>, typename ContainerAllocator::template rebind<char>::other >  policy;


  typedef boost::shared_ptr< ::sandia_hand_msgs::SetJointLimitPolicyRequest_<ContainerAllocator> > Ptr;
  typedef boost::shared_ptr< ::sandia_hand_msgs::SetJointLimitPolicyRequest_<ContainerAllocator>  const> ConstPtr;
  boost::shared_ptr<std::map<std::string, std::string> > __connection_header;
}; // struct SetJointLimitPolicyRequest
typedef  ::sandia_hand_msgs::SetJointLimitPolicyRequest_<std::allocator<void> > SetJointLimitPolicyRequest;

typedef boost::shared_ptr< ::sandia_hand_msgs::SetJointLimitPolicyRequest> SetJointLimitPolicyRequestPtr;
typedef boost::shared_ptr< ::sandia_hand_msgs::SetJointLimitPolicyRequest const> SetJointLimitPolicyRequestConstPtr;


template <class ContainerAllocator>
struct SetJointLimitPolicyResponse_ {
  typedef SetJointLimitPolicyResponse_<ContainerAllocator> Type;

  SetJointLimitPolicyResponse_()
  {
  }

  SetJointLimitPolicyResponse_(const ContainerAllocator& _alloc)
  {
  }


  typedef boost::shared_ptr< ::sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator> > Ptr;
  typedef boost::shared_ptr< ::sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator>  const> ConstPtr;
  boost::shared_ptr<std::map<std::string, std::string> > __connection_header;
}; // struct SetJointLimitPolicyResponse
typedef  ::sandia_hand_msgs::SetJointLimitPolicyResponse_<std::allocator<void> > SetJointLimitPolicyResponse;

typedef boost::shared_ptr< ::sandia_hand_msgs::SetJointLimitPolicyResponse> SetJointLimitPolicyResponsePtr;
typedef boost::shared_ptr< ::sandia_hand_msgs::SetJointLimitPolicyResponse const> SetJointLimitPolicyResponseConstPtr;

struct SetJointLimitPolicy
{

typedef SetJointLimitPolicyRequest Request;
typedef SetJointLimitPolicyResponse Response;
Request request;
Response response;

typedef Request RequestType;
typedef Response ResponseType;
}; // struct SetJointLimitPolicy
} // namespace sandia_hand_msgs

namespace ros
{
namespace message_traits
{
template<class ContainerAllocator> struct IsMessage< ::sandia_hand_msgs::SetJointLimitPolicyRequest_<ContainerAllocator> > : public TrueType {};
template<class ContainerAllocator> struct IsMessage< ::sandia_hand_msgs::SetJointLimitPolicyRequest_<ContainerAllocator>  const> : public TrueType {};
template<class ContainerAllocator>
struct MD5Sum< ::sandia_hand_msgs::SetJointLimitPolicyRequest_<ContainerAllocator> > {
  static const char* value() 
  {
    return "e910d3ed1e2e8ad67a9ceacdc38b1c45";
  }

  static const char* value(const  ::sandia_hand_msgs::SetJointLimitPolicyRequest_<ContainerAllocator> &) { return value(); } 
  static const uint64_t static_value1 = 0xe910d3ed1e2e8ad6ULL;
  static const uint64_t static_value2 = 0x7a9ceacdc38b1c45ULL;
};

template<class ContainerAllocator>
struct DataType< ::sandia_hand_msgs::SetJointLimitPolicyRequest_<ContainerAllocator> > {
  static const char* value() 
  {
    return "sandia_hand_msgs/SetJointLimitPolicyRequest";
  }

  static const char* value(const  ::sandia_hand_msgs::SetJointLimitPolicyRequest_<ContainerAllocator> &) { return value(); } 
};

template<class ContainerAllocator>
struct Definition< ::sandia_hand_msgs::SetJointLimitPolicyRequest_<ContainerAllocator> > {
  static const char* value() 
  {
    return "string policy\n\
\n\
";
  }

  static const char* value(const  ::sandia_hand_msgs::SetJointLimitPolicyRequest_<ContainerAllocator> &) { return value(); } 
};

} // namespace message_traits
} // namespace ros


namespace ros
{
namespace message_traits
{
template<class ContainerAllocator> struct IsMessage< ::sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator> > : public TrueType {};
template<class ContainerAllocator> struct IsMessage< ::sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator>  const> : public TrueType {};
template<class ContainerAllocator>
struct MD5Sum< ::sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator> > {
  static const char* value() 
  {
    return "d41d8cd98f00b204e9800998ecf8427e";
  }

  static const char* value(const  ::sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator> &) { return value(); } 
  static const uint64_t static_value1 = 0xd41d8cd98f00b204ULL;
  static const uint64_t static_value2 = 0xe9800998ecf8427eULL;
};

template<class ContainerAllocator>
struct DataType< ::sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator> > {
  static const char* value() 
  {
    return "sandia_hand_msgs/SetJointLimitPolicyResponse";
  }

  static const char* value(const  ::sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator> &) { return value(); } 
};

template<class ContainerAllocator>
struct Definition< ::sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator> > {
  static const char* value() 
  {
    return "\n\
\n\
";
  }

  static const char* value(const  ::sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator> &) { return value(); } 
};

template<class ContainerAllocator> struct IsFixedSize< ::sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator> > : public TrueType {};
} // namespace message_traits
} // namespace ros

namespace ros
{
namespace serialization
{

template<class ContainerAllocator> struct Serializer< ::sandia_hand_msgs::SetJointLimitPolicyRequest_<ContainerAllocator> >
{
  template<typename Stream, typename T> inline static void allInOne(Stream& stream, T m)
  {
    stream.next(m.policy);
  }

  ROS_DECLARE_ALLINONE_SERIALIZER;
}; // struct SetJointLimitPolicyRequest_
} // namespace serialization
} // namespace ros


namespace ros
{
namespace serialization
{

template<class ContainerAllocator> struct Serializer< ::sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator> >
{
  template<typename Stream, typename T> inline static void allInOne(Stream& stream, T m)
  {
  }

  ROS_DECLARE_ALLINONE_SERIALIZER;
}; // struct SetJointLimitPolicyResponse_
} // namespace serialization
} // namespace ros

namespace ros
{
namespace service_traits
{
template<>
struct MD5Sum<sandia_hand_msgs::SetJointLimitPolicy> {
  static const char* value() 
  {
    return "e910d3ed1e2e8ad67a9ceacdc38b1c45";
  }

  static const char* value(const sandia_hand_msgs::SetJointLimitPolicy&) { return value(); } 
};

template<>
struct DataType<sandia_hand_msgs::SetJointLimitPolicy> {
  static const char* value() 
  {
    return "sandia_hand_msgs/SetJointLimitPolicy";
  }

  static const char* value(const sandia_hand_msgs::SetJointLimitPolicy&) { return value(); } 
};

template<class ContainerAllocator>
struct MD5Sum<sandia_hand_msgs::SetJointLimitPolicyRequest_<ContainerAllocator> > {
  static const char* value() 
  {
    return "e910d3ed1e2e8ad67a9ceacdc38b1c45";
  }

  static const char* value(const sandia_hand_msgs::SetJointLimitPolicyRequest_<ContainerAllocator> &) { return value(); } 
};

template<class ContainerAllocator>
struct DataType<sandia_hand_msgs::SetJointLimitPolicyRequest_<ContainerAllocator> > {
  static const char* value() 
  {
    return "sandia_hand_msgs/SetJointLimitPolicy";
  }

  static const char* value(const sandia_hand_msgs::SetJointLimitPolicyRequest_<ContainerAllocator> &) { return value(); } 
};

template<class ContainerAllocator>
struct MD5Sum<sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator> > {
  static const char* value() 
  {
    return "e910d3ed1e2e8ad67a9ceacdc38b1c45";
  }

  static const char* value(const sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator> &) { return value(); } 
};

template<class ContainerAllocator>
struct DataType<sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator> > {
  static const char* value() 
  {
    return "sandia_hand_msgs/SetJointLimitPolicy";
  }

  static const char* value(const sandia_hand_msgs::SetJointLimitPolicyResponse_<ContainerAllocator> &) { return value(); } 
};

} // namespace service_traits
} // namespace ros

#endif // SANDIA_HAND_MSGS_SERVICE_SETJOINTLIMITPOLICY_H
