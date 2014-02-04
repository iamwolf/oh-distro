import os
import vtkAll as vtk
from ddapp import botpy
import math
import numpy as np

from ddapp import transformUtils
from ddapp import lcmUtils
from ddapp.timercallback import TimerCallback
from ddapp import objectmodel as om
from ddapp import visualization as vis
from ddapp import applogic as app
from ddapp.debugVis import DebugData
from ddapp import ioUtils
from ddapp.simpletimer import SimpleTimer
from ddapp.utime import getUtime

import drc as lcmdrc



class SystemStatusListener(object):

    def __init__(self):
        lcmUtils.addSubscriber('SYSTEM_STATUS', lcmdrc.system_status_t, self.onSystemStatus)

    def onSystemStatus(self, message):
        print 'SYSTEM_STATUS:', message.value


class AtlasDriver(object):

    def __init__(self):

        self.lastAtlasStatusMessage = None
        self.lastAtlasStateMessage = None
        self._setupSubscriptions()
        self.timer = SimpleTimer()

    def _setupSubscriptions(self):
        #lcmUtils.addSubscriber('ATLAS_STATE', lcmdrc.atlas_state_t, self.onAtlasState)
        lcmUtils.addSubscriber('ATLAS_STATUS', lcmdrc.atlas_status_t, self.onAtlasStatus)

    def onAtlasState(self, message):
        self.lastAtlasStateMessage = message

    def onAtlasStatus(self, message):
        self.lastAtlasStatusMessage = message


    def getBehaviorMap(self):
        msg = lcmdrc.atlas_status_t
        behaviors = {
                    msg.BEHAVIOR_NONE        : 'none',
                    msg.BEHAVIOR_FREEZE      : 'freeze',
                    msg.BEHAVIOR_STAND_PREP  : 'prep',
                    msg.BEHAVIOR_STAND       : 'stand',
                    msg.BEHAVIOR_WALK        : 'walk',
                    msg.BEHAVIOR_STEP        : 'step',
                    msg.BEHAVIOR_MANIPULATE  : 'manip',
                    msg.BEHAVIOR_USER        : 'user',
                    8                        : 'calibrate',
                    9                        : 'stop',
                    }
        return behaviors

    def getCurrentBehaviorName(self):
        if not self.lastAtlasStatusMessage:
            return '<waiting for status message>'

        behaviors = self.getBehaviorMap()

        behaviorId = self.lastAtlasStatusMessage.behavior

        if behaviorId not in behaviors:
            return '<unknown behavior: %d' % behaviorId

        return behaviors[behaviorId]


    def sendBehaviorCommand(self, behaviorName):

        assert behaviorName in self.getBehaviorMap().values()

        msg = lcmdrc.atlas_behavior_command_t()
        msg.utime = getUtime()
        msg.command = behaviorName
        lcmUtils.publish('ATLAS_BEHAVIOR_COMMAND', msg)

    def sendStopCommand(self):
        self.sendBehaviorCommand('stop')

    def sendFreezeCommand(self):
        self.sendBehaviorCommand('freeze')

    def sendPrepCommand(self):
        self.sendBehaviorCommand('prep')

    def sendStandCommand(self):
        self.sendBehaviorCommand('stand')

    def sendManipCommand(self):
        self.sendBehaviorCommand('manip')

    def sendUserCommand(self):
        self.sendBehaviorCommand('user')

    def sendCalibrateCommand(self):
        self.sendBehaviorCommand('calibrate')

    def sendCalibrateEncodersCommand(self):
        msg = lcmdrc.utime_t()
        msg.utime = getUtime()
        lcmUtils.publish('CALIBRATE_ARM_ENCODERS', msg)


    def getPelvisHeightLimits(self):
        '''
        returns pelvis height limits in meters: min, max
        '''
        return (0.66, 0.92)


    def sendPelvisHeightCommand(self, height):

        heightLimit = self.getPelvisHeightLimits()
        assert heightLimit[0] <= height <= heightLimit[1]

        pelvisParams = lcmdrc.atlas_behavior_pelvis_servo_params_t()
        pelvisParams.com_v0 = 0.0
        pelvisParams.com_v1 = 0.0
        pelvisParams.pelvis_height = height
        pelvisParams.pelvis_yaw = 0.0
        pelvisParams.pelvis_pitch = 0.0
        pelvisParams.pelvis_roll = 0.0

        msg = lcmdrc.atlas_behavior_manipulate_params_t()
        msg.use_demo_mode = 0
        msg.use_desired = 1
        msg.desired = pelvisParams

        lcmUtils.publish('ATLAS_MANIPULATE_PARAMS', msg)



def init():

    global driver
    driver = AtlasDriver()

    global systemStatus
    systemStatus = SystemStatusListener()

