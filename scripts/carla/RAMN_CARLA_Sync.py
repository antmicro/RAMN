# Copyright (c) 2026 Antmicro <www.antmicro.com>
#
# This work is licensed under the terms of the MIT license.
# For a copy, see <https://opensource.org/licenses/MIT>.

# Helpers for running CARLA in synchronous mode, in lockstep with Renode.

import threading

FIXED_DELTA_SECONDS = 0.05
TICKS_PER_SECOND = round(1 / FIXED_DELTA_SECONDS)
SENSOR_TIMEOUT_SECONDS = 2.0

# Virtual time given to the emulated ECUs to boot before sending them CAN frames
RENODE_BOOT_SECONDS = 1.0


def enable_synchronous_mode(carla_world, fixed_delta_seconds=FIXED_DELTA_SECONDS):
    original_settings = carla_world.get_settings()
    settings = carla_world.get_settings()
    settings.synchronous_mode = True
    settings.fixed_delta_seconds = fixed_delta_seconds
    carla_world.apply_settings(settings)
    return original_settings


def restore_settings(carla_world, original_settings):
    if original_settings is not None:
        carla_world.apply_settings(original_settings)


def tick_world(carla_world, imu_sensor, renode=None):
    frame = carla_world.tick()
    if not imu_sensor.wait_for_frame(frame):
        print(f"Warning: no IMU sample received for frame {frame}")
    if renode is not None:
        renode.run_for(FIXED_DELTA_SECONDS)
    return frame


class FrameNotifier:

    def __init__(self):
        self._condition = threading.Condition()
        self._frame = None

    def notify(self, frame):
        with self._condition:
            self._frame = frame
            self._condition.notify_all()

    def wait_for(self, frame, timeout=SENSOR_TIMEOUT_SECONDS):
        with self._condition:
            return self._condition.wait_for(lambda: self._frame is not None and self._frame >= frame, timeout)
