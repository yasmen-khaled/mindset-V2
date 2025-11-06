<?php

namespace App\Http\Controllers;

use App\Models\Task;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class TaskController extends Controller
{
    public function index(Category $category)
    {
        return response()->json($category->tasks);
    }

    public function showCategory(Category $category)
    {
        return view('tasks', compact('category'));
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'category_id' => 'required|exists:categories,id',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'priority' => 'required|in:low,medium,high',
            'video_url' => 'nullable|url|max:255',
            'image' => 'nullable|file|mimes:png|max:2048',
            'avatar' => 'nullable|file|mimes:svg|max:1024'
        ]);

        // Handle file uploads
        if ($request->hasFile('image')) {
            $validated['image'] = $request->file('image')->store('task-images', 'public');
        }

        if ($request->hasFile('avatar')) {
            $validated['avatar'] = $request->file('avatar')->store('task-avatars', 'public');
        }

        $task = Task::create($validated);
        return response()->json($task);
    }

    public function update(Task $task, Request $request)
    {
        if ($request->has('completed')) {
            $validated = $request->validate([
                'completed' => 'required|boolean'
            ]);
        } else {
            $validated = $request->validate([
                'title' => 'required|string|max:255',
                'description' => 'nullable|string',
                'priority' => 'required|in:low,medium,high',
                'video_url' => 'nullable|url|max:255',
                'image' => 'nullable|file|mimes:png|max:2048',
                'avatar' => 'nullable|file|mimes:svg|max:1024'
            ]);

            // Handle file uploads
            if ($request->hasFile('image')) {
                // Delete old image if exists
                if ($task->image) {
                    Storage::disk('public')->delete($task->image);
                }
                $validated['image'] = $request->file('image')->store('task-images', 'public');
            }

            if ($request->hasFile('avatar')) {
                // Delete old avatar if exists
                if ($task->avatar) {
                    Storage::disk('public')->delete($task->avatar);
                }
                $validated['avatar'] = $request->file('avatar')->store('task-avatars', 'public');
            }
        }

        $task->update($validated);
        return response()->json($task);
    }

    public function destroy(Task $task)
    {
        // Delete associated files
        if ($task->image) {
            Storage::disk('public')->delete($task->image);
        }
        if ($task->avatar) {
            Storage::disk('public')->delete($task->avatar);
        }

        $task->delete();
        return response()->json(['message' => 'Task deleted successfully']);
    }

    public function indexAll()
    {
        $tasks = Task::with('category')->get();
        return response()->json($tasks);
    }

    public function show(Task $task)
    {
        return response()->json($task->load('category'));
    }

    public function toggleStatus(Task $task, Request $request)
    {
        $validated = $request->validate([
            'completed' => 'required|boolean'
        ]);

        $task->update($validated);
        return response()->json($task);
    }
} 