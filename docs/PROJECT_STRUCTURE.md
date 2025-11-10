# מבנה הפרויקט

סקירה מלאה של מבנה הפרויקט של Supabase Local Development Environment.

## תיקיות ראשיות

```
supabase-local-package/
├── 📁 scripts/           # סקריפטים ל-Linux/macOS
├── 📁 windows/           # סקריפטים ל-Windows
├── 📁 docs/              # תיעוד מפורט
├── 📁 supabase/          # קבצי תצורה של Supabase
├── 📄 .env               # הגדרות סביבה
├── 📄 docker-compose-simple.yml  # קובץ Docker Compose
├── 📄 kong.yml           # הגדרות Kong API Gateway
├── 📄 download-and-install.sh     # סקריפט הורדה/התקנה (Linux/macOS)
├── 📄 download-and-install.bat    # סקריפט הורדה/התקנה (Windows)
└── 📄 README.md          # תיעוד ראשי
```

## תיקיית `scripts/`

סקריפטים למערכות הפעלה מבוססות Unix:

- `setup-and-start.sh` - התקנה והפעלה מהירה מארכיון מקומי
- `install-docker-images.sh` - התקנת תמונות Docker בלבד
- `install-optimized.sh` - התקנה מותאמת
- `cleanup-project.sh` - ניקוי קבצים כבדים ואופטימיזציה

## תיקיית `windows/`

סקריפטים למערכת Windows:

- `setup-and-start.bat` - התקנה והפעלה מהירה מארכיון מקומי
- `install-docker-images.bat` - התקנת תמונות Docker בלבד
- `install-optimized.bat` - התקנה מותאמת
- `cleanup-project.bat` - ניקוי קבצים כבדים ואופטימיזציה

## תיקיית `docs/`

תיעוד מפורט של הפרויקט:

- `INSTALL.md` - מדריך התקנה מפורט
- `PROJECT_STRUCTURE.md` - מסמך זה - מבנה הפרויקט
- (ניתן להוסיף עוד מסמכים לפי הצורך)

## תיקיית `supabase/`

קבצי תצורה ספציפיים ל-Supabase:

### `supabase/config.toml`
הגדרות תצורה של Supabase CLI:
- פורטים של שירותים שונים
- הגדרות API, Auth, Studio
- הגדרות Storage ו-Realtime

### `supabase/migrations/`
קבצי מיגרציה לבסיס הנתונים:
- `01-auth-schema.sql` - סכימת האימות
- `02-storage-schema.sql` - סכימת האחסון
- `03-realtime-schema.sql` - סכימת Realtime
- `06-realtime-underscore-schema.sql` - סכימת Realtime נוספת

### `supabase/seed.sql`
נתוני התחלה (seed) לבסיס הנתונים.

## קבצי תצורה ראשיים

### `.env`
הגדרות סביבה:
- פרטי התחברות לבסיס נתונים
- פורטים של שירותים
- מפתחות API ו-JWT
- הגדרות נוספות

### `docker-compose-simple.yml`
הגדרות Docker Compose:
- שירותי Supabase (Postgres, Studio, Auth, וכו')
- תצורת רשתות ו-wolumes
- תלות בין שירותים

### `kong.yml`
הגדרות Kong API Gateway:
- ניתוב של API endpoints
- תצורת CORS ואימות
- חיבור בין שירותים

## סקריפטים מאוחדים

### `download-and-install.sh` / `.bat`
סקריפט הורדה והתקנה מאוחד עם אפשרויות:
1. **הורדה מ-Docker Hub** - מתאים לחיבור אינטרנט
2. **טעינה מארכיון מקומי** - מהיר יותר
3. **בדיקת תמונות קיימות** - רק אם כבר קיימות

## זרימת עבודה מומלצת

1. **התקנה ראשונית:** השתמש בסקריפט המאוחד
2. **פיתוח שוטף:** השתמש בסקריפטי ניהול (start/stop)
3. **תחזוקה:** השתמש בסקריפט ניקוי לאופטימיזציה
4. **שינויים:** ערוך קבצי תצורה והפעל מחדש

## הערות חשובות

- כל הסקריפטים בעלי הרשאות ביצוע
- קבצים כבדים (כמו ארכיוני Docker) מוגנים ב-.gitignore
- הפרויקט תומך ב-Windows, Linux ו-macOS
- ניתן להתאים אישית את כל ההגדרות לפי הצורך