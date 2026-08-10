-- ============================================================
-- คัดลอกทั้งไฟล์นี้ไปวางใน Supabase Dashboard → SQL Editor → Run
-- ============================================================

create table if not exists config (
  id int primary key default 1,
  shop_name text default 'DEADSTOCK.',
  tagline text default 'Curated Vintage & Streetwear',
  hero_sub text default 'ตรวจสภาพ วัดขนาดจริง ถ่ายรูปตำหนิให้ดูก่อนตัดสินใจ — ไม่มีของซ้ำ หมดแล้วหมดเลย',
  line_url text default 'https://line.me/ti/p/~yourshop',
  fb_url text default 'https://facebook.com/yourshop',
  ig_url text default 'https://instagram.com/yourshop',
  constraint single_row check (id = 1)
);
insert into config (id) values (1) on conflict (id) do nothing;

create table if not exists items (
  id bigint generated always as identity primary key,
  title text not null,
  brand text not null,
  category text not null,
  era text not null default '90s' check (era in ('80s','90s','00s','Y2K')),
  size_label text not null default 'M',
  condition_score int not null default 7 check (condition_score in (5,7,9)),
  price integer not null,
  old_price integer,
  single_stock boolean not null default true,
  sold boolean not null default false,
  images jsonb not null default '[]',       -- array of image URLs (แกลเลอรีสินค้า)
  measurements jsonb not null default '{}', -- { "อก": "58 cm", "ยาว": "68 cm", "ไหล่": "52 cm", "แขน": "60 cm" }
  defects jsonb not null default '[]',      -- array of { "note": "...", "image": "url or null" }
  created_at timestamptz default now()
);

alter table config enable row level security;
alter table items enable row level security;

create policy "public can read config" on config for select using (true);
create policy "public can read items" on items for select using (true);

create policy "authenticated can update config" on config for update using (auth.role() = 'authenticated');
create policy "authenticated can insert items" on items for insert with check (auth.role() = 'authenticated');
create policy "authenticated can update items" on items for update using (auth.role() = 'authenticated');
create policy "authenticated can delete items" on items for delete using (auth.role() = 'authenticated');

-- ============================================================
-- ตั้งค่า Storage bucket สำหรับรูปภาพ (ทำผ่านหน้าเว็บ Dashboard)
-- 1. Storage → Create bucket → ชื่อ "item-photos" → เปิด "Public bucket" ✅
-- 2. ที่ bucket นี้ → Configuration → จำกัดความปลอดภัยเพิ่ม:
--    - Allowed MIME types: image/jpeg, image/png, image/webp
--    - Max file size: 5 MB
--    (ตั้งตรงนี้แน่นกว่าเช็กแค่ฝั่งเบราว์เซอร์ เพราะเซิร์ฟเวอร์ Supabase บังคับเอง)
-- 3. Storage → item-photos → Policies → เพิ่มจากเทมเพลตสำเร็จรูป 4 อัน:
--    - "Give users read access" (public select)
--    - "Give authenticated users insert access"
--    - "Give authenticated users update access"
--    - "Give authenticated users delete access"
-- ============================================================
