# התקנת Supabase מקומי

## דרישות
- Docker Desktop מותקן

## התקנה מהירה

### הפעלה אוטומטית (מומלץ)

#### Windows:
```bash
# הפעל סקריפט אחד שעושה הכל
setup-and-start.bat
```

#### Linux/macOS:
```bash
# הפעל סקריפט אחד שעושה הכל
./setup-and-start.sh
```

### התקנה ידנית
#### 1. חילוץ תמונות Docker
```bash
# חלץ את התמונות מהארכיון
tar -xzf supabase-docker-images-*.tar.gz
```

#### 2. טעינת תמונות Docker
```bash
# טען את כל תמונות ה-Docker
docker load -i docker-images/*.tar
```

#### 3. הפעלה
```bash
# הפעל את כל השירותים
docker-compose -f docker-compose-simple.yml up -d
```

### 3. גישה לשירותים
- Studio: http://localhost:54323
- Auth: http://localhost:9999
- Database: localhost:54322

### פרטי התחברות לבסיס נתונים
```
Host: localhost
Port: 54322
Database: postgres
User: postgres
Password: postgres
```

### כיבוי
```bash
docker-compose -f docker-compose-simple.yml down
```

זהו! סופרבייס מוכן לשימוש.