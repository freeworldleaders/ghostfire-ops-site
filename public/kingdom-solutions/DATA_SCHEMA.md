# Data Schema (v1)

## users
- id (uuid)
- email (string, unique)
- created_at (timestamp)
- preferences (json)

## stories
- id (uuid)
- user_id (uuid FK users.id)
- title (string)
- description (text)
- visibility (enum: private | unlisted | public)
- status (enum: draft | active | archived)
- created_at, updated_at (timestamp)

## assets
- id (uuid)
- story_id (uuid FK stories.id)
- type (enum: audio | video | text | image)
- storage_url (string)
- original_filename (string)
- size_bytes (int)
- created_at (timestamp)

## transcripts
- id (uuid)
- story_id (uuid)
- asset_id (uuid)
- provider (string)
- status (enum: queued | running | done | failed)
- text (longtext, nullable until done)
- created_at, updated_at

## exports
- id (uuid)
- story_id (uuid)
- type (enum: book_draft | audiobook_script | clips_plan)
- status (enum: queued | running | done | failed)
- storage_url (string, nullable until done)
- created_at, updated_at

## reports
- id (uuid)
- reporter_user_id (uuid)
- target_type (enum: story | asset | user)
- target_id (uuid)
- reason (string)
- details (text)
- status (enum: open | reviewing | resolved)
- created_at, updated_at
