<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\TaskController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Dashboard Stats API
Route::get('/dashboard/stats', function () {
    $stats = [
        'total_categories' => \App\Models\Category::count(),
        'total_tasks' => \App\Models\Task::count(),
        'completed_tasks' => \App\Models\Task::where('completed', true)->count(),
        'total_users' => \App\Models\User::count(),
        'categories_by_level' => \App\Models\Category::selectRaw('level, COUNT(*) as count')
            ->groupBy('level')
            ->pluck('count', 'level')
            ->toArray()
    ];
    
    return response()->json($stats);
});

// Categories API
Route::get('/categories', [CategoryController::class, 'index']);
Route::post('/categories', [CategoryController::class, 'store']);
Route::get('/categories/{category}', [CategoryController::class, 'show']);
Route::put('/categories/{category}', [CategoryController::class, 'update']);
Route::delete('/categories/{category}', [CategoryController::class, 'destroy']);

// Tasks API
Route::get('/tasks', [TaskController::class, 'indexAll']);
Route::post('/tasks', [TaskController::class, 'store']);
Route::get('/tasks/{task}', [TaskController::class, 'show']);
Route::put('/tasks/{task}', [TaskController::class, 'update']);
Route::delete('/tasks/{task}', [TaskController::class, 'destroy']);
Route::patch('/tasks/{task}/toggle', [TaskController::class, 'toggleStatus']);

// Category Tasks API
Route::get('/categories/{category}/tasks', [TaskController::class, 'index']);

// Users API
Route::get('/users', function () {
    return response()->json(\App\Models\User::all());
});
Route::get('/users/{user}', function (\App\Models\User $user) {
    return response()->json($user);
});
