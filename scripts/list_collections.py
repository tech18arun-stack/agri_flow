import os
from appwrite.client import Client
from appwrite.services.databases import Databases
from dotenv import load_dotenv

load_dotenv()

client = Client()
client.set_endpoint(os.getenv('APPWRITE_ENDPOINT'))
client.set_project(os.getenv('APPWRITE_PROJECT_ID'))
client.set_key(os.getenv('APPWRITE_API_KEY'))

db = Databases(client)
db_id = os.getenv('APPWRITE_DATABASE_ID')

print(f"Checking database: {db_id}")
try:
    collections = db.list_collections(db_id)
    print(f"Found {collections['total']} collections:")
    for col in collections['collections']:
        print(f" - {col['name']} (ID: {col['$id']})")
except Exception as e:
    print(f"Error: {e}")
