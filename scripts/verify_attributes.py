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
col_id = "products"

print(f"Checking collection: {col_id} in database: {db_id}")
try:
    col = db.get_collection(db_id, col_id)
    print(f"Attributes for {col['name']}:")
    for attr in col['attributes']:
        print(f" - {attr['key']} ({attr['type']}) - Status: {attr['status']}")
except Exception as e:
    print(f"Error: {e}")
