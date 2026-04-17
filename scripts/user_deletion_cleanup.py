"""
Agri Flow - User Deletion Cleanup Script
Processes scheduled account deletions (status: 'deletion_requested')
that are older than 48 hours. Deletes all user-related data across collections.
"""

import os
import sys
import time
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv

from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.services.users import Users
from appwrite.query import Query

load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

APPWRITE_ENDPOINT = os.getenv("APPWRITE_ENDPOINT", "https://cloud.appwrite.io/v1")
APPWRITE_API_KEY = os.getenv("APPWRITE_API_KEY", "")
APPWRITE_PROJECT_ID = os.getenv("APPWRITE_PROJECT_ID", "")
DATABASE_ID = os.getenv("APPWRITE_DATABASE_ID", "agriflow_db")

# Collections to clean per user
# Field name maps the user's ID in that collection
COLLECTIONS_MAPPING = {
    "products": "farmerId",
    "orders": ["customerId", "farmerId"],
    "cart": "userId",
    "transactions": "userId",
    "bids": "userId",
    "reviews": "userId",
    "notifications": "userId",
    "price_logs": "updaterId",
    "wishlist": "userId",
}

def delete_user_data(db, user_id):
    """Delete all documents associated with a user across all relevant collections."""
    print(f"  --- Cleaning data for user: {user_id} ---")
    
    for collection_id, field in COLLECTIONS_MAPPING.items():
        fields = [field] if isinstance(field, str) else field
        
        for f in fields:
            try:
                # Page through documents to delete
                while True:
                    result = db.list_documents(
                        database_id=DATABASE_ID,
                        collection_id=collection_id,
                        queries=[Query.equal(f, user_id)]
                    )
                    docs = result.get('documents', [])
                    if not docs:
                        break
                    
                    for doc in docs:
                        doc_id = doc.get('$id')
                        try:
                            db.delete_document(DATABASE_ID, collection_id, doc_id)
                            print(f"    Deleted {collection_id} doc: {doc_id}")
                        except Exception as e:
                            print(f"    Failed to delete {collection_id} doc {doc_id}: {e}")
            except Exception as e:
                if "not found" not in str(e).lower():
                    print(f"    Error querying {collection_id}: {e}")

def main():
    if not APPWRITE_API_KEY or not APPWRITE_PROJECT_ID:
        print("❌ Error: Set APPWRITE_API_KEY and APPWRITE_PROJECT_ID in .env")
        sys.exit(1)

    client = Client()
    client.set_endpoint(APPWRITE_ENDPOINT)
    client.set_project(APPWRITE_PROJECT_ID)
    client.set_key(APPWRITE_API_KEY)

    db = Databases(client)
    users_svc = Users(client)

    print("=" * 60)
    print(f"Agri Flow - Processing Deletions ({datetime.now().isoformat()})")
    print("=" * 60)

    try:
        # 1. Find users requesting deletion
        result = db.list_documents(
            database_id=DATABASE_ID,
            collection_id="users",
            queries=[Query.equal("status", "deletion_requested")]
        )
        candidates = result.get('documents', [])
        
        if not candidates:
            print("No pending deletion requests found.")
            return

        now = datetime.now(timezone.utc)
        grace_period = timedelta(hours=48)
        deleted_count = 0

        for user_doc in candidates:
            user_id = user_doc['$id']
            email = user_doc.get('email', 'N/A')
            requested_str = user_doc.get('deletionRequestedAt')
            
            if not requested_str:
                print(f"⚠️ User {user_id} has no deletion timestamp. Skipping.")
                continue
                
            requested_at = datetime.fromisoformat(requested_str.replace('Z', '+00:00'))
            if requested_at.tzinfo is None:
                requested_at = requested_at.replace(tzinfo=timezone.utc)

            # Check if 48 hours passed
            if now - requested_at >= grace_period:
                print(f"\n🚀 Processing PERMANENT deletion for: {email} ({user_id})")
                
                # A. Delete all related collection data
                delete_user_data(db, user_id)
                
                # B. Delete the Auth account
                try:
                    users_svc.delete(user_id=user_id)
                    print(f"    ✅ Auth account deleted.")
                except Exception as e:
                    print(f"    ❌ Failed to delete Auth account: {e}")

                # C. Delete the Profile document
                try:
                    db.delete_document(DATABASE_ID, "users", user_id)
                    print(f"    ✅ Profile document deleted.")
                except Exception as e:
                    print(f"    ❌ Failed to delete Profile document: {e}")
                
                deleted_count += 1
            else:
                remaining = grace_period - (now - requested_at)
                print(f"⏳ User {email} still in grace period. ({remaining.total_seconds()/3600:.1f} hours left)")

        print("\n" + "=" * 60)
        print(f"✨ Finished. Permanently deleted {deleted_count} user(s).")
        print("=" * 60)

    except Exception as e:
        print(f"❌ Error during processing: {e}")

if __name__ == "__main__":
    main()
