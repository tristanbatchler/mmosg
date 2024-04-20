import asyncio
from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine
from netbound.app import ServerApp

async def main() -> None:
    from server.state.play import PlayState
    db_engine: AsyncEngine = create_async_engine("sqlite+aiosqlite:///database/database.sqlite3")
    server_app: ServerApp = ServerApp("localhost", 8081, db_engine)

    async with asyncio.TaskGroup() as tg:
        tg.create_task(server_app.start(PlayState))
        tg.create_task(server_app.run(ticks_per_second=10))


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("Server stopped by user")