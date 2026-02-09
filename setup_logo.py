from PIL import Image
import os

# Resmi aç
img = Image.open('/Users/emodvc/OyunEvreni2/axolotl_logo.png')

# Android icon boyutları (DPI'e göre)
sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

base_path = '/Users/emodvc/OyunEvreni2/android/app/src/main/res'

for dir_name, size in sizes.items():
    # Resmi yeniden boyutlandır
    resized_img = img.resize((size, size), Image.Resampling.LANCZOS)
    
    # Hedef dizine kaydet
    output_path = f'{base_path}/{dir_name}/ic_launcher.png'
    resized_img.save(output_path, 'PNG')
    print(f'✅ {output_path} oluşturuldu ({size}x{size})')

print('\n✅ Tüm Android icon boyutları oluşturuldu!')
