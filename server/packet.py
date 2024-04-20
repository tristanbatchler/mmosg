from typing import Any
from netbound.packet import BasePacket

class HelloPacket(BasePacket):
    state_view: dict[str, Any]