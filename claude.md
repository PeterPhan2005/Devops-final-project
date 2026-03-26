# Document Management System - Claude Context

## Project Overview
Simple document management system with file upload, listing, download, update, and delete capabilities.

## Tech Stack
- **Backend**: Spring Boot 3.2+ (Java 21), Spring Web, Spring Data JPA
- **Frontend**: React (Vite), Tailwind CSS, Axios
- **Database**: PostgreSQL
- **Storage**: Local filesystem (`uploads/` folder)

## Project Structure
```
Devop-final/
├── backend/              # Spring Boot API
│   ├── src/main/java/
│   ├── src/main/resources/
│   └── pom.xml
├── frontend/             # React + Vite
│   ├── src/
│   └── package.json
├── uploads/              # Local file storage
└── docker-compose.yml
```

## Document Entity
- `id`: Long (auto-increment)
- `name`: String
- `uploadTime`: LocalDateTime
- `fileName`: String (stored filename in uploads/)

## API Endpoints
| Method | Endpoint              | Description                |
|--------|-----------------------|----------------------------|
| POST   | `/api/documents`       | Upload file + save metadata |
| GET    | `/api/documents`       | List all documents          |
| GET    | `/api/documents/{id}`  | Download file               |
| PUT    | `/api/documents/{id}`  | Update doc info/file        |
| DELETE | `/api/documents/{id}`  | Delete file + DB record     |

## Ports
- Backend: `8080`
- Frontend: `5173`
- PostgreSQL: `5432`

## Commands
```bash
# Backend
cd backend && mvn spring-boot:run

# Frontend
cd frontend && npm install && npm run dev

# Docker
docker-compose up -d
```

## Docker Network — Frontend gọi Backend
- Frontend (nginx) gọi backend qua hostname `backend` (Docker service name), không phải `localhost:8080`
- Cấu hình proxy trong `frontend/Dockerfile`:
  ```dockerfile
  # Dockerfile của frontend dùng nginx proxy /api/ → http://backend:8080/api/
  location /api/ {
      proxy_pass http://backend:8080/api/;
  }
  ```

## Known Issues & Fixes

### 1. PostgreSQL volume incompatible (version 15 vs 16)
**Lỗi:** `FATAL: database files are incompatible with server` — data dir version 15, image version 16.
**Fix:**
```bash
docker-compose down
docker volume rm devop-final_postgres_data
docker-compose up -d
```

### 2. Nginx proxy 404 khi preview file (GET /api/documents/{id})
**Lỗi:** `GET :5173/api/documents/2 → 404` — frontend container không resolve được `backend` hostname.
**Nguyên nhân:** Docker network `devop-final_default` không tạo hoặc frontend không cùng network.
**Cách kiểm tra:**
```bash
docker network inspect devop-final_default | grep backend
docker exec doc-frontend nslookup backend
docker exec doc-frontend wget -O- http://backend:8080/api/documents
```
**Fix nếu thiếu network:**
```bash
docker network connect devop-final_default doc-frontend
docker network connect devop-final_default doc-backend
# Hoặc đơn giản nhất:
docker-compose down && docker-compose up -d
```

### 3. File preview dùng mammoth (DOCX)
- Thư viện `mammoth` đọc file `.docx` và trả về HTML để hiển thị inline trong preview modal
- Preview bằng `dangerouslySetInnerHTML` với class `prose` (Tailwind typography plugin)
- Các định dạng preview: `pdf` (iframe), `jpg/png/gif` (img), `docx` (mammoth), `txt` (iframe)
