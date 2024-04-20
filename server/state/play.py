from netbound.state import BaseState
from server.packet import HelloPacket
from typing import Coroutine, Any
from dataclasses import dataclass

class PlayState(BaseState):
    @dataclass
    class View:
        x: float
        y: float

    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        self._x: float = 0
        self._y: float = 0

    async def _on_transition(self, previous_state_view: BaseState.View | None = None) -> Coroutine[Any, Any, None]:
        print(f"Play state entered from {previous_state_view.__class__.__name__ if previous_state_view else 'nowhere'}")
    
    async def handle_hello(self, hello_packet: HelloPacket) -> None:
        print(f"Hello from {hello_packet.state_view}")