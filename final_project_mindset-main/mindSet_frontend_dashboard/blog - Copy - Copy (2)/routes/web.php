<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\TaskController;
use App\Http\Controllers\QuizController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::get('/admin1', function () {
    return view('admin1');
});

Route::get('/categories', [CategoryController::class, 'index'])->name('categories.index');
Route::post('/categories', [CategoryController::class, 'store'])->name('categories.store');
Route::put('/categories/{category}', [CategoryController::class, 'update'])->name('categories.update');
Route::post('/categories/{category}', [CategoryController::class, 'update'])->name('categories.update.post');
Route::delete('/categories/{category}', [CategoryController::class, 'destroy'])->name('categories.destroy');

// Task routes
Route::get('/categories/{category}/tasks', [TaskController::class, 'index']);
Route::get('/categories/{category}/manage-tasks', [TaskController::class, 'showCategory']);
Route::post('/tasks', [TaskController::class, 'store']);
Route::put('/tasks/{task}', [TaskController::class, 'update']);
Route::patch('/tasks/{task}', [TaskController::class, 'update']);
Route::delete('/tasks/{task}', [TaskController::class, 'destroy']);

// Quiz routes
Route::get('/categories/{category}/questions', [QuizController::class, 'getQuestions']);
Route::post('/questions', [QuizController::class, 'addQuestion']);
Route::put('/categories/{category}/questions/{question}', [QuizController::class, 'updateQuestion']);
Route::delete('/categories/{category}/questions/{question}', [QuizController::class, 'deleteQuestion']);
