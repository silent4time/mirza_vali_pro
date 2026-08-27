# mirza_vali Pro — Changelog

## v4.0.3 (2026-08-27)

### لایسنس کلاینت (اتصال به سرور لایسنس)
- فایل `license_client.php`: بررسی دوره‌ای لایسنس با API
- قفل فقط روی دامنه (`$domainhosts`)
- انقضا → فقط توقف فروش (ربات قطع نمی‌شود)
- هشدار ~۷ روز قبل و پیام انقضا به ادمین تلگرام/بله
- مهلت (grace) ۹۶ ساعته اگر سرور لایسنس در دسترس نباشد
- کش محلی در `storage/license_cache.json`
- دستور ادمین: `/license`
- هنگام نصب: پرسش License key و License API URL
- متغیرهای `config.php`: `$LICENSE_ENABLED`, `$LICENSE_KEY`, `$LICENSE_API_URL`

### نوت و مستندات
- README و CHANGELOG مخصوص Pro (نه نسخه کلاسیک)
- نسخه در VERSION و پیام aboutBot: 4.0.3

---

## v4.0.2
- مسیر نصب پیش‌فرض: `/home/mirza_vali_pro`
- STATE: `/etc/mirza_vali_pro`
- برندینگ Pro

## v4.0.1
- اصلاحات نصب و برندینگ اولیه Pro

## v4.0.0
- شروع خط Pro (جدا از mirza_vali کلاسیک ≤ v2.0.1 و خط v3)
- پشتیبانی Connectix + چندنصب موازی
- امکانات سفارشی بله‌پی و پنل ایلان از خط قبلی

---

> تاریخچه نسخه کلاسیک (mirza_vali بدون Pro) در ریپوی جدا / بسته‌های v1.x و v2.x نگهداری می‌شود.
