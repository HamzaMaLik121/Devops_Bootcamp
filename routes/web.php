<?php

use App\Models\Entry;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    $entries = Entry::latest()->get();
    $dbhost = DB::selectOne('select @@hostname as h')->h;
    return view('guestbook', compact('entries', 'dbhost'));
});

Route::post('/entries', function (Request $request) {
    $data = $request->validate([
        'name' => 'required|max:100',
        'message' => 'required|max:1000', 'city' => 'nullable|max:100',
    ]);
    Entry::create($data);
    return redirect('/');
});

Route::get('/health', function () {
    try {
        DB::select('select 1');
        return response('OK', 200)->header('Content-Type', 'text/plain');
    } catch (\Throwable $e) {
        return response('DB DOWN', 500)->header('Content-Type', 'text/plain');
    }
});
