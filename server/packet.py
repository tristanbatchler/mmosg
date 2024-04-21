from typing import Any
from netbound.packet import BasePacket

class PidPacket(BasePacket):
    ...

class HelloPacket(BasePacket):
    state_view: dict[str, Any]

class TargetLocationPacket(BasePacket):
    x: float
    y: float
    z: float

class DisconnectPacket(BasePacket):
    reason: str