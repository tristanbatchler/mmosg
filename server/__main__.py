import asyncio
from ssl import SSLContext, PROTOCOL_TLS_SERVER
from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine
from netbound.app import ServerApp
import server.packet

def get_ssl_context(certpath: str, keypath: str) -> SSLContext:
    ssl_context: SSLContext = SSLContext(PROTOCOL_TLS_SERVER)
    try:
        ssl_context.load_cert_chain(certpath, keypath)
    except FileNotFoundError:
        raise FileNotFoundError(f"No encryption key or certificate found. Please generate a pair and save them to {certpath} and {keypath}")

    return ssl_context

async def main() -> None:
    from server.state.play import PlayState
    db_engine: AsyncEngine = create_async_engine("sqlite+aiosqlite:///database/database.sqlite3")

    ssl_context: SSLContext = get_ssl_context("server/ssl/localhost+2.pem", "server/ssl/localhost+2-key.pem")

    server_app: ServerApp = ServerApp("localhost", 8081, db_engine, ssl_context=ssl_context)
    server_app.register_packets(server.packet)

    async with asyncio.TaskGroup() as tg:
        tg.create_task(server_app.start(PlayState))
        tg.create_task(server_app.run(ticks_per_second=30))       


if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("Server stopped by user")