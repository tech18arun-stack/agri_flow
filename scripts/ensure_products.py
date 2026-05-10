
import os
import sys
import json
import io
from dotenv import load_dotenv

# Fix Windows console encoding
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.query import Query

APPWRITE_ENDPOINT = os.getenv("APPWRITE_ENDPOINT", "https://cloud.appwrite.io/v1")
APPWRITE_API_KEY = os.getenv("APPWRITE_API_KEY", "")
APPWRITE_PROJECT_ID = os.getenv("APPWRITE_PROJECT_ID", "")
DATABASE_ID = os.getenv("APPWRITE_DATABASE_ID", "agriflow_db")

def main():
    print("=" * 60)
    print("  AgriFlow - Product Template Sync & De-duplication")
    print("=" * 60)

    if not APPWRITE_API_KEY or not APPWRITE_PROJECT_ID:
        print("❌ Error: Set APPWRITE_API_KEY and APPWRITE_PROJECT_ID in .env")
        sys.exit(1)

    client = Client()
    client.set_endpoint(APPWRITE_ENDPOINT)
    client.set_project(APPWRITE_PROJECT_ID)
    client.set_key(APPWRITE_API_KEY)

    db = Databases(client)

    # 1. Load templates from JSON
    json_path = os.path.join(os.path.dirname(__file__), 'migrations', 'product_templates.json')
    if not os.path.exists(json_path):
        print(f"❌ Error: {json_path} not found")
        sys.exit(1)

    with open(json_path, 'r', encoding='utf-8') as f:
        master_templates = json.load(f)
    
    print(f"📋 Loaded {len(master_templates)} templates from master JSON.")

    # 2. Fetch existing templates from DB
    existing_docs_dict = {}
    try:
        # Use simple list_documents, might need pagination for > 100
        result = db.list_documents(DATABASE_ID, "product_templates", [Query.limit(100)])
        docs = result.get('documents', [])
        for doc in docs:
            existing_docs_dict[doc['$id']] = doc
    except Exception as e:
        print(f"❌ Error fetching templates: {e}")
        sys.exit(1)

    print(f"🔍 Found {len(existing_docs_dict)} templates in database.")

    # 3. Check for duplicates and cleanup
    seen_names = {} # nameEn -> id
    docs_to_delete = []

    for doc_id, doc in existing_docs_dict.items():
        name_en = doc.get('nameEn')
        
        if name_en in seen_names:
            # Duplicate name found, mark for deletion unless it's the same ID
            docs_to_delete.append(doc_id)
        else:
            seen_names[name_en] = doc_id

    if docs_to_delete:
        print(f"🗑️  Removing {len(docs_to_delete)} duplicate products...")
        for doc_id in docs_to_delete:
            try:
                db.delete_document(DATABASE_ID, "product_templates", doc_id)
                if doc_id in existing_docs_dict:
                    del existing_docs_dict[doc_id]
                print(f"  ✅ Deleted duplicate {doc_id}")
            except Exception as e:
                print(f"  ❌ Failed to delete {doc_id}: {e}")
    else:
        print("✅ No duplicate products found in database.")

    # 4. Add or Update templates
    print("\n🚀 Syncing master templates...")
    added_count = 0
    updated_count = 0
    
    for template in master_templates:
        tid = template['id']
        template_img = template.get('imageUrl', '')
        
        data = {
            "id": tid,
            "nameEn": template['nameEn'],
            "nameTa": template['nameTa'],
            "category": template['category'],
            "unit": template.get('unit', 'kg'),
            "icon": template.get('icon', '🌾'),
            "color": template.get('color', '#4CAF50'),
            "keywords": template.get('keywords', ''),
            "active": template.get('active', True),
            "sortOrder": template.get('sortOrder', 0),
            "imageUrl": template_img
        }

        try:
            # Check if exists by ID
            if tid in existing_docs_dict:
                existing_doc = existing_docs_dict[tid]
                
                # PRESERVE IMAGE URL: If template has no image but DB does, keep DB image
                # This protects admin-added images
                if not template_img and existing_doc.get('imageUrl'):
                    data['imageUrl'] = existing_doc['imageUrl']
                    print(f"  ℹ️  Preserving existing image for {template['nameEn']}")

                # Only update if data actually changed (optional but cleaner)
                # For simplicity, we'll update anyway but with preserved image
                db.update_document(DATABASE_ID, "product_templates", tid, data)
                updated_count += 1
            else:
                # Create if not
                db.create_document(DATABASE_ID, "product_templates", tid, data)
                added_count += 1
                existing_docs_dict[tid] = data
        except Exception as e:
            if "already exists" in str(e).lower():
                print(f"  ⚠️  {template['nameEn']} already exists with different ID, skipping.")
            else:
                print(f"  ❌ Error syncing {template['nameEn']}: {e}")

    print(f"\n✨ Sync Complete!")
    print(f"  ✅ Added: {added_count}")
    print(f"  🔄 Updated: {updated_count}")
    print("=" * 60)

if __name__ == "__main__":
    main()
