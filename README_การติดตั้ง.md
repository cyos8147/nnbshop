# คู่มือติดตั้งเว็บ DEADSTOCK. (Vercel + Supabase)

เว็บ static ล้วนๆ คุยกับ Supabase ตรงๆ ไม่มีเซิร์ฟเวอร์ของเราเอง ฟรีถ้าใช้งานไม่เกิน limit ฟรี

## ขั้นตอนที่ 1: สร้างโปรเจกต์ Supabase
1. supabase.com → New Project (ฟรี)

## ขั้นตอนที่ 2: สร้างตารางฐานข้อมูล
1. SQL Editor → คัดลอกทั้งไฟล์ `supabase-schema.sql` → วาง → Run

## ขั้นตอนที่ 3: ตั้งค่าที่เก็บรูปภาพ
1. Storage → Create bucket → ชื่อ `item-photos` → Public bucket ✅
2. Configuration → จำกัด MIME type เป็น image/jpeg, image/png, image/webp และขนาดไฟล์สูงสุด 5MB
3. Policies → เพิ่ม 4 เทมเพลตสำเร็จรูป (read/insert/update/delete สำหรับผู้ล็อกอิน)

## ขั้นตอนที่ 4: สร้างบัญชีแอดมิน
1. Authentication → Users → Add user → ใส่อีเมล+รหัสผ่าน → ยืนยันอีเมลให้เรียบร้อย (หรือปิดการยืนยันใน Settings)

## ขั้นตอนที่ 5: ใส่ค่าเชื่อมต่อ
1. Project Settings → API → คัดลอก Project URL และ anon public key
2. copy `config.example.js` → ตั้งชื่อ `config.js` → ใส่ค่าทั้งสอง

## ขั้นตอนที่ 6: Deploy ขึ้น Vercel
1. อัปโหลดทั้งโฟลเดอร์ (รวม `config.js`) ขึ้น GitHub repo
2. vercel.com → New Project → เชื่อม repo → Deploy (ไม่ต้องตั้ง Build Command)

## หน้า Admin ซ่อนอยู่ที่ไหน
ไม่มีลิงก์ไปหน้า Admin บนเว็บสาธารณะเลย เข้าผ่าน URL ตรง:
```
https://yourdomain.com/panel-8k2q.html
```
**บุ๊กมาร์กหน้านี้เก็บไว้ อย่าแชร์ลิงก์นี้ให้ใคร** ไฟล์ `robots.txt` ตั้งไว้ไม่ให้ Google เก็บหน้านี้ไปแสดงผลค้นหาแล้ว แต่การซ่อนชื่อไฟล์ป้องกันคนทั่วไปเจอโดยบังเอิญเท่านั้น ตัวป้องกันจริงคือรหัสผ่านล็อกอิน Supabase — เปลี่ยนรหัสผ่านให้คาดเดายากเสมอ

ถ้าอยากเปลี่ยนชื่อไฟล์เป็นอย่างอื่น: เปลี่ยนชื่อไฟล์ `panel-8k2q.html` และแก้ path ในไฟล์ `robots.txt` ให้ตรงกัน

## ค่าใช้จ่าย
- Vercel: ฟรี ไม่มีวันหมดอายุ
- Supabase แผนฟรี: ฐานข้อมูล 500MB, เก็บรูป 1GB — พักชั่วคราวถ้าไม่ใช้งานเกิน 7 วัน (ปลุกใหม่ได้)
- โตเกิน limit ฟรี → Supabase Pro ~$25/เดือน (เช็กราคาล่าสุดที่ supabase.com/pricing)

## ความปลอดภัย
- ป้องกัน XSS ด้วยการ escape ข้อความทุกจุดที่แสดงผล (รวมฟิลด์ใหม่: แบรนด์, จุดตำหนิ, ตารางไซส์)
- แก้ไขข้อมูลได้เฉพาะผู้ล็อกอินผ่าน Supabase Auth เท่านั้น บังคับด้วย RLS ระดับฐานข้อมูล ปลอมคำขอไม่ได้
- CSRF ไม่ใช่ปัญหาของสถาปัตยกรรมนี้ (ใช้ token ผ่าน header ไม่ใช่ cookie)
- Brute-force login มีการจำกัดอัตราในตัวจาก Supabase Auth อยู่แล้ว
- ไฟล์รูปถูกจำกัดชนิด/ขนาดที่ระดับ Storage bucket โดยตรง (ข้อ 3)
- อย่าเปิดเผย `service_role key` ให้ใครเด็ดขาด
