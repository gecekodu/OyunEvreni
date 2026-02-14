#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🔧 Admin Script - Tüm kullanıcıların toplam puanlarını sıfırla
Python + Firestore REST API
Çalıştırma: python3 admin_reset_scores.py
"""

import json
import os
import sys
import requests
from typing import Dict, List, Optional

def reset_scores_via_rest():
    """Firestore REST API kullanarak puan sıfırla"""
    
    try:
        print("📋 Admin Script Başlatılıyor...")
        print("🔍 google-services.json okunuyor...")
        
        # google-services.json'ı oku
        with open('android/app/google-services.json', 'r') as f:
            config = json.load(f)
        
        project_id = config['project_info']['project_id']
        api_key = config['client'][0]['api_key'][0]['current_key']
        
        print(f"✅ Project ID: {project_id}")
        print(f"✅ API Key bulundu")
        print()
        
        # Firestore REST API endpoint
        base_url = f"https://firestore.googleapis.com/v1/projects/{project_id}/databases/(default)/documents"
        
        print(f"📍 Firestore URL: {base_url}")
        print()
        
        # 1. Tüm users'ları sor
        print("🔍 Tüm kullanıcılar sorgulanıyor...")
        query_url = f"{base_url}/users?key={api_key}"
        
        response = requests.get(query_url)
        
        if response.status_code != 200:
            print(f"❌ Query hatası: {response.status_code}")
            print(f"   Yanıt: {response.text}")
            return False
        
        data = response.json()
        documents = data.get('documents', [])
        
        print(f"👥 {len(documents)} kullanıcı bulundu")
        print()
        
        if len(documents) == 0:
            print("ℹ️  Hiç kullanıcı bulunamadı")
            return True
        
        # 2. Her user'ı update et
        print("🔄 Puanlar sıfırlanıyor...")
        print("-" * 60)
        
        updated_count = 0
        failed_count = 0
        
        for i, doc in enumerate(documents, 1):
            doc_name = doc['name']
            user_id = doc_name.split('/')[-1]
            
            # PATCH isteği gönder - tam URL oluştur
            if not doc_name.startswith('http'):
                update_url = f"{base_url}/users/{user_id}?key={api_key}"
            else:
                update_url = f"{doc_name}?key={api_key}"
            
            # Firestore field format
            update_data = {
                "fields": {
                    "totalScore": {"integerValue": "0"}
                }
            }
            
            try:
                response = requests.patch(
                    update_url,
                    json=update_data,
                    headers={"Content-Type": "application/json"}
                )
                
                if response.status_code == 200:
                    updated_count += 1
                    status = "✅"
                else:
                    failed_count += 1
                    status = "❌"
                
                if i % 5 == 0 or i == len(documents):
                    print(f"  [{i}/{len(documents)}] {status} işlendi...")
                    
            except Exception as e:
                failed_count += 1
                print(f"  ❌ User {user_id}: {str(e)}")
        
        print("-" * 60)
        print()
        
        if failed_count > 0:
            print(f"⚠️  Sonuç: {updated_count} başarılı, {failed_count} başarısız")
        else:
            print(f"✅ TÜM PUANLAR BAŞARILI İLE SIFIRLANDI!")
            print(f"📊 Güncellenen kullanıcı sayısı: {updated_count}")
        
        return failed_count == 0
        
    except FileNotFoundError as e:
        print(f"❌ Dosya bulunamadı: {e}")
        print("   Lütfen proje kök dizininde çalıştırın: /Users/emodvc/OyunEvreni2")
        return False
    except json.JSONDecodeError as e:
        print(f"❌ JSON parse hatası: {e}")
        return False
    except Exception as e:
        print(f"❌ Hata: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    print("\n" + "="*60)
    print("🔧 OYUN EVRENI - YÖNETICI PUAN SIFIRLA")
    print("="*60 + "\n")
    
    success = reset_scores_via_rest()
    
    print("\n" + "="*60)
    if success:
        print("✅ İşlem başarılı!")
    else:
        print("❌ İşlem başarısız oldu")
    print("="*60 + "\n")
