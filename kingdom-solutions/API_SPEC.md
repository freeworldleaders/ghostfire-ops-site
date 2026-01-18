# API Spec (v1)

Base URL: `/api/v1`

## Auth
- `POST /auth/signup`
- `POST /auth/login`
- `POST /auth/logout`
- `GET  /auth/me`

## Stories
- `POST /stories` → create story
- `GET  /stories` → list my stories
- `GET  /stories/:id` → get story
- `PATCH /stories/:id` → update metadata/visibility
- `DELETE /stories/:id` → delete story

## Assets (Uploads)
- `POST /stories/:id/assets` → upload (audio/video/text)
- `GET  /stories/:id/assets` → list assets
- `DELETE /assets/:assetId`

## Transcription (opt-in)
- `POST /stories/:id/transcribe` → create transcription job
- `GET  /jobs/:jobId` → job status

## Exports
- `POST /stories/:id/exports` → create export (book draft, script)
- `GET  /stories/:id/exports` → list exports
- `GET  /exports/:exportId` → download

## Reports
- `POST /reports` → report content
- `GET  /reports/:id` → status

## Admin (MVP minimal)
- `GET /admin/reports`
- `PATCH /admin/reports/:id` → resolve/action
