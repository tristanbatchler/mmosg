from netbound.state import BaseState
from netbound.constants import EVERYONE
from typing import Coroutine, Any
from dataclasses import dataclass
from random import uniform, choice, randint
import server.packet as pck

class PlayState(BaseState):
    @dataclass
    class View:
        x: float
        y: float
        z: float
        name: str
        mesh_index: int

    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        self._x: float = uniform(-50.084, -37.317)
        self._y: float = 2.5
        self._z: float = uniform(11.714, 33.918)
        self._name: str = \
              choice(("random", "friendly", "obscene", "funny", "serious", "silly", "boring", "exciting", "cool", "lame")) + " " \
            + choice(("fish", "tree", "rock", "boss", "john", "monster", "prawn", "rice bowl", "noodle", "cat")) + " " \
            + self._pid.hex()[:4]
        self._mesh_index: int = randint(0, 5)
            
        self._known_others: dict[bytes, PlayState.View] = {}

    async def _on_transition(self, previous_state_view: BaseState.View | None = None) -> Coroutine[Any, Any, None]:
        print(f"Play state entered from {previous_state_view.__class__.__name__ if previous_state_view else 'nowhere'}")
        
        await self._send_to_client(pck.PidPacket(from_pid=self._pid))
        await self._send_to_other(pck.HelloPacket(state_view=self.view_dict, from_pid=self._pid, to_pid=EVERYONE))
    
    async def handle_hello(self, p: pck.HelloPacket) -> None:
        # If we already know about this player, ignore the hello
        if p.from_pid in self._known_others:
            return

        # Tell our client about the new player (it might be us!)
        await self._send_to_client(p)

        if p.from_pid != self._pid:
            # Add the new player to our known others
            self._known_others[p.from_pid] = PlayState.View(**p.state_view)
            # Tell the new player about us
            await self._send_to_other(pck.HelloPacket(state_view=self.view_dict, from_pid=self._pid, to_pid=p.from_pid))

    async def handle_targetlocation(self, p: pck.TargetLocationPacket) -> None:
        if p.from_pid == self._pid:
            await self._send_to_other(pck.TargetLocationPacket(from_pid=self._pid, x=p.x, y=p.y, z=p.z, to_pid=EVERYONE, exclude_sender=True))
        else:
            await self._send_to_client(p)

    async def handle_disconnect(self, p: pck.DisconnectPacket) -> None:
        # If this came from our own client, forward it on
        if p.from_pid == self._pid:
            await self._send_to_other(pck.DisconnectPacket(from_pid=self._pid, to_pid=EVERYONE, exclude_sender=True, reason=p.reason))

        # If this came from a different protocol, forward it directly to our client
        else:
            await self._send_to_client(pck.DisconnectPacket(from_pid=p.from_pid, reason=p.reason))
            self._known_others.pop(p.from_pid, None)

    async def handle_chat(self, p: pck.ChatPacket) -> None:
        if p.from_pid == self._pid:
            await self._send_to_other(pck.ChatPacket(from_pid=self._pid, message=p.message, to_pid=EVERYONE, exclude_sender=True))
        
        await self._send_to_client(p)