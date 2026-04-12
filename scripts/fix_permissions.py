"""Fix users collection permissions to allow user registration"""
import os, sys, io
from dotenv import load_dotenv

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.permission import Permission
from appwrite.role import Role

client = Client()
client.set_endpoint(os.getenv("APPWRITE_ENDPOINT", "https://cloud.appwrite.io/v1"))
client.set_project(os.getenv("APPWRITE_PROJECT_ID", ""))
client.set_key(os.getenv("APPWRITE_API_KEY", ""))

db = Databases(client)
DB_ID = os.getenv("APPWRITE_DATABASE_ID", "agriflow_db")

print("Updating users collection permissions...")
try:
    db.update_collection(
        database_id=DB_ID,
        collection_id="users",
        name="Users",
        permissions=[
            Permission.read(Role.any()),
            Permission.create(Role.any()),
            Permission.update(Role.users()),
            Permission.delete(Role.users()),
        ],
    )
    print("SUCCESS - users collection now allows: read(any), create(any), update(users), delete(users)")
except Exception as e:
    print(f"ERROR: {e}")
