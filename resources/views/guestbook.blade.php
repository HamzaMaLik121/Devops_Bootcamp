<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>{{ config('app.name') }}</title>
    <style>
        body { font-family: sans-serif; max-width: 600px; margin: 40px auto; padding: 0 16px; }
        input, textarea { width: 100%; padding: 8px; margin: 4px 0 12px; box-sizing: border-box; }
        button { padding: 8px 16px; }
        .entry { border-top: 1px solid #ccc; padding: 10px 0; }
        .error { color: #b00; }
        footer { margin-top: 30px; color: #666; font-size: 13px; }
    </style>
</head>
<body>
    <h1>Guestbook v2</h1>

    <form method="POST" action="/entries">
        @csrf
        <label>Name</label>
        <input type="text" name="name" value="{{ old('name') }}">
        @error('name') <div class="error">{{ $message }}</div> @enderror

        <label>Message</label>
        <textarea name="message" rows="3">{{ old('message') }}</textarea>
        @error('message') <div class="error">{{ $message }}</div> @enderror

        <label>City</label><input type="text" name="city"><button type="submit">Sign guestbook</button>
    </form>

    <h2>Entries ({{ $entries->count() }})</h2>
    @foreach ($entries as $entry)
        <div class="entry">
            <strong>{{ $entry->name }}</strong>
            <small>{{ $entry->created_at }}</small> <em>{{ $entry->city }}</em>
            <p>{{ $entry->message }}</p>
        </div>
    @endforeach

    <footer>Database server: {{ $dbhost }}</footer>
</body>
</html>
