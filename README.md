# Supabase Local Development Environment

סביבת פיתוח מקומית מותאמת של Supabase עם כל השירותים הנדרשים.

[![Supabase](https://img.shields.io/badge/Supabase-3FCF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)

## תכונות

- ✅ PostgreSQL Database עם כל ההרחבות
- ✅ Supabase Studio - ממשק ניהול ווב
- ✅ Auth - מערכת אימות מלאה
- ✅ REST API - PostgREST אוטומטי
- ✅ Realtime - חיבורים אשפוזיים בזמן אמת
- ✅ Storage - אחסון קבצים
- ✅ Functions - פונקציות Edge
- ✅ Mail Service - שירות מייל לפיתוח
- ✅ Kong API Gateway - ניתוב API

## התקנה

**דרישות:** Docker Desktop, 4GB+ RAM

### מקוון:
```bash
./setup-all.sh
```

### אופליין (שרתים ללא אינטרנט):
```bash
# 1. הכן תלויות (מחשב עם אינטרנט)
./prepare-offline.sh

# 2. העבר קובץ זיפ לשרת והפעל
./install-offline.sh
```

## גישה לשירותים

| שירות | URL | תיאור |
|--------|-----|------|
| 🎨 Studio | http://localhost:54323 | ממשק ניהול |
| 🔐 Auth | http://localhost:9999 | אימות משתמשים |
| 🗄️ Database | localhost:54322 | PostgreSQL |
| 📧 Mail Test | http://localhost:54324 | מייל טסט |
| 🌐 API | http://localhost:54321 | Kong Gateway |

## פרטי התחברות לבסיס נתונים

```
Host: localhost
Port: 54322
Database: postgres
User: postgres
Password: postgres
```

## מפתחות API

**מפתח אנונימי:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODQ4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
```

**מפתח שירות:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4NDgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
```

## ניהול הפרויקט

### כיבוי השירותים
```bash
docker-compose -f docker-compose-simple.yml down
```

### הפעלה מחדש
```bash
docker-compose -f docker-compose-simple.yml up -d
```

### צפייה בלוגים
```bash
docker-compose -f docker-compose-simple.yml logs -f
```

### ניקוי קבצים כבדים
```bash
# Linux/macOS
./scripts/cleanup-project.sh

# Windows
windows\cleanup-project.bat
```

## מבנה הפרויקט

```
supabase-local-package/
├── 📁 scripts/           # סקריפטים ל-Linux/macOS
├── 📁 windows/           # סקריפטים ל-Windows
├── 📁 docs/              # תיעוד
├── 📁 supabase/          # קבצי Supabase
│   ├── 📁 migrations/    # מיגרציות בסיס נתונים
│   ├── config.toml       # הגדרות
│   └── seed.sql          # נתוני התחלה
├── 📄 .env               # הגדרות סביבה
├── 📄 docker-compose-simple.yml  # הגדרות Docker
├── 📄 kong.yml           # Kong Gateway
└── 📄 README.md          # תיעוד ראשי
```

## התאמה אישית

### שינוי פורטים
ערוך את הקובץ `.env` לשינוי הגדרות:
- `POSTGRES_PORT`: פורט בסיס הנתונים
- `KONG_HTTP_PORT`: פורט ה-API
- `STUDIO_PORT_EXTERNAL`: פורט הממשק

### הוספת מיגרציות
הוסף קבצי SQL לתיקייה `supabase/migrations/` עם סדר מספרי:
- `01-your-schema.sql`
- `02-your-data.sql`

### הוספת פונקציות
הוסף פונקציות לתיקייה `supabase/functions/`.

## טיפים לפיתוח

1. **גיבוי:** גבה את בסיס הנתונים לפני שינויים
2. **לוגים:** השתמש ב-Docker logs לאיתור בעיות
3. **פיתוח:** השתמש ב-Studio לניהול בסיס נתונים ויזואלי
4. **בדיקות:** בדוק חיבורים לפני פריסה

## פתרון בעיות

### שירות לא עולה
```bash
# בדוק סטטוס Docker
docker ps

# בדוק לוגים
docker-compose -f docker-compose-simple.yml logs [service-name]
```

### בעיות פורט
```bash
# בדוק פורטים תפוסים
netstat -an | grep [port-number]
```

### אתחול מחדש
```bash
# כיבוי ומחיקת ווליומים
docker-compose -f docker-compose-simple.yml down -v

# הפעלה מחדש
docker-compose -f docker-compose-simple.yml up -d
```

## תיעוד נוסף

- [תיעוד מלא](docs/INSTALL.md)
- [מדריך התקנה](docs/INSTALL.md)
- [Supabase Docs](https://supabase.com/docs)

## רישיון

פרויקט זה משתמש ברישיון קוד פתוח של Supabase.

---

**🎉 מוכן לפיתוח!** הפעל את הסקריפט והתחל לבנות.