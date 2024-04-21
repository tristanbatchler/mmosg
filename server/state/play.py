from netbound.state import BaseState
from netbound.constants import EVERYONE
from typing import Coroutine, Any
from dataclasses import dataclass
from random import uniform, choice
import server.packet as pck

class PlayState(BaseState):
    @dataclass
    class View:
        x: float
        y: float
        z: float
        name: str

    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        self._x: float = uniform(-10, 10)
        self._y: float = 0
        self._z: float = uniform(-10, 10)
        self._name: str = \
              choice(("random", "friendly", "obscene", "funny", "serious", "silly", "boring", "exciting", "cool", "lame")) + " " \
            + choice(("fish", "tree", "rock", "boss", "john", "monster", "prawn", "rice bowl", "noodle", "cat")) + " " \
            + self._pid.hex()[:4]
            
        self._known_others: dict[bytes, PlayState.View] = {}

    async def _on_transition(self, previous_state_view: BaseState.View | None = None) -> Coroutine[Any, Any, None]:
        print(f"Play state entered from {previous_state_view.__class__.__name__ if previous_state_view else 'nowhere'}")
        
        await self._send_to_client(pck.PidPacket(from_pid=self._pid))
        await self._send_to_other(pck.HelloPacket(state_view=self.view_dict, from_pid=self._pid, to_pid=EVERYONE))
    
    async def handle_hello(self, p: pck.HelloPacket) -> None:
        await self._send_to_client(pck.HelloPacket(state_view=p.state_view, from_pid=p.from_pid))

        if p.from_pid != self._pid and p.from_pid not in self._known_others:
            self._known_others[p.from_pid] = PlayState.View(**p.state_view)

            await self._send_to_other(pck.HelloPacket(from_pid=self._pid, to_pid=p.from_pid, state_view=self.view_dict))

    async def handle_targetlocation(self, p: pck.TargetLocationPacket) -> None:
        if p.from_pid == self._pid:
            await self._send_to_other(pck.TargetLocationPacket(from_pid=self._pid, x=p.x, y=p.y, z=p.z, to_pid=EVERYONE, exclude_sender=True))
        else:
            await self._send_to_client(p)
